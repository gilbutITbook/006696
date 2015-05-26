

1. 사원테이블에서 입사년도별 사원수를 구하는 쿼리를 작성해보자. 

<정답>

SELECT TO_CHAR(hire_date, 'YYYY') AS hire_year,
       COUNT(*)
  FROM employees
GROUP BY TO_CHAR(hire_date, 'YYYY')
ORDER BY TO_CHAR(hire_date, 'YYYY');

2. kor_loan_status 테이블에서 2012년도 월별, 지역별 대출 총 잔액을 구하는 쿼리를 작성하라. 

<정답>

SELECT period, region, SUM(loan_jan_amt)
FROM kor_loan_status
WHERE period LIKE '2012%'
GROUP BY period, region
ORDER BY period, region;


3. 아래의 쿼리는 분할 ROLLUP을 적용한 쿼리이다.

SELECT period, gubun, SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period LIKE '2013%' 
 GROUP BY period, ROLLUP( gubun );
 
 이 쿼리를 ROLLUP을 사용하지 않고, 집합연산자를 사용해서 동일한 결과가 나오도록 쿼리를 작성해보자. 
 
<정답>
SELECT period, gubun, SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period LIKE '2013%' 
 GROUP BY period,  gubun
UNION 
SELECT period, '', SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period LIKE '2013%' 
 GROUP BY period;  
 
 
4. 다음 쿼리를 실행해서 결과를 확인한 후, 집합 연산자를 사용해 동일한 결과를 추출하도록 쿼리를 작성해 보자. 

SELECT period, 
       CASE WHEN gubun = '주택담보대출' THEN SUM(loan_jan_amt) ELSE 0 END 주택담보대출액,
       CASE WHEN gubun = '기타대출'     THEN SUM(loan_jan_amt) ELSE 0 END 기타대출액 
  FROM kor_loan_status
 WHERE period = '201311' 
 GROUP BY period, gubun;
 
 <정답>
SELECT period, SUM(loan_jan_amt) 주택담보대출액, 0 기타대출액
  FROM kor_loan_status
 WHERE period = '201311' 
   AND gubun = '주택담보대출'
 GROUP BY period, gubun
 UNION ALL
SELECT period, 0 주택담보대출액, SUM(loan_jan_amt) 기타대출액
  FROM kor_loan_status
 WHERE period = '201311' 
   AND gubun = '기타대출'
 GROUP BY period, gubun ;


5. 다음과 같은 형태, 즉 지역과 각 월별 대출총잔액을 구하는 쿼리를 작성해 보자.

---------------------------------------------------------------------------------------
지역   201111   201112    201210    201211   201212   203110    201311
---------------------------------------------------------------------------------------
서울   
부산
...
...
---------------------------------------------------------------------------------------

<정답>

SELECT REGION, 
       SUM(AMT1) AS "201111", 
       SUM(AMT2) AS "201112", 
       SUM(AMT3) AS "201210", 
       SUM(AMT4) AS "201211", 
       SUM(AMT5) AS "201312", 
       SUM(AMT6) AS "201310",
       SUM(AMT6) AS "201311"
  FROM ( 
         SELECT REGION,
                CASE WHEN PERIOD = '201111' THEN LOAN_JAN_AMT ELSE 0 END AMT1,
                CASE WHEN PERIOD = '201112' THEN LOAN_JAN_AMT ELSE 0 END AMT2,
                CASE WHEN PERIOD = '201210' THEN LOAN_JAN_AMT ELSE 0 END AMT3, 
                CASE WHEN PERIOD = '201211' THEN LOAN_JAN_AMT ELSE 0 END AMT4, 
                CASE WHEN PERIOD = '201212' THEN LOAN_JAN_AMT ELSE 0 END AMT5, 
                CASE WHEN PERIOD = '201310' THEN LOAN_JAN_AMT ELSE 0 END AMT6,
                CASE WHEN PERIOD = '201311' THEN LOAN_JAN_AMT ELSE 0 END AMT7
         FROM KOR_LOAN_STATUS
       )
GROUP BY REGION
ORDER BY REGION       
;