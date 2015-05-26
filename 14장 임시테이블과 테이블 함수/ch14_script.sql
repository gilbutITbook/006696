-- 01. 개요

-- MSSQL 프로시저

CREATE PROCEDURE test_proc 
AS
  -- 임시 테이블 생성
  CREATE #ch13_physicist (
         ids      INT,
         names    VARCAR(30),
         birth_dt DATETIME );
         
  -- 비즈니스 로직 처리.
  ....
  ....
  
  -- 임시 테이블에 데이터 insert
  INSERT INTO #ch13_physicist
  SELECT ....
  
  
  -- 마지막에 임시 테이블 SELECT
  SELECT *
    FROM #ch13_physicist
    

-- 02. GTT
-- (1) 트랜잭션 GTT

CREATE GLOBAL TEMPORARY TABLE ch14_tranc_gtt
     (
       ids        NUMBER,
       names      VARCHAR2(50),
       birth_dt   DATE  
     )
 ON COMMIT DELETE ROWS;  
 
 
       
DECLARE 
   vn_cnt  int  := 0;
   vn_cnt2 int  := 0;

BEGIN
	-- 데이터를 넣는다. 
	INSERT INTO ch14_tranc_gtt
	SELECT *
	  FROM ch13_physicist;
	  
	-- COMMIT 전 데이터 건수  
  SELECT COUNT(*)
    INTO vn_cnt
    FROM ch14_tranc_gtt;
    
  COMMIT;
  
	-- COMMIT 후 데이터 건수  
  SELECT COUNT(*)
    INTO vn_cnt2
    FROM ch14_tranc_gtt;  
    
  DBMS_OUTPUT.PUT_LINE('COMMIT 전: ' || vn_cnt);
  DBMS_OUTPUT.PUT_LINE('COMMIT 후: ' || vn_cnt2);
    
	
END;          


-- (2) 세션 GTT
CREATE GLOBAL TEMPORARY TABLE ch14_sess_gtt
     (
       ids        NUMBER,
       names      VARCHAR2(50),
       birth_dt   DATE  
     )
 ON COMMIT PRESERVE ROWS;
 
DECLARE 
   vn_cnt  int  := 0;
   vn_cnt2 int  := 0;

BEGIN
	-- 데이터를 넣는다. 
	INSERT INTO ch14_sess_gtt
	SELECT *
	  FROM ch13_physicist;
	  
	-- COMMIT 전 데이터 건수  
  SELECT COUNT(*)
    INTO vn_cnt
    FROM ch14_sess_gtt;
    
  COMMIT;
  
	-- COMMIT 후 데이터 건수  
  SELECT COUNT(*)
    INTO vn_cnt2
    FROM ch14_sess_gtt;  
    
  DBMS_OUTPUT.PUT_LINE('COMMIT 전: ' || vn_cnt);
  DBMS_OUTPUT.PUT_LINE('COMMIT 후: ' || vn_cnt2);
    
	
END; 


-- TABLE 함수
-- (2) 사용자 정의 테이블 함수
CREATE OR REPLACE TYPE ch14_num_nt IS TABLE OF NUMBER;

CREATE OR REPLACE FUNCTION fn_ch14_table1 ( p_n NUMBER )
    RETURN ch14_num_nt
IS
  -- 컬렉션 변수 선언 (컬렉션 타입이므로 초기화를 한다)
  vnt_return ch14_num_nt := ch14_num_nt();
BEGIN
  -- 1부터 입력매개변수인 p_n만큼 숫자를 넣는다.   
  FOR i IN 1..p_n
  LOOP
    vnt_return.EXTEND;
    vnt_return(i) := i;  
  END LOOP;

  RETURN vnt_return; -- 컬렉션 타입을 반환한다. 
END;

SELECT fn_ch14_table1 (10)
FROM DUAL;

SELECT *
  FROM TABLE(fn_ch14_table1 (10));
  
-- 커서를 매개변수로

CREATE OR REPLACE TYPE ch14_obj_type1 AS OBJECT (
         varchar_col1    VARCHAR2(100),
         varchar_col2    VARCHAR2(100),
         num_col       NUMBER,
         date_col       DATE               );


CREATE OR REPLACE TYPE ch14_cmplx_nt IS TABLE OF ch14_obj_type1;

  
CREATE OR REPLACE PACKAGE ch14_empty_pkg 
IS
  -- 사원테이블에 대한 커서 
  TYPE emp_refc_t IS REF CURSOR RETURN employees%ROWTYPE;

END ch14_empty_pkg;

  
CREATE OR REPLACE FUNCTION fn_ch14_table2 ( p_cur ch14_empty_pkg.emp_refc_t )
   RETURN ch14_cmplx_nt
