--

1. hr_pkg에는 사원이름반환, 신규사원입력, 퇴사사원을 처리하는 서브 프로그램이 있다. 
   hr_pkg2라는 패키지를 만들고, 이번에는 부서이름반환, 신규부서입력, 부서를 삭제하는 서브프로그램을 만들어 보자. 
   ( 단, 부서를 삭제할 때는 삭제할 부서에 속한 사원이 있는지 체크해서, 있으면 메시지처리하고 없을 경우만 삭제해야 한다)
   
<정답>

CREATE OR REPLACE PACKAGE hr_pkg2 IS

  -- 부서번호를 받아 부서명을 반환하는 함수
  FUNCTION fn_get_dep_name ( pn_department_id IN NUMBER )
     RETURN VARCHAR2;
     
  -- 신규부서 입력  
  PROCEDURE new_emp_proc ( ps_dep_name   IN VARCHAR2, 
                           pn_parent_id  IN NUMBER, 
                           pn_manager_id IN NUMBER);
                               
  -- 부서삭제처리                     
  PROCEDURE del_dep_proc ( pn_department_id IN NUMBER );
  
END  hr_pkg2; 

CREATE OR REPLACE PACKAGE BODY hr_pkg2 IS

  -- 부서번호를 받아 부서명을 반환하는 함수
  FUNCTION fn_get_dep_name ( pn_department_id IN NUMBER )
     RETURN VARCHAR2
  IS
    vs_dep_name departments.department_name%TYPE;
  BEGIN
  
    SELECT department_name
      INTO vs_dep_name
      FROM departments 
     WHERE department_id = pn_department_id;
     
     RETURN vs_dep_name;

     EXCEPTION WHEN OTHERS THEN
           RETURN '해당 부서 없음';
           
  END fn_get_dep_name;
     
  -- 신규부서 입력  
  PROCEDURE new_emp_proc ( ps_dep_name   IN VARCHAR2, 
                           pn_parent_id  IN NUMBER, 
                           pn_manager_id IN NUMBER)
  IS
     vn_max_dep_id departments.department_id%TYPE;
     vn_cnt NUMBER := 0;
  BEGIN
     SELECT COUNT(*)
       INTO vn_cnt
       FROM departments
      WHERE department_name = ps_dep_name;
      
     SELECT NVL(max(department_id),0) + 1
       INTO vn_max_dep_id
       FROM departments;
      
     IF vn_cnt > 0 THEN
        DBMS_OUTPUT.PUT_LINE(ps_dep_name || ' 라는 부서가 이미 존재합니다!');
        RETURN;
     END IF;
     
     INSERT INTO departments (department_id, department_name, parent_id, manager_id, create_date, update_date)
     VALUES (vn_max_dep_id, ps_dep_name, pn_parent_id, pn_manager_id, SYSDATE, SYSDATE);
     
     COMMIT;
     
     EXCEPTION WHEN OTHERS THEN
              DBMS_OUTPUT.PUT_LINE(SQLERRM);
              ROLLBACK;
  END new_emp_proc;
                               
  -- 부서삭제처리                     
  PROCEDURE del_dep_proc ( pn_department_id IN NUMBER )
  IS 
    vn_cnt1 NUMBER := 0;
    vn_cnt2 NUMBER := 0;
  BEGIN
  
    SELECT COUNT(*)
      INTO vn_cnt1
      FROM departments 
     WHERE department_id = pn_department_id;
  
     IF vn_cnt1 = 0 THEN
        DBMS_OUTPUT.PUT_LINE(pn_department_id || ' 부서가 존재하지 않습니다!');
        RETURN;
     END IF;  
     
    SELECT COUNT(*)
      INTO vn_cnt2
      FROM employees 
     WHERE department_id = pn_department_id
       AND retire_date IS NOT NULL;
  
     IF vn_cnt2 > 0 THEN
        DBMS_OUTPUT.PUT_LINE(pn_department_id || ' 부서에 속한 사원이 존재하므로 삭제할 수 없습니다');
        RETURN;
     END IF;       
     
     DELETE departments
      WHERE department_id = pn_department_id;
      
     COMMIT;
     
     EXCEPTION WHEN OTHERS THEN
              DBMS_OUTPUT.PUT_LINE(SQLERRM);
              ROLLBACK;     

  END del_dep_proc;
  
