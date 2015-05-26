-- NDS
-- (1) EXECUTE IMMEDIATE

BEGIN
	EXECUTE IMMEDIATE 'SELECT employee_id, emp_name, job_id 
	                     FROM employees WHERE job_id = ''AD_ASST'' ';
	
END;

-- 값 출력
DECLARE
  --출력 변수 선언 
  vn_emp_id    employees.employee_id%TYPE;
  vs_emp_name  employees.emp_name%TYPE;
  vs_job_id    employees.job_id%TYPE;
BEGIN
	EXECUTE IMMEDIATE 'SELECT employee_id, emp_name, job_id 
	                     FROM employees WHERE job_id = ''AD_ASST'' '
	                  INTO vn_emp_id, vs_emp_name, vs_job_id;
	                  
  DBMS_OUTPUT.PUT_LINE( 'emp_id : '   || vn_emp_id );	          
  DBMS_OUTPUT.PUT_LINE( 'emp_name : ' || vs_emp_name );	 
  DBMS_OUTPUT.PUT_LINE( 'job_id : '   || vs_job_id );	         
	
END;


-- SQL문을 변수로
DECLARE
  --출력 변수 선언 
  vn_emp_id    employees.employee_id%TYPE;
  vs_emp_name  employees.emp_name%TYPE;
  vs_job_id    employees.job_id%TYPE;
  
  vs_sql VARCHAR2(1000);
BEGIN
	-- SQL문을 변수에 담는다. 
	vs_sql := 'SELECT employee_id, emp_name, job_id 
	                FROM employees WHERE job_id = ''AD_ASST'' ';
	
  EXECUTE IMMEDIATE vs_sql INTO vn_emp_id, vs_emp_name, vs_job_id;
	                  
  DBMS_OUTPUT.PUT_LINE( 'emp_id : '   || vn_emp_id );	          
  DBMS_OUTPUT.PUT_LINE( 'emp_name : ' || vs_emp_name );	 
  DBMS_OUTPUT.PUT_LINE( 'job_id : '   || vs_job_id );	         
END;


-- 바인드 변수
DECLARE
  --출력 변수 선언 
  vn_emp_id    employees.employee_id%TYPE;
  vs_emp_name  employees.emp_name%TYPE;
  vs_job_id    employees.job_id%TYPE;
  
  vs_sql VARCHAR2(1000);
BEGIN
	-- SQL문을 변수에 담는다. 
	vs_sql := 'SELECT employee_id, emp_name, job_id 
	            FROM employees 
	           WHERE job_id = ''SA_REP'' 
	             AND salary < 7000
	             AND manager_id  =148 ';
	
  EXECUTE IMMEDIATE vs_sql INTO vn_emp_id, vs_emp_name, vs_job_id;
	                  
  DBMS_OUTPUT.PUT_LINE( 'emp_id : '   || vn_emp_id );	          
  DBMS_OUTPUT.PUT_LINE( 'emp_name : ' || vs_emp_name );	 
  DBMS_OUTPUT.PUT_LINE( 'job_id : '   || vs_job_id );	         
END;

-- 바인드변수 2
DECLARE
  --출력 변수 선언 
  vn_emp_id    employees.employee_id%TYPE;
  vs_emp_name  employees.emp_name%TYPE;
  vs_job_id    employees.job_id%TYPE;
  
  vs_sql VARCHAR2(1000);
  
  -- 바인드 변수 선언과 값 설정
  vs_job      employees.job_id%TYPE := 'SA_REP';
  vn_sal      employees.salary%TYPE := 7000;
  vn_manager  employees.manager_id%TYPE := 148;
BEGIN
	-- SQL문을 변수에 담는다. (바인드 변수 앞에 : 를 붙인다)
	vs_sql := 'SELECT employee_id, emp_name, job_id 
	            FROM employees 
	           WHERE job_id = :a 
	             AND salary < :b
	             AND manager_id = :c ';
	
	-- SQL문에서 선언한 순서대로 USING 다음에 변수를 넣는다. 
  EXECUTE IMMEDIATE vs_sql INTO vn_emp_id, vs_emp_name, vs_job_id
                           USING vs_job, vn_sal, vn_manager;
	                  
  DBMS_OUTPUT.PUT_LINE( 'emp_id : '   || vn_emp_id );	          
  DBMS_OUTPUT.PUT_LINE( 'emp_name : ' || vs_emp_name );	 
  DBMS_OUTPUT.PUT_LINE( 'job_id : '   || vs_job_id );	         
END;

-- INSERT, UPDATE, DELETE, MERGE

