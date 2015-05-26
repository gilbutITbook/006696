01. 소스관리

-- (2) 소스 백업
SELECT *
FROM USER_SOURCE
ORDER BY NAME, LINE;


CREATE OR REPLACE PACKAGE ch17_src_test_pkg IS

   pv_name VARCHAR2(30) := 'ch17_SRC_TEST_PKG';

END ch17_src_test_pkg;

SELECT *
FROM USER_SOURCE
WHERE NAME = 'ch17_SRC_TEST_PKG'
ORDER BY LINE;


CREATE OR REPLACE PACKAGE BODY ch17_src_test_pkg IS

   pvv_temp VARCHAR2(30) := 'TEST';

END ch17_src_test_pkg;

SELECT *
FROM USER_SOURCE
WHERE NAME = 'ch17_SRC_TEST_PKG'
ORDER BY TYPE, LINE;


SELECT *
FROM USER_SOURCE
WHERE TEXT LIKE '%EMPLOYEES%'
   OR TEXT LIKE '%employees%' 
ORDER BY name, type, line;


CREATE TABLE bk_source_20150106 AS
SELECT *
FROM USER_SOURCE
ORDER BY NAME, TYPE, LINE;

SELECT *
FROM bk_source_20150106;


-- 02. 디버깅기법

CREATE TABLE ch17_sales_detail (
             channnel_name VARCHAR2(50),
             prod_name     VARCHAR2(300),
             cust_name     VARCHAR2(100),
             emp_name      VARCHAR2(100),
             sales_date    DATE,
             sales_month   VARCHAR2(6),
             sales_qty     NUMBER   DEFAULT 0,
             sales_amt     NUMBER   DEFAULT 0 );
             
CREATE INDEX idx_ch17_sales_dtl on ch17_sales_detail (sales_month);    



CREATE OR REPLACE PACKAGE ch17_src_test_pkg IS

  pv_name VARCHAR2(30) := 'ch17_SRC_TEST_PKG';
   
  PROCEDURE sales_detail_prc ( ps_month IN VARCHAR2, 
                               pn_amt   IN NUMBER,
                               pn_rate  IN NUMBER
                             );

END ch17_src_test_pkg;



CREATE OR REPLACE PACKAGE BODY ch17_src_test_pkg IS
  
  PROCEDURE sales_detail_prc ( ps_month IN VARCHAR2, 
                               pn_amt   IN NUMBER,
                               pn_rate  IN NUMBER   )
  IS
  
  BEGIN
    --1. p_month에 해당하는 월의 ch17_SALES_DETAIL 데이터 삭제
    DELETE ch17_SALES_DETAIL
     WHERE sales_month = ps_month;
     
    --2. p_month에 해당하는 월의 ch17_SALES_DETAIL 데이터 생성
    INSERT INTO ch17_SALES_DETAIL
    SELECT b.prod_name, 
           d.channel_desc,
           c.cust_name,
           e.emp_name,
           a.sales_date,
           a.sales_month,
           sum(a.quantity_sold),
           sum(a.amount_sold)
      FROM sales a,
           products b,
           customers c,
           channels d,
           employees e
    WHERE a.sales_month = ps_month
      AND a.prod_id     = b.prod_id
      AND a.cust_id     = c.cust_id
      AND a.channel_id  = d.channel_id
      AND a.employee_id = e.employee_id
    GROUP BY b.prod_name, 
           d.channel_desc,
           c.cust_name,
           e.emp_name,
           a.sales_date,
           a.sales_month;
           
           
    -- 3. 판매금액(sales_amt)이 pn_amt 보다 큰 건은 pn_rate 비율 만큼 할인한다.
    UPDATE ch17_SALES_DETAIL
       SET sales_amt = sales_amt - ( sales_amt * pn_rate * 0.01)
     WHERE sales_month = ps_month
       AND sales_amt   > pn_amt;
       
    
    COMMIT;
    
  EXCEPTION WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE(SQLERRM);
         ROLLBACK;          
  
  
  END sales_detail_prc;

