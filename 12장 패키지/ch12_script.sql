-- 패키지 사용

-- 패키지 선언부 
CREATE OR REPLACE PACKAGE hr_pkg IS

  -- 사번을 받아 이름을 반환하는 함수
  FUNCTION fn_get_emp_name ( pn_employee_id IN NUMBER )
     RETURN VARCHAR2;
     
  -- 신규 사원 입력  
  PROCEDURE new_emp_proc ( ps_emp_name   IN VARCHAR2, 
                           pd_hire_date  IN VARCHAR2 );
                               
  -- 퇴사 사원 처리                          
  PROCEDURE retire_emp_proc ( pn_employee_id IN NUMBER );
  
END  hr_pkg; 
                               
-- 패키지 본문
 
CREATE OR REPLACE PACKAGE BODY hr_pkg IS

  -- 사번을 받아 이름을 반환하는 함수
  FUNCTION fn_get_emp_name ( pn_employee_id IN NUMBER )
     RETURN VARCHAR2
  IS
    vs_emp_name employees.emp_name%TYPE;
  BEGIN
    -- 사원명을 가져온다. 
    SELECT emp_name
      INTO vs_emp_name
      FROM employees
     WHERE employee_id = pn_employee_id;
     
    -- 사원명 반환
    RETURN NVL(vs_emp_name, '해당사원없음');
  
  END fn_get_emp_name;
     
  -- 신규 사원 입력  
  PROCEDURE new_emp_proc ( ps_emp_name   IN VARCHAR2, 
                           pd_hire_date  IN VARCHAR2)
  IS
    
    vn_emp_id    employees.employee_id%TYPE;
    vd_hire_date DATE := TO_DATE(pd_hire_date, 'YYYY-MM-DD');
  BEGIN
     -- 신규사원의 사번 = 최대 사번+1 
     SELECT NVL(max(employee_id),0) + 1
       INTO vn_emp_id
       FROM employees;
  
    
    INSERT INTO employees (employee_id, emp_name,hire_date, create_date, update_date)
                   VALUES (vn_emp_id, ps_emp_name, NVL(vd_hire_date,SYSDATE), SYSDATE, SYSDATE );
                   
    COMMIT;
    
    EXCEPTION WHEN OTHERS THEN
              DBMS_OUTPUT.PUT_LINE(SQLERRM);
              ROLLBACK;               
  
  
  END new_emp_proc;
  
                               
  -- 퇴사 사원 처리                          
  PROCEDURE retire_emp_proc ( pn_employee_id IN NUMBER )
  IS
    vn_cnt NUMBER := 0;
    e_no_data    EXCEPTION;
  BEGIN
    -- 퇴사한 사원은 사원테이블에서 삭제하지 않고 일단 퇴사일자(RETIRE_DATE)를 NULL에서 갱신한다.
    UPDATE employees
       SET retire_date = SYSDATE
     WHERE employee_id = pn_employee_id
       AND retire_date IS NULL;
       
    -- UPDATE된 건수를 가져온다.    
    vn_cnt := SQL%ROWCOUNT;
    
    -- 갱신된 건수가 없으면 사용자 예외처리 
    IF vn_cnt = 0 THEN 
       RAISE e_no_data;
    END IF;
    
    COMMIT;
    
    EXCEPTION WHEN e_no_data THEN
                   DBMS_OUTPUT.PUT_LINE (pn_employee_id || '에 해당되는 퇴사처리할 사원이 없습니다!');
                   ROLLBACK;
              WHEN OTHERS THEN
                   DBMS_OUTPUT.PUT_LINE (SQLERRM);
                   ROLLBACK;              
  
  
  END retire_emp_proc;
  
END  hr_pkg; 


-- hr_pkg 사용
SELECT hr_pkg.fn_get_emp_name (171)
  FROM DUAL;
  
-- 신규사원 입력
EXEC hr_pkg.new_emp_proc ('Julia Roberts', '2014-01-10');

SELECT employee_id, emp_name, hire_date, retire_date, create_date
  FROM employees
 WHERE emp_name like 'Julia R%';  
 
-- 퇴사처리 
EXEC hr_pkg.retire_emp_proc (207);

SELECT employee_id, emp_name, hire_date, retire_date, create_date
  FROM employees
 WHERE emp_name like 'Julia R%'; 
 
 
