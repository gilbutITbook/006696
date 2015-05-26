--
1. 다음은 7장에서 학습했던 부서별 계층형 쿼리이다. 

SELECT department_id, LPAD(' ' , 3 * (LEVEL-1)) || department_name, LEVEL
  FROM departments
  START WITH parent_id IS NULL
CONNECT BY PRIOR department_id  = parent_id;

위 문장과 동일한 결과를 내도록 my_dep_hier_proc란 이름으로 프로시저를 만들어보자.
계층형 쿼리 문장은 전혀 사용하지 말고, 커서와 반복문을 사용해서 구현해 보자. 


<정답>

CREATE OR REPLACE PROCEDURE my_dep_hier_proc (
               p_start  departments.department_name%TYPE,
               p_level  NUMBER )
IS
BEGIN
	 DBMS_OUTPUT.PUT_LINE( LPAD( ' ', p_level*2, ' ' ) || p_start );
	 
	 FOR c in ( SELECT * 
	                from departments
                 where parent_id in ( select department_id
                                            from departments
                                          where department_name = p_start )
                 order by department_name )
    LOOP
          my_dep_hier_proc ( c.ename, p_level+1 );
    END LOOP;
	
END;



2. 다차원 컬렉션 절에서 요소의 타입이 테이블형 레코드인 중첩테이블을 선언해 사원정보를 출력하였다. 
   이번에는 중첩테이블 대신 연관배열을 사용해서 사원명을 인덱스로 해서 이메일 정보를 출력하는 익명블록을 작성해보자. 
   
   
<정답>

DECLARE
    -- 연관배열 선언
    TYPE av_type IS TABLE OF employees.email%TYPE INDEX BY employees.emp_name%TYPE;

   -- 연관배열 변수선언
   vav_test  av_type;
BEGIN
  -- 커서와 연결된 for문을 돌면서 연관배열에 데이터를 넣는다. 
  FOR rec IN ( SELECT emp_name, email
                 FROM employees )
  LOOP
     -- 인덱스 키로 사원명을, 값으로 이메일을 넣는다. 
     vav_test(rec.emp_name) := rec.email;  
  END LOOP;
    
  DBMS_OUTPUT.PUT_LINE( 'Elizabeth Bates 의 이메일 주소는 ' || vav_test('Elizabeth Bates'));
  DBMS_OUTPUT.PUT_LINE( 'Kimberely Grant 의 이메일 주소는 ' || vav_test('Kimberely Grant'));  

END;
   
   
   
   
3. 사원명을 값으로 받기 위한 하는 중첩테이블 nt_ch11_emp 라는 이름으로 사용자정의 타입으로 만들어보자.

<정답>

-- 중첩 테이블 타입을 만든다. 
CREATE OR REPLACE TYPE nt_ch11_emp IS TABLE OF VARCHAR2(80);
             



4. 매개변수로 부서번호를 넘기면 해당 부서에 속한 사원번호, 사원이름, 부서이름을 출력하는 프로시저를 만들어보자. 
   단, 사원번호, 사원이름, 부서이름 정보를 조회해 가져와 중첩테이블에 담은 다음, 다시 이 중첩 테이블에 들어간 데이터를 출력하도록 작성해보자. 


<정답>
      
CREATE OR REPLACE PROCEDURE ch11_emp_proc ( p_dep_id departments.department_id%TYPE )


IS
  -- 사원정보를 받는 커서 선언 
  CURSOR c1 IS
    SELECT a.employee_id, a.emp_name, b.department_name
      FROM employees a,
           departments b
     WHERE a.department_id = b.department_id;
      
  -- 중첩테이블 선언     
  TYPE nt_ch11_emp IS TABLE OF c1%ROWTYPE;
  
  -- 중첩테이블 변수 선언 
  vnt_test nt_ch11_emp; 



BEGIN

  -- 1개 이상 데이터를 넣을 때는 BULK COLLECT INTO 구문을 사용한다
  
    SELECT a.employee_id, a.emp_name, b.department_name
    BULK COLLECT INTO vnt_test
      FROM employees a,
           departments b
     WHERE a.department_id = b.department_id
       AND a.department_id = p_dep_id;
  
  FOR i IN vnt_test.FIRST .. vnt_test.LAST 
  LOOP
      DBMS_OUTPUT.PUT_LINE (
           vnt_test(i).employee_id || ' ' ||
           vnt_test(i).emp_name || ', ' ||
           vnt_test(i).department_name
      );
  END LOOP;
  
END;  
   