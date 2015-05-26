--
  
1. 다음과 같이 부서테이블의 복사본을 만든다. 

CREATE TABLE ch10_departments 
AS
SELECT department_id, department_name 
  FROM departments;
  
  
ALTER TABLE ch10_departments ADD CONSTRAINTS pk_ch10_departments PRIMARY KEY (department_id);  
  
  
부서번호, 부서명, 작업 flag(I: insert, U:update, D:delete)을 매개변수로 받아 ch10_departments 테이블에 
각각 INSERT, UPDATE, DELETE 하는 ch10_iud_dep_proc 란 이름의 프로시저를 만들어보자.

<정답>

CREATE OR REPLACE PROCEDURE ch10_iud_dep_proc (
                    p_department_id    ch10_departments.department_id%TYPE,
                    p_department_name  ch10_departments.department_name%TYPE,
                    p_flag             VARCHAR2 )
IS

BEGIN
	
	IF p_flag = 'I' THEN
	   
	   INSERT INTO ch10_departments
	          VALUES ( p_department_id, p_department_name);
	  
	ELSIF p_flag = 'U' THEN
	
	   UPDATE ch10_departments
	      SET department_name = p_department_name
	    WHERE department_id   = p_department_id;
	
	
	ELSIF p_flag = 'D' THEN
	
	   DELETE ch10_departments
	    WHERE department_id   = p_department_id;
	
	
  END IF;
  
  COMMIT;
	
END;                       


2. 다음과 같이 프로시저를 실행해 보고 결과가 어떻게 나왔는지 그 이유를 설명하라. 

   EXEC ch10_iud_dep_proc (10, '총무기획부', 'I');
   
<정답>
ch10_departments 테이블은 department_id가 PRIMARY KEY인데 이미 존재하는 10번 부서에 대해 INSERT 작업을 하므로
시스템 오류(무결성 제약조건 위반)가 발생한다. 


3. ch10_iud_dep_proc 에서 시스템 예외 처리 로직을 추가해 보자. 예외가 발생할 경우 ROLLBACK 하도록 한다. 그리고 2번 문제의 프로시저를 실행해보고 결과를 확인해보자. 

<정답>

CREATE OR REPLACE PROCEDURE ch10_iud_dep_proc (
                    p_department_id    ch10_departments.department_id%TYPE,
                    p_department_name  ch10_departments.department_name%TYPE,
                    p_flag             VARCHAR2 )
IS

BEGIN
	
	IF p_flag = 'I' THEN
	   
	   INSERT INTO ch10_departments
	          VALUES ( p_department_id, p_department_name);
	  
	ELSIF p_flag = 'U' THEN
	
	   UPDATE ch10_departments
	      SET department_name = p_department_name
	    WHERE department_id   = p_department_id;
	
	
	ELSIF p_flag = 'D' THEN
	
	   DELETE ch10_departments
	    WHERE department_id   = p_department_id;
	
	
  END IF;
  
  COMMIT;
  
  EXCEPTION WHEN OTHERS THEN
                 DBMS_OUTPUT.PUT_LINE(SQLCODE);
                 DBMS_OUTPUT.PUT_LINE(SQLERRM);
                 ROLLBACK;
	
END;   


4. ch10_iud_dep_proc에서 부서를 삭제 시, 사원테이블을 검색해 해당 부서에 할당된 사원이 있는 경우,
   삭제할 수 없다는 메시지와 함께 이를 사용자 정의 예외로 구현해보자. 
   
<정답>

CREATE OR REPLACE PROCEDURE ch10_iud_dep_proc (
                    p_department_id    ch10_departments.department_id%TYPE,
                    p_department_name  ch10_departments.department_name%TYPE,
                    p_flag             VARCHAR2 )
IS
  vn_cnt         NUMBER := 0;
  dept_exception EXCEPTION;