END ch17_src_test_pkg;

-- (1) DBMS_OUTPUT.PUT_LINE
BEGIN
  ch17_src_test_pkg.sales_detail_prc ( ps_month => '200112',
                                       pn_amt   => 0,
                                       pn_rate  => 1 );
END;


SELECT sales_month, count(*)
  FROM ch17_SALES_DETAIL
 GROUP BY sales_month
 ORDER BY sales_month;
 

CREATE OR REPLACE PACKAGE BODY ch17_src_test_pkg IS
  
  PROCEDURE sales_detail_prc ( ps_month IN VARCHAR2, 
                               pn_amt   IN NUMBER,
                               pn_rate  IN NUMBER   )
  IS
  
  BEGIN
  	DBMS_OUTPUT.PUT_LINE('--------------<변수값 출력>---------------------');
  	DBMS_OUTPUT.PUT_LINE('ps_month : ' || ps_month);
  	DBMS_OUTPUT.PUT_LINE('pn_amt   : ' || pn_amt);
  	DBMS_OUTPUT.PUT_LINE('pn_rate  : ' || pn_rate);  	
  	DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
  	
    --1. p_month에 해당하는 월의 ch17_SALES_DETAIL 데이터 삭제
    DELETE ch17_SALES_DETAIL
     WHERE sales_month = ps_month;
     
    DBMS_OUTPUT.PUT_LINE('DELETE 건수 : ' || SQL%ROWCOUNT);
     
    --2. p_month에 해당하는 월의 ch17_SALES_DETAIL 데이터 생성
    INSERT INTO ch17_SALES_DETAIL
    SELECT b.prod_name, 
           d.channel_desc,
           c.cust_name,
           e.emp_name,
           a.sales_date,
           a.sales_month,
           sum(a.quantity_sold),
           sum(a.amount_sold)
      FROM sales a,
           products b,
           customers c,
           channels d,
           employees e
    WHERE a.sales_month = ps_month
      AND a.prod_id     = b.prod_id
      AND a.cust_id     = c.cust_id
      AND a.channel_id  = d.channel_id
      AND a.employee_id = e.employee_id
    GROUP BY b.prod_name, 
           d.channel_desc,
           c.cust_name,
           e.emp_name,
           a.sales_date,
           a.sales_month;
           
    DBMS_OUTPUT.PUT_LINE('INSERT 건수 : ' || SQL%ROWCOUNT);           
           
           
    -- 3. 판매금액(sales_amt)이 pn_amt 보다 큰 건은 pn_rate 비율 만큼 할인한다.
    UPDATE ch17_SALES_DETAIL
       SET sales_amt = sales_amt - ( sales_amt * pn_rate * 0.01)
     WHERE sales_month = ps_month
       AND sales_amt   > pn_amt;
       
    DBMS_OUTPUT.PUT_LINE('UPDATE 건수 : ' || SQL%ROWCOUNT);           
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('여기서의 값은???? : ' || SQL%ROWCOUNT);    
    
  EXCEPTION WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE(SQLERRM);
         ROLLBACK;          
  
  
  END sales_detail_prc;

END ch17_src_test_pkg; 

BEGIN
  ch17_src_test_pkg.sales_detail_prc ( ps_month => '200112',
                                       pn_amt   => 10000,
                                       pn_rate  => 1 );
END;


-- (2) 소요시간 출력

