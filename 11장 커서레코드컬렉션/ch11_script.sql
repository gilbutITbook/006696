-- 묵시적 커서와 커서속성

DECLARE 
  vn_department_id employees.department_id%TYPE := 80;
BEGIN
	-- 80번 부서의 사원이름을 자신의 이름으로 갱신
	 UPDATE employees
	     SET emp_name = emp_name
	   WHERE department_id = vn_department_id;	   
	   
	-- 몇 건의 데이터가 갱신됐는지 출력   
	DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
	COMMIT;

END;


-- 명시적 커서
DECLARE
   -- 사원명을 받아오기 위한 변수 선언
   vs_emp_name employees.emp_name%TYPE;

   -- 커서 선언, 매개변수로 부서코드를 받는다.
   CURSOR cur_emp_dep ( cp_department_id employees.department_id%TYPE )
   IS
   SELECT emp_name
     FROM employees
    WHERE department_id = cp_department_id;
BEGIN
	
	-- 커서 오픈 (매개변수로 90번 부서를 전달)
	OPEN cur_emp_dep (90);
	
	-- 반복문을 통한 커서 패치작업
	LOOP
	  -- 커서 결과로 나온 로우를 패치함 (사원명을 변수에 할당)
	  FETCH cur_emp_dep INTO vs_emp_name;
	  
	  -- 더 이상 패치된 참조로우가 없는 경우 LOOP 탈출
	  EXIT WHEN cur_emp_dep%NOTFOUND;
	  
	  -- 사원명을 출력
	  DBMS_OUTPUT.PUT_LINE(vs_emp_name);
	
  END LOOP;
  
  -- 커서 닫기
  CLOSE cur_emp_dep;
END;
	
	
-- 커서와 FOR문

DECLARE
   
   -- 커서 선언, 매개변수로 부서코드를 받는다.
   CURSOR cur_emp_dep ( cp_department_id employees.department_id%TYPE )
   IS
   SELECT emp_name
     FROM employees
    WHERE department_id = cp_department_id;
    
BEGIN
	

	-- FOR문을 통한 커서 패치작업
	FOR emp_rec IN cur_emp_dep(90)
	LOOP
	  
	  -- 사원명을 출력, 레코드 타입은 레코드명.컬럼명 형태로 사용
	  DBMS_OUTPUT.PUT_LINE(emp_rec.emp_name);
	
  END LOOP;
  
END;



DECLARE

BEGIN

	-- FOR문을 통한 커서 패치작업 ( 커서 선언시 정의 부분을 FOR문에 직접 기술)
	FOR emp_rec IN ( SELECT emp_name
                     FROM employees
                    WHERE department_id = 90	
	               ) 
	LOOP
	  
	  -- 사원명을 출력, 레코드 타입은 레코드명.컬럼명 형태로 사용
	  DBMS_OUTPUT.PUT_LINE(emp_rec.emp_name);
	
  END LOOP;
  
END;


-- 커서변수
DECLARE
   -- 사원명을 받아오기 위한 변수 선언
   vs_emp_name employees.emp_name%TYPE;
   
   -- 약한 커서타입 선언
   TYPE emp_dep_curtype IS REF CURSOR;
   -- 커서변수 선언
   emp_dep_curvar emp_dep_curtype;
BEGIN

  -- 커서변수를 사용한 커서정의 및 오픈
  OPEN emp_dep_curvar FOR SELECT emp_name
                     FROM employees
                    WHERE department_id = 90	;

  -- LOOP문
  LOOP
     -- 커서변수를 사용해 결과집합을  vs_emp_name 변수에 할당 
     FETCH emp_dep_curvar INTO vs_emp_name;

	  -- 더 이상 패치된 참조로우가 없는 경우 LOOP 탈출(커서변수를 이용한 커서속성 참조)
	  EXIT WHEN emp_dep_curvar%NOTFOUND;
	  
	  -- 사원명을 출력
	  DBMS_OUTPUT.PUT_LINE(vs_emp_name);
  
  
  END LOOP;
 
END;


DECLARE
   -- 사원명을 받아오기 위한 변수 선언
   vs_emp_name employees.emp_name%TYPE;
   
   -- SYS_REFCURSOR 타입의 커서변수 선언
   emp_dep_curvar SYS_REFCURSOR;
BEGIN

  -- 커서변수를 사용한 커서정의 및 오픈
  OPEN emp_dep_curvar FOR SELECT emp_name
                     FROM employees
                    WHERE department_id = 90	;

  -- LOOP문
  LOOP
     -- 커서변수를 사용해 결과집합을  vs_emp_name 변수에 할당 
     FETCH emp_dep_curvar INTO vs_emp_name;

	  -- 더 이상 패치된 참조로우가 없는 경우 LOOP 탈출(커서변수를 이용한 커서속성 참조)
	  EXIT WHEN emp_dep_curvar%NOTFOUND;
	  
	  -- 사원명을 출력
	  DBMS_OUTPUT.PUT_LINE(vs_emp_name);
  
  
  END LOOP;
 