CREATE TABLE ch13_physicist ( ids       NUMBER, 
                              names     VARCHAR2(50), 
                              birth_dt  DATE );
                         
-- INSERT 문
DECLARE
  vn_ids   ch13_physicist.ids%TYPE := 10;
  vs_name  ch13_physicist.names%TYPE := 'Albert Einstein';
  vd_dt    ch13_physicist.birth_dt%TYPE := TO_DATE('1879-03-14', 'YYYY-MM-DD');
  
  vs_sql   VARCHAR2(1000);  

BEGIN
	-- INSERT문 작성 
	vs_sql := 'INSERT INTO ch13_physicist VALUES (:a, :a, :a)';
	
	EXECUTE IMMEDIATE vs_sql USING vn_ids, vs_name, vd_dt;
	
	COMMIT;
	
END;                         
                         
-- UPDATE와 DELETE
DECLARE
  vn_ids   ch13_physicist.ids%TYPE := 10;
  vs_name  ch13_physicist.names%TYPE := 'Max Planck';
  vd_dt    ch13_physicist.birth_dt%TYPE := TO_DATE('1858-04-23', 'YYYY-MM-DD');
  
  vs_sql   VARCHAR2(1000);  
  
  vn_cnt   NUMBER := 0;

BEGIN
	-- UPDATE문
	vs_sql := 'UPDATE ch13_physicist
	              SET names = :a, birth_dt = :a
	            WHERE ids = :a ';
	
	EXECUTE IMMEDIATE vs_sql USING vs_name, vd_dt, vn_ids;
	
	SELECT names
	  INTO vs_name
	  FROM ch13_physicist;
	  
	DBMS_OUTPUT.PUT_LINE('UPDATE 후 이름: ' || vs_name);
	
	-- DELETE 문
	vs_sql := 'DELETE ch13_physicist
	            WHERE ids = :a ';
	
	EXECUTE IMMEDIATE vs_sql USING vn_ids;	
	
  SELECT COUNT(*)
    INTO vn_cnt
    FROM ch13_physicist;
	
	DBMS_OUTPUT.PUT_LINE('vn_cnt : ' || vn_cnt);
	
	COMMIT;
	
END;  

-- 바인드 변수처리 2

CREATE OR REPLACE PROCEDURE ch13_bind_proc1 ( pv_arg1 IN VARCHAR2, 
                                              pn_arg2 IN NUMBER, 
                                              pd_arg3 IN DATE )
IS
BEGIN
	DBMS_OUTPUT.PUT_LINE ('pv_arg1 = ' || pv_arg1);
	DBMS_OUTPUT.PUT_LINE ('pn_arg2 = ' || pn_arg2);
	DBMS_OUTPUT.PUT_LINE ('pd_arg3 = ' || pd_arg3);
	
END;
                                              
                            
-- 동적 SQL로 프로시저 실행
DECLARE
  vs_data1 VARCHAR2(30) := 'Albert Einstein';
  vn_data2 NUMBER := 100;
  vd_data3 DATE   := TO_DATE('1879-03-14', 'YYYY-MM-DD');

  vs_sql   VARCHAR2(1000);
BEGIN
  -- 프로시저 실행
  ch13_bind_proc1 ( vs_data1, vn_data2, vd_data3);
  
  DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    
  vs_sql := 'BEGIN ch13_bind_proc1 (:a, :b, :c); END;';
  
  EXECUTE IMMEDIATE vs_sql USING vs_data1, vn_data2, vd_data3;
  
END;

-- 바인드 변수를 잘못 기재한 경우
BEGIN
	DBMS_OUTPUT.PUT_LINE ('pv_arg1 = ' || pv_arg1);
	DBMS_OUTPUT.PUT_LINE ('pn_arg2 = ' || pn_arg2);
	DBMS_OUTPUT.PUT_LINE ('pd_arg3 = ' || pd_arg3);
	
END;
                                              
                            
-- 동적 SQL로 프로시저 실행
DECLARE
  vs_data1 VARCHAR2(30) := 'Albert Einstein';
  vn_data2 NUMBER := 100;
  vd_data3 DATE   := TO_DATE('1879-03-14', 'YYYY-MM-DD');

  vs_sql   VARCHAR2(1000);
BEGIN
  -- 바인드 변수명을 잘못 기재한 경우.    
  vs_sql := 'BEGIN ch13_bind_proc1 (:a, :a, :c); END;';
  
  EXECUTE IMMEDIATE vs_sql USING vs_data1, vn_data2, vd_data3;
  
END;