CREATE OR REPLACE PACKAGE BODY ch17_src_test_pkg IS
  
  PROCEDURE sales_detail_prc ( ps_month IN VARCHAR2, 
                               pn_amt   IN NUMBER,
                               pn_rate  IN NUMBER   )
  IS
     vd_sysdate     DATE;        -- 현재일자 
     vn_total_time NUMBER := 0;  -- 소요시간 계산용 변수 
  
  BEGIN
  	DBMS_OUTPUT.PUT_LINE('--------------<변수값 출력>---------------------');
  	DBMS_OUTPUT.PUT_LINE('ps_month : ' || ps_month);
  	DBMS_OUTPUT.PUT_LINE('pn_amt   : ' || pn_amt);
  	DBMS_OUTPUT.PUT_LINE('pn_rate  : ' || pn_rate);  	
  	DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
  	
    --1. p_month에 해당하는 월의 ch17_SALES_DETAIL 데이터 삭제
    
	  -- delete 전 vd_sysdate에 현재시가 설정
	  vd_sysdate := SYSDATE;
	      
    DELETE ch17_SALES_DETAIL
     WHERE sales_month = ps_month;
     
    -- DELETE 소요시간 계산 (초로 계산하기 위해 * 60 * 60 * 24을 곱함)
    vn_total_time := (SYSDATE - vd_sysdate) * 60 * 60 * 24;
       
     
    DBMS_OUTPUT.PUT_LINE('DELETE 건수 : ' || SQL%ROWCOUNT || ' , 소요시간: ' || vn_total_time );
     
    --2. p_month에 해당하는 월의 ch17_SALES_DETAIL 데이터 생성
    vd_sysdate := SYSDATE;
    
    INSERT INTO ch17_SALES_DETAIL
    SELECT b.prod_name, 
           d.channel_desc,
           c.cust_name,
           e.emp_name,
           a.sales_date,
           a.sales_month,
           sum(a.quantity_sold),
           sum(a.amount_sold)
      FROM sales a,
           products b,
           customers c,
           channels d,
           employees e
    WHERE a.sales_month = ps_month
      AND a.prod_id     = b.prod_id
      AND a.cust_id     = c.cust_id
      AND a.channel_id  = d.channel_id
      AND a.employee_id = e.employee_id
    GROUP BY b.prod_name, 
           d.channel_desc,
           c.cust_name,
           e.emp_name,
           a.sales_date,
           a.sales_month;
           
    -- INSERT 소요시간 계산 (초로 계산하기 위해 * 60 * 60 * 24을 곱함)
    vn_total_time := (SYSDATE - vd_sysdate) * 60 * 60 * 24;           
           
    DBMS_OUTPUT.PUT_LINE('INSERT 건수 : ' || SQL%ROWCOUNT || ' , 소요시간: ' || vn_total_time ); 
           
           
    -- 3. 판매금액(sales_amt)이 pn_amt 보다 큰 건은 pn_rate 비율 만큼 할인한다.
    vd_sysdate := SYSDATE;
    
    UPDATE ch17_SALES_DETAIL
       SET sales_amt = sales_amt - ( sales_amt * pn_rate * 0.01)
     WHERE sales_month = ps_month
       AND sales_amt   > pn_amt;
       
    -- UPDATE 소요시간 계산 (초로 계산하기 위해 * 60 * 60 * 24을 곱함)
    vn_total_time := (SYSDATE - vd_sysdate) * 60 * 60 * 24;               
       
    DBMS_OUTPUT.PUT_LINE('UPDATE 건수 : ' || SQL%ROWCOUNT || ' , 소요시간: ' || vn_total_time ); 
    
    COMMIT;
  
    
  EXCEPTION WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE(SQLERRM);
         ROLLBACK;          
  
  
  END sales_detail_prc;

END ch17_src_test_pkg; 


BEGIN
  ch17_src_test_pkg.sales_detail_prc ( ps_month => '200112',
                                       pn_amt   => 50,
                                       pn_rate  => 32.5 );
END;


-- DBMS_UTILITY.GET_TIME 사용

