-- 예외처리구문

DECLARE 
   vi_num NUMBER := 0;
BEGIN
	
	 vi_num := 10 / 0;
	 
	 DBMS_OUTPUT.PUT_LINE('Success!');
	 
END;



DECLARE 
   vi_num NUMBER := 0;
BEGIN
	
	 vi_num := 10 / 0;
	 
	 DBMS_OUTPUT.PUT_LINE('Success!');
	 
EXCEPTION WHEN OTHERS THEN
	 
	 DBMS_OUTPUT.PUT_LINE('오류가 발생했습니다');	
END;


CREATE OR REPLACE PROCEDURE ch10_no_exception_proc 
IS
  vi_num NUMBER := 0;
BEGIN
	vi_num := 10 / 0;
	 
	DBMS_OUTPUT.PUT_LINE('Success!');
	
END;	


CREATE OR REPLACE PROCEDURE ch10_exception_proc 
IS
  vi_num NUMBER := 0;
BEGIN
	vi_num := 10 / 0;
	 
	DBMS_OUTPUT.PUT_LINE('Success!');
	
EXCEPTION WHEN OTHERS THEN
	 
	 DBMS_OUTPUT.PUT_LINE('오류가 발생했습니다');		
	
END;	


DECLARE 
   vi_num NUMBER := 0;
BEGIN
	
	 ch10_no_exception_proc;
	 	 
	 DBMS_OUTPUT.PUT_LINE('Success!');

END;

DECLARE 
   vi_num NUMBER := 0;
BEGIN
	
	 ch10_exception_proc;
	 	 
	 DBMS_OUTPUT.PUT_LINE('Success!');

END;


-- SQLCODE, SQLERRM을 이용한 예외정보 참조

CREATE OR REPLACE PROCEDURE ch10_exception_proc 
IS
  vi_num NUMBER := 0;
BEGIN
	vi_num := 10 / 0;
	 
	DBMS_OUTPUT.PUT_LINE('Success!');
	
EXCEPTION WHEN OTHERS THEN
	 
 DBMS_OUTPUT.PUT_LINE('오류가 발생했습니다');		
 DBMS_OUTPUT.PUT_LINE( 'SQL ERROR CODE: ' || SQLCODE);
 DBMS_OUTPUT.PUT_LINE( 'SQL ERROR MESSAGE: ' || SQLERRM); -- 매개변수 없는 SQLERRM
 DBMS_OUTPUT.PUT_LINE( SQLERRM(SQLCODE)); -- 매개변수 있는 SQLERRM

	
END;	

EXEC ch10_exception_proc;


CREATE OR REPLACE PROCEDURE ch10_exception_proc 
IS
  vi_num NUMBER := 0;
BEGIN
	vi_num := 10 / 0;
	 
	DBMS_OUTPUT.PUT_LINE('Success!');
	