CREATE OR REPLACE PROCEDURE ch13_bind_proc2 ( pv_arg1 IN     VARCHAR2, 
                                              pv_arg2 OUT    VARCHAR2,
                                              pv_arg3 IN OUT VARCHAR2 )
                                              
IS
BEGIN
	DBMS_OUTPUT.PUT_LINE ('pv_arg1 = ' || pv_arg1);
	
	pv_arg2 := '두 번째 OUT 변수';
	pv_arg3 := '세 번째 INOUT 변수';
	
END;

-- 
DECLARE
  vs_data1 VARCHAR2(30) := 'Albert Einstein';
  vs_data2 VARCHAR2(30);
  vs_data3 VARCHAR2(30);

  vs_sql   VARCHAR2(1000);
BEGIN
  -- 바인드 변수  
  vs_sql := 'BEGIN ch13_bind_proc2 (:a, :b, :c); END;';
  
  EXECUTE IMMEDIATE vs_sql USING vs_data1, OUT vs_data2, IN OUT vs_data3;
  
  
  DBMS_OUTPUT.PUT_LINE ('vs_data2 = ' || vs_data2);
  DBMS_OUTPUT.PUT_LINE ('vs_data3 = ' || vs_data3);
END;


-- DDL문과 ALTER SESSION
CREATE OR REPLACE PROCEDURE ch13_ddl_proc ( pd_arg1 IN DATE )
IS
BEGIN
	
	 DBMS_OUTPUT.PUT_LINE('pd_arg1 : ' || pd_arg1);
END;


CREATE OR REPLACE PROCEDURE ch13_ddl_proc ( pd_arg1 IN DATE )
IS
BEGIN
	 CREATE TABLE ch13_ddl_tab ( col1 VARCHAR2(30));	
	 DBMS_OUTPUT.PUT_LINE('pd_arg1 : ' || pd_arg1);
END;


CREATE OR REPLACE PROCEDURE ch13_ddl_proc ( pd_arg1 IN DATE )
IS
  vs_sql VARCHAR2(1000);
BEGIN
	 -- DDL문을 동적SQL로 ...
	 vs_sql := 'CREATE TABLE ch13_ddl_tab ( col1 VARCHAR2(30) )' ;
	 EXECUTE IMMEDIATE vs_sql;
	 
	 DBMS_OUTPUT.PUT_LINE('pd_arg1 : ' || pd_arg1);
END;



EXEC ch13_ddl_proc ( SYSDATE );


SELECT SYSDATE
  FROM DUAL;
  
CREATE OR REPLACE PROCEDURE ch13_ddl_proc ( pd_arg1 IN DATE )
IS
  vs_sql VARCHAR2(1000);
BEGIN
	 -- ALTER SESSION 
	 vs_sql := 'ALTER SESSION SET NLS_DATE_FORMAT = "YYYY/MM/DD"';
	 EXECUTE IMMEDIATE vs_sql;
	 
	 DBMS_OUTPUT.PUT_LINE('pd_arg1 : ' || pd_arg1);
END; 
  
  
-- (2) 다중로우 처리
-- ① OPEN FOR문
TRUNCATE TABLE ch13_physicist ;

INSERT INTO ch13_physicist VALUES (1, 'Galileo Galilei', TO_DATE('1564-02-15','YYYY-MM-DD'));

INSERT INTO ch13_physicist VALUES (2, 'Isaac Newton', TO_DATE('1643-01-04','YYYY-MM-DD'));

INSERT INTO ch13_physicist VALUES (3, 'Max Plank', TO_DATE('1858-04-23','YYYY-MM-DD'));

INSERT INTO ch13_physicist VALUES (4, 'Albert Einstein', TO_DATE('1879-03-14','YYYY-MM-DD'));

COMMIT;

   
DECLARE
  -- 커서타입 선언
  TYPE query_physicist IS REF CURSOR;
  -- 커서 변수 선언
  myPhysicist query_physicist;
  -- 반환값을 받을 레코드 선언
  empPhysicist ch13_physicist%ROWTYPE;
  

  vs_sql VARCHAR2(1000);

BEGIN
	vs_sql := 'SELECT * FROM ch13_physicist';
	-- OPEN FOR문을 사용한 동적 SQL
	OPEN myPhysicist FOR vs_sql;
	--루프를 돌며 커서변수에 담긴 값을 출력한다.
	LOOP
	  FETCH myPhysicist INTO empPhysicist;
    EXIT WHEN myPhysicist%NOTFOUND;	
    DBMS_OUTPUT.PUT_LINE(empPhysicist.names);
  END LOOP;
	
	CLOSE myPhysicist;