CREATE OR REPLACE PACKAGE BODY ch17_src_test_pkg IS
  
  PROCEDURE sales_detail_prc ( ps_month IN VARCHAR2, 
                               pn_amt   IN NUMBER,
                               pn_rate  IN NUMBER   )
  IS
     vn_total_time NUMBER := 0;  -- 소요시간 계산용 변수 
  
  BEGIN
  	DBMS_OUTPUT.PUT_LINE('--------------<변수값 출력>---------------------');
  	DBMS_OUTPUT.PUT_LINE('ps_month : ' || ps_month);
  	DBMS_OUTPUT.PUT_LINE('pn_amt   : ' || pn_amt);
  	DBMS_OUTPUT.PUT_LINE('pn_rate  : ' || pn_rate);  	
  	DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
  	
    --1. p_month에 해당하는 월의 ch17_SALES_DETAIL 데이터 삭제
    
	  -- delete 전 시간 가져오기 
	  vn_total_time := DBMS_UTILITY.GET_TIME;
	      
    DELETE ch17_SALES_DETAIL
     WHERE sales_month = ps_month;
     
    -- DELETE 소요시간 계산 (초로 계산하기 위해 100으로 나눈다)
    vn_total_time := (DBMS_UTILITY.GET_TIME - vn_total_time) / 100;
       
     
    DBMS_OUTPUT.PUT_LINE('DELETE 건수 : ' || SQL%ROWCOUNT || ' , 소요시간: ' || vn_total_time );
     
    --2. p_month에 해당하는 월의 ch17_SALES_DETAIL 데이터 생성
    vn_total_time := DBMS_UTILITY.GET_TIME;
    
    INSERT INTO ch17_SALES_DETAIL
    SELECT b.prod_name, 
           d.channel_desc,
           c.cust_name,
           e.emp_name,
           a.sales_date,
           a.sales_month,
           sum(a.quantity_sold),
           sum(a.amount_sold)
      FROM sales a,
           products b,
           customers c,
           channels d,
           employees e
    WHERE a.sales_month = ps_month
      AND a.prod_id     = b.prod_id
      AND a.cust_id     = c.cust_id
      AND a.channel_id  = d.channel_id
      AND a.employee_id = e.employee_id
    GROUP BY b.prod_name, 
           d.channel_desc,
           c.cust_name,
           e.emp_name,
           a.sales_date,
           a.sales_month;
           
    -- INSERT 소요시간 계산 (초로 계산하기 위해 100으로 나눈다)
    vn_total_time := (DBMS_UTILITY.GET_TIME - vn_total_time)  / 100;        
           
    DBMS_OUTPUT.PUT_LINE('INSERT 건수 : ' || SQL%ROWCOUNT || ' , 소요시간: ' || vn_total_time ); 
           
           
    -- 3. 판매금액(sales_amt)이 pn_amt 보다 큰 건은 pn_rate 비율 만큼 할인한다.
    vn_total_time := DBMS_UTILITY.GET_TIME;
    
    UPDATE ch17_SALES_DETAIL
       SET sales_amt = sales_amt - ( sales_amt * pn_rate * 0.01)
     WHERE sales_month = ps_month
       AND sales_amt   > pn_amt;
       
    -- UPDATE 소요시간 계산 (초로 계산하기 위해 100으로 나눈다)
    vn_total_time := (DBMS_UTILITY.GET_TIME - vn_total_time)  / 100;        
       
    DBMS_OUTPUT.PUT_LINE('UPDATE 건수 : ' || SQL%ROWCOUNT || ' , 소요시간: ' || vn_total_time ); 
    
    COMMIT;
  
    
  EXCEPTION WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE(SQLERRM);
         ROLLBACK;          
  
  
  END sales_detail_prc;

END ch17_src_test_pkg; 


-- (3) 로그 테이블
CREATE TABLE program_log (
       log_id        NUMBER,         -- 로그 아이디
       program_name  VARCHAR2(100),  -- 프로그램명
       parameters    VARCHAR2(500),  -- 프로그램 매개변수
       state         VARCHAR2(10),   -- 상태(Running, Completed, Error) 
       start_time    TIMESTAMP,      -- 시작시간
       end_time      TIMESTAMP,      -- 종료시간
       log_desc      VARCHAR2(2000)  -- 로그내용 
       );
       