EXCEPTION WHEN OTHERS THEN
	 
 DBMS_OUTPUT.PUT_LINE('오류가 발생했습니다');		
 DBMS_OUTPUT.PUT_LINE( 'SQL ERROR CODE: ' || SQLCODE);
 DBMS_OUTPUT.PUT_LINE( 'SQL ERROR MESSAGE: ' || SQLERRM); 
 
 DBMS_OUTPUT.PUT_LINE( DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	
END;	


-- 시스템 예외 

CREATE OR REPLACE PROCEDURE ch10_exception_proc 
IS
  vi_num NUMBER := 0;
BEGIN
	vi_num := 10 / 0;
	 
	DBMS_OUTPUT.PUT_LINE('Success!');
	
EXCEPTION WHEN ZERO_DIVIDE THEN
	 
	 DBMS_OUTPUT.PUT_LINE('오류가 발생했습니다');		
	 DBMS_OUTPUT.PUT_LINE('SQL ERROR CODE: ' || SQLCODE);
	 DBMS_OUTPUT.PUT_LINE('SQL ERROR MESSAGE: ' || SQLERRM);
	
END;	

EXEC ch10_exception_proc;



CREATE OR REPLACE PROCEDURE ch10_exception_proc 
IS
  vi_num NUMBER := 0;
BEGIN
	vi_num := 10 / 0;
	 
	DBMS_OUTPUT.PUT_LINE('Success!');
	
EXCEPTION WHEN ZERO_DIVIDE THEN
	          	 DBMS_OUTPUT.PUT_LINE('오류1');		
	             DBMS_OUTPUT.PUT_LINE('SQL ERROR MESSAGE1: ' || SQLERRM);
	        WHEN OTHERS THEN
	          	 DBMS_OUTPUT.PUT_LINE('오류2');		
	             DBMS_OUTPUT.PUT_LINE('SQL ERROR MESSAGE2: ' || SQLERRM);	
END;	

EXEC ch10_exception_proc;


CREATE OR REPLACE PROCEDURE ch10_upd_jobid_proc 
                  ( p_employee_id employees.employee_id%TYPE,
                    p_job_id      jobs.job_id%TYPE )
IS
  vn_cnt NUMBER := 0;
BEGIN
	
	SELECT COUNT(*)
	  INTO vn_cnt
	  FROM JOBS
	 WHERE JOB_ID = p_job_id;
	 
	IF vn_cnt = 0 THEN
	   DBMS_OUTPUT.PUT_LINE('job_id가 없습니다');
	   RETURN;
	ELSE
	   UPDATE employees
	      SET job_id = p_job_id
	    WHERE employee_id = p_employee_id;
	
  END IF;
  
  COMMIT;
	
END;

EXEC ch10_upd_jobid_proc (200, 'SM_JOB2');



CREATE OR REPLACE PROCEDURE ch10_upd_jobid_proc 
                  ( p_employee_id employees.employee_id%TYPE,
                    p_job_id      jobs.job_id%TYPE )
IS
  vn_cnt NUMBER := 0;
BEGIN
	
	SELECT 1
	  INTO vn_cnt
	  FROM JOBS
	 WHERE JOB_ID = p_job_id;
	 
   UPDATE employees
      SET job_id = p_job_id
    WHERE employee_id = p_employee_id;
	
  COMMIT;
  
  EXCEPTION WHEN NO_DATA_FOUND THEN
                 DBMS_OUTPUT.PUT_LINE(SQLERRM);
                 DBMS_OUTPUT.PUT_LINE(p_job_id ||'에 해당하는 job_id가 없습니다');
            WHEN OTHERS THEN
                 DBMS_OUTPUT.PUT_LINE('기타 에러: ' || SQLERRM);
END;
                   

EXEC ch10_upd_jobid_proc (200, 'SM_JOB2');


CREATE OR REPLACE PROCEDURE ch10_upd_jobid_proc 
                  ( p_employee_id employees.employee_id%TYPE,
                    p_job_id      jobs.job_id%TYPE)
IS
  vn_cnt NUMBER := 0;
BEGIN
	
	SELECT 1
	  INTO vn_cnt
	  FROM JOBS
	 WHERE JOB_ID = p_job_id;
	 
   UPDATE employees
      SET job_id = p_job_id
    WHERE employee_id = p_employee_id;
	
  COMMIT;
  
  EXCEPTION WHEN NO_DATA_FOUND THEN
                 DBMS_OUTPUT.PUT_LINE(SQLERRM);
                 DBMS_OUTPUT.PUT_LINE(p_job_id ||'에 해당하는 job_id가 없습니다');
            WHEN OTHERS THEN
                 DBMS_OUTPUT.PUT_LINE('기타 에러: ' || SQLERRM);
END;

-- 사용자 정의 예외

CREATE OR REPLACE PROCEDURE ch10_ins_emp_proc ( 
                  p_emp_name       employees.emp_name%TYPE,
                  p_department_id  departments.department_id%TYPE )
IS
   vn_employee_id  employees.employee_id%TYPE;
   vd_curr_date    DATE := SYSDATE;
   vn_cnt          NUMBER := 0;
   
   ex_invalid_depid EXCEPTION; -- 잘못된 부서번호일 경우 예외 정의
BEGIN
	
	 -- 부서테이블에서 해당 부서번호 존재유무 체크
	 SELECT COUNT(*)
	   INTO vn_cnt
	   FROM departments
	  WHERE department_id = p_department_id;
	  
	 IF vn_cnt = 0 THEN
	    RAISE ex_invalid_depid; -- 사용자 정의 예외 발생
	 END IF;
	 
	 -- employee_id의 max 값에 +1
	 SELECT MAX(employee_id) + 1
	   INTO vn_employee_id
	   FROM employees;
	 
	 -- 사용자예외처리 예제이므로 사원 테이블에 최소한 데이터만 입력함
	 INSERT INTO employees ( employee_id, emp_name, hire_date, department_id )
              VALUES ( vn_employee_id, p_emp_name, vd_curr_date, p_department_id );
              
   COMMIT;              
              
EXCEPTION WHEN ex_invalid_depid THEN -- 사용자 정의 예외 처리
               DBMS_OUTPUT.PUT_LINE('해당 부서번호가 없습니다');
          WHEN OTHERS THEN
               DBMS_OUTPUT.PUT_LINE(SQLERRM);              
	
END;                	


EXEC ch10_ins_emp_proc ('홍길동', 999);


CREATE OR REPLACE PROCEDURE ch10_ins_emp_proc ( 
                  p_emp_name       employees.emp_name%TYPE,
                  p_department_id  departments.department_id%TYPE,
                  p_hire_month  VARCHAR2  )
IS
   vn_employee_id  employees.employee_id%TYPE;
   vd_curr_date    DATE := SYSDATE;
   vn_cnt          NUMBER := 0;
   
   ex_invalid_depid EXCEPTION; -- 잘못된 부서번호일 경우 예외 정의
   
   ex_invalid_month EXCEPTION; -- 잘못된 입사월인 경우 예외 정의
   PRAGMA EXCEPTION_INIT ( ex_invalid_month, -1843); -- 예외명과 예외코드 연결
BEGIN
	
	 -- 부서테이블에서 해당 부서번호 존재유무 체크
	 SELECT COUNT(*)
	   INTO vn_cnt
	   FROM departments
	  WHERE department_id = p_department_id;
	  
	 IF vn_cnt = 0 THEN
	    RAISE ex_invalid_depid; -- 사용자 정의 예외 발생
	 END IF;
	 
	 -- 입사월 체크 (1~12월 범위를 벗어났는지 체크)
	 IF SUBSTR(p_hire_month, 5, 2) NOT BETWEEN '01' AND '12' THEN
	    RAISE ex_invalid_month; -- 사용자 정의 예외 발생
	 
	 END IF;
	 
	 
	 -- employee_id의 max 값에 +1
	 SELECT MAX(employee_id) + 1
	   INTO vn_employee_id
	   FROM employees;
	 
	 -- 사용자예외처리 예제이므로 사원 테이블에 최소한 데이터만 입력함
	 INSERT INTO employees ( employee_id, emp_name, hire_date, department_id )
              VALUES ( vn_employee_id, p_emp_name, TO_DATE(p_hire_month || '01'), p_department_id );
              
   COMMIT;              
              
EXCEPTION WHEN ex_invalid_depid THEN -- 사용자 정의 예외 처리
               DBMS_OUTPUT.PUT_LINE('해당 부서번호가 없습니다');
          WHEN ex_invalid_month THEN -- 입사월 사용자 정의 예외 처리
               DBMS_OUTPUT.PUT_LINE(SQLCODE);
               DBMS_OUTPUT.PUT_LINE(SQLERRM);
               DBMS_OUTPUT.PUT_LINE('1~12월 범위를 벗어난 월입니다');               
          WHEN OTHERS THEN
               DBMS_OUTPUT.PUT_LINE(SQLERRM);              
	
END;    

EXEC ch10_ins_emp_proc ('홍길동', 110, '201314');


-- RAISE와 RAISE_APPLICATOIN_ERROR

CREATE OR REPLACE PROCEDURE ch10_raise_test_proc ( p_num NUMBER)
IS

BEGIN
	IF p_num <= 0 THEN
	   RAISE INVALID_NUMBER;
  END IF;
  
  DBMS_OUTPUT.PUT_LINE(p_num);
  
EXCEPTION WHEN INVALID_NUMBER THEN
               DBMS_OUTPUT.PUT_LINE('양수만 입력받을 수 있습니다');
          WHEN OTHERS THEN
               DBMS_OUTPUT.PUT_LINE(SQLERRM);
	
END;

EXEC ch10_raise_test_proc (-10);               



CREATE OR REPLACE PROCEDURE ch10_raise_test_proc ( p_num NUMBER)
IS

BEGIN
	IF p_num <= 0 THEN
	   --RAISE INVALID_NUMBER;
	   RAISE_APPLICATION_ERROR (-20000, '양수만 입력받을 수 있단 말입니다!');
  END IF;
  
  DBMS_OUTPUT.PUT_LINE(p_num);
  
EXCEPTION WHEN INVALID_NUMBER THEN
               DBMS_OUTPUT.PUT_LINE('양수만 입력받을 수 있습니다');
          WHEN OTHERS THEN
               DBMS_OUTPUT.PUT_LINE(SQLCODE);
               DBMS_OUTPUT.PUT_LINE(SQLERRM);
	
END;

EXEC ch10_raise_test_proc (-10);               



-- 현장 노하우

CREATE TABLE error_log (
             error_seq     NUMBER,        -- 에러 시퀀스
             prog_name     VARCHAR2(80),  -- 프로그램명
             error_code    NUMBER,        -- 에러코드
             error_message VARCHAR2(300), -- 에러 메시지
             error_line    VARCHAR2(100), -- 에러 라인
             error_date    DATE DEFAULT SYSDATE -- 에러발생일자
             );
             
CREATE SEQUENCE error_seq
INCREMENT BY 1
START WITH 1
MINVALUE 1
MAXVALUE 999999
NOCYCLE
NOCACHE;

CREATE OR REPLACE PROCEDURE error_log_proc (
                  p_prog_name      error_log.prog_name%TYPE,
                  p_error_code     error_log.error_code%TYPE,
                  p_error_messgge  error_log.error_message%TYPE,
                  p_error_line     error_log.error_line%TYPE  )
IS

BEGIN
	
	INSERT INTO error_log (error_seq, prog_name, error_code, error_message, error_line)
	VALUES ( error_seq.NEXTVAL, p_prog_name, p_error_code, p_error_messgge, p_error_line );
	
	COMMIT;
	
END;                  


CREATE OR REPLACE PROCEDURE ch10_ins_emp2_proc ( 
                  p_emp_name       employees.emp_name%TYPE,
                  p_department_id  departments.department_id%TYPE,
                  p_hire_month     VARCHAR2 )
IS
   vn_employee_id  employees.employee_id%TYPE;
   vd_curr_date    DATE := SYSDATE;
   vn_cnt          NUMBER := 0;
   
   ex_invalid_depid EXCEPTION; -- 잘못된 부서번호일 경우 예외 정의
   PRAGMA EXCEPTION_INIT ( ex_invalid_depid, -20000); -- 예외명과 예외코드 연결

   ex_invalid_month EXCEPTION; -- 잘못된 입사월인 경우 예외 정의
   PRAGMA EXCEPTION_INIT ( ex_invalid_month, -1843); -- 예외명과 예외코드 연결
   
   v_err_code error_log.error_code%TYPE;
   v_err_msg  error_log.error_message%TYPE;
   v_err_line error_log.error_line%TYPE;
BEGIN
 -- 부서테이블에서 해당 부서번호 존재유무 체크
 SELECT COUNT(*)
   INTO vn_cnt
   FROM departments
  WHERE department_id = p_department_id;
	  
 IF vn_cnt = 0 THEN
    RAISE ex_invalid_depid; -- 사용자 정의 예외 발생
 END IF;

-- 입사월 체크 (1~12월 범위를 벗어났는지 체크)
 IF SUBSTR(p_hire_month, 5, 2) NOT BETWEEN '01' AND '12' THEN
    RAISE ex_invalid_month; -- 사용자 정의 예외 발생
 END IF;

 -- employee_id의 max 값에 +1
 SELECT MAX(employee_id) + 1
   INTO vn_employee_id
   FROM employees;
 
-- 사용자예외처리 예제이므로 사원 테이블에 최소한 데이터만 입력함
INSERT INTO employees ( employee_id, emp_name, hire_date, department_id )
            VALUES ( vn_employee_id, p_emp_name, TO_DATE(p_hire_month || '01'), p_department_id );              
 COMMIT;

EXCEPTION WHEN ex_invalid_depid THEN -- 사용자 정의 예외 처리
               v_err_code := SQLCODE;
               v_err_msg  := '해당 부서가 없습니다';
               v_err_line := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
               ROLLBACK;
               error_log_proc ( 'ch10_ins_emp2_proc', v_err_code, v_err_msg, v_err_line); 
          WHEN ex_invalid_month THEN -- 입사월 사용자 정의 예외 처리
               v_err_code := SQLCODE;
               v_err_msg  := SQLERRM;
               v_err_line := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
               ROLLBACK;
               error_log_proc ( 'ch10_ins_emp2_proc', v_err_code, v_err_msg, v_err_line); 
          WHEN OTHERS THEN
               v_err_code := SQLCODE;
               v_err_msg  := SQLERRM;
               v_err_line := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
               ROLLBACK;  
               error_log_proc ( 'ch10_ins_emp2_proc', v_err_code, v_err_msg, v_err_line);        	
END;


EXEC ch10_ins_emp2_proc ('HONG', 1000, '201401'); -- 잘못된 부서

EXEC ch10_ins_emp2_proc ('HONG', 100, '201413'); -- 잘못된 월


SELECT *
  FROM  error_log ;
  
  

CREATE TABLE app_user_define_error (
             error_code    NUMBER,         -- 에러코드
             error_message VARCHAR2(300),  -- 에러 메시지
             create_date   DATE DEFAULT SYSDATE, -- 등록일자 
             PRIMARY KEY (error_code)
             );
             
             
INSERT INTO app_user_define_error ( error_code, error_message ) VALUES (-1843, '지정한 월이 부적합합니다');
INSERT INTO app_user_define_error ( error_code, error_message ) VALUES (-20000, '해당 부서가 없습니다');

COMMIT;
             
             
CREATE OR REPLACE PROCEDURE error_log_proc (
                  p_prog_name      error_log.prog_name%TYPE,
                  p_error_code     error_log.error_code%TYPE,
                  p_error_messgge  error_log.error_message%TYPE,
                  p_error_line     error_log.error_line%TYPE  )
IS
  vn_error_code     error_log.error_code%TYPE    := p_error_code;
  vn_error_message  error_log.error_message%TYPE := p_error_messgge;
  
BEGIN
	
	-- 사용자 정의 에러 테이블에서 에러 메시지를 받아오는 부분을 BLOCK으로 감싼다.
	-- 해당 메시지가 없을 경우 처리를 위해서....
	BEGIN
	  -- 
	  SELECT error_message 
	    INTO vn_error_message
	    FROM app_user_define_error 
	   WHERE error_code = vn_error_code;
	 
   	-- 해당 에러가 테이블에 없다면 매개변수로 받아온 메시지를 그대로 할당한다. 
	  EXCEPTION WHEN NO_DATA_FOUND THEN
	               vn_error_message :=  p_error_messgge;
	
  END;
	
	INSERT INTO error_log (error_seq, prog_name, error_code, error_message, error_line)
	VALUES ( error_seq.NEXTVAL, p_prog_name, vn_error_code, vn_error_message, p_error_line );
	
	COMMIT;
	
END;                 


CREATE OR REPLACE PROCEDURE ch10_ins_emp2_proc ( 
                  p_emp_name       employees.emp_name%TYPE,
                  p_department_id  departments.department_id%TYPE,
                  p_hire_month     VARCHAR2 )
IS
   vn_employee_id  employees.employee_id%TYPE;
   vd_curr_date    DATE := SYSDATE;
   vn_cnt          NUMBER := 0;
   
   ex_invalid_depid EXCEPTION; -- 잘못된 부서번호일 경우 예외 정의
   PRAGMA EXCEPTION_INIT ( ex_invalid_depid, -20000); -- 예외명과 예외코드 연결

   ex_invalid_month EXCEPTION; -- 잘못된 입사월인 경우 예외 정의
   PRAGMA EXCEPTION_INIT ( ex_invalid_month, -1843); -- 예외명과 예외코드 연결
   
  -- 예외 관련 변수 선언
   v_err_code error_log.error_code%TYPE;
   v_err_msg  error_log.error_message%TYPE;
   v_err_line error_log.error_line%TYPE;
BEGIN
 -- 부서테이블에서 해당 부서번호 존재유무 체크
 SELECT COUNT(*)
   INTO vn_cnt
   FROM departments
  WHERE department_id = p_department_id;
	  
 IF vn_cnt = 0 THEN
    RAISE ex_invalid_depid; -- 사용자 정의 예외 발생
 END IF;

-- 입사월 체크 (1~12월 범위를 벗어났는지 체크)
 IF SUBSTR(p_hire_month, 5, 2) NOT BETWEEN '01' AND '12' THEN
    RAISE ex_invalid_month; -- 사용자 정의 예외 발생
 END IF;

 -- employee_id의 max 값에 +1
 SELECT MAX(employee_id) + 1
   INTO vn_employee_id
   FROM employees;
 
-- 사용자예외처리 예제이므로 사원 테이블에 최소한 데이터만 입력함
INSERT INTO employees ( employee_id, emp_name, hire_date, department_id )
            VALUES ( vn_employee_id, p_emp_name, TO_DATE(p_hire_month || '01'), p_department_id );              
 COMMIT;

EXCEPTION WHEN ex_invalid_depid THEN -- 사용자 정의 예외 처리
               v_err_code := SQLCODE;
               v_err_line := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
               ROLLBACK;
               error_log_proc ( 'ch10_ins_emp2_proc', v_err_code, v_err_msg, v_err_line); 
          WHEN ex_invalid_month THEN -- 입사월 사용자 정의 예외 처리
               v_err_code := SQLCODE;
               v_err_line := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
               ROLLBACK;
               error_log_proc ( 'ch10_ins_emp2_proc', v_err_code, v_err_msg, v_err_line); 
          WHEN OTHERS THEN
               v_err_code := SQLCODE;
               v_err_msg  := SQLERRM;
               v_err_line := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
               ROLLBACK;  
               error_log_proc ( 'ch10_ins_emp2_proc', v_err_code, v_err_msg, v_err_line);        	
END;

-- 잘못된 부서
EXEC ch10_ins_emp2_proc ('HONG', 1000, '201401');
 
-- 잘못된 월
EXEC ch10_ins_emp2_proc ('HONG', 100, '201413'); 


SELECT *
  FROM  error_log ;



-- COMMIT 과 ROLLBACK

CREATE TABLE ch10_sales (
       sales_month   VARCHAR2(8),
       country_name  VARCHAR2(40),
       prod_category VARCHAR2(50),
       channel_desc  VARCHAR2(20),
       sales_amt     NUMBER );
       
       
CREATE OR REPLACE PROCEDURE iud_ch10_sales_proc 
            ( p_sales_month ch10_sales.sales_month%TYPE )
IS

BEGIN
	INSERT INTO ch10_sales (sales_month, country_name, prod_category, channel_desc, sales_amt)
	SELECT A.SALES_MONTH, 
       C.COUNTRY_NAME, 
       D.PROD_CATEGORY,
       E.CHANNEL_DESC,
       SUM(A.AMOUNT_SOLD)
  FROM SALES A, CUSTOMERS B, COUNTRIES C, PRODUCTS D, CHANNELS E
 WHERE A.SALES_MONTH = p_sales_month
   AND A.CUST_ID = B.CUST_ID
   AND B.COUNTRY_ID = C.COUNTRY_ID
   AND A.PROD_ID = D.PROD_ID
   AND A.CHANNEL_ID = E.CHANNEL_ID
 GROUP BY A.SALES_MONTH, 
         C.COUNTRY_NAME, 
       D.PROD_CATEGORY,
       E.CHANNEL_DESC;
	
END;            

EXEC iud_ch10_sales_proc ( '199901');

SELECT COUNT(*)
FROM ch10_sales ;


CREATE OR REPLACE PROCEDURE iud_ch10_sales_proc 
            ( p_sales_month ch10_sales.sales_month%TYPE )
IS

BEGIN
	INSERT INTO ch10_sales (sales_month, country_name, prod_category, channel_desc, sales_amt)	   
	SELECT A.SALES_MONTH, 
       C.COUNTRY_NAME, 
       D.PROD_CATEGORY,
       E.CHANNEL_DESC,
       SUM(A.AMOUNT_SOLD)
  FROM SALES A, CUSTOMERS B, COUNTRIES C, PRODUCTS D, CHANNELS E
 WHERE A.SALES_MONTH = p_sales_month
   AND A.CUST_ID = B.CUST_ID
   AND B.COUNTRY_ID = C.COUNTRY_ID
   AND A.PROD_ID = D.PROD_ID
   AND A.CHANNEL_ID = E.CHANNEL_ID
 GROUP BY A.SALES_MONTH, 
         C.COUNTRY_NAME, 
       D.PROD_CATEGORY,
       E.CHANNEL_DESC;
       
 COMMIT;
 --ROLLBACK;
	
END;         

TRUNCATE TABLE ch10_sales;

EXEC iud_ch10_sales_proc ( '199901');

SELECT COUNT(*)
FROM ch10_sales ;


TRUNCATE TABLE ch10_sales;


ALTER TABLE ch10_sales ADD CONSTRAINTS pk_ch10_sales PRIMARY KEY (sales_month, country_name, prod_category, channel_desc);



CREATE OR REPLACE PROCEDURE iud_ch10_sales_proc 
            ( p_sales_month ch10_sales.sales_month%TYPE )
IS

BEGIN
	
	INSERT INTO ch10_sales (sales_month, country_name, prod_category, channel_desc, sales_amt)	   
	SELECT A.SALES_MONTH, 
       C.COUNTRY_NAME, 
       D.PROD_CATEGORY,
       E.CHANNEL_DESC,
       SUM(A.AMOUNT_SOLD)
  FROM SALES A, CUSTOMERS B, COUNTRIES C, PRODUCTS D, CHANNELS E
 WHERE A.SALES_MONTH = p_sales_month
   AND A.CUST_ID = B.CUST_ID
   AND B.COUNTRY_ID = C.COUNTRY_ID
   AND A.PROD_ID = D.PROD_ID
   AND A.CHANNEL_ID = E.CHANNEL_ID
 GROUP BY A.SALES_MONTH, 
         C.COUNTRY_NAME, 
       D.PROD_CATEGORY,
       E.CHANNEL_DESC;
       
 COMMIT;

EXCEPTION WHEN OTHERS THEN
               DBMS_OUTPUT.PUT_LINE(SQLERRM);
               ROLLBACK;
	
END;   

EXEC iud_ch10_sales_proc ( '199901');

SELECT COUNT(*)
FROM ch10_sales ;


CREATE TABLE ch10_country_month_sales (
               sales_month   VARCHAR2(8),
               country_name  VARCHAR2(40),
               sales_amt     NUMBER,
               PRIMARY KEY (sales_month, country_name) );
              



CREATE OR REPLACE PROCEDURE iud_ch10_sales_proc 
            ( p_sales_month  ch10_sales.sales_month%TYPE, 
              p_country_name ch10_sales.country_name%TYPE )
IS

BEGIN
	
	--기존 데이터 삭제
	DELETE ch10_sales
	 WHERE sales_month  = p_sales_month
	   AND country_name = p_country_name;
	   
	   
	-- 신규로 월, 국가를 매개변수로 받아 INSERT 
	-- DELETE를 수행하므로 PRIMARY KEY 중복이 발생치 않음
	INSERT INTO ch10_sales (sales_month, country_name, prod_category, channel_desc, sales_amt)	   
	SELECT A.SALES_MONTH, 
       C.COUNTRY_NAME, 
       D.PROD_CATEGORY,
       E.CHANNEL_DESC,
       SUM(A.AMOUNT_SOLD)
  FROM SALES A, CUSTOMERS B, COUNTRIES C, PRODUCTS D, CHANNELS E
 WHERE A.SALES_MONTH  = p_sales_month
   AND C.COUNTRY_NAME = p_country_name
   AND A.CUST_ID = B.CUST_ID
   AND B.COUNTRY_ID = C.COUNTRY_ID
   AND A.PROD_ID = D.PROD_ID
   AND A.CHANNEL_ID = E.CHANNEL_ID
 GROUP BY A.SALES_MONTH, 
         C.COUNTRY_NAME, 
       D.PROD_CATEGORY,
       E.CHANNEL_DESC;
       
 -- SAVEPOINT 확인을 위한 UPDATE
  -- 현재시간에서 초를 가져와 숫자로 변환한 후 * 10 (매번 초는 달라지므로 성공적으로 실행 시 이 값은 매번 달라짐)
 UPDATE ch10_sales
    SET sales_amt = 10 * to_number(to_char(sysdate, 'ss'))
  WHERE sales_month  = p_sales_month
	   AND country_name = p_country_name;
	   
 -- SAVEPOINT 지정      
 SAVEPOINT mysavepoint;      
 
 
 -- ch10_country_month_sales 테이블에 INSERT
 -- 중복 입력 시 PRIMARY KEY 중복됨
 INSERT INTO ch10_country_month_sales 
       SELECT sales_month, country_name, SUM(sales_amt)
         FROM ch10_sales
        WHERE sales_month  = p_sales_month
	        AND country_name = p_country_name
	      GROUP BY sales_month, country_name;         
       
 COMMIT;

EXCEPTION WHEN OTHERS THEN
               DBMS_OUTPUT.PUT_LINE(SQLERRM);
               ROLLBACK TO mysavepoint; -- SAVEPOINT 까지만 ROLLBACK
               COMMIT; -- SAVEPOINT 이전까지는 COMMIT

	
END;   

TRUNCATE TABLE ch10_sales;

EXEC iud_ch10_sales_proc ( '199901', 'Italy');

SELECT DISTINCT sales_amt
FROM ch10_sales;



EXEC iud_ch10_sales_proc ( '199901', 'Italy');

SELECT DISTINCT sales_amt
FROM ch10_sales;