END;


-- 바인드 변수    
DECLARE
  -- 커서 변수 선언
  myPhysicist SYS_REFCURSOR;
  -- 반환값을 받을 레코드 선언
  empPhysicist ch13_physicist%ROWTYPE;
  

  vs_sql VARCHAR2(1000);
  vn_id    ch13_physicist.ids%TYPE    := 1;
  vs_names ch13_physicist.names%TYPE  := 'Albert%';

BEGIN
	-- 바인드 변수 사용을 위해 WHERE조건 추가 
	vs_sql := 'SELECT * FROM ch13_physicist WHERE IDS > :a AND NAMES LIKE :a ';
	-- OPEN FOR문을 사용한 동적 SQL
	OPEN myPhysicist FOR vs_sql USING vn_id, vs_names;
	--루프를 돌며 커서변수에 담긴 값을 출력한다.
	LOOP
	  FETCH myPhysicist INTO empPhysicist;
    EXIT WHEN myPhysicist%NOTFOUND;	
    DBMS_OUTPUT.PUT_LINE(empPhysicist.names);
  END LOOP;
	
	CLOSE myPhysicist;
END;


-- 성능 향상을 위한 다중 로우 처리

-- BULK COLLECT INTO를 사용한 정적 SQL
DECLARE
  -- 레코드 선언 
  TYPE rec_physicist IS RECORD  (
      ids      ch13_physicist.ids%TYPE,
      names    ch13_physicist.names%TYPE,
      birth_dt ch13_physicist.birth_dt%TYPE );
  -- 레코드를 항목으로 하는 중첩테이블 선언
  TYPE NT_physicist IS TABLE OF rec_physicist;
  -- 중첩테이블 변수 선언
  vr_physicist NT_physicist;
BEGIN
  -- BULK COLLECT INTO 절 
	SELECT * 
   BULK COLLECT INTO vr_physicist
   FROM ch13_physicist;
   -- 루프를 돌며 출력
   FOR i IN 1..vr_physicist.count
   LOOP
     DBMS_OUTPUT.PUT_LINE(vr_physicist(i).names);
   END LOOP;

END;

-- BULK COLLECT INTO를 사용한 동적  SQL
DECLARE
  -- 레코드 선언 
  TYPE rec_physicist IS RECORD  (
      ids      ch13_physicist.ids%TYPE,
      names    ch13_physicist.names%TYPE,
      birth_dt ch13_physicist.birth_dt%TYPE );
  -- 레코드를 항목으로 하는 중첩테이블 선언
  TYPE NT_physicist IS TABLE OF rec_physicist;
  -- 중첩테이블 변수 선언
  vr_physicist NT_physicist;
  
  vs_sql VARCHAR2(1000);
  vn_ids ch13_physicist.ids%TYPE := 1;
BEGIN
  -- SELECT 구문 
  vs_sql := 'SELECT * FROM ch13_physicist WHERE ids > :a' ;
  
  -- EXECUTE IMMEDIATE .. BULK COLLECT INTO 구문
  EXECUTE IMMEDIATE vs_sql BULK COLLECT INTO vr_physicist USING vn_ids;
  
   -- 루프를 돌며 출력
   FOR i IN 1..vr_physicist.count
   LOOP
     DBMS_OUTPUT.PUT_LINE(vr_physicist(i).names);
   END LOOP;

END;

-- 기본 활용법 (DBMS_SQL)
DECLARE
  --출력 변수 선언 
  vn_emp_id    employees.employee_id%TYPE;
  vs_emp_name  employees.emp_name%TYPE;
  vs_job_id    employees.job_id%TYPE;
  
  vs_sql VARCHAR2(1000);
  
  -- 바인드 변수 선언과 값 설정
  vs_job      employees.job_id%TYPE := 'SA_REP';
  vn_sal      employees.salary%TYPE := 7000;
  vn_manager  employees.manager_id%TYPE := 148;
  
  -- DBMS_SQL 패키지 관련 변수
  vn_cur_id   NUMBER := DBMS_SQL.OPEN_CURSOR(); -- 커서를 연다
  vn_return   NUMBER;