-- 로그 테이블 시퀀스
CREATE SEQUENCE prg_log_seq
INCREMENT BY 1
START WITH 1
MINVALUE 1
MAXVALUE 1000000
NOCYCLE
NOCACHE;
              

CREATE OR REPLACE PACKAGE BODY ch17_src_test_pkg IS
  
  PROCEDURE sales_detail_prc ( ps_month IN VARCHAR2, 
                               pn_amt   IN NUMBER,
                               pn_rate  IN NUMBER   )
  IS
     vn_total_time NUMBER := 0;     -- 소요시간 계산용 변수 
     
     vn_log_id     NUMBER;          -- 로그 아이디 
     vs_parameters VARCHAR2(500);   -- 매개변수   
     vs_prg_log    VARCHAR2(2000);  -- 로그내용
  BEGIN
  	-- 매개변수와 그 값을 가져온다 
  	vs_parameters := 'ps_month => ' || ps_month || ', pn_amt => ' || pn_amt || ' , pn_rate => ' || pn_rate;
  	
  	BEGIN
  	    -- 로그 아이디 값 생성
  	    vn_log_id := prg_log_seq.NEXTVAL;
  	    
  	    -- 로그 테이블에 데이터 생성
  	    INSERT INTO program_log (
  	                log_id, 
  	                program_name, 
  	                parameters, 
  	                state, 
  	                start_time )
           VALUES ( vn_log_id,
                    'ch17_src_test_pkg.sales_detail_prc',  
                    vs_parameters,
                    'Running',
                    SYSTIMESTAMP);
                    
        COMMIT;
    END;
  	
    --1. p_month에 해당하는 월의 ch17_SALES_DETAIL 데이터 삭제
    
	  -- delete 전 시간 가져오기 
	  vn_total_time := DBMS_UTILITY.GET_TIME;
	      
    DELETE ch17_SALES_DETAIL
     WHERE sales_month = ps_month;
     
    -- DELETE 소요시간 계산 (초로 계산하기 위해 100으로 나눈다)
    vn_total_time := (DBMS_UTILITY.GET_TIME - vn_total_time) / 100;
    
    -- DELETE 로그 내용 만들기
    vs_prg_log :=  'DELETE 건수 : ' || SQL%ROWCOUNT || ' , 소요시간: ' || vn_total_time || CHR(13); 
     
    --2. p_month에 해당하는 월의 ch17_SALES_DETAIL 데이터 생성
    vn_total_time := DBMS_UTILITY.GET_TIME;
    
    INSERT INTO ch17_SALES_DETAIL
    SELECT b.prod_name, 
           d.channel_desc,
           c.cust_name,
           e.emp_name,
           a.sales_date,
           a.sales_month,
           sum(a.quantity_sold),
           sum(a.amount_sold)
      FROM sales a,
           products b,
           customers c,
           channels d,
           employees e
    WHERE a.sales_month = ps_month
      AND a.prod_id     = b.prod_id
      AND a.cust_id     = c.cust_id
      AND a.channel_id  = d.channel_id
      AND a.employee_id = e.employee_id
    GROUP BY b.prod_name, 
           d.channel_desc,
           c.cust_name,
           e.emp_name,
           a.sales_date,
           a.sales_month;
           
    -- INSERT 소요시간 계산 (초로 계산하기 위해 100으로 나눈다)
    vn_total_time := (DBMS_UTILITY.GET_TIME - vn_total_time)  / 100;    
    
    -- INSERT 로그 내용 만들기
    vs_prg_log :=  vs_prg_log || 'INSERT 건수 : ' || SQL%ROWCOUNT || ' , 소요시간: ' || vn_total_time || CHR(13);                 
           
    -- 3. 판매금액(sales_amt)이 pn_amt 보다 큰 건은 pn_rate 비율 만큼 할인한다.
    vn_total_time := DBMS_UTILITY.GET_TIME;
    
    UPDATE ch17_SALES_DETAIL
       SET sales_amt = sales_amt - ( sales_amt * pn_rate * 0.01)
     WHERE sales_month = ps_month
       AND sales_amt   > pn_amt;
       
    -- UPDATE 소요시간 계산 (초로 계산하기 위해 100으로 나눈다)
    vn_total_time := (DBMS_UTILITY.GET_TIME - vn_total_time)  / 100; 
      
    -- UPDATE 로그 내용 만들기
    vs_prg_log :=  vs_prg_log || 'UPDATE 건수 : ' || SQL%ROWCOUNT || ' , 소요시간: ' || vn_total_time || CHR(13);          

    COMMIT;  
    
    
    BEGIN
    
       -- 로그 종료
       UPDATE program_log
          SET state = 'Completed',
              end_time = SYSTIMESTAMP,
              log_desc = vs_prg_log || '작업종료!'
        WHERE log_id = vn_log_id;
        
       COMMIT;
     
    END;
    
  EXCEPTION WHEN OTHERS THEN
        BEGIN 
          vs_prg_log := SQLERRM;
          -- 오류 로그
          UPDATE program_log
             SET state = 'Error',
                 end_time = SYSTIMESTAMP,
                 log_desc = vs_prg_log
           WHERE log_id = vn_log_id;
           
          COMMIT;
         
        END;
       
        ROLLBACK;          
  
  
  END sales_detail_prc;