-- (3) 타 프로그램에서 패키지 호출  
CREATE OR REPLACE PACKAGE hr_pkg IS

  -- 사번을 받아 이름을 반환하는 함수
  FUNCTION fn_get_emp_name ( pn_employee_id IN NUMBER )
     RETURN VARCHAR2;
     
  -- 신규 사원 입력  
  PROCEDURE new_emp_proc ( ps_emp_name   IN VARCHAR2, 
                           pd_hire_date  IN VARCHAR2 );
                               
  -- 퇴사 사원 처리                          
  PROCEDURE retire_emp_proc ( pn_employee_id IN NUMBER );
  
  -- 사번을 입력받아 부서명을 반환하는 함수
  FUNCTION fn_get_dep_name ( pn_employee_id IN NUMBER )
     RETURN VARCHAR2;
  
END  hr_pkg; 

-- 신규 프로시저
CREATE OR REPLACE PROCEDURE ch12_dep_proc ( pn_employee_id IN NUMBER )
IS
  vs_emp_name employees.emp_name%TYPE;  --사원명 변수
  vs_dep_name departments.department_name%TYPE;  -- 부서명 변수
BEGIN
	

  
  -- 부서명 가져오기
  vs_dep_name := hr_pkg.fn_get_dep_name (pn_employee_id);
  
  -- 부서명 출력
  DBMS_OUTPUT.PUT_LINE(NVL(vs_dep_name, '부서명 없음'));
	
END;



-- fn_get_dep_name 함수를 추가한 패키지 본문 
CREATE OR REPLACE PACKAGE BODY hr_pkg IS

  -- 사번을 받아 이름을 반환하는 함수
  FUNCTION fn_get_emp_name ( pn_employee_id IN NUMBER )
     RETURN VARCHAR2
  IS
    vs_emp_name employees.emp_name%TYPE;
  BEGIN
    -- 사원명을 가져온다. 
    SELECT emp_name
      INTO vs_emp_name
      FROM employees
     WHERE employee_id = pn_employee_id;
     
    -- 사원명 반환
    RETURN NVL(vs_emp_name, '해당사원없음');
  
  END fn_get_emp_name;
     
  -- 신규 사원 입력  
  PROCEDURE new_emp_proc ( ps_emp_name   IN VARCHAR2, 
                           pd_hire_date  IN VARCHAR2)
  IS
    
    vn_emp_id    employees.employee_id%TYPE;
    vd_hire_date DATE := TO_DATE(pd_hire_date, 'YYYY-MM-DD');
  BEGIN
     -- 신규사원의 사번 = 최대 사번+1 
     SELECT NVL(max(employee_id),0) + 1
       INTO vn_emp_id
       FROM employees;
  
    
    INSERT INTO employees (employee_id, emp_name,hire_date, create_date, update_date)
                   VALUES (vn_emp_id, ps_emp_name, NVL(vd_hire_date,SYSDATE), SYSDATE, SYSDATE );
                   
    COMMIT;
    
    EXCEPTION WHEN OTHERS THEN
              DBMS_OUTPUT.PUT_LINE(SQLERRM);
              ROLLBACK;               
  
  
  END new_emp_proc;
  
                               
  -- 퇴사 사원 처리                          
  PROCEDURE retire_emp_proc ( pn_employee_id IN NUMBER )
  IS
    vn_cnt NUMBER := 0;
    e_no_data    EXCEPTION;
  BEGIN
    -- 퇴사한 사원은 사원테이블에서 삭제하지 않고 일단 퇴사일자(RETIRE_DATE)를 NULL에서 갱신한다.
    UPDATE employees
       SET retire_date = SYSDATE
     WHERE employee_id = pn_employee_id
       AND retire_date IS NULL;
       
    -- UPDATE된 건수를 가져온다.    
    vn_cnt := SQL%ROWCOUNT;
    
    -- 갱신된 건수가 없으면 사용자 예외처리 
    IF vn_cnt = 0 THEN 
       RAISE e_no_data;
    END IF;
    
    COMMIT;
    
    EXCEPTION WHEN e_no_data THEN
                   DBMS_OUTPUT.PUT_LINE (pn_employee_id || '에 해당되는 퇴사처리할 사원이 없습니다!');
                   ROLLBACK;
              WHEN OTHERS THEN
                   DBMS_OUTPUT.PUT_LINE (SQLERRM);
                   ROLLBACK;              
  
  
  END retire_emp_proc;
  
  -- 사번을 입력받아 부서명을 반환하는 함수
  FUNCTION fn_get_dep_name ( pn_employee_id IN NUMBER )
     RETURN VARCHAR2
  IS
    vs_dep_name departments.department_name%TYPE;
  BEGIN
  	
  	-- 부서테이블과 조인해 사번을 이용, 부서명까지 가져온다. 
  	SELECT b.department_name
  	  INTO vs_dep_name
  	  FROM employees a, departments b
  	 WHERE a.employee_id = pn_employee_id
  	   AND a.department_id = b.department_id;
  	   
  	-- 부서명 반환
  	RETURN vs_dep_name;   
  	
  	
  END fn_get_dep_name;
    
  