BEGIN
	-- 1.SQL문을 변수에 담는다. (바인드 변수 앞에 : 를 붙인다)
	vs_sql := 'SELECT employee_id, emp_name, job_id 
	            FROM employees 
	           WHERE job_id = :a 
	             AND salary < :b
	             AND manager_id = :c ';
	             
  -- 2. 파싱
  DBMS_SQL.PARSE (vn_cur_id, vs_sql, DBMS_SQL.NATIVE);
  
  -- 3. 바인드 변수 연결 (WHERE 절에 사용한 변수가 3개 이므로 각 변수별로 총 3회 호출)
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':a', vs_job);
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':b', vn_sal);
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':c', vn_manager);
  
  -- 4. 결과선택 컬럼 정의 ( 사번, 사원명, job_id 총 3개의 컬럼을 선택했으므로 각각 순서대로 호출)
  -- SELECT 순서에 따라 순번을 맞추고 결과를 담을 변수와 연결한다. 
  DBMS_SQL.DEFINE_COLUMN ( vn_cur_id, 1, vn_emp_id);
  DBMS_SQL.DEFINE_COLUMN ( vn_cur_id, 2, vs_emp_name, 80); --문자형은 크기까지 지정 
  DBMS_SQL.DEFINE_COLUMN ( vn_cur_id, 3, vs_job_id, 10);
  
  -- 5. 쿼리실행
  vn_return := DBMS_SQL.EXECUTE (vn_cur_id);
  
  -- 6. 결과패치 
  LOOP
    -- 결과건수가 없으면 루프를 빠져나간다. 
    IF DBMS_SQL.FETCH_ROWS (vn_cur_id) = 0 THEN
       EXIT;
    END IF;
    
    -- 7. 패치된 결과값 받아오기 
    DBMS_SQL.COLUMN_VALUE ( vn_cur_id, 1, vn_emp_id);
    DBMS_SQL.COLUMN_VALUE ( vn_cur_id, 2, vs_emp_name);
    DBMS_SQL.COLUMN_VALUE ( vn_cur_id, 3, vs_job_id);
    
    -- 결과 출력
    DBMS_OUTPUT.PUT_LINE( 'emp_id : '   || vn_emp_id );	          
    DBMS_OUTPUT.PUT_LINE( 'emp_name : ' || vs_emp_name );	 
    DBMS_OUTPUT.PUT_LINE( 'job_id : '   || vs_job_id );	  
  
  END LOOP;
  
  -- 8. 커서 닫기
    DBMS_SQL.CLOSE_CURSOR (vn_cur_id);
           
END;

-- DBMS_SQL을 이용한 INSERT
DECLARE
  vn_ids   ch13_physicist.ids%TYPE := 1;
  vs_name  ch13_physicist.names%TYPE := 'Galileo Galilei';
  vd_dt    ch13_physicist.birth_dt%TYPE := TO_DATE('1564-02-15', 'YYYY-MM-DD');
  
  vs_sql   VARCHAR2(1000);  
  
  -- DBMS_SQL 패키지 관련 변수
  vn_cur_id   NUMBER := DBMS_SQL.OPEN_CURSOR(); -- 커서를 연다
  vn_return   NUMBER;  

BEGIN
	-- 1. INSERT문 작성 
	vs_sql := 'INSERT INTO ch13_physicist VALUES (:a, :b, :c)';
	
  -- 2. 파싱
  DBMS_SQL.PARSE (vn_cur_id, vs_sql, DBMS_SQL.NATIVE);
  
  -- 3. 바인드 변수 연결 (VALUES 절에서 사용한 변수가 3개 이므로 각 변수별로 총 3회 호출)
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':a', vn_ids);
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':b', vs_name);
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':c', vd_dt);
  
  -- 4. 쿼리실행
  vn_return := DBMS_SQL.EXECUTE (vn_cur_id);  
  
  -- 5. 커서 닫기
  DBMS_SQL.CLOSE_CURSOR (vn_cur_id);  
  --결과건수 출력
  DBMS_OUTPUT.PUT_LINE('결과건수: ' || vn_return);
	
	COMMIT;
	
END; 


INSERT INTO ch13_physicist VALUES (2, 'Isaac Newton', TO_DATE('1643-01-04', 'YYYY-MM-DD'));

INSERT INTO ch13_physicist VALUES (3, 'Max Plank', TO_DATE('1858-04-23', 'YYYY-MM-DD'));

INSERT INTO ch13_physicist VALUES (4, 'Albert Einstein', TO_DATE('1879-03-14', 'YYYY-MM-DD'));

COMMIT;

-- DBMS_SQL을 이용한 UPDATE
DECLARE
  vn_ids   ch13_physicist.ids%TYPE := 3;
  vs_name  ch13_physicist.names%TYPE := ' UPDATED';
  
  vs_sql   VARCHAR2(1000);  
  
  -- DBMS_SQL 패키지 관련 변수
  vn_cur_id   NUMBER := DBMS_SQL.OPEN_CURSOR(); -- 커서를 연다
  vn_return   NUMBER;  