END ch17_src_test_pkg; 


BEGIN
  ch17_src_test_pkg.sales_detail_prc ( ps_month => '200112',
                                       pn_amt   => 50,
                                       pn_rate  => 32.5 );
END;


SELECT *
  FROM program_log;

-- 03. 동적쿼리 디버깅
-- (1) 개요

CREATE OR REPLACE PROCEDURE ch17_dynamic_test ( p_emp_id   NUMBER, 
                                                p_emp_name VARCHAR2, 
                                                p_job_id   VARCHAR2
                                              )
IS
  vs_query    VARCHAR2(1000);
  vn_cnt      NUMBER := 0;
  vs_empname  employees.emp_name%TYPE := '%' || p_emp_name || '%';
  
BEGIN
	
	-- 동적쿼리 생성
	vs_query :=             'SELECT COUNT(*) ' || CHR(13);
	vs_query := vs_query || '  FROM employees ' || CHR(13);
  vs_query := vs_query || ' WHERE 1=1 ' || CHR(13);
  
  -- 사번이 NULL이 아니면 조건추가
  IF p_emp_id IS NOT NULL THEN     
     vs_query := vs_query || ' AND employee_id = ' || p_emp_id || CHR(13);
  END IF;
  
  -- 사원명이 NULL이 아니면 조건추가	
  IF p_emp_name IS NOT NULL THEN     
     vs_query := vs_query || ' AND emp_name like ' || '''' || vs_empname || '''' || CHR(13);
  END IF;	
	-- JOB_ID가 NULL이 아니면 조건추가 
  IF p_job_id IS NOT NULL THEN     
     vs_query := vs_query || ' AND job_id = ' || '''' || p_job_id || '''' || CHR(13);
  END IF;		
  -- 동적쿼리 실행, 건수는 vn_cnt 변수에 담는다. 
  EXECUTE IMMEDIATE vs_query INTO vn_cnt;
  
  DBMS_OUTPUT.PUT_LINE('결과건수 : ' || vn_cnt);
  DBMS_OUTPUT.PUT_LINE(vs_query);  
	
END;              

EXEC ch17_dynamic_test (171, NULL, NULL );

EXEC ch17_dynamic_test (NULL, 'Jon', NULL );

EXEC ch17_dynamic_test (NULL, NULL, 'SA_REP' );

EXEC ch17_dynamic_test (NULL, 'Jon', 'SA_REP' );

-- (2) CLOB 타입을 이용한 디버깅