END  hr_pkg2; 


   
2. 오라클에서는 채번을 할 때, 보통 시퀀스 객체를 사용한다. 
   예를 들어, 신규 사원 입력 시 사번을 가져와야 하는데, 이 때 사번 시퀀스를 생성해 놓으면 "사번시퀀스.NEXTVAL"로 다음 순번의 사번을 가져올 수 있다. 
   ch12_seq_pkg란 이름의 패키지에 시퀀스 처럼 동작하도록 get_nextval 이란 함수를 만들어보자. 
   이 함수는 세션별 시퀀스 값을 가져와야 하며 초기값은 1, 1씩 증가하고 세션이 달라지면 다시 초기값을 가져와야 한다. 
   
   
<정답>   

CREATE OR REPLACE PACKAGE ch12_seq_pkg IS
   -- 다음 시퀀스 번호 반환 함수 
    FUNCTION get_nextval RETURN NUMBER;
END ch12_seq_pkg;


CREATE OR REPLACE PACKAGE BODY ch12_seq_pkg IS
    -- 시퀀스 번호를 가진 내부(PRIVATE) 변수 선언 
    cv_seq NUMBER := 0;
    
    -- 다음 시퀀스 번호 반환 함수 
    FUNCTION get_nextval RETURN NUMBER
    IS     
    BEGIN
       -- 1을 증가시킨다. 
       cv_seq := cv_seq + 1;
       -- 시퀀스 번호 반환 
       RETURN cv_seq;
    END get_nextval;
END ch12_seq_pkg;

   
3. 패키지 커서를 사용할 때는 주의해야 한다. 즉, 사용 후 커서를 닫지 않았을 경우, 같은 세션에서 다시 해당 커서를 사용할 때 오류가 발생한다. 
   
   CREATE OR REPLACE PACKAGE ch12_exacur_pkg IS 
       
     -- ROWTYPE형 커서 헤더선언 
     CURSOR pc_depname_cur ( dep_id IN departments.department_id%TYPE ) 
         RETURN departments%ROWTYPE;

   END ch12_exacur_pkg;
   
   ch12_exacur_pkg 패키지의 선언부인데. pc_depname_cur 커서를 사용해 부서정보를 추출하는 프로시저를 추가해보자. 
   단, 이 프로시저 내부에서는 해당 커서의 "열기-패치-닫기" 작업을 수행해야 하며, 
   해당 커서를 열때 혹시라도 닫혀 있지 않을 경우에는 오류를 발생시키지 말고 닫는 작업까지 수행하도록 작성해야 한다. 
   
   
<정답>   

   CREATE OR REPLACE PACKAGE ch12_exacur_pkg IS 
       
     -- ROWTYPE형 커서 헤더선언 
     CURSOR pc_depname_cur ( p_parent_id IN departments.department_id%TYPE ) 
         RETURN departments%ROWTYPE;
         
     -- 커서 처리 프로시저     
     PROCEDURE cur_example_proc ( p_parent_id IN NUMBER);

   END ch12_exacur_pkg;
   
   
   CREATE OR REPLACE PACKAGE BODY ch12_exacur_pkg IS 
       
     -- ROWTYPE형 커서 본문 
     CURSOR pc_depname_cur ( p_parent_id IN departments.department_id%TYPE ) 
         RETURN departments%ROWTYPE
     IS 
        SELECT *
          FROM departments
         WHERE parent_id = p_parent_id;
         
     -- 커서 처리 프로시저     
     PROCEDURE cur_example_proc ( p_parent_id IN NUMBER)
     IS
      -- 커서변수 선언
      dep_cur  ch12_exacur_pkg.pc_depname_cur%ROWTYPE;

     BEGIN
     
       -- 커서가 열려 있으면 커서를 닫는다. 
       IF ch12_exacur_pkg.pc_depname_cur%ISOPEN THEN
          CLOSE ch12_exacur_pkg.pc_depname_cur;
       END IF;
       
       OPEN ch12_exacur_pkg.pc_depname_cur(p_parent_id);

       LOOP
         FETCH ch12_exacur_pkg.pc_depname_cur INTO dep_cur;
         EXIT WHEN ch12_exacur_pkg.pc_depname_cur%NOTFOUND;
         DBMS_OUTPUT.PUT_LINE ( dep_cur.department_id || ' - ' || dep_cur.department_name);
       END LOOP;
       
       -- 커서닫기 
       CLOSE ch12_exacur_pkg.pc_depname_cur;	     
     
     END cur_example_proc;        

   END ch12_exacur_pkg;   
   