IS
   -- 입력 커서에 대한 변수 선언
   v_cur  p_cur%ROWTYPE;
   
   -- 반환할 컬렉션 변수 선언 (컬렉션 타입이므로 초기화를 한다)
   vnt_return  ch14_cmplx_nt :=  ch14_cmplx_nt();  
BEGIN
   -- 루프를 돌며 입력 매개변수 p_cur를 v_cur로 패치
   LOOP
     FETCH p_cur INTO v_cur;
     EXIT WHEN p_cur%NOTFOUND; 
     
     -- 컬렉션 타입이므로 EXTEND 메소를 사용해 한 로우씩 신규 삽입
     vnt_return.EXTEND();
     -- 컬렉션 요소인 OBJECT 타입에 대한 초기화 
     vnt_return(vnt_return.LAST) := ch14_obj_type1(null, null, null, null);
     -- 컬렉션 변수에 커서변수의 값 할당 
     vnt_return(vnt_return.LAST).varchar_col1 := v_cur.emp_name; 
     vnt_return(vnt_return.LAST).varchar_col2 := v_cur.phone_number; 
     vnt_return(vnt_return.LAST).num_col      := v_cur.employee_id;
     vnt_return(vnt_return.LAST).date_col     := v_cur.hire_date;
     
   END LOOP;
   -- 컬렉션 반환
   RETURN vnt_return;
END;


SELECT *
FROM TABLE( fn_ch14_table2 ( CURSOR ( SELECT * FROM EMPLOYEES WHERE ROWNUM < 6)
                           ));  

-- (3) 파이프라인 테이블 함수

CREATE OR REPLACE FUNCTION fn_ch14_pipe_table ( p_n NUMBER )
    RETURN ch14_num_nt
    PIPELINED
IS
  -- 컬렉션 변수 선언 (컬렉션 타입이므로 초기화를 한다)
  vnt_return ch14_num_nt := ch14_num_nt();
BEGIN
  -- 1부터 입력매개변수인 p_n만큼 숫자를 넣는다.   
  FOR i IN 1..p_n
  LOOP
    vnt_return.EXTEND;
    vnt_return(i) := i;  
    
    -- 컬렉션 타입을 반환한다. 
    PIPE ROW (vnt_return(i));
    
  END LOOP;

  RETURN; 
END;

SELECT *
  FROM TABLE(fn_ch14_pipe_table (10));  
  
  
-- 일반 테이블 함수 (4,000,000회 루프)
SELECT *
FROM TABLE( fn_ch14_table1 (4000000));

-- 파이프라인 테이블 함수 (4,000,000회 루프)
SELECT count(*)
FROM TABLE( fn_ch14_pipe_table (4000000));


CREATE OR REPLACE FUNCTION fn_ch14_pipe_table2 ( p_cur ch14_empty_pkg.emp_refc_t )
   RETURN ch14_cmplx_nt
   PIPELINED
IS
   -- 입력 커서에 대한 변수 선언
   v_cur  p_cur%ROWTYPE;
   
   -- 반환할 컬렉션 변수 선언 (컬렉션 타입이므로 초기화를 한다)
   vnt_return  ch14_cmplx_nt :=  ch14_cmplx_nt();  
BEGIN
   -- 루프를 돌며 입력 매개변수 p_cur를 v_cur로 패치
   LOOP
     FETCH p_cur INTO v_cur;
     EXIT WHEN p_cur%NOTFOUND; 
     
     -- 컬렉션 타입이므로 EXTEND 메소를 사용해 한 로우씩 신규 삽입
     vnt_return.EXTEND();
     -- 컬렉션 요소인 OBJECT 타입에 대한 초기화 
     vnt_return(vnt_return.LAST) := ch14_obj_type1(null, null, null, null);
     -- 컬렉션 변수에 커서변수의 값 할당 
     vnt_return(vnt_return.LAST).varchar_col1 := v_cur.emp_name; 
     vnt_return(vnt_return.LAST).varchar_col2 := v_cur.phone_number;      
     vnt_return(vnt_return.LAST).num_col      := v_cur.employee_id;
     vnt_return(vnt_return.LAST).date_col     := v_cur.hire_date;
     PIPE ROW ( vnt_return(vnt_return.LAST)); -- 첫 번째 반환
     
     vnt_return(vnt_return.LAST).varchar_col1 := v_cur.job_id; 
     vnt_return(vnt_return.LAST).varchar_col2 := v_cur.email;  
     PIPE ROW ( vnt_return(vnt_return.LAST)); -- 두 번째 반환
   END LOOP;
   RETURN; 
END;