END;


-- 커서변수를 매개변수로 전달

DECLARE
    -- (ⅰ) SYS_REFCURSOR 타입의 커서변수 선언
   emp_dep_curvar SYS_REFCURSOR;
   
    -- 사원명을 받아오기 위한 변수 선언
   vs_emp_name employees.emp_name%TYPE;
   
   -- (ⅱ) 커서변수를 매개변수르 받는 프로시저, 매개변수는 SYS_REFCURSOR 타입의 IN OUT형
   PROCEDURE test_cursor_argu ( p_curvar IN OUT SYS_REFCURSOR)
   IS
       c_temp_curvar SYS_REFCURSOR;
   BEGIN
       -- 커서를 오픈한다
       OPEN c_temp_curvar FOR 
             SELECT emp_name
               FROM employees
             WHERE department_id = 90;
             
        -- (ⅲ) 오픈한 커서를 IN OUT 매개변수에 다시 할당한다. 
        p_curvar := c_temp_curvar;
   END;
BEGIN
   -- 프로시저를 호출한다. 
   test_cursor_argu (emp_dep_curvar);
   
   -- (ⅳ) 전달해서 받은 매개변수를 LOOP문을 사용해 결과를 출력한다. 
   LOOP
     -- 커서변수를 사용해 결과집합을  vs_emp_name 변수에 할당 
     FETCH emp_dep_curvar INTO vs_emp_name;

	  -- 더 이상 패치된 참조로우가 없는 경우 LOOP 탈출(커서변수를 이용한 커서속성 참조)
	  EXIT WHEN emp_dep_curvar%NOTFOUND;
	  
	  -- 사원명을 출력
	  DBMS_OUTPUT.PUT_LINE(vs_emp_name);
  
  
  END LOOP;

END;

-- 커서 표현식

SELECT ( SELECT department_name
             FROM departments d
            WHERE e.department_id = d.department_id) AS dep_name,  
       e.emp_name         
  FROM employees e
 WHERE e.department_id = 90;
 
 
  SELECT d.department_name,      
        ( SELECT e.emp_name
             FROM employees e
            WHERE e.department_id = d.department_id) AS emp_name        
  FROM departments d
 WHERE d.department_id = 90;
 
 
 SELECT d.department_name,      
         CURSOR ( SELECT e.emp_name
                        FROM employees e
                       WHERE e.department_id = d.department_id) AS emp_name        
  FROM departments d
 WHERE d.department_id = 90;


DECLARE
    -- 커서표현식을 사용한 명시적 커서 선언
    CURSOR mytest_cursor IS
         SELECT d.department_name,      
                  CURSOR ( SELECT e.emp_name
                                 FROM employees e
                                WHERE e.department_id = d.department_id) AS emp_name        
          FROM departments d
        WHERE d.department_id = 90;
        
    -- 부서명을 받아오기 위한 변수
    vs_department_name departments.department_name%TYPE;
    
    --커서표현식 결과를 받기 위한 커서타입변수
    c_emp_name SYS_REFCURSOR;
    
    -- 사원명을 받는 변수
    vs_emp_name employees.emp_name%TYPE;
        
BEGIN

    -- 커서오픈
    OPEN mytest_cursor;
    
    -- 명시적 커서를 받아오는 첫 번째 LOOP
    LOOP
       -- 부서명은 변수, 사원명 결과집합은 커서변수에 패치
       FETCH mytest_cursor INTO vs_department_name, c_emp_name;
       EXIT WHEN mytest_cursor%NOTFOUND;
       DBMS_OUTPUT.PUT_LINE ('부서명 : ' || vs_department_name);
       
       -- 사원명을 출력하기 위한 두 번째 LOOP 
       LOOP
          -- 사원명 패치
          FETCH c_emp_name INTO vs_emp_name;
          EXIT WHEN c_emp_name%NOTFOUND;
          
          DBMS_OUTPUT.PUT_LINE('   사원명 : ' || vs_emp_name);
       
       END LOOP; -- 두 번째 LOOP 종료    
    
    END LOOP; -- 첫 번째 LOOP 종료

END;



--- 레코드

DECLARE
  -- 부서레코드 타입선언
   TYPE depart_rect IS RECORD (
         department_id     NUMBER(6),
         department_name VARCHAR2(80),
         parent_id           NUMBER(6),
         manager_id        NUMBER(6)   
   );
   
  -- 위에서 선언된 타입으로 레코드 변수 선언  
   vr_dep depart_rect;

