-- 02. 일괄처리
-- (1) BULK COLLECT 절

CREATE TABLE emp_bulk (
        bulk_id         NUMBER        NOT NULL, 
        employee_id     NUMBER(6)     NOT NULL,   
        emp_name        VARCHAR2(80)  NOT NULL,
        email           VARCHAR2(50),
        phone_number    VARCHAR2(30),
        hire_date       DATE          NOT NULL,
        salary          NUMBER(8,2),  
        manager_id      NUMBER(6),    
        commission_pct  NUMBER(2,2),  
        retire_date     DATE,         
        department_id   NUMBER(6),    
        job_id          VARCHAR2(10),
        dep_name        VARCHAR2(100),
        job_title       VARCHAR2(80)
        ) ;
        

BEGIN
	FOR i IN 1..10000
	LOOP
	
	  INSERT INTO emp_bulk
	        ( bulk_id, 
	          employee_id, emp_name, email, 
	          phone_number, hire_date, salary, manager_id, 
	          commission_pct, retire_date, department_id, job_id)
	  SELECT i, 
	         employee_id, emp_name, email, 
	         phone_number, hire_date, salary, manager_id, 
	         commission_pct, retire_date, department_id, job_id
	    FROM employees;   
	         
	
	
  END LOOP;
	
	COMMIT;
	
END;


SELECT COUNT(*)
  FROM emp_bulk;
  
  
-- 일반 커서  
DECLARE
  -- 커서선언 
  CURSOR c1 IS
  SELECT employee_id
   FROM emp_bulk;
   
  vn_cnt      NUMBER := 0;  
  vn_emp_id   NUMBER; 
  vd_sysdate  DATE;
  vn_total_time NUMBER := 0;
BEGIN
	-- 시작전 vd_sysdate에 현재시가 설정
	vd_sysdate := SYSDATE;
	
	OPEN c1;
	
	LOOP
	  FETCH c1 INTO vn_emp_id;
	  EXIT WHEN c1%NOTFOUND;
	  
	  -- 루프횟수
	  vn_cnt := vn_cnt + 1;
	
  END LOOP;
  
  CLOSE c1;
  
  -- 총 소요시간 계산 (초로 계산하기 위해 * 60 * 60 * 24을 곱함)
  vn_total_time := (SYSDATE - vd_sysdate) * 60 * 60 * 24;
  
  -- 루프횟수 출력
  DBMS_OUTPUT.PUT_LINE('전체건수 : ' || vn_cnt);
  -- 총 소요시간 출력
  DBMS_OUTPUT.PUT_LINE('소요시간 : ' || vn_total_time);  
	
END;  


-- BULK COLLECT 
DECLARE
  -- 커서선언 
  CURSOR c1 IS
  SELECT employee_id
   FROM emp_bulk;
   
  -- 컬렉션 타입 선언
  TYPE bkEmpTP IS TABLE OF emp_bulk.employee_id%TYPE;
  -- bkEmpTP 형 변수선언
  vnt_bkEmpTP bkEmpTP;

  vd_sysdate  DATE;
  vn_total_time NUMBER := 0;
BEGIN
	-- 시작전 vd_sysdate에 현재시가 설정
	vd_sysdate := SYSDATE;
	
	OPEN c1;
	-- 루프를 돌리지 않는다. 
	FETCH c1 BULK COLLECT INTO vnt_bkEmpTP;
  
  CLOSE c1;
  
  -- 총 소요시간 계산 (초로 계산하기 위해 * 60 * 60 * 24을 곱함)
  vn_total_time := (SYSDATE - vd_sysdate) * 60 * 60 * 24;
  
  -- 컬렉션변수인 vnt_bkEmpTP 요소갯수 출력 
  DBMS_OUTPUT.PUT_LINE('전체건수 : ' || vnt_bkEmpTP.COUNT);
  -- 총 소요시간 출력
  DBMS_OUTPUT.PUT_LINE('소요시간 : ' || vn_total_time);  
	
END;  

--(2) FORALL문

SELECT MIN(bulk_id), MAX(bulk_id), COUNT(*)
  FROM emp_bulk;
  
-- 인덱스 생성  
CREATE INDEX emp_bulk_idx01 ON emp_bulk ( bulk_id );  

-- 통계정보 생성
EXECUTE DBMS_STATS.GATHER_TABLE_STATS( 'ORA_USER', 'EMP_BULK');

-- 일반적인 커서와 루프
DECLARE
  -- 커서선언 
  CURSOR c1 IS
  SELECT DISTINCT bulk_id
   FROM emp_bulk;

  
  -- 컬렉션 타입 선언
  TYPE BulkIDTP IS TABLE OF emp_bulk.bulk_id%TYPE;
  
  -- BulkIDTP 형 변수선언
  vnt_BulkID    BulkIDTP;
  vd_sysdate    DATE;
  vn_total_time NUMBER := 0; 

BEGIN
	
	-- 시작전 vd_sysdate에 현재시가 설정
	vd_sysdate := SYSDATE;
	
	OPEN c1;
	
  -- BULK COLLECT 절을 사용해 vnt_BulkID 변수에 데이터 담기
	FETCH c1 BULK COLLECT INTO vnt_BulkID;	
	
	-- 루프를 돌며 DELETE 
	FOR i IN 1..vnt_BulkID.COUNT
  LOOP
	  UPDATE emp_bulk
       SET retire_date = hire_date
	   WHERE bulk_id = vnt_BulkID(i);
  END LOOP;
	
  
  COMMIT;
  
  CLOSE c1;
  
  -- 총 소요시간 계산 (초로 계산하기 위해 * 60 * 60 * 24을 곱함)
  vn_total_time := (SYSDATE - vd_sysdate) * 60 * 60 * 24;
  
  -- 컬렉션변수인 vnt_BulkID 요소갯수 출력 
  DBMS_OUTPUT.PUT_LINE('전체건수 : ' || vnt_BulkID.COUNT);
  -- 총 소요시간 출력
  DBMS_OUTPUT.PUT_LINE('FOR LOOP 소요시간 : ' || vn_total_time);  	
	
	
