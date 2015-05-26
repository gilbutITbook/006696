1. 계층형 쿼리 응용편에서 LISTAGG 함수를 사용해 다음과 같이 로우를 컬럼으로 분리했었다. 
   
  SELECT department_id,
         LISTAGG(emp_name, ',') WITHIN GROUP (ORDER BY emp_name) as empnames
    FROM employees
   WHERE department_id IS NOT NULL
   GROUP BY department_id;
   
  LISTAGG 함수 대신 계층형 쿼리, 분석함수를 사용해서 위 쿼리와 동일한 결과를 산출하는 쿼리를 작성해 보자. 
  
  <정답>
SELECT department_id, 
       SUBSTR(SYS_CONNECT_BY_PATH(emp_name, ','),2) empnames
 FROM ( SELECT emp_name, 
               department_id, 
               COUNT(*) OVER ( partition BY department_id ) cnt, 
               ROW_NUMBER () OVER ( partition BY department_id order BY emp_name) rowseq 
          FROM employees
         WHERE department_id IS NOT NULL) 
 WHERE rowseq = cnt 
 START WITH rowseq = 1 
CONNECT BY PRIOR rowseq + 1 = rowseq 
    AND PRIOR department_id = department_id; 
    
    
2. 아래의 쿼리는 사원테이블에서 JOB_ID가 'SH_CLERK'인 사원을 조회하는 쿼리이다. 

SELECT employee_id, emp_name, hire_date
FROM employees
WHERE job_id = 'SH_CLERK'
ORDER By hire_date; 

EMPLOYEE_ID EMP_NAME             HIRE_DATE         
----------- -------------------- -------------------
        184 Nandita Sarchand     2004/01/27 00:00:00 
        192 Sarah Bell           2004/02/04 00:00:00 
        185 Alexis Bull          2005/02/20 00:00:00 
        193 Britney Everett      2005/03/03 00:00:00 
        188 Kelly Chung          2005/06/14 00:00:00
....        
....
        199 Douglas Grant        2008/01/13 00:00:00
        183 Girard Geoni         2008/02/03 00:00:00

사원테이블에서 퇴사일자(retire_date)는 모두 비어있는데, 위 결과에서 사원번호가 184인 사원의 퇴사일자는 다음으로 입사일자가 빠른 192번 사원의 입사일자라고 가정해서
다음과 같은 형태로 결과를 추출해낼 수 있도록 쿼리를 작성해 보자. (입사일자가 가장 최근인 183번 사원의 퇴사일자는 NULL이다)

EMPLOYEE_ID EMP_NAME             HIRE_DATE             RETIRE_DATE
----------- -------------------- -------------------  ---------------------------
        184 Nandita Sarchand     2004/01/27 00:00:00  2004/02/04 00:00:00
        192 Sarah Bell           2004/02/04 00:00:00  2005/02/20 00:00:00
        185 Alexis Bull          2005/02/20 00:00:00  2005/03/03 00:00:00
        193 Britney Everett      2005/03/03 00:00:00  2005/06/14 00:00:00
        188 Kelly Chung          2005/06/14 00:00:00  2005/08/13 00:00:00
....        
....
        199 Douglas Grant        2008/01/13 00:00:00  2008/02/03 00:00:00
        183 Girard Geoni         2008/02/03 00:00:00
        
        
<정답>
SELECT employee_id, emp_name, hire_date,
       LEAD(hire_date) OVER ( PARTITION BY JOB_ID ORDER BY HIRE_DATE) AS retire_date
FROM employees
WHERE job_id = 'SH_CLERK'
ORDER BY hire_date;


3. sales 테이블에는 판매데이터, customers 테이블에는 고객정보가 있다. 2001년 12월(SALES_MONTH = '200112') 판매데이터 중
   현재일자를 기준으로 고객의 나이(customers.cust_year_of_birth)를 계산해서 다음과 같이 연령대별 매출금액을 보여주는 쿼리를 작성해 보자.
   
-------------------------   
연령대    매출금액
-------------------------
10대      xxxxxx
20대      ....
30대      .... 
40대      ....
-------------------------   
   
<정답>
WITH basis AS ( SELECT WIDTH_BUCKET(to_char(sysdate, 'yyyy') - b.cust_year_of_birth, 10, 90, 8) AS old_seg,
                       TO_CHAR(SYSDATE, 'yyyy') - b.cust_year_of_birth as olds,
                       s.amount_sold
                  FROM sales s, 
                       customers b
                 WHERE s.sales_month = '200112'
                   AND s.cust_id = b.CUST_ID
              ),
     real_data AS ( SELECT old_seg * 10 || ' 대' AS old_segment,
                           SUM(amount_sold) as old_seg_amt
                      FROM basis
                     GROUP BY old_seg
              )
 SELECT *
 FROM real_data
 ORDER BY old_segment;   
 
 