BEGIN
	-- 1. UPDATE문 작성 
	vs_sql := 'UPDATE ch13_physicist SET names = names || :a WHERE ids < :b' ;
	
  -- 2. 파싱
  DBMS_SQL.PARSE (vn_cur_id, vs_sql, DBMS_SQL.NATIVE);
  
  -- 3. 바인드 변수 연결 
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':a', vs_name);
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':b', vn_ids);
  
  -- 4. 쿼리실행
  vn_return := DBMS_SQL.EXECUTE (vn_cur_id);  
  
  -- 5. 커서 닫기
  DBMS_SQL.CLOSE_CURSOR (vn_cur_id);  
  --결과건수 출력
  DBMS_OUTPUT.PUT_LINE('UPDATE 결과건수: ' || vn_return);
	
	COMMIT;
	
END; 


SELECT *
  FROM ch13_physicist;
  
  
-- DBMS_SQL을 이용한 DELETE
DECLARE
  vn_ids   ch13_physicist.ids%TYPE := 3;
  
  vs_sql   VARCHAR2(1000);  
  
  -- DBMS_SQL 패키지 관련 변수
  vn_cur_id   NUMBER := DBMS_SQL.OPEN_CURSOR(); -- 커서를 연다
  vn_return   NUMBER;  

BEGIN
	--  DELETE 문 작성 
	vs_sql := 'DELETE ch13_physicist WHERE ids < :b' ;
	
  -- 2. 파싱
  DBMS_SQL.PARSE (vn_cur_id, vs_sql, DBMS_SQL.NATIVE);
  
  -- 3. 바인드 변수 연결 
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':b', vn_ids);
  
  -- 4. 쿼리실행
  vn_return := DBMS_SQL.EXECUTE (vn_cur_id);  
  
  -- 5. 커서 닫기
  DBMS_SQL.CLOSE_CURSOR (vn_cur_id);  
  --결과건수 출력
  DBMS_OUTPUT.PUT_LINE('DELETE 결과건수: ' || vn_return);
	
	COMMIT;
	
END;   


TRUNCATE TABLE ch13_physicist;


-- DBMS_SQL을 이용한 INSERT 2
DECLARE
  -- DBMS_SQL 패키지에서 제공하는 컬렉션 타입 변수 선언 
  vn_ids_array   DBMS_SQL.NUMBER_TABLE;
  vs_name_array  DBMS_SQL.VARCHAR2_TABLE;
  vd_dt_array    DBMS_SQL.DATE_TABLE;
  
  vs_sql   VARCHAR2(1000);  
  
  -- DBMS_SQL 패키지 관련 변수
  vn_cur_id   NUMBER := DBMS_SQL.OPEN_CURSOR(); -- 커서를 연다
  vn_return   NUMBER;  

BEGIN
	-- 0. 입력할 값 설정
	vn_ids_array(1)  := 1;
	vs_name_array(1) := 'Galileo Galilei'; 
	vd_dt_array(1)   := TO_DATE('1564-02-15', 'YYYY-MM-DD');
	
	vn_ids_array(2)  := 2;
	vs_name_array(2) := 'Isaac Newton'; 
	vd_dt_array(2)   := TO_DATE('1643-01-04', 'YYYY-MM-DD');
	
	vn_ids_array(3)  := 3;
	vs_name_array(3) := 'Max Plank';
	vd_dt_array(3)   := TO_DATE('1858-04-23', 'YYYY-MM-DD');
	
	vn_ids_array(4)  := 4;
	vs_name_array(4) := 'Albert Einstein';
	vd_dt_array(4)   := TO_DATE('1879-03-14', 'YYYY-MM-DD');	
	
	
	-- 1. INSERT문 작성 
	vs_sql := 'INSERT INTO ch13_physicist VALUES (:a, :b, :c)';
	
  -- 2. 파싱
  DBMS_SQL.PARSE (vn_cur_id, vs_sql, DBMS_SQL.NATIVE);
  
  -- 3. 바인드 변수 연결 (BIND_VARIABLE 대신 BIND_ARRAY 사용)
  DBMS_SQL.BIND_ARRAY ( vn_cur_id, ':a', vn_ids_array);
  DBMS_SQL.BIND_ARRAY ( vn_cur_id, ':b', vs_name_array);
  DBMS_SQL.BIND_ARRAY ( vn_cur_id, ':c', vd_dt_array);
  
  -- 4. 쿼리실행
  vn_return := DBMS_SQL.EXECUTE (vn_cur_id);  
  
  -- 5. 커서 닫기
  DBMS_SQL.CLOSE_CURSOR (vn_cur_id);  
  --결과건수 출력
  DBMS_OUTPUT.PUT_LINE('결과건수: ' || vn_return);
	
	COMMIT;
	