END  hr_pkg; 

-- 프로시저 실행
EXEC ch12_dep_proc(177);


-- 03. 패키지 데이터
--(1) 상수와 변수 선언
CREATE OR REPLACE PACKAGE ch12_var IS
  -- 상수선언
     c_test CONSTANT VARCHAR2(10) := 'TEST';
     
  -- 변수선언 
     v_test VARCHAR2(10);

END ch12_var;

BEGIN
  DBMS_OUTPUT.PUT_LINE('상수 ch12_var.c_test = ' || ch12_var.c_test);
  DBMS_OUTPUT.PUT_LINE('변수 ch12_var.c_test = ' || ch12_var.v_test);
END;

BEGIN
  DBMS_OUTPUT.PUT_LINE('값 설정 이전 = ' || ch12_var.v_test);
  ch12_var.v_test := 'FIRST';
  DBMS_OUTPUT.PUT_LINE('값 설정 이후 = ' || ch12_var.v_test);
END;


-- 신규세션
BEGIN
  DBMS_OUTPUT.PUT_LINE('ch12_var.v_test = ' || ch12_var.v_test);
END;


CREATE OR REPLACE PACKAGE BODY ch12_var IS
  -- 상수선언
     c_test_body CONSTANT VARCHAR2(10) := 'CONSTANT_BODY';
     
  -- 변수선언 
     v_test_body VARCHAR2(10);

END ch12_var;

BEGIN
	 DBMS_OUTPUT.PUT_LINE('ch12_var.c_test_body = '|| ch12_var.c_test_body);	 
	 
	 DBMS_OUTPUT.PUT_LINE('ch12_var.v_test_body = '|| ch12_var.v_test_body);
END;


CREATE OR REPLACE PACKAGE ch12_var IS
  -- 상수선언
     c_test CONSTANT VARCHAR2(10) := 'TEST';     
  -- 변수선언 
     v_test VARCHAR2(10);
     
  -- 내부변수 값을 가져오는 함수   
  FUNCTION fn_get_value RETURN VARCHAR2;   
  
  -- 내부변수 값을 변경하는 프로시저
  PROCEDURE sp_set_value ( ps_value VARCHAR2);

END ch12_var;

CREATE OR REPLACE PACKAGE BODY ch12_var IS
  -- 상수선언
     c_test_body CONSTANT VARCHAR2(10) := 'CONSTANT_BODY';
     
  -- 변수선언 
     v_test_body VARCHAR2(10);
     
  -- 내부변수 값을 가져오는 함수   
  FUNCTION fn_get_value RETURN VARCHAR2 
  IS
  
  BEGIN  	
  	-- 변수 값을 반환한다. 
  	RETURN NVL(v_test_body, 'NULL 이다');
  END fn_get_value;  
  
  -- 내부변수 값을 변경하는 프로시저
  PROCEDURE sp_set_value ( ps_value VARCHAR2)
  IS
  
  BEGIN
  	--내부변수에 값 할당
  	v_test_body := ps_value;
  END sp_set_value;

END ch12_var;


DECLARE 
  vs_value VARCHAR2(10);
  
BEGIN
	-- 값을 할당
	ch12_var.sp_set_value ('EXTERNAL');
	
	-- 값 참조
	vs_value :=	ch12_var.fn_get_value;
	DBMS_OUTPUT.PUT_LINE(vs_value);
	
END;


  
BEGIN
	-- 값 참조
	DBMS_OUTPUT.PUT_LINE(ch12_var.fn_get_value);	
END;