CREATE TABLE ch17_dyquery (
             program_name  VARCHAR2(50),
             query_text    CLOB );
             
             
CREATE OR REPLACE PROCEDURE ch17_dynamic_test ( p_emp_id   NUMBER, 
                                                p_emp_name VARCHAR2, 
                                                p_job_id   VARCHAR2
                                              )
IS
  vs_query    VARCHAR2(1000);
  vn_cnt      NUMBER := 0;
  vs_empname  employees.emp_name%TYPE := '%' || p_emp_name || '%';
  
BEGIN
	
	-- 동적쿼리 생성
	vs_query :=             'SELECT COUNT(*) ' || CHR(13);
	vs_query := vs_query || '  FROM employees ' || CHR(13);
  vs_query := vs_query || ' WHERE 1=1 ' || CHR(13);
  
  -- 사번이 NULL이 아니면 조건추가
  IF p_emp_id IS NOT NULL THEN     
     vs_query := vs_query || ' AND employee_id = ' || p_emp_id || CHR(13);
  END IF;
  
  -- 사원명이 NULL이 아니면 조건추가	
  IF p_emp_name IS NOT NULL THEN     
     vs_query := vs_query || ' AND emp_name like ' || '''' || vs_empname || '''' || CHR(13);
  END IF;	
	-- JOB_ID가 NULL이 아니면 조건추가 
  IF p_job_id IS NOT NULL THEN     
     vs_query := vs_query || ' AND job_id = ' || '''' || p_job_id || '''' || CHR(13);
  END IF;		
  -- 동적쿼리 실행, 건수는 vn_cnt 변수에 담는다. 
  EXECUTE IMMEDIATE vs_query INTO vn_cnt;
  
  DBMS_OUTPUT.PUT_LINE('결과건수 : ' || vn_cnt);
  --DBMS_OUTPUT.PUT_LINE(vs_query);  
  
  -- 기존 데이터를 모두 삭제한다. 
  DELETE ch17_dyquery;
  
  -- 쿼리구문을 ch17_dyquery 에 넣는다.
  INSERT INTO ch17_dyquery (program_name, query_text)
  VALUES ( 'ch17_dynamic_test', vs_query);
  
  COMMIT;
	
END;                   


EXEC ch17_dynamic_test (NULL, 'Jon', 'SA_REP' );

SELECT  *
FROM ch17_dyquery;

-- 04. DML문을 실행한 데이터 추적
--(1) 변경되거나 삭제 된 데이터를 추적해보자

CREATE OR REPLACE ch17_upd_test_prc ( pn_emp_id NUMBER,
                                      pn_rate   NUMBER )
IS

BEGIN
	-- 급여 = 급여 * pn_rate * 0.01
	UPDATE employees
     SET salary = salary * pn_rate * 0.01
   WHERE employee_id = pn_emp_id;
   
  DBMS_OUTPUT.PUT_LINE('사번 : ' || pn_emp_id);
  DBMS_OUTPUT.PUT_LINE('급여는??? : ');
 
 COMMIT;
	
END;



CREATE OR REPLACE PROCEDURE ch17_upd_test_prc ( pn_emp_id NUMBER,
                                      pn_rate   NUMBER )
IS
  vn_salary NUMBER := 0; -- 갱신된 급여를 받아올 변수
BEGIN
	-- 급여 = 급여 * pn_rate * 0.01
	UPDATE employees
     SET salary = salary * pn_rate * 0.01
   WHERE employee_id = pn_emp_id;
   
  -- 급여를 조회한다.
  SELECT salary 
    INTO vn_salary
    FROM employees
   WHERE employee_id = pn_emp_id;
   
  DBMS_OUTPUT.PUT_LINE('사번 : ' || pn_emp_id);
  DBMS_OUTPUT.PUT_LINE('급여 : ' || vn_salary);
 
 COMMIT;
	
END;

                                
-- (2) RETURNING INTO 절을 이용한 디버깅