BEGIN
	
	IF p_flag = 'I' THEN
	   
	   INSERT INTO ch10_departments
	          VALUES ( p_department_id, p_department_name);
	  
	ELSIF p_flag = 'U' THEN
	
	   UPDATE ch10_departments
	      SET department_name = p_department_name
	    WHERE department_id   = p_department_id;
	
	
	ELSIF p_flag = 'D' THEN
	   
	  SELECT COUNT(*)
	    INTO vn_cnt 
	    FROM employees
	   WHERE department_id = p_department_id;
	   
	  IF vn_cnt > 0 THEN
	     RAISE dept_exception;
	  
	  END IF;
	
	  DELETE ch10_departments
	   WHERE department_id   = p_department_id;
	
	
  END IF;
  
  COMMIT;
  
  EXCEPTION WHEN dept_exception THEN
                 DBMS_OUTPUT.PUT_LINE('해당 부서에 할당된 사원이 존재해 삭제할 수 없습니다!');
                 ROLLBACK;
  
            WHEN OTHERS THEN
                 DBMS_OUTPUT.PUT_LINE(SQLCODE);
                 DBMS_OUTPUT.PUT_LINE(SQLERRM);
                 ROLLBACK;
	
END;      


5. 4번에서 작성한 로직을 동일한 사용자 정의 예외로 처리하는데, 이번에는 사용자 정의 예외를 예외코드 -20000 번으로 매핑해서 처리해보자. 

<정답>

CREATE OR REPLACE PROCEDURE ch10_iud_dep_proc (
                    p_department_id    ch10_departments.department_id%TYPE,
                    p_department_name  ch10_departments.department_name%TYPE,
                    p_flag             VARCHAR2 )
IS
  vn_cnt         NUMBER := 0;
  dept_exception EXCEPTION;
  PRAGMA EXCEPTION_INIT (dept_exception, -20000 );
BEGIN
	
	IF p_flag = 'I' THEN
	   
	   INSERT INTO ch10_departments
	          VALUES ( p_department_id, p_department_name);
	  
	ELSIF p_flag = 'U' THEN
	
	   UPDATE ch10_departments
	      SET department_name = p_department_name
	    WHERE department_id   = p_department_id;
	
	
	ELSIF p_flag = 'D' THEN
	   
	  SELECT COUNT(*)
	    INTO vn_cnt 
	    FROM employees
	   WHERE department_id = p_department_id;
	   
	  IF vn_cnt > 0 THEN
	     RAISE dept_exception;
	  
	  END IF;
	
	  DELETE ch10_departments
	   WHERE department_id   = p_department_id;
	
	
  END IF;
  
  COMMIT;
  
  EXCEPTION WHEN dept_exception THEN
                 DBMS_OUTPUT.PUT_LINE(SQLCODE);
                 DBMS_OUTPUT.PUT_LINE(SQLERRM);

                 DBMS_OUTPUT.PUT_LINE('해당 부서에 할당된 사원이 존재해 삭제할 수 없습니다!');
                 ROLLBACK;
  
            WHEN OTHERS THEN
                 DBMS_OUTPUT.PUT_LINE(SQLCODE);
                 DBMS_OUTPUT.PUT_LINE(SQLERRM);
                 ROLLBACK;
	
END;      


6. 5번 문제와 동일한 로직을 구현하는데, 이번에는 RAISE_APPLICATION_ERROR 를 사용해서 구현해보자. 

<정답>

CREATE OR REPLACE PROCEDURE ch10_iud_dep_proc (
                    p_department_id    ch10_departments.department_id%TYPE,
                    p_department_name  ch10_departments.department_name%TYPE,
                    p_flag             VARCHAR2 )
IS
  vn_cnt         NUMBER := 0;
  dept_exception EXCEPTION;

BEGIN
	
	IF p_flag = 'I' THEN
	   
	   INSERT INTO ch10_departments
	          VALUES ( p_department_id, p_department_name);
	  
	ELSIF p_flag = 'U' THEN
	
	   UPDATE ch10_departments
	      SET department_name = p_department_name
	    WHERE department_id   = p_department_id;
	
	
	ELSIF p_flag = 'D' THEN
	   
	  SELECT COUNT(*)
	    INTO vn_cnt 
	    FROM employees
	   WHERE department_id = p_department_id;
	   
	  IF vn_cnt > 0 THEN
	     RAISE_APPLICATION_ERROR (-20000, '해당 부서에 할당된 사원이 존재해 삭제할 수 없습니다!');
	  
	  END IF;
	
	  DELETE ch10_departments
	   WHERE department_id   = p_department_id;
	
	
  END IF;
  
  COMMIT;
  
  EXCEPTION WHEN OTHERS THEN
                 DBMS_OUTPUT.PUT_LINE(SQLCODE);
                 DBMS_OUTPUT.PUT_LINE(SQLERRM);
                 ROLLBACK;
	
END;      