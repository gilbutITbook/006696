--
1. 101번 사원에 대해 아래의 결과를 산출하는 쿼리를 작성해 보자. 
---------------------------------------------------------------------------------------
사번   사원명   job명칭 job시작일자  job종료일자   job수행부서명
---------------------------------------------------------------------------------------


<정답>
select a.employee_id, a.emp_name, d.job_title, b.start_date, b.end_date, c.department_name
  from employees a,
       job_history b,
       departments c,
       jobs d
 where a.employee_id   = b.employee_id
   and b.department_id = c.department_id
   and b.job_id        = d.job_id
   and a.employee_id = 101;  
   

2. 아래의 쿼리를 수행하면 오류가 발생한다. 오류의 원인은 무엇인가?

select a.employee_id, a.emp_name, b.job_id, b.department_id 
  from employees a,
       job_history b
 where a.employee_id      = b.employee_id(+)
   and a.department_id(+) = b.department_id;
   
<정답>
외부 조인의 경우, 조인조건에서 데이터가 없는 테이블의 컬럼에만 (+)를 붙여야 한다.
따라서 위 쿼리의 경우, and a.department_id(+) = b.department_id 가 아닌 and a.department_id = b.department_id(+)로 고쳐야 한다. 



3. 외부조인시 (+)연산자를 같이 사용할 수 없는데, IN절에 사용하는 값이 1개인 경우는 사용 가능하다. 그 이유는 무엇일까?

<정답>
오라클은 IN 절에 포함된 값을 기준으로 OR로 변환한다.
예를 들어, 
   department_id IN (10, 20, 30) 은
   department_id = 10
   OR department_id = 20
   OR department_id = 30) 로 바꿔 쓸 수 있다.
   
그런데 IN절에 값이 1개인 경우, 즉 department_id IN (10)일 경우 department_id = 10 로 변환할 수 있으므로, 외부조인을 하더라도 값이 1개인 경우는 사용할 수 있다.



4. 다음의 쿼리를 ANSI 문법으로 변경해 보자.

SELECT a.department_id, a.department_name
  FROM departments a, employees b
 WHERE a.department_id = b.department_id
   AND b.salary > 3000
ORDER BY a.department_name;


<정답>
SELECT a.department_id, a.department_name
  FROM departments a
  INNER JOIN employees b
     ON ( a.department_id = b.department_id )
 WHERE b.salary > 3000
ORDER BY a.department_name;



5. 다음은 연관성 있는 서브쿼리이다. 이를 연관성 없는 서브쿼리로 변환해 보자. 

SELECT a.department_id, a.department_name
 FROM departments a
WHERE EXISTS ( SELECT 1 
                 FROM job_history b
                WHERE a.department_id = b.department_id );
                
                

<정답>
SELECT a.department_id, a.department_name
 FROM departments a
WHERE a.department_id IN ( SELECT department_id
                             FROM job_history  );
                             
                             
6. 연도별 이태리 최대매출액과 사원을 작성하는 쿼리를 학습했다. 이 쿼리를 기준으로 최대 매출액 뿐만 아니라 최소매출액과 해당 사원을 조회하는 쿼리를 작성해 보자. 

SELECT emp.years, 
       emp.employee_id,
       emp2.emp_name,
       emp.amount_sold
  FROM ( SELECT SUBSTR(a.sales_month, 1, 4) as years,
                a.employee_id, 
                SUM(a.amount_sold) AS amount_sold
           FROM sales a,
                customers b,
                countries c
          WHERE a.cust_id = b.CUST_ID
            AND b.country_id = c.COUNTRY_ID
            AND c.country_name = 'Italy'     
          GROUP BY SUBSTR(a.sales_month, 1, 4), a.employee_id   
        ) emp,
       ( SELECT  years, 
                 MAX(amount_sold) AS max_sold,
                 MIN(amount_sold) AS min_sold
          FROM ( SELECT SUBSTR(a.sales_month, 1, 4) as years,
                        a.employee_id, 
                        SUM(a.amount_sold) AS amount_sold
                   FROM sales a,
                        customers b,
                        countries c
                  WHERE a.cust_id = b.CUST_ID
                    AND b.country_id = c.COUNTRY_ID
                    AND c.country_name = 'Italy'     
                  GROUP BY SUBSTR(a.sales_month, 1, 4), a.employee_id    
               ) K
          GROUP BY years
       ) sale,
       employees emp2
  WHERE emp.years = sale.years
   AND (emp.amount_sold = sale.max_sold  OR emp.amount_sold = sale.min_sold)
   AND emp.employee_id = emp2.employee_id
  ORDER BY years;
  
  
       
                                    
