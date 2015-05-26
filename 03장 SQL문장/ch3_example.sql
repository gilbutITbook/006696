
1. ex3_6란 테이블을 만들고, 사원테이블(employees)에서 관리자사번이 124번이고 급여가 2000에서 3000 사이에 있는 사원의 사번, 사원명, 급여, 관리자사번을 입력하는
   INSERT문을 작성해보자.
   
   <정답>
   CREATE TABLE ex3_6 ( 
          employee_id  NUMBER(6),
          emp_name     VARCHAR2(80),
          salary       NUMBER(8,2),
          manager_id   NUMBER(6) );
          
   INSERT INTO ex3_6
   SELECT employee_id, emp_name, salary, manager_id
     FROM employees a
    WHERE a.manager_id = 124
      AND a.salary BETWEEN 2000 AND 3000;

2. 다음 문장을 실행해보자. 
DELETE ex3_3;

INSERT INTO ex3_3 (employee_id)
SELECT e.employee_id 
  FROM employees e, sales s
 WHERE e.employee_id = s.employee_id
   AND s.SALES_MONTH BETWEEN '200010' AND '200012'
 GROUP BY e.employee_id;
 
COMMIT;

관리자사번(manager_id)이 145번인 사원을 찾아 위 테이블에 있는 사원의 사번과 일치하면 보너스 금액(bonus_amt)에 자신의 급여의 1%를 보너스로 갱신하고, 
ex3_3 테이블에 있는 사원의 사번과 일치하지 않는 사원을 신규 입력 (이때 보너스 금액은 급여의 0.5%로 한다) 하는 MERGE 문을 작성해 보자.

<정답>

MERGE INTO ex3_3 d
     USING (SELECT employee_id, salary, manager_id
              FROM employees
             WHERE manager_id = 145) b
        ON (d.employee_id = b.employee_id)
 WHEN MATCHED THEN 
      UPDATE SET d.bonus_amt = d.bonus_amt + b.salary * 0.01
 WHEN NOT MATCHED THEN 
      INSERT (d.employee_id, d.bonus_amt) VALUES (b.employee_id, b.salary *.005) ;


3. 사원테이블(employees)에서 커미션(commission_pct) 값이 없는 사원의 사번과 사원명을 추출하는 쿼리를 작성해보자.

<정답>
SELECT employee_id, emp_name
  FROM employees
WHERE commission_pct IS NULL
ORDER BY employee_id;



4. 아래의 쿼리를 논리연산자로 변환해보자. 

SELECT employee_id, salary 
  FROM employees
WHERE salary BETWEEN 2000 AND 2500
ORDER BY employee_id;

<정답>
SELECT employee_id, salary 
  FROM employees
WHERE salary >= 2000 
  AND salary <= 2500
ORDER BY employee_id;


5. 다음의 두 쿼리를 ANY, ALL을 사용해서 동일한 결과를 추출하도록 변경해보자.

SELECT employee_id, salary 
  FROM employees
WHERE salary IN (2000, 3000, 4000)
ORDER BY employee_id;

<정답>
SELECT employee_id, salary 
  FROM employees
WHERE salary = ANY (2000, 3000, 4000)
ORDER BY employee_id;


SELECT employee_id, salary 
  FROM employees
WHERE salary NOT IN (2000, 3000, 4000)
ORDER BY employee_id;

<정답>
SELECT employee_id, salary 
  FROM employees
WHERE salary <> ALL (2000, 3000, 4000)
ORDER BY employee_id;