-- 커서
-- 패키지 선언부에 커서 전체 선언
CREATE OR REPLACE PACKAGE ch12_cur_pkg IS
  -- 커서전체 선언
  CURSOR pc_empdep_cur ( dep_id IN DEPARTMENTS.DEPARTMENT_ID%TYPE ) IS
    SELECT a.employee_id, a.emp_name, b.department_name
      FROM employees a, departments b
     WHERE a.department_id = dep_id
       AND a.department_id = b.department_id;   

END ch12_cur_pkg;

-- 커서 사용
BEGIN
	FOR rec IN ch12_cur_pkg.pc_empdep_cur(30)
	LOOP
	  DBMS_OUTPUT.PUT_LINE(rec.emp_name || ' - ' || rec.department_name);
	
  END LOOP;	
END;


-- ROWTYPE형 커서
CREATE OR REPLACE PACKAGE ch12_cur_pkg IS
  -- 커서전체 선언
  CURSOR pc_empdep_cur ( dep_id IN departments.department_id%TYPE ) IS
    SELECT a.employee_id, a.emp_name, b.department_name
      FROM employees a, departments b
     WHERE a.department_id = dep_id
       AND a.department_id = b.department_id;   
       
  -- ROWTYPE형 커서 헤더선언 
  CURSOR pc_depname_cur ( dep_id IN departments.department_id%TYPE ) 
      RETURN departments%ROWTYPE;

END ch12_cur_pkg;

-- 패키지 본문
CREATE OR REPLACE PACKAGE BODY ch12_cur_pkg IS
       
  -- ROWTYPE형 커서본문 
  CURSOR pc_depname_cur ( dep_id IN departments.department_id%TYPE ) 
      RETURN departments%ROWTYPE 
  IS
      SELECT *
        FROM departments
       WHERE department_id = dep_id;

END ch12_cur_pkg;

-- 커서 사용2
BEGIN
	FOR rec IN ch12_cur_pkg.pc_depname_cur(30)
	LOOP
	  DBMS_OUTPUT.PUT_LINE(rec.department_id || ' - ' || rec.department_name);
	
  END LOOP;	
END;


-- 레코드 타입 커서 선언
CREATE OR REPLACE PACKAGE ch12_cur_pkg IS
  -- 커서전체 선언
  CURSOR pc_empdep_cur ( dep_id IN departments.department_id%TYPE ) IS
    SELECT a.employee_id, a.emp_name, b.department_name
      FROM employees a, departments b
     WHERE a.department_id = dep_id
       AND a.department_id = b.department_id;   
       
  -- ROWTYPE형 커서 헤더선언 
  CURSOR pc_depname_cur ( dep_id IN departments.department_id%TYPE ) 
      RETURN departments%ROWTYPE;
      
  -- 사용자정의 레코드 타입
  TYPE emp_dep_rt IS RECORD (
       emp_id     employees.employee_id%TYPE,
       emp_name   employees.emp_name%TYPE,
       job_title  jobs.job_title%TYPE );
       
  -- 사용자정의 레코드를 반환하는 커서
  CURSOR pc_empdep2_cur ( p_job_id IN jobs.job_id%TYPE ) 
       RETURN emp_dep_rt;

END ch12_cur_pkg;

-- 레코드 타입 커서 쿼리 작성(패키지 본문)
CREATE OR REPLACE PACKAGE BODY ch12_cur_pkg IS
       
  -- ROWTYPE형 커서본문 
  CURSOR pc_depname_cur ( dep_id IN departments.department_id%TYPE ) 
      RETURN departments%ROWTYPE 
  IS
      SELECT *
        FROM departments
       WHERE department_id = dep_id;
       
  -- 사용자정의 레코드를 반환하는 커서
  CURSOR pc_empdep2_cur ( p_job_id IN jobs.job_id%TYPE ) 
      RETURN emp_dep_rt
  IS
      SELECT a.employee_id, a.emp_name, b.job_title
        FROM employees a,
             jobs b
       WHERE a.job_id = p_job_id
         AND a.job_id = b.job_id;

END ch12_cur_pkg;

-- 커서사용3
BEGIN
	FOR rec IN ch12_cur_pkg.pc_empdep2_cur('FI_ACCOUNT')
	LOOP
	  DBMS_OUTPUT.PUT_LINE(rec.emp_id || ' - ' || rec.emp_name || ' - ' || rec.job_title );
	
  END LOOP;	
END;

--패키지 커서 사용시 주의점
DECLARE
  -- 커서변수 선언
  dep_cur ch12_cur_pkg.pc_depname_cur%ROWTYPE;