BEGIN
 ...
END;


DECLARE
  -- 부서레코드 타입선언
   TYPE depart_rect IS RECORD (
         department_id     departments.department_id%TYPE,
         department_name  departments.department_name%TYPE, 
         parent_id          departments.parent_id%TYPE,
         manager_id        departments.manager_id%TYPE
   );
   
  -- 위에서 선언된 타입으로 레코드 변수 선언  
   vr_dep depart_rect;

BEGIN
 …
END;


DECLARE
  -- 부서레코드 타입선언
   TYPE depart_rect IS RECORD (
         department_id     departments.department_id%TYPE,
         department_name  departments.department_name%TYPE, 
         parent_id          departments.parent_id%TYPE,
         manager_id        departments.manager_id%TYPE
   );
   
  -- 위에서 선언된 타입으로 레코드 변수 선언  
   vr_dep depart_rect;
   
  -- 두 번째 변수 선언 
   vr_dep2 depart_rect;
BEGIN

   vr_dep.department_id := 999;
   vr_dep.department_name := '테스트부서';
   vr_dep.parent_id := 100;
   vr_dep.manager_id := NULL;
   
   -- 두 번째 변수에 첫 번째 레코드변수 대입
   vr_dep2 := vr_dep;
   
   DBMS_OUTPUT.PUT_LINE( 'vr_dep2.department_id :' || vr_dep2.department_id);
   DBMS_OUTPUT.PUT_LINE( 'vr_dep2.department_name :' ||  vr_dep2.department_name);
   DBMS_OUTPUT.PUT_LINE( 'vr_dep2.parent_id :' ||  vr_dep2.parent_id);
   DBMS_OUTPUT.PUT_LINE( 'vr_dep2.manager_id :' ||  vr_dep2.manager_id);
END;


DECLARE
  -- 부서레코드 타입선언
   TYPE depart_rect IS RECORD (
         department_id     departments.department_id%TYPE,
         department_name  departments.department_name%TYPE, 
         parent_id          departments.parent_id%TYPE,
         manager_id        departments.manager_id%TYPE
   );
   
  -- 위에서 선언된 타입으로 레코드 변수 선언  
   vr_dep depart_rect;
   
  -- 두 번째 변수 선언 
   vr_dep2 depart_rect;
BEGIN

   vr_dep.department_id := 999;
   vr_dep.department_name := '테스트부서';
   vr_dep.parent_id := 100;
   vr_dep.manager_id := NULL;
   
   -- 두 번째 변수의 department_name에만 할당 
   vr_dep2.department_name := vr_dep.department_name;
   
   DBMS_OUTPUT.PUT_LINE( 'vr_dep2.department_id :' || vr_dep2.department_id);
   DBMS_OUTPUT.PUT_LINE( 'vr_dep2.department_name :' ||  vr_dep2.department_name);
   DBMS_OUTPUT.PUT_LINE( 'vr_dep2.parent_id :' ||  vr_dep2.parent_id);
   DBMS_OUTPUT.PUT_LINE( 'vr_dep2.manager_id :' ||  vr_dep2.manager_id);
END;


CREATE TABLE ch11_dep AS
SELECT department_id, department_name, parent_id, manager_id
  FROM DEPARTMENTS ;
  
TRUNCATE TABLE   ch11_dep;
  
 DECLARE
  -- 부서레코드 타입선언
   TYPE depart_rect IS RECORD (
         department_id     departments.department_id%TYPE,
         department_name  departments.department_name%TYPE, 
         parent_id          departments.parent_id%TYPE,
         manager_id        departments.manager_id%TYPE
   );
   
  -- 위에서 선언된 타입으로 레코드 변수 선언  
   vr_dep depart_rect;

BEGIN

   vr_dep.department_id := 999;
   vr_dep.department_name := '테스트부서';
   vr_dep.parent_id := 100;
   vr_dep.manager_id := NULL;
   
   -- 레코드 필드를 명시해서 INSERT
   INSERT INTO ch11_dep VALUES ( vr_dep.department_id, vr_dep.department_name, vr_dep.parent_id, vr_dep.manager_id);
   
   -- 레코드 필드 순서와 개수, 타입이 같다면 레코드변수명으로만 INSERT 가능
   INSERT INTO ch11_dep VALUES vr_dep;
   
   COMMIT;
END;

CREATE TABLE ch11_dep2 AS
SELECT *
  FROM DEPARTMENTS;

TRUNCATE TABLE   ch11_dep2;



-- 테이블형 레코드 
DECLARE
  -- 테이블형 레코드 변수 선언 
   vr_dep departments%ROWTYPE;