-- ① 단일 로우 UPDATE
DECLARE
  vn_salary   NUMBER := 0;
  vs_empname  VARCHAR2(30); 
BEGIN

  -- 171번 사원의 급여를 10000로 갱신
  UPDATE employees
     SET salary = 10000
   WHERE employee_id = 171
  RETURNING emp_name, salary 
       INTO vs_empname, vn_salary;
       
  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE('변경 사원명 : ' || vs_empname);
  DBMS_OUTPUT.PUT_LINE('변경 급여 : ' || vn_salary); 
END;


-- ② 다중 로우 UPDATE
DECLARE
  -- 레코드 타입 선언  
  TYPE NT_EMP_REC IS RECORD (
       emp_name      employees.emp_name%type,
       department_id employees.department_id%type,
       retire_date   employees.retire_date%type);
       
  -- NT_EMP_REC 레코드를 요소로 하는 중첩테이블 선언
  TYPE NTT_EMP IS TABLE OF NT_EMP_REC;
  -- NTT_EMP 중첩테이블 변수 선언
  VR_EMP NTT_EMP;
  
BEGIN
  -- 100번 부서의 retire_date를 현재일자로 ...
  UPDATE employees
     SET retire_date = SYSDATE
   WHERE department_id = 100
  RETURNING emp_name, department_id, retire_date
  BULK COLLECT  INTO VR_EMP;
       
  COMMIT;
  
  FOR i in VR_EMP.FIRST .. VR_EMP.LAST
  LOOP
    DBMS_OUTPUT.PUT_LINE(i || '--------------------------------');
    DBMS_OUTPUT.PUT_LINE('변경 사원명 : ' || VR_EMP(i).emp_name);
    DBMS_OUTPUT.PUT_LINE('변경 부서 : ' || VR_EMP(i).department_id);
    DBMS_OUTPUT.PUT_LINE('retire_date : ' || VR_EMP(i).retire_date);
  END LOOP;
  

END;

-- ③ 단일 로우 DELETE

CREATE TABLE emp_bk AS
SELECT *
FROM employees;


DECLARE
  vn_salary   NUMBER := 0;
  vs_empname  VARCHAR2(30); 
BEGIN

  -- 171번 사원 삭제
  DELETE emp_bk
   WHERE employee_id = 171
  RETURNING emp_name, salary 
       INTO vs_empname, vn_salary;
       
  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE('삭제 사원명 : ' || vs_empname);
  DBMS_OUTPUT.PUT_LINE('삭제된 급여 : ' || vn_salary); 
END;


-- ④ 다중 로우 DELETE
DECLARE
  -- 레코드 타입 선언  
  TYPE NT_EMP_REC IS RECORD (
       emp_name      employees.emp_name%type,
       department_id employees.department_id%type,
       job_id        employees.job_id%type);
        
  -- NT_EMP_REC 레코드를 요소로 하는 중첩테이블 선언
  TYPE NTT_EMP IS TABLE OF NT_EMP_REC;
  -- NTT_EMP 중첩테이블 변수 선언
  VR_EMP NTT_EMP;
  
BEGIN
  -- 60번 부서에 속한 사원 삭제  ...
  DELETE emp_bk
   WHERE department_id = 60
  RETURNING emp_name, department_id, job_id
  BULK COLLECT  INTO VR_EMP;
       
  COMMIT;
  
  FOR i in VR_EMP.FIRST .. VR_EMP.LAST
  LOOP
    DBMS_OUTPUT.PUT_LINE(i || '--------------------------------');
    DBMS_OUTPUT.PUT_LINE('변경 사원명 : ' || VR_EMP(i).emp_name);
    DBMS_OUTPUT.PUT_LINE('변경 부서 : ' || VR_EMP(i).department_id);
    DBMS_OUTPUT.PUT_LINE('retire_date : ' || VR_EMP(i).job_id);
  END LOOP;
  

END;