4. 3번 문제를 이용해 월별로 판매금액이 가장 하위에 속하는 대륙 목록을 뽑아보자.
   ( 대륙목록은 countries 테이블의 country_region에 있으며, country_id 컬럼으로 customers 테이블과 조인을 해서 구한다.)
   
---------------------------------   
매출월    지역(대륙)  매출금액 
---------------------------------
199801    Oceania      xxxxxx
199803    Oceania      xxxxxx
...
---------------------------------

<정답>
WITH basis AS ( SELECT c.country_region, s.sales_month, SUM(s.amount_solD) AS amt
                  FROM sales s, 
                       customers b,
                       countries c
                 WHERE s.cust_id = b.CUST_ID
                   AND b.COUNTRY_ID = c.COUNTRY_ID
                 GROUP BY c.country_region, s.sales_month
              ),
     real_data AS ( SELECT sales_month, 
                           country_region,
                           amt,
                           RANK() OVER ( PARTITION BY sales_month ORDER BY amt ) ranks
                      FROM basis
                   )
 select *
 from real_data
 where ranks = 1;




5. 5장 연습문제 5번의 정답 결과를 이용해 다음과 같이 지역별, 대출종류별, 월별 대출잔액과 지역별 파티션을 만들어 대출종류별 대출잔액의 %를 구하는 쿼리를 작성해보자. 

------------------------------------------------------------------------------------------------
지역    대출종류        201111         201112    201210    201211   201212   203110    201311
------------------------------------------------------------------------------------------------
서울    기타대출       73996.9( 36% )
서울    주택담보대출   130105.9( 64% ) 
부산
...
...
-------------------------------------------------------------------------------------------------

  <정답>
WITH basis AS (
SELECT REGION, GUBUN,
       SUM(AMT1) AS AMT1, 
       SUM(AMT2) AS AMT2, 
       SUM(AMT3) AS AMT3, 
       SUM(AMT4) AS AMT4, 
       SUM(AMT5) AS AMT5, 
       SUM(AMT6) AS AMT6, 
       SUM(AMT6) AS AMT7 
  FROM ( 
         SELECT REGION,
                GUBUN,
                CASE WHEN PERIOD = '201111' THEN LOAN_JAN_AMT ELSE 0 END AMT1,
                CASE WHEN PERIOD = '201112' THEN LOAN_JAN_AMT ELSE 0 END AMT2,
                CASE WHEN PERIOD = '201210' THEN LOAN_JAN_AMT ELSE 0 END AMT3, 
                CASE WHEN PERIOD = '201211' THEN LOAN_JAN_AMT ELSE 0 END AMT4, 
                CASE WHEN PERIOD = '201212' THEN LOAN_JAN_AMT ELSE 0 END AMT5, 
                CASE WHEN PERIOD = '201310' THEN LOAN_JAN_AMT ELSE 0 END AMT6,
                CASE WHEN PERIOD = '201311' THEN LOAN_JAN_AMT ELSE 0 END AMT7
         FROM KOR_LOAN_STATUS
       )
GROUP BY REGION, GUBUN
)   
SELECT REGION, 
       GUBUN,
       AMT1 || '( ' || ROUND(RATIO_TO_REPORT(amt1) OVER ( PARTITION BY REGION ),2) * 100 || '% )' AS "201111",
       AMT2 || '( ' || ROUND(RATIO_TO_REPORT(amt2) OVER ( PARTITION BY REGION ),2) * 100 || '% )' AS "201112",
       AMT3 || '( ' || ROUND(RATIO_TO_REPORT(amt3) OVER ( PARTITION BY REGION ),2) * 100 || '% )' AS "201210",
       AMT4 || '( ' || ROUND(RATIO_TO_REPORT(amt4) OVER ( PARTITION BY REGION ),2) * 100 || '% )' AS "201211",
       AMT5 || '( ' || ROUND(RATIO_TO_REPORT(amt5) OVER ( PARTITION BY REGION ),2) * 100 || '% )' AS "201212",
       AMT6 || '( ' || ROUND(RATIO_TO_REPORT(amt6) OVER ( PARTITION BY REGION ),2) * 100 || '% )' AS "201310",
       AMT7 || '( ' || ROUND(RATIO_TO_REPORT(amt7) OVER ( PARTITION BY REGION ),2) * 100 || '% )' AS "201311"
FROM basis
ORDER BY REGION;