BEGIN
  -- 커서열기
	OPEN ch12_cur_pkg.pc_depname_cur(30);
	
	LOOP
	  FETCH ch12_cur_pkg.pc_depname_cur INTO dep_cur;
    EXIT WHEN ch12_cur_pkg.pc_depname_cur%NOTFOUND;
	  DBMS_OUTPUT.PUT_LINE ( dep_cur.department_id || ' - ' || dep_cur.department_name);
  END LOOP;
  -- 커서닫기 
  CLOSE ch12_cur_pkg.pc_depname_cur;	
END;


-- 레코드와 컬렉션
-- 패키지 선언부
CREATE OR REPLACE PACKAGE ch12_col_pkg IS
    -- 중첩 테이블 선언
    TYPE nt_dep_name IS TABLE OF VARCHAR2(30);
    
    -- 중첩 테이블 변수 선언 및 초기화 
    pv_nt_dep_name nt_dep_name := nt_dep_name();
    
    -- 선언한 중첩테이블에 데이터 생성 프로시저
    PROCEDURE make_dep_proc ( p_par_id IN NUMBER) ;
    
END ch12_col_pkg;


-- 패키지 본문
CREATE OR REPLACE PACKAGE BODY ch12_col_pkg IS
   -- 선언한 중첩테이블에 데이터 생성 프로시저
  PROCEDURE make_dep_proc ( p_par_id IN NUMBER)
  IS
    
  BEGIN
  	-- 부서 테이블의 PARENT_ID를 받아 부서명을 가져온다. 
  	FOR rec IN ( SELECT department_name
  	               FROM departments
  	              WHERE parent_id = p_par_id )
  	LOOP
  	  -- 중첩 테이블 변수 EXTEND
  	  pv_nt_dep_name.EXTEND();
  	  -- 중첩 테이블 변수에 데이터를 넣는다.
  	  pv_nt_dep_name( pv_nt_dep_name.COUNT) := rec.department_name;  	
  	
    END LOOP;  	
  	
  END make_dep_proc;
  
END ch12_col_pkg;
    	
    	
-- 컬렉션 변수값 출력(1)
BEGIN
	-- 100번 부서에 속한 부서명을 컬렉션 변수에 담는다. 
	ch12_col_pkg.make_dep_proc(100);
	
	-- 루프를 돌며 컬렉션 변수 값을 출력한다
	FOR i IN 1..ch12_col_pkg.pv_nt_dep_name.COUNT
	LOOP
	  DBMS_OUTPUT.PUT_LINE( ch12_col_pkg.pv_nt_dep_name(i));
  END LOOP;
	
END;

-- 컬렉션 변수값 출력(2)
BEGIN

	-- 루프를 돌며 컬렉션 변수 값을 출력한다
	FOR i IN 1..ch12_col_pkg.pv_nt_dep_name.COUNT
	LOOP
	  DBMS_OUTPUT.PUT_LINE( ch12_col_pkg.pv_nt_dep_name(i));
  END LOOP;
	
END;


--PRAGMA SERIALLY_REUSABLE 옵션
CREATE OR REPLACE PACKAGE ch12_col_pkg IS
    PRAGMA SERIALLY_REUSABLE;
    
    -- 중첩 테이블 선언
    TYPE nt_dep_name IS TABLE OF VARCHAR2(30);
    
    -- 중첩 테이블 변수 선언 및 초기화 
    pv_nt_dep_name nt_dep_name := nt_dep_name();
    
    -- 선언한 중첩테이블에 데이터 생성 프로시저
    PROCEDURE make_dep_proc ( p_par_id IN NUMBER) ;
    
END ch12_col_pkg;


CREATE OR REPLACE PACKAGE BODY ch12_col_pkg IS

  PRAGMA SERIALLY_REUSABLE; 

   -- 선언한 중첩테이블에 데이터 생성 프로시저
  PROCEDURE make_dep_proc ( p_par_id IN NUMBER)
  IS
    
  BEGIN
  	-- 부서 테이블의 PARENT_ID를 받아 부서명을 가져온다. 
  	FOR rec IN ( SELECT department_name
  	               FROM departments
  	              WHERE parent_id = p_par_id )
  	LOOP
  	  -- 중첩 테이블 변수 EXTEND
  	  pv_nt_dep_name.EXTEND();
  	  -- 중첩 테이블 변수에 데이터를 넣는다.
  	  pv_nt_dep_name( pv_nt_dep_name.COUNT) := rec.department_name;  	
  	
    END LOOP;  	
  	
  END make_dep_proc;
  