END; 


-- DBMS_SQL을 이용한 UPDATE 2
DECLARE
  -- DBMS_SQL 패키지에서 제공하는 컬렉션 타입 변수 선언 
  vn_ids_array   DBMS_SQL.NUMBER_TABLE;
  vs_name_array  DBMS_SQL.VARCHAR2_TABLE;

  vs_sql   VARCHAR2(1000);  
  
  -- DBMS_SQL 패키지 관련 변수
  vn_cur_id   NUMBER := DBMS_SQL.OPEN_CURSOR(); -- 커서를 연다
  vn_return   NUMBER;  

BEGIN
	-- 0. 갱신할 값 설정
	vn_ids_array(1)  := 1;
	vs_name_array(1) := 'Albert Einstein';
	
	vn_ids_array(2)  := 2;
	vs_name_array(2) := 'Galileo Galilei'; 
	
	vn_ids_array(3)  := 3;
	vs_name_array(3) := 'Isaac Newton'; 

	vn_ids_array(4)  := 4;
	vs_name_array(4) := 'Max Plank';
	
	
	-- 1. UPDATE문 작성 
	vs_sql := 'UPDATE ch13_physicist SET names = :a WHERE ids = :b';
	
  -- 2. 파싱
  DBMS_SQL.PARSE (vn_cur_id, vs_sql, DBMS_SQL.NATIVE);
  
  -- 3. 바인드 변수 연결 (BIND_VARIABLE 대신 BIND_ARRAY 사용)
  DBMS_SQL.BIND_ARRAY ( vn_cur_id, ':a', vs_name_array);
  DBMS_SQL.BIND_ARRAY ( vn_cur_id, ':b', vn_ids_array);
  
  -- 4. 쿼리실행
  vn_return := DBMS_SQL.EXECUTE (vn_cur_id);  
  
  -- 5. 커서 닫기
  DBMS_SQL.CLOSE_CURSOR (vn_cur_id);  
  --결과건수 출력
  DBMS_OUTPUT.PUT_LINE('결과건수: ' || vn_return);
	
	COMMIT;
	
END; 


select ids, names
from ch13_physicist;


-- DBMS_SQ.TO_REFCURSOR 함수
DECLARE
  --출력용 변수 선언 
  vc_cur       SYS_REFCURSOR;
  va_emp_id    DBMS_SQL.NUMBER_TABLE;
  va_emp_name  DBMS_SQL.VARCHAR2_TABLE;
  
  vs_sql VARCHAR2(1000);
  
  -- 바인드 변수 선언과 값 설정
  vs_job      employees.job_id%TYPE := 'SA_REP';
  vn_sal      employees.salary%TYPE := 9000;
  vn_manager  employees.manager_id%TYPE := 148;
  
  -- DBMS_SQL 패키지 관련 변수
  vn_cur_id   NUMBER := DBMS_SQL.OPEN_CURSOR(); -- 커서를 연다
  vn_return   NUMBER;
BEGIN
	-- 1.SQL문을 변수에 담는다. (바인드 변수 앞에 : 를 붙인다)
	vs_sql := 'SELECT employee_id, emp_name
	            FROM employees 
	           WHERE job_id = :a 
	             AND salary < :b
	             AND manager_id = :c ';
	             
  -- 2. 파싱
  DBMS_SQL.PARSE (vn_cur_id, vs_sql, DBMS_SQL.NATIVE);
  
  -- 3. 바인드 변수 연결 (WHERE 절에 사용한 변수가 3개 이므로 각 변수별로 총 3회 호출)
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':a', vs_job);
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':b', vn_sal);
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':c', vn_manager);  
 
  -- 4. 쿼리실행
  vn_return := DBMS_SQL.EXECUTE (vn_cur_id);
  
  -- 5. DBMS_SQL.TO_REFCURSOR를 사용해 커서로 변환 
  vc_cur := DBMS_SQL.TO_REFCURSOR (vn_cur_id);
  
  -- 6. 변환한 커서를 사용해 결과를 패치하고 결과 출력
  FETCH vc_cur BULK COLLECT INTO va_emp_id, va_emp_name;
   
  FOR i IN 1 .. va_emp_id.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE(va_emp_id(i) || ' - ' || va_emp_name(i));
  END LOOP; 
  
  -- 7. 커서 닫기
  CLOSE vc_cur;
           
END;