BEGIN

   -- 부서 테이블의 모든 정보를 레코드 변수에 넣는다. 
   SELECT *
     INTO vr_dep
     FROM departments
    WHERE department_id = 20;
   
   -- 레코드 변수를 이용해 ch11_dep2 테이블에 데이터를 넣는다. 
   INSERT INTO ch11_dep2 VALUES vr_dep;
   
   COMMIT;
END;


-- 커서형 레코드 
DECLARE
  -- 커서 선언
   CURSOR c1 IS
       SELECT department_id, department_name, parent_id, manager_id
         FROM departments;       
        
   -- 커서형 레코드변수 선언  
   vr_dep c1%ROWTYPE;

BEGIN
   -- 데이터 삭제 
   DELETE ch11_dep;
 
   -- 커서 오픈 
   OPEN c1;
   
   -- 루프를 돌며 vr_dep 레코드 변수에 값을 넣고, 다시 ch11_dep에 INSERT
   LOOP
     FETCH c1 INTO vr_dep;
     
     EXIT WHEN c1%NOTFOUND;
     -- 레코드 변수를 이용해 ch11_dep2 테이블에 데이터를 넣는다. 
     INSERT INTO ch11_dep VALUES vr_dep;
   
   END LOOP;
   
   COMMIT;
END;


DECLARE
   -- 레코드 변수 선언 
   vr_dep ch11_dep%ROWTYPE;

BEGIN
 
   vr_dep.department_id := 20;
   vr_dep.department_name := '테스트';
   vr_dep.parent_id := 10;
   vr_dep.manager_id := 200;
     
   -- ROW를 사용하면 해당 로우 전체가 갱신됨
     UPDATE ch11_dep
          SET ROW = vr_dep
      WHERE department_id = vr_dep.department_id; 
   
   COMMIT;
END;


-- 중첩 레코드

DECLARE
  -- 부서번호, 부서명을 필드로 가진 dep_rec 레코드 타입 선언 
  TYPE dep_rec IS RECORD (
        dep_id      departments.department_id%TYPE,
        dep_name departments.department_name%TYPE );
        
  --사번, 사원명 그리고 dep_rec(부서번호, 부서명) 타입의 레코드 선언 
  TYPE emp_rec IS RECORD (
        emp_id      employees.employee_id%TYPE,
        emp_name employees.emp_name%TYPE,
        dep          dep_rec                          );
        
   --  emp_rec 타입의 레코드 변수 선언 
   vr_emp_rec emp_rec;

BEGIN
   -- 100번 사원의 사번, 사원명, 부서번호, 부서명을 가져온다. 
   SELECT a.employee_id, a.emp_name, a.department_id, b.department_name
     INTO vr_emp_rec.emp_id, vr_emp_rec.emp_name, vr_emp_rec.dep.dep_id, vr_emp_rec.dep.dep_name
     FROM employees a, 
             departments b
    WHERE a.employee_id = 100
       AND a.department_id = b.department_id;
       
    -- 레코드 변수 값 출력    
    DBMS_OUTPUT.PUT_LINE('emp_id : ' ||  vr_emp_rec.emp_id);
    DBMS_OUTPUT.PUT_LINE('emp_name : ' ||  vr_emp_rec.emp_name);
    DBMS_OUTPUT.PUT_LINE('dep_id : ' ||  vr_emp_rec.dep.dep_id);
    DBMS_OUTPUT.PUT_LINE('dep_name : ' ||  vr_emp_rec.dep.dep_name);
END;


-- 연관배열

DECLARE
   -- 숫자-문자 쌍의 연관배열 선언
   TYPE av_type IS TABLE OF VARCHAR2(40)
        INDEX BY PLS_INTEGER;
        
   -- 연관배열 변수 선언
   vav_test av_type;
BEGIN
  -- 연관배열에 값 할당
  vav_test(10) := '10에 대한 값';
  vav_test(20) := '20에 대한 값';
  
  --연관배열 값 출력
  DBMS_OUTPUT.PUT_LINE(vav_test(10));
  DBMS_OUTPUT.PUT_LINE(vav_test(20));

END;

-- VARRAY

DECLARE
   -- 5개의 문자형 값으로 이루어진 VARRAY 선언
   TYPE va_type IS VARRAY(5) OF VARCHAR2(20);
   
   -- VARRY 변수 선언
   vva_test va_type;
   
   vn_cnt NUMBER := 0;