-- 현장노하우
CREATE TABLE ch14_score_table (
       YEARS     VARCHAR2(4),   -- 연도
       GUBUN     VARCHAR2(30),  -- 구분(중간/기말)
       SUBJECTS  VARCHAR2(30),  -- 과목
       SCORE     NUMBER );      -- 점수
       
INSERT INTO ch14_SCORE_TABLE VALUES('2014','중간고사','국어',92);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','중간고사','영어',87);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','중간고사','수학',67);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','중간고사','과학',80);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','중간고사','지리',93);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','중간고사','독일어',82);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','기말고사','국어',88);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','기말고사','영어',80);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','기말고사','수학',93);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','기말고사','과학',91);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','기말고사','지리',89);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','기말고사','독일어',83);
COMMIT;

SELECT *
FROM ch14_score_table;

-- 로우를 컬럼으로
-- DECODE나 CASE

SELECT years, 
       gubun, 
       CASE WHEN subjects = '국어'   THEN score ELSE 0 END "국어",
       CASE WHEN subjects = '영어'   THEN score ELSE 0 END "영어",
       CASE WHEN subjects = '수학'   THEN score ELSE 0 END "수학",
       CASE WHEN subjects = '과학'   THEN score ELSE 0 END "과학",
       CASE WHEN subjects = '지리'   THEN score ELSE 0 END "지리",
       CASE WHEN subjects = '독일어' THEN score ELSE 0 END "독일어"
  FROM ch14_score_table a;
  
SELECT years, gubun, 
       SUM(국어) AS 국어, SUM(영어) AS 영어, SUM(수학) AS 수학,
       SUM(과학) AS 과학, SUM(지리) AS 지리, SUM(독일어) AS 독일어
FROM (
SELECT years, 
       gubun, 
       CASE WHEN subjects = '국어'   THEN score ELSE 0 END "국어",
       CASE WHEN subjects = '영어'   THEN score ELSE 0 END "영어",
       CASE WHEN subjects = '수학'   THEN score ELSE 0 END "수학",
       CASE WHEN subjects = '과학'   THEN score ELSE 0 END "과학",
       CASE WHEN subjects = '지리'   THEN score ELSE 0 END "지리",
       CASE WHEN subjects = '독일어' THEN score ELSE 0 END "독일어"
  FROM ch14_score_table a
)
GROUP BY years, gubun;

-- WITH문을 이용한 방법
WITH mains AS ( SELECT years, 
                       gubun, 
                       CASE WHEN subjects = '국어'   THEN score ELSE 0 END "국어",
                       CASE WHEN subjects = '영어'   THEN score ELSE 0 END "영어",
                       CASE WHEN subjects = '수학'   THEN score ELSE 0 END "수학",
                       CASE WHEN subjects = '과학'   THEN score ELSE 0 END "과학",
                       CASE WHEN subjects = '지리'   THEN score ELSE 0 END "지리",
                       CASE WHEN subjects = '독일어' THEN score ELSE 0 END "독일어"
                  FROM ch14_score_table a
              )
SELECT years, gubun, 
       SUM(국어) AS 국어, SUM(영어) AS 영어, SUM(수학) AS 수학,
       SUM(과학) AS 과학, SUM(지리) AS 지리, SUM(독일어) AS 독일어
FROM mains       
GROUP BY years, gubun;
       
       
-- PIVOT
SELECT * 
  FROM ( SELECT years, gubun, subjects, score 
           FROM ch14_score_table )
  PIVOT ( SUM(score)
          FOR subjects IN ( '국어', '영어', '수학', '과학', '지리', '독일어')
        );
        
-- 컬럼을 로우로

CREATE TABLE ch14_score_col_table  (
       YEARS     VARCHAR2(4),   -- 연도
       GUBUN     VARCHAR2(30),  -- 구분(중간/기말)
       KOREAN    NUMBER,        -- 국어점수
       ENGLISH   NUMBER,        -- 영어점수
       MATH      NUMBER,        -- 수학점수
       SCIENCE   NUMBER,        -- 과학점수
       GEOLOGY   NUMBER,        -- 지리점수
       GERMAN    NUMBER         -- 독일어점수
      );
  
INSERT INTO ch14_score_col_table
VALUES ('2014', '중간고사', 92, 87, 67, 80, 93, 82 );

INSERT INTO ch14_score_col_table
VALUES ('2014', '기말고사', 88, 80, 93, 91, 89, 83 );

COMMIT;

SELECT *
FROM ch14_score_col_table;


-- UNION ALL

SELECT YEARS, GUBUN, '국어' AS SUBJECT, KOREAN AS SCORE       
  FROM ch14_score_col_table
UNION ALL
SELECT YEARS, GUBUN, '영어' AS SUBJECT, ENGLISH AS SCORE       
  FROM ch14_score_col_table
