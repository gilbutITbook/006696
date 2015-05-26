-- 17장 연습문제 


1. 사원 테이블(employees)을 참조하고 있는 모든 프로그램을 찾는 2가지 방법을 설명하라. 

<정답>
1. USER_SOURCE 시스템 뷰에서 TEXT 컬럼 값에 사원테이블명, 즉 employees란 명칭이 있는지 검색한다. 

SELECT *
FROM USER_SOURCE
WHERE TEXT LIKE '%EMPLOYEES%'
OR    TEXT LIKE '%employees%';

2. USER_DEPENDENCIES 시스템 뷰에서 REFERENCED_NAME 컬럼 값이 사원테이블명이 있는지 검색한다. 
SELECT *
FROM  USER_DEPENDENCIES
WHERE REFERENCED_NAME = 'EMPLOYEES';


2. "디버깅 기법 - 로그 테이블" 절에서 로그 테이블에 로그를 남기는 루틴을 SALES_DETAIL_PRC 프로시저에 추가했다.
   그런데 자세히 보면 로그 테이블에 데이터를 쌓는 부분은 별도의 BEGIN ~ END 절로 묶어놨는데, 그 이유는 무엇일까?

<정답>   
SALES_DETAIL_PRC 프로시저가 수행되면서 만약 오류가 나면 예외처리부로 제어가 옮겨져 ROLLBACK이 된다. 
그런데 오류가 발생해 ROLLBACK 되더라도 로그 테이블에는 오류내역이 입력되어야 하기 때문에,
별도의 BEGIN ~END 절로 묶어 트랜잭션 처리를 따로 한 것이다. 
   
   
3. 로그 테이블에 로그를 쌓는 루틴을 하나의 프로시저로 만들어보자. 단, 독립적 트랜잭션 처리를 하도록 해야 한다. 

<정답>   

CREATE OR REPLACE PROCEDURE my_log_prc ( pn_log_id   NUMBER    -- 로그 아이디
                                        ,ps_prg_name VARCHAR2  -- 프로그램명
                                        ,ps_param    VARCHAR2  -- 파라미터
                                        ,ps_status   VARCHAR2  -- 구분(START, END, ERROR)
                                        ,ps_desc     VARCHAR2  -- 로그내용
                                       )
IS
  PRAGMA AUTONOMOUS_TRANSACTION;  -- 독립적 트랜잭션 처리
BEGIN
	-- ps_status, 구분 값에 따라 처리루틴을 달리한다. 
	
  IF ps_status = 'START' THEN   -- 시작로그일 경우 
  
     INSERT INTO program_log (
  	                log_id, 
  	                program_name, 
  	                parameters, 
  	                state, 
  	                start_time )
           VALUES ( pn_log_id,
                    ps_prg_name,  
                    ps_param,
                    'Running',
                    SYSTIMESTAMP);  
  
  ELSIF ps_status = 'END' THEN -- 종료로그일 경우 
  
      UPDATE program_log
         SET state    = 'Completed',
             end_time = SYSTIMESTAMP,
             log_desc = ps_desc || '작업종료!'
      WHERE log_id    = pn_log_id;
  
  ELSIF ps_status = 'ERROR' THEN  -- 에러로그일 경우 
  
      UPDATE program_log
         SET state   = 'Error',
             end_time = SYSTIMESTAMP,
             log_desc = ps_desc
       WHERE log_id   = pn_log_id; 
  
  END IF;
  
  COMMIT;
  
EXCEPTION WHEN OTHERS THEN 
   ROLLBACK;
   DBMS_OUTPUT.PUT_LINE('LOG ERROR : ' || SQLERRM);  
	
	
END;


4. 추가된 로그루틴을 제거하고 대신 3번에서 만든 만든 프로시저로 대체하도록 SALES_DETAIL_PRC 프로시저를 수정해보자. 

<정답>      

CREATE OR REPLACE PACKAGE BODY ch17_src_test_pkg IS
  
  PROCEDURE sales_detail_prc ( ps_month IN VARCHAR2, 
                               pn_amt   IN NUMBER,
                               pn_rate  IN NUMBER   )
  IS
     vn_total_time NUMBER := 0;     -- 소요시간 계산용 변수 
     
     vn_log_id       NUMBER;          -- 로그 아이디 
     vs_parameters  VARCHAR2(500);   -- 매개변수   
     vs_prg_log      VARCHAR2(2000);  -- 로그내용
  BEGIN
    -- 매개변수와 그 값을 가져온다 
    vs_parameters := 'ps_month => ' || ps_month || ', pn_amt => ' || pn_amt || ' , pn_rate => ' || pn_rate;
  	
      -- 로그 아이디 값 생성
      vn_log_id := prg_log_seq.NEXTVAL;  	    

      -- 로그 프로시저 호출 (시작 -> START)
      my_log_prc ( vn_log_id, 'ch17_src_test_pkg.sales_detail_prc', vs_parameters, 'START', '' );                  
                                       
  	
    --1. p_month에 해당하는 월의 CH17_SALES_DETAIL 데이터 삭제
    vn_total_time := DBMS_UTILITY.GET_TIME;
	      
    DELETE CH17_SALES_DETAIL
     WHERE sales_month = ps_month;
     
    -- DELETE 소요시간 계산 (초로 계산하기 위해 100으로 나눈다)
    vn_total_time := (DBMS_UTILITY.GET_TIME - vn_total_time) / 100;
    
    -- DELETE 로그 내용 만들기
    vs_prg_log :=  'DELETE 건수 : ' || SQL%ROWCOUNT || ' , 소요시간: ' || vn_total_time || CHR(13); 
     
    --2. p_month에 해당하는 월의 CH17_SALES_DETAIL 데이터 생성
    vn_total_time := DBMS_UTILITY.GET_TIME;
    
    INSERT INTO CH17_SALES_DETAIL
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
           
    -- INSERT 소요시간 계산(초로 계산하기 위해 100으로 나눈다)
    vn_total_time := (DBMS_UTILITY.GET_TIME - vn_total_time)  / 100;    
    
    -- INSERT 로그 내용 만들기
    vs_prg_log :=  vs_prg_log || 'INSERT 건수 : ' || SQL%ROWCOUNT || ' , 소요시간: ' || vn_total_time || CHR(13);                 
           
    -- 3. 판매금액(sales_amt)이 pn_amt 보다 큰 건은 pn_rate 비율 만큼 할인한다.
    vn_total_time := DBMS_UTILITY.GET_TIME;
    
    UPDATE CH17_SALES_DETAIL
       SET sales_amt = sales_amt - ( sales_amt * pn_rate * 0.01)
     WHERE sales_month = ps_month
       AND sales_amt   > pn_amt;
       
    -- UPDATE 소요시간 계산 (초로 계산하기 위해 100으로 나눈다)
    vn_total_time := (DBMS_UTILITY.GET_TIME - vn_total_time)  / 100; 
      
    -- UPDATE 로그 내용 만들기
    vs_prg_log :=  vs_prg_log || 'UPDATE 건수 : ' || SQL%ROWCOUNT || ' , 소요시간: ' || vn_total_time || CHR(13);          

    COMMIT; 
    
    -- 로그 프로시저 호출 (종료 -> END)
    my_log_prc ( vn_log_id, '', '', 'END', vs_prg_log);                   
    
    
  EXCEPTION WHEN OTHERS THEN
  
    -- 로그 프로시저 호출 (오류 -> ERROR)
    my_log_prc ( vn_log_id, '', '', 'ERROR', vs_prg_log);  
                 
        ROLLBACK;   
  
  END sales_detail_prc;
END ch17_src_test_pkg; 



   

   