END;


-- FORALL 문 사용
DECLARE
  -- 커서선언 
  CURSOR c1 IS
  SELECT DISTINCT bulk_id
   FROM emp_bulk;

  
  -- 컬렉션 타입 선언
  TYPE BulkIDTP IS TABLE OF emp_bulk.bulk_id%TYPE;
  
  -- BulkIDTP 형 변수선언
  vnt_BulkID    BulkIDTP;
  vd_sysdate    DATE;
  vn_total_time NUMBER := 0;  

BEGIN
	
	-- 시작전 vd_sysdate에 현재시가 설정
	vd_sysdate := SYSDATE;
	
	OPEN c1;
	
	-- BULK COLLECT 절을 사용해 vnt_BulkID 변수에 데이터 담기
	FETCH c1 BULK COLLECT INTO vnt_BulkID;
	
	-- 루프를 돌리지 않고 DELETE. 	
	FORALL i IN 1..vnt_BulkID.COUNT
	  UPDATE emp_bulk
       SET retire_date = hire_date
	   WHERE bulk_id = vnt_BulkID(i);
	
  COMMIT;
  
  CLOSE c1;
  
  -- 총 소요시간 계산 (초로 계산하기 위해 * 60 * 60 * 24을 곱함)
  vn_total_time := (SYSDATE - vd_sysdate) * 60 * 60 * 24;
  
  -- 컬렉션변수인 vnt_bkEmpTP 요소갯수 출력 
  DBMS_OUTPUT.PUT_LINE('전체건수 : ' || vnt_BulkID.COUNT);
  -- 총 소요시간 출력
  DBMS_OUTPUT.PUT_LINE('FORALL 소요시간 : ' || vn_total_time);  	
	
	
END;


-- 03. 함수 성능 향상

-- 일반함수 생성
CREATE OR REPLACE FUNCTION fn_get_depname_normal ( pv_dept_id VARCHAR2 )
     RETURN VARCHAR2
IS
   vs_dep_name DEPARTMENTS.DEPARTMENT_NAME%TYPE;
BEGIN
	
	SELECT department_name
	  INTO vs_dep_name
	  FROM DEPARTMENTS
	 WHERE department_id = pv_dept_id;
	 
  RETURN vs_dep_name;
  
EXCEPTION WHEN OTHERS THEN
  RETURN '';	
	
END;

-- 일반함수를 이용한 UPDATE
DECLARE
  vn_cnt        NUMBER := 0;
  vd_sysdate    DATE;
  vn_total_time NUMBER := 0;  
BEGIN

  vd_sysdate := SYSDATE;
  
  -- dep_name 컬럼에 부서명을 가져와 갱신 
  UPDATE emp_bulk
     SET dep_name = fn_get_depname_normal ( department_id )
   WHERE bulk_id BETWEEN 1 AND 1000;
  
  vn_cnt := SQL%ROWCOUNT;
  
  COMMIT;

  -- 총 소요시간 계산 (초로 계산하기 위해 * 60 * 60 * 24을 곱함)
  vn_total_time := (SYSDATE - vd_sysdate) * 60 * 60 * 24;
  
  -- UPDATE 건수 출력  
  DBMS_OUTPUT.PUT_LINE('UPDATE 건수 : ' || vn_cnt);
  -- 총 소요시간 출력
  DBMS_OUTPUT.PUT_LINE('소요시간 : ' || vn_total_time);  

END;


SELECT department_id, dep_name, COUNT(*)
  FROM emp_bulk
 WHERE bulk_id BETWEEN 1 AND 1000
 GROUP BY department_id, dep_name
 ORDER BY department_id, dep_name;
 
 
-- RESULT CACHE 기능이 탑재된 함수  
CREATE OR REPLACE FUNCTION fn_get_depname_rsltcache ( pv_dept_id VARCHAR2 )
     RETURN VARCHAR2
     RESULT_CACHE
     RELIES_ON ( DEPARTMENTS )
IS
   vs_dep_name DEPARTMENTS.DEPARTMENT_NAME%TYPE;
BEGIN
	-- 부서명을 가져온다.
	SELECT department_name
	  INTO vs_dep_name
	  FROM DEPARTMENTS
	 WHERE department_id = pv_dept_id;
	 
  RETURN vs_dep_name;
  
EXCEPTION WHEN OTHERS THEN
  RETURN '';	
	
END;


DECLARE
  vn_cnt        NUMBER := 0;
  vd_sysdate    DATE;
  vn_total_time NUMBER := 0;  
BEGIN

  vd_sysdate := SYSDATE;
  
  UPDATE emp_bulk
     SET dep_name = fn_get_depname_rsltcache ( department_id )
   WHERE bulk_id BETWEEN 1 AND 1000;
  
  vn_cnt := SQL%ROWCOUNT;
  
  COMMIT;

  -- 총 소요시간 계산 (초로 계산하기 위해 * 60 * 60 * 24을 곱함)
  vn_total_time := (SYSDATE - vd_sysdate) * 60 * 60 * 24;
  
  -- UPDATE 건수 출력  
  DBMS_OUTPUT.PUT_LINE('전체건수 : ' || vn_cnt);
  -- 총 소요시간 출력
  DBMS_OUTPUT.PUT_LINE('소요시간 : ' || vn_total_time);  

END;

SELECT * FROM V$RESULT_CACHE_STATISTICS;