4. 다음과 같은 기능을 수행하는 get_dep_hierarchy_proc 란 이름으로 2개의 프로시저를 만들어보자. 
   (1) 매개변수 : department_id
       출력     : 부서 번호와 부서명
       
   (2) 매개변수 : department_id, parent_id
       출력     : 해당 부서번호와 부서명,
                  parent_id에 속하는 모든 부서번호와 부서명
                  
<정답>
                  
CREATE OR REPLACE PACKAGE ch12_exam4_pkg IS

    PROCEDURE get_dep_hierarchy_proc ( p_dep_id IN NUMBER);
    
    PROCEDURE get_dep_hierarchy_proc ( p_dep_id IN NUMBER, 
                                       p_par_id IN NUMBER);

END ch12_exam4_pkg;


CREATE OR REPLACE PACKAGE BODY ch12_exam4_pkg IS

    PROCEDURE get_dep_hierarchy_proc ( p_dep_id IN NUMBER)
    IS
      vn_dep_id    departments.department_id%TYPE;
      vs_dep_name  departments.department_name%TYPE;
    BEGIN
    	
    	SELECT department_id, department_name
    	  INTO vn_dep_id, vs_dep_name
    	  FROM departments
    	 WHERE department_id = p_dep_id;
    	
    	DBMS_OUTPUT.PUT_LINE('부서번호: ' || vn_dep_id);
    	DBMS_OUTPUT.PUT_LINE('부서명 : ' ||  vs_dep_name);
    	
    END get_dep_hierarchy_proc;
    
    PROCEDURE get_dep_hierarchy_proc ( p_dep_id IN NUMBER, 
                                       p_par_id IN NUMBER )
    IS
      vn_dep_id    departments.department_id%TYPE;
      vs_dep_name  departments.department_name%TYPE;   
      
    -- 커서 선언 
    CURSOR my_dep ( p_par_id departments.parent_id%TYPE ) IS
      SELECT department_id AS dep_id, LPAD(' ' , 3 * (LEVEL-1)) || department_name AS dep_nm
        FROM departments
       START WITH parent_id = p_par_id
     CONNECT BY PRIOR department_id  = parent_id;      
    
    BEGIN
    	
    	SELECT department_id, department_name
    	  INTO vn_dep_id, vs_dep_name
    	  FROM departments
    	 WHERE department_id = p_dep_id;
    	
    	DBMS_OUTPUT.PUT_LINE('부서번호: ' || vn_dep_id);
    	DBMS_OUTPUT.PUT_LINE('부서명 : ' ||  vs_dep_name);    
    	
    	FOR rec IN my_dep(p_par_id)
    	LOOP
    	   DBMS_OUTPUT.PUT_LINE( rec.dep_id || ' - ' || rec.dep_nm);
    	
      END LOOP;
    		
    	
    END get_dep_hierarchy_proc;    

END ch12_exam4_pkg;



5. 시스템 패키지인 DBMS_METADATA를 사용해 DBMS_OUTPUT 패키지 소스를 추출해보자. 

<정답>

SELECT DBMS_METADATA.GET_DDL('PACKAGE', 'DBMS_OUTPUT', 'SYS')
  FROM DUAL;

   --소스를 추출해보면 이상한 문자로 가득차 있을 것이다. 그 이유는 dbms_output 시스템 패키지의
   --명세(스펙)은 공용이지만 body 부분은 감춰져있기 때문이다. 