-- 현장 노하우 

CREATE OR REPLACE PROCEDURE print_table( p_query IN VARCHAR2 )
IS
    l_theCursor     INTEGER DEFAULT DBMS_SQL.OPEN_CURSOR;
    l_columnValue   VARCHAR2(4000);
    l_status        INTEGER;
    l_descTbl       DBMS_SQL.DESC_TAB;
    l_colCnt        NUMBER;
BEGIN
    -- 쿼리구문 자체를 p_query 매개변수에 받아온다. 
    -- 받아온 쿼리를 파싱한다. 
    DBMS_SQL.PARSE(  l_theCursor,  p_query, DBMS_SQL.NATIVE );
    
    -- DESCRIBE_COLUMN 프로시저 : 커서에 대한 컬럼정보를 DBMS_SQL.DESC_TAB 형 변수에 넣는다. 
    DBMS_SQL.DESCRIBE_COLUMNS ( l_theCursor, l_colCnt, l_descTbl );

    -- 선택된 컬럼 개수만큼 루프를 돌며 DEFINE_COLUMN 프로시저를 호출해 컬럼을 정의한다. 
    FOR i IN 1..l_colCnt 
    LOOP
        DBMS_SQL.DEFINE_COLUMN (l_theCursor, i, l_columnValue, 4000);
    END LOOP;

    -- 실행 
    l_status := DBMS_SQL.EXECUTE(l_theCursor);

    WHILE ( DBMS_SQL.FETCH_ROWS (l_theCursor) > 0 ) 
    LOOP
        -- 컬럼 개수만큼 다시 루프를 돌면서 컬럼 값을 l_columnValue 변수에 담는다.
        -- DBMS_SQL.DESC_TAB 형 변수인 l_descTbl.COL_NAME은 컬럼 명칭이 있고 
        -- l_columnValue에는 컬럼 값이 들어있다. 
        FOR i IN 1..l_colCnt 
        LOOP
          DBMS_SQL.COLUMN_VALUE ( l_theCursor, i, l_columnValue );
          DBMS_OUTPUT.PUT_LINE  ( rpad( l_descTbl(i).COL_NAME, 30 ) || ': ' || l_columnValue );
        END LOOP;
        DBMS_OUTPUT.PUT_LINE( '-----------------' );
    END LOOP;
    
    DBMS_SQL.CLOSE_CURSOR (l_theCursor);

END;


EXEC print_table ( 'SELECT * FROM ch13_physicist');


CREATE OR REPLACE PROCEDURE insert_ddl ( p_table IN VARCHAR2 )
IS
    l_theCursor     INTEGER DEFAULT DBMS_SQL.OPEN_CURSOR;
    l_status        INTEGER;
    l_descTbl       DBMS_SQL.DESC_TAB;
    l_colCnt        NUMBER;   
    
    v_sel_sql       VARCHAR2(1000);  -- SELECT 문장
    v_ins_sql       VARCHAR2(1000);  -- INSERT 문장
BEGIN
	  -- 입력받은 테이블명으로 SELECT 쿼리를 만든다. 
    v_sel_sql := 'SELECT * FROM ' || p_table || ' WHERE ROWNUM = 1';


    -- 받아온 쿼리를 파싱한다. 
    DBMS_SQL.PARSE(  l_theCursor,  v_sel_sql, DBMS_SQL.NATIVE );
    
    -- DESCRIBE_COLUMN 프로시저 : 커서에 대한 컬럼정보를 DBMS_SQL.DESC_TAB 형 변수에 넣는다. 
    DBMS_SQL.DESCRIBE_COLUMNS ( l_theCursor, l_colCnt, l_descTbl );

    -- INSERT문 쿼리를 만든다. 
    v_ins_sql := 'INSERT INTO ' || p_table || ' ( ';   

    FOR i IN 1..l_colCnt 
    LOOP
      -- 맨 마지막 컬럼에 오면 끝에 괄호를 붙인다. 
      IF i = l_colCnt THEN        
        v_ins_sql := v_ins_sql || l_descTbl(i).COL_NAME || ' )';     
      ELSE -- 루프를 돌며 '컬러명,' 형태로 만든다. 
        v_ins_sql := v_ins_sql || l_descTbl(i).COL_NAME || ', ';      
      END IF;
    END LOOP;
  
    DBMS_OUTPUT.PUT_LINE ( v_ins_sql );
    
    DBMS_SQL.CLOSE_CURSOR (l_theCursor);

END;

EXEC insert_ddl ( 'ch13_physicist');

EXEC insert_ddl ( 'CUSTOMERS');