END ch12_col_pkg;

-- 컬렉션 변수값 출력(1)
BEGIN
	-- 100번 부서에 속한 부서명을 컬렉션 변수에 담는다. 
	ch12_col_pkg.make_dep_proc(100);
	
	-- 루프를 돌며 컬렉션 변수 값을 출력한다
	FOR i IN 1..ch12_col_pkg.pv_nt_dep_name.COUNT
	LOOP
	  DBMS_OUTPUT.PUT_LINE( ch12_col_pkg.pv_nt_dep_name(i));
  END LOOP;
	
END;


-- 오버로딩
CREATE OR REPLACE PACKAGE ch12_overload_pkg IS
   -- 매개변수로 사번을 받아 해당 사원의 부서명을 출력
   PROCEDURE get_dep_nm_proc ( p_emp_id IN NUMBER);
   
   -- 매개변수로 사원명을 받아 해당 사원의 부서명을 출력
   PROCEDURE get_dep_nm_proc ( p_emp_name IN VARCHAR2);

END ch12_overload_pkg;


CREATE OR REPLACE PACKAGE BODY ch12_overload_pkg IS
   -- 매개변수로 사번을 받아 해당 사원의 부서명을 출력
   PROCEDURE get_dep_nm_proc ( p_emp_id IN NUMBER)
   IS
     -- 부서명 변수
     vs_dep_nm departments.department_name%TYPE;
   BEGIN
   	 SELECT b.department_name
   	   INTO vs_dep_nm
   	   FROM employees a, departments b
   	  WHERE a.employee_id = p_emp_id
   	    AND a.department_id = b.department_id;
   	
   	 DBMS_OUTPUT.PUT_LINE('emp_id: ' || p_emp_id || ' - ' || vs_dep_nm);
   	
   END get_dep_nm_proc;
   
   -- 매개변수로 사원명을 받아 해당 사원의 부서명을 출력
   PROCEDURE get_dep_nm_proc ( p_emp_name IN VARCHAR2)
   IS
     -- 부서명 변수
     vs_dep_nm departments.department_name%TYPE;
   BEGIN
   	 SELECT b.department_name
   	   INTO vs_dep_nm
   	   FROM employees a, departments b
   	  WHERE a.emp_name      = p_emp_name
   	    AND a.department_id = b.department_id;
   	
   	 DBMS_OUTPUT.PUT_LINE('emp_name: ' || p_emp_name || ' - ' || vs_dep_nm);
   	
   END get_dep_nm_proc;


END ch12_overload_pkg;

-- 프로시저 테스트
BEGIN
	-- 사번을 통해 부서명 출력
	ch12_overload_pkg.get_dep_nm_proc (176);
	
	-- 사원명을 통해 부서명 출력
	ch12_overload_pkg.get_dep_nm_proc ('Jonathon Taylor');	
	
END;


-- 현장 노하우 : 시스템 패키지

SELECT OWNER, OBJECT_NAME, OBJECT_TYPE, STATUS 
FROM ALL_OBJECTS
WHERE OBJECT_TYPE = 'PACKAGE'
  AND ( OBJECT_NAME LIKE 'DBMS%'  OR OBJECT_NAME LIKE 'UTL%')
ORDER BY OBJECT_NAME;


-- DBMS_METADATA 패키지 
SELECT DBMS_METADATA.GET_DDL('TABLE', 'EMPLOYEES', 'ORA_USER')
 FROM DUAL;
 
 
SELECT DBMS_METADATA.GET_DDL('PACKAGE', 'ch12_OVERLOAD_PKG', 'ORA_USER')
 FROM DUAL; 
 
-- DBMS_RANDOM 패키지
SELECT DBMS_RANDOM.STRING ('U', 10) AS 대문자, 
       DBMS_RANDOM.STRING ('L', 10) AS 소문자,
       DBMS_RANDOM.STRING ('A', 10) AS 대소문자_혼합,
       DBMS_RANDOM.STRING ('X', 10) AS 대문자숫자_혼합,
       DBMS_RANDOM.STRING ('P', 10) AS 특수문자까지_혼합
FROM DUAL;