BEGIN
  -- 생성자를 사용해 값 할당 (총 5개지만 최초 3개만 값 할당)
  vva_test := va_type('FIRST', 'SECOND', 'THIRD', '', '');
  
  LOOP
     vn_cnt := vn_cnt + 1;     
     -- 크기가 5이므로 5회 루프를 돌면서 각 요소 값 출력 
     IF vn_cnt > 5 THEN 
        EXIT;
     END IF;
  
     -- VARRY 요소 값 출력 
     DBMS_OUTPUT.PUT_LINE(vva_test(vn_cnt));
  
  END LOOP;
  
  -- 값 변경
  vva_test(2) := 'TEST';
  vva_test(4) := 'FOURTH';
  
  -- 다시 루프를 돌려 값 출력
  vn_cnt := 0;
  LOOP
     vn_cnt := vn_cnt + 1;     
     -- 크기가 5이므로 5회 루프를 돌면서 각 요소 값 출력 
     IF vn_cnt > 5 THEN 
        EXIT;
     END IF;
  
     -- VARRY 요소 값 출력 
     DBMS_OUTPUT.PUT_LINE(vva_test(vn_cnt));
  
  END LOOP;
END;

-- 중첩 테이블
DECLARE
  -- 중첩 테이블 선언
  TYPE nt_typ IS TABLE OF VARCHAR2(10);
  
  -- 변수 선언
  vnt_test nt_typ;
BEGIN

  -- 생성자를 사용해 값 할당
  vnt_test := nt_typ('FIRST', 'SECOND', 'THIRD', '');
  
  vnt_test(4) := 'FOURTH';
  
  -- 값 출력
  DBMS_OUTPUT.PUT_LINE (vnt_test(1));
  DBMS_OUTPUT.PUT_LINE (vnt_test(2));
  DBMS_OUTPUT.PUT_LINE (vnt_test(3));
  DBMS_OUTPUT.PUT_LINE (vnt_test(4));
  
END;

-- DELETE 메소드
DECLARE
   -- 숫자-문자 쌍의 연관배열 선언
   TYPE av_type IS TABLE OF VARCHAR2(40)
        INDEX BY VARCHAR2(10);
        
   -- 연관배열 변수 선언
   vav_test av_type;
   
   vn_cnt number := 0;
BEGIN
  -- 연관배열에 값 할당
  vav_test('A') := '10에 대한 값';
  vav_test('B') := '20에 대한 값';
  vav_test('C') := '20에 대한 값';
  
  vn_cnt := vav_test.COUNT;
  DBMS_OUTPUT.PUT_LINE('삭제 전 요소 개수: ' || vn_cnt);  
  
  vav_test.DELETE('A', 'B');
  
  vn_cnt := vav_test.COUNT;
  DBMS_OUTPUT.PUT_LINE('삭제 후 요소 개수: ' || vn_cnt);
END;


-- TRIM 메소드
DECLARE
  -- 중첩 테이블 선언
  TYPE nt_typ IS TABLE OF VARCHAR2(10);
  
  -- 변수 선언
  vnt_test nt_typ;