UNION ALL
SELECT YEARS, GUBUN, '수학' AS SUBJECT, MATH AS SCORE       
  FROM ch14_score_col_table
UNION ALL
SELECT YEARS, GUBUN, '과학' AS SUBJECT, SCIENCE AS SCORE       
  FROM ch14_score_col_table
UNION ALL
SELECT YEARS, GUBUN, '지리' AS SUBJECT, GEOLOGY AS SCORE       
  FROM ch14_score_col_table
UNION ALL
SELECT YEARS, GUBUN, '독일어' AS SUBJECT, GERMAN AS SCORE       
  FROM ch14_score_col_table
ORDER BY 1, 2 DESC;

-- UNPIVOT 
SELECT *
  FROM ch14_score_col_table 
  UNPIVOT ( score 
            FOR subjects IN ( KOREAN   AS '국어', 
                              ENGLISH  AS '영어', 
                              MATH     AS '수학',  
                              SCIENCE  AS '과학', 
                              GEOLOGY  AS '지리', 
                              GERMAN   AS '독일어'
                            )
        );
        
        
-- 파이프라인 테이블 함수
CREATE OR REPLACE TYPE ch14_obj_subject AS OBJECT (
       YEARS     VARCHAR2(4),   -- 연도
       GUBUN     VARCHAR2(30),  -- 구분(중간/기말)
       SUBJECTS  VARCHAR2(30),  -- 과목
       SCORE     NUMBER         -- 점수
      ); 
         
CREATE OR REPLACE TYPE ch14_subject_nt IS TABLE OF ch14_obj_subject;     

   


CREATE OR REPLACE FUNCTION fn_ch14_pipe_table3 
   RETURN ch14_subject_nt
   PIPELINED
IS

   vp_cur  SYS_REFCURSOR;
   v_cur   ch14_score_col_table%ROWTYPE;
   
   -- 반환할 컬렉션 변수 선언 (컬렉션 타입이므로 초기화를 한다)
   vnt_return  ch14_subject_nt :=  ch14_subject_nt();  
BEGIN
	 -- SYS_REFCURSOR 변수로 ch14_score_col_table 테이블을 선택해 커서를 오픈 
	 OPEN vp_cur FOR SELECT * FROM ch14_score_col_table ;
	 
   -- 루프를 돌며 입력 매개변수 vp_cur를 v_cur로 패치
   LOOP
     FETCH vp_cur INTO v_cur;
     EXIT WHEN vp_cur%NOTFOUND; 
     
     -- 컬렉션 타입이므로 EXTEND 메소를 사용해 한 로우씩 신규 삽입
     vnt_return.EXTEND();
     -- 컬렉션 요소인 OBJECT 타입에 대한 초기화 
     vnt_return(vnt_return.LAST) := ch14_obj_subject(null, null, null, null);
     
     -- 컬렉션 변수에 커서변수의 값 할당 
     vnt_return(vnt_return.LAST).YEARS     := v_cur.YEARS; 
     vnt_return(vnt_return.LAST).GUBUN     := v_cur.GUBUN;      
     vnt_return(vnt_return.LAST).SUBJECTS  := '국어';
     vnt_return(vnt_return.LAST).SCORE     := v_cur.KOREAN;
     PIPE ROW ( vnt_return(vnt_return.LAST)); -- 국어 반환
     
     vnt_return(vnt_return.LAST).SUBJECTS  := '영어';
     vnt_return(vnt_return.LAST).SCORE     := v_cur.ENGLISH;
     PIPE ROW ( vnt_return(vnt_return.LAST)); -- 영어 반환
     
     vnt_return(vnt_return.LAST).SUBJECTS  := '수학';
     vnt_return(vnt_return.LAST).SCORE     := v_cur.MATH;
     PIPE ROW ( vnt_return(vnt_return.LAST)); -- 수학 반환
     
     vnt_return(vnt_return.LAST).SUBJECTS  := '과학';
     vnt_return(vnt_return.LAST).SCORE     := v_cur.SCIENCE;
     PIPE ROW ( vnt_return(vnt_return.LAST)); -- 과학 반환
     
     vnt_return(vnt_return.LAST).SUBJECTS  := '지리';
     vnt_return(vnt_return.LAST).SCORE     := v_cur.GEOLOGY;
     PIPE ROW ( vnt_return(vnt_return.LAST)); -- 지리 반환
     
     vnt_return(vnt_return.LAST).SUBJECTS  := '독일어';
     vnt_return(vnt_return.LAST).SCORE     := v_cur.GERMAN;
     PIPE ROW ( vnt_return(vnt_return.LAST)); -- 독일어 반환                    
     
     
   END LOOP;
   RETURN; 
END;



SELECT *
  FROM TABLE ( fn_ch14_pipe_table3 );