BEGIN
  -- 생성자를 사용해 값 할당
  vnt_test := nt_typ('FIRST', 'SECOND', 'THIRD', 'FOURTH', 'FIFTH');

  -- 맨 마지막부터 2개 요소 삭제 
  vnt_test.TRIM(2);
  
  DBMS_OUTPUT.PUT_LINE(vnt_test(1));
  DBMS_OUTPUT.PUT_LINE(vnt_test(2));
  DBMS_OUTPUT.PUT_LINE(vnt_test(3));
  DBMS_OUTPUT.PUT_LINE(vnt_test(4));
  
  EXCEPTION WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
      DBMS_OUTPUT.PUT_LINE( DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
END;

-- EXTEND 메소드
DECLARE
  -- 중첩 테이블 선언
  TYPE nt_typ IS TABLE OF VARCHAR2(10);
  
  -- 변수 선언
  vnt_test nt_typ;
BEGIN
  -- 생성자를 사용해 값 할당
  vnt_test := nt_typ('FIRST', 'SECOND', 'THIRD');

  -- 맨 끝에 NULL 요소 추가한 뒤 값 할당 후 출력
  vnt_test.EXTEND;
  vnt_test(4) := 'fourth';
  DBMS_OUTPUT.PUT_LINE(vnt_test(4));
  
  -- 맨 끝에 첫 번째 요소를 2개 복사해 추가 후 출력
  vnt_test.EXTEND(2, 1);
  DBMS_OUTPUT.PUT_LINE('첫번째 : ' || vnt_test(1));
  -- 첫 번째 요소를 복사해 2개 추가했으므로 추가된 요소는 5, 6
  DBMS_OUTPUT.PUT_LINE('추가한 요소1 : ' || vnt_test(5));
  DBMS_OUTPUT.PUT_LINE('추가한 요소2 : ' || vnt_test(6));

END;

-- FIRST와 LAST 메소드 
DECLARE
  -- 중첩 테이블 선언
  TYPE nt_typ IS TABLE OF VARCHAR2(10);
  
  -- 변수 선언
  vnt_test nt_typ;
BEGIN
  -- 생성자를 사용해 값 할당
  vnt_test := nt_typ('FIRST', 'SECOND', 'THIRD', 'FOURTH', 'FIFTH');

  -- FIRST와 LAST 메소드를 FOR문에서 사용해 컬렉션 값을 출력
  FOR i IN vnt_test.FIRST..vnt_test.LAST
  LOOP
  
     DBMS_OUTPUT.PUT_LINE(i || '번째 요소 값: ' || vnt_test(i));
  END LOOP;

END;


-- COUNT와 LIMIT

DECLARE
  
  TYPE nt_typ IS TABLE OF VARCHAR2(10);      -- 중첩테이블 선언
  TYPE va_type IS VARRAY(5) OF VARCHAR2(10); -- VARRAY 선언
 
  -- 변수 선언
  vnt_test nt_typ;
  vva_test va_type;
BEGIN
  -- 생성자를 사용해 값 할당
  vnt_test := nt_typ('FIRST', 'SECOND', 'THIRD', 'FOURTH'); -- 중첩테이블
  vva_test := va_type('첫번째', '두번째', '세번째', '네번째'); -- VARRAY
  
  DBMS_OUTPUT.PUT_LINE('VARRAY COUNT: ' || vva_test.COUNT);
  DBMS_OUTPUT.PUT_LINE('중첩테이블 COUNT: ' || vnt_test.COUNT);

  DBMS_OUTPUT.PUT_LINE('VARRAY LIMIT: ' || vva_test.LIMIT); 
  DBMS_OUTPUT.PUT_LINE('중첩테이블 LIMIT: ' || vnt_test.LIMIT);  

END;


-- PRIOR와 NEXT
DECLARE
  TYPE va_type IS VARRAY(5) OF VARCHAR2(10); -- VARRAY 선언
  -- 변수 선언
  vva_test va_type;
BEGIN
  -- 생성자를 사용해 값 할당
  vva_test := va_type('첫번째', '두번째', '세번째', '네번째'); -- VARRAY
  
  DBMS_OUTPUT.PUT_LINE('FIRST의 PRIOR : ' || vva_test.PRIOR(vva_test.FIRST));
  DBMS_OUTPUT.PUT_LINE('LAST의 NEXT : ' || vva_test.NEXT(vva_test.LAST));

  DBMS_OUTPUT.PUT_LINE('인덱스3의 PRIOR :' || vva_test.PRIOR(3));
  DBMS_OUTPUT.PUT_LINE('인덱스3의 NEXT :' || vva_test.NEXT(3));

END;


-- 사용자 정의 데이터 타입

-- 5개의 문자형 값으로 이루어진 VARRAY 사용자정의타입 선언
CREATE OR REPLACE TYPE ch11_va_type IS VARRAY(5) OF VARCHAR2(20);

-- 문자형 값의 중첩테이블 사용자정의타입 선언
CREATE OR REPLACE TYPE ch11_nt_type IS TABLE OF VARCHAR2(20);

-- 사용자정의타입인 va_type와 nt_type 사용
DECLARE
   vva_test ch11_va_type;  -- VARRAY인 va_type 변수선언   
   vnt_test ch11_nt_type;  -- 중첩테이블인  nt_type 변수선언   

BEGIN
    -- 생성자를 사용해 값 할당 (총 5개지만 최초 3개만 값 할당)
    vva_test := ch11_va_type('FIRST', 'SECOND', 'THIRD', '', '');
    vnt_test := ch11_nt_type('FIRST', 'SECOND', 'THIRD', '');
    
    DBMS_OUTPUT.PUT_LINE('VARRAY의 1번째 요소값: ' || vva_test(1));
    DBMS_OUTPUT.PUT_LINE('중첩테이블의 1번째 요소값: ' || vnt_test(1));

END;


-- 컬렉션 타입별 차이점과 활용
-- 다차원 컬렉션

DECLARE
    -- 첫 번째 VARRAY 타입선언 (구구단중 각단 X5값을 가진  요소를 갖는 VARRAY )
    TYPE va_type1 IS VARRAY(5) OF NUMBER;
    
    -- 위에서 선언한 va_type1을 요소타입으로 하는 VARRAY 타입 선언 (구구단중 1~3단까지 요소를 갖는 VARRAY)
    TYPE va_type11 IS VARRAY(3) OF va_type1;
    -- 두번째 va_type11 타입의 변수 선언 
    va_test va_type11;
BEGIN
    -- 생성자를 이용해 값 초기화, 
    va_test := va_type11( va_type1(1, 2, 3, 4, 5), 
                                 va_type1(2, 4, 6, 8, 10),
                                 va_type1(3, 6, 9, 12, 15));
                        
   -- 구구단 출력                               
   DBMS_OUTPUT.PUT_LINE('2곱하기 3은 ' || va_test(2)(3));             
   DBMS_OUTPUT.PUT_LINE('3곱하기 5는 ' || va_test(3)(5));               

END;



DECLARE
    -- 요소타입을 employees%ROWTYPE 로 선언, 즉 테이블형 레코드를 요소 타입으로 한 중첩테이블 
    TYPE nt_type IS TABLE OF employees%ROWTYPE;

   -- 중첩테이블 변수선언
   vnt_test nt_type;
BEGIN
  -- 빈 생성자로 초기화
  vnt_test := nt_type();
  
  -- 중첩테이블에 요소 1개 추가 
  vnt_test.EXTEND;
  
  -- 사원테이블에서 100번 사원의 정보를 가져온다. 
  SELECT *
     INTO vnt_test(1) -- 위에서 요소1개를 추가했으므로 인덱스는 1
    FROM employees
   WHERE employee_id = 100;
   
  -- 100반 사원의 사번과 성명 출력
  DBMS_OUTPUT.PUT_LINE(vnt_test(1).employee_id);
  DBMS_OUTPUT.PUT_LINE(vnt_test(1).emp_name);

END;

DECLARE
    -- 요소타입을 employees%ROWTYPE 로 선언, 즉 테이블형 레코드를 요소 타입으로 한 중첩테이블 
    TYPE nt_type IS TABLE OF employees%ROWTYPE;

   -- 중첩테이블 변수선언
   vnt_test nt_type;
BEGIN
  -- 빈 생성자로 초기화
  vnt_test := nt_type();
  
  -- 사원테이블 전체를 중첩테이블에 담는다. 
  FOR rec IN ( SELECT * FROM employees) 
  LOOP
     -- 요소 1개 추가 
     vnt_test.EXTEND;
     
     -- LAST 메소드를 사용하면 항상 위에서 추가한 요소의 인덱스를 가져온다. 
     vnt_test ( vnt_test.LAST) := rec;
     
  END LOOP;
   
  -- 출력
  FOR i IN vnt_test.FIRST..vnt_test.LAST
  LOOP
       DBMS_OUTPUT.PUT_LINE(vnt_test(i).employee_id || ' - ' ||   vnt_test(i).emp_name);
  END LOOP;

END;


-- 테이블 컬럼 타입으로 VARRAY 사용하기 

-- 국가 이름을 가지고 있는 VARRAY 타입 생성.
CREATE OR REPLACE TYPE country_var IS VARRAY(7) OF VARCHAR2(30);

-- 대륙별 국가 리스트를 담을 테이블 생성
CREATE TABLE ch11_continent ( 
            continent   VARCHAR2(50), -- 대륙명
            country_nm  country_var -- 국가명을 넣을 VARRAY 타입
            );
            
DECLARE

BEGIN
   -- 생성자를 사용해 국가명을 입력한다. 
   INSERT INTO ch11_continent
         VALUES('아시아', country_var('한국','중국','일본'));
         
   INSERT INTO ch11_continent 
         VALUES('북아메리카', country_var('미국','캐나다','멕시코'));
         
   INSERT INTO ch11_continent 
         VALUES('유럽', country_var('영국','프랑스','독일', '스위스'));         

   COMMIT;

END;            


DECLARE
  -- 새로운 국가 세팅
  new_country country_var := country_var('이태리', '스페인', '네델란드', '체코', '포르투칼');
  country_list country_var;
BEGIN
   -- 새로운 국가로 update
   UPDATE ch11_continent 
      SET country_nm = new_country 
    WHERE continent = '유럽';
   
   COMMIT;
   
   -- UPDATE 됐는지 확인을 위해 국가명 컬럼을 VARRAY 변수에 받아온다. 
   SELECT country_nm 
     INTO country_list 
     FROM ch11_continent 
    WHERE continent = '유럽';
   
  -- 루프를 돌며 국가를 출력한다.  
  FOR i IN country_list.FIRST .. country_list.LAST
  LOOP
     DBMS_OUTPUT.PUT_LINE('유럽국가명 = ' || country_list(i));
  END LOOP;
END;


-- 테이블 컬럼 타입으로 중첩테이블 사용하기

-- 국가 이름을 가지고 있는 중첩테이블 타입 생성.
CREATE OR REPLACE TYPE country_nt IS TABLE OF VARCHAR2(30);

-- 대륙별 국가 리스트를 담을 테이블 생성
CREATE TABLE ch11_continent_nt ( 
            continent   VARCHAR2(50), -- 대륙명
            country_nm  country_nt    -- 국가명을 넣을 중첩테이블 타입
            )
  NESTED TABLE country_nm STORE AS country_nm_nt;        
  

DECLARE 
  -- 새로운 국가 세팅
  new_country country_nt := country_nt('이태리', '스페인', '네델란드', '체코', '포르투칼');
  country_list country_nt;  
  
BEGIN
   -- 생성자를 사용해 국가명을 입력한다. 
   INSERT INTO ch11_continent_nt
         VALUES('아시아', country_nt('한국','중국','일본'));
         
   INSERT INTO ch11_continent_nt 
         VALUES('북아메리카', country_nt('미국','캐나다','멕시코'));
         
   INSERT INTO ch11_continent_nt 
         VALUES('유럽', country_nt('영국','프랑스','독일', '스위스'));         

   -- 새로운 국가로 update
   UPDATE ch11_continent_nt 
      SET country_nm = new_country 
    WHERE continent = '유럽';
   
   COMMIT;
   
   -- UPDATE 됐는지 확인을 위해 국가명 컬럼을 중첩테이블 변수에 받아온다. 
   SELECT country_nm 
     INTO country_list 
     FROM ch11_continent_nt 
    WHERE continent = '유럽';
   
  -- 루프를 돌며 국가를 출력한다.  
  FOR i IN country_list.FIRST .. country_list.LAST
  LOOP
     DBMS_OUTPUT.PUT_LINE('유럽국가명 = ' || country_list(i));
  END LOOP;
END;    


SELECT *
  FROM ch11_continent;
  
  
SELECT continent, b.*
 FROM ch11_continent a, TABLE(a.country_nm) b
WHERE continent = '유럽';


SELECT *
FROM TABLE(SELECT d.country_nm
            FROM ch11_continent_nt d
            WHERE d.continent = '유럽');
            
            
-- DML을 이용한 요소처리       


DECLARE 
    -- 출력용 중첩테이블 변수 선언
  country_list country_nt;  
  
BEGIN
      
   -- 기존 국가명을 받아와 출력한다.  
   SELECT country_nm 
     INTO country_list 
     FROM ch11_continent_nt 
    WHERE continent = '유럽';
   
  -- 루프를 돌며 국가를 출력한다.  
  FOR i IN country_list.FIRST .. country_list.LAST
  LOOP
     DBMS_OUTPUT.PUT_LINE('유럽국가명(OLD) = ' || country_list(i));
  END LOOP;
  
  -- 유럽에 벨기에를 추가한다. TABLE 함수를 써서 INSERT가 가능함.
  INSERT INTO TABLE ( SELECT d.country_nm
                        FROM ch11_continent_nt d
                       WHERE d.continent = '유럽')
  VALUES ('벨기에');
  
  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
                         
   -- 추가됐는지 확인 
   SELECT country_nm 
     INTO country_list 
     FROM ch11_continent_nt 
    WHERE continent = '유럽';
   
  -- 루프를 돌며 국가를 출력한다.  
  FOR i IN country_list.FIRST .. country_list.LAST
  LOOP
     DBMS_OUTPUT.PUT_LINE('유럽국가명(NEW) = ' || country_list(i));
  END LOOP;
  
END;  


-- UPDATE

DECLARE 
    -- 출력용 중첩테이블 변수 선언
  country_list country_nt;  
  
BEGIN
  
  -- 이태리를 영국으로 변경한다. 
  
  UPDATE TABLE( SELECT d.country_nm
                  FROM ch11_continent_nt d
                 WHERE d.continent = '유럽' ) a
     SET VALUE(a) = '영국'
   WHERE a.column_value = '이태리';
  
  COMMIT;
  
                        
   -- 변경됐는지 확인 
   SELECT country_nm 
     INTO country_list 
     FROM ch11_continent_nt 
    WHERE continent = '유럽';
   
  -- 루프를 돌며 국가를 출력한다.  
  FOR i IN country_list.FIRST .. country_list.LAST
  LOOP
     DBMS_OUTPUT.PUT_LINE('유럽국가명(NEW) = ' || country_list(i));
  END LOOP;
  
END;  


-- DELETE

DECLARE 
    -- 출력용 중첩테이블 변수 선언
  country_list country_nt;  
  
BEGIN
  
  -- 변경된 영국을 지운다.   
  DELETE FROM  TABLE( SELECT d.country_nm
                        FROM ch11_continent_nt d
                       WHERE d.continent = '유럽' ) t
   WHERE t.column_value = '영국';
  
  COMMIT;
  
                        
   -- 변경됐는지 확인 
   SELECT country_nm 
     INTO country_list 
     FROM ch11_continent_nt 
    WHERE continent = '유럽';
   
  -- 루프를 돌며 국가를 출력한다.  
  FOR i IN country_list.FIRST .. country_list.LAST
  LOOP
     DBMS_OUTPUT.PUT_LINE('유럽국가명(NEW) = ' || country_list(i));
  END LOOP;
  
END;  