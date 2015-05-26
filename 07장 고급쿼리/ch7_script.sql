-- 계층형 쿼리


SELECT department_id, 
       department_name, 
       0 AS PARENT_ID,
       1 as levels,
        parent_id || department_id AS sort
FROM departments 
WHERE parent_id IS NULL
UNION ALL
SELECT t2.department_id, 
       LPAD(' ' , 3 * (2-1)) || t2.department_name AS department_name, 
       t2.parent_id,
       2 AS levels,
       t2.parent_id || t2.department_id AS sort
FROM departments t1,
     departments t2
WHERE t1.parent_id is null
  AND t2.parent_id = t1.department_id
UNION ALL
SELECT t3.department_id, 
       LPAD(' ' , 3 * (3-1)) || t3.department_name AS department_name, 
       t3.parent_id,
       3 as levels,
       t2.parent_id || t3.parent_id || t3.department_id as sort
FROM departments t1,
     departments t2,
     departments t3
WHERE t1.parent_id IS NULL
  AND t2.parent_id = t1.department_id
  AND t3.parent_id = t2.department_id
UNION ALL
SELECT t4.department_id, 
       LPAD(' ' , 3 * (4-1)) || t4.department_name as department_name, 
       t4.parent_id,
       4 as levels,
       t2.parent_id || t3.parent_id || t4.parent_id || t4.department_id AS sort
FROM departments t1,
     departments t2,
     departments t3,
     departments t4
WHERE t1.parent_id IS NULL
  AND t2.parent_id = t1.department_id
  AND t3.parent_id = t2.department_id
  and t4.parent_id = t3.department_id
ORDER BY sort;


SELECT department_id, LPAD(' ' , 3 * (LEVEL-1)) || department_name, LEVEL
  FROM departments
  START WITH parent_id IS NULL
  CONNECT BY PRIOR department_id  = parent_id;
  
  
SELECT a.employee_id, LPAD(' ' , 3 * (LEVEL-1)) || a.emp_name, 
       LEVEL,
       b.department_name
  FROM employees a,
       departments b
 WHERE a.department_id = b.department_id
 START WITH a.manager_id IS NULL
 CONNECT BY PRIOR a.employee_id = a.manager_id;


SELECT a.employee_id, LPAD(' ' , 3 * (LEVEL-1)) || a.emp_name, 
       LEVEL,
       b.department_name, a.DEPARTMENT_ID
  FROM employees a,
       departments b
 WHERE a.department_id = b.department_id
   AND a.department_id = 30
 START WITH a.manager_id IS NULL
 CONNECT BY NOCYCLE PRIOR a.employee_id = a.manager_id;


SELECT a.employee_id, LPAD(' ' , 3 * (LEVEL-1)) || a.emp_name, 
       LEVEL,
       b.department_name, a.DEPARTMENT_ID
  FROM employees a,
       departments b
 WHERE a.department_id = b.department_id
 START WITH a.manager_id IS NULL
 CONNECT BY NOCYCLE PRIOR a.employee_id = a.manager_id
     AND a.department_id = 30;
  
  
SELECT department_id, LPAD(' ' , 3 * (LEVEL-1)) || department_name, LEVEL
  FROM departments
  START WITH parent_id IS NULL
  CONNECT BY PRIOR department_id  = parent_id
  ORDER BY department_name;  
  
SELECT department_id, LPAD(' ' , 3 * (LEVEL-1)) || department_name, LEVEL
  FROM departments
  START WITH parent_id IS NULL
  CONNECT BY PRIOR department_id  = parent_id
  ORDER SIBLINGS BY department_name;    
  
SELECT department_id, LPAD(' ' , 3 * (LEVEL-1)) || department_name, LEVEL, CONNECT_BY_ROOT
  FROM departments
  START WITH parent_id IS NULL
  CONNECT BY PRIOR department_id  = parent_id
  ORDER SIBLINGS BY department_name;      
  
SELECT department_id, LPAD(' ' , 3 * (LEVEL-1)) || department_name, LEVEL, 
       CONNECT_BY_ROOT department_name AS root_name
  FROM departments
  START WITH parent_id IS NULL
  CONNECT BY PRIOR department_id  = parent_id;
  
  
SELECT department_id, LPAD(' ' , 3 * (LEVEL-1)) || department_name, LEVEL, CONNECT_BY_ISLEAF
  FROM departments
  START WITH parent_id IS NULL
  CONNECT BY PRIOR department_id  = parent_id;  
  
SELECT department_id, LPAD(' ' , 3 * (LEVEL-1)) || department_name, LEVEL, 
       SYS_CONNECT_BY_PATH( department_name, '|')
  FROM departments
  START WITH parent_id IS NULL
  CONNECT BY PRIOR department_id  = parent_id;   
  
  
SELECT department_id, LPAD(' ' , 3 * (LEVEL-1)) || department_name, LEVEL, 
       SYS_CONNECT_BY_PATH( department_name, '/')
  FROM departments
  START WITH parent_id IS NULL
  CONNECT BY PRIOR department_id  = parent_id;     
  
  
UPDATE departments
   SET parent_id = 170
 WHERE department_id = 30;
 
SELECT department_id, LPAD(' ' , 3 * (LEVEL-1)) || department_name, LEVEL, 
       parent_id
  FROM departments
  START WITH department_id = 30
CONNECT BY PRIOR department_id  = parent_id; 


SELECT department_id, LPAD(' ' , 3 * (LEVEL-1)) || department_name AS depname, LEVEL, 
       CONNECT_BY_ISCYCLE IsLoop,
       parent_id
  FROM departments
  START WITH department_id = 30
CONNECT BY NOCYCLE PRIOR department_id  = parent_id; 

  
-- 계층형 쿼리 응용 
-- 샘플 데이터 생성  
  
CREATE TABLE ex7_1 AS  
SELECT ROWNUM seq, 
       '2014' || LPAD(CEIL(ROWNUM/1000) , 2, '0' ) month,
        ROUND(DBMS_RANDOM.VALUE (100, 1000)) amt
FROM DUAL
CONNECT BY LEVEL <= 12000;

SELECT *
  FROM ex7_1;
  
SELECT month, SUM(amt)
FROM ex7_1
GROUP BY month
ORDER BY month;

SELECT ROWNUM
FROM (
       SELECT 1 AS row_num
         FROM DUAL
        UNION ALL
       SELECT 1 AS row_num
         FROM DUAL
)
CONNECT BY LEVEL <= 4;
  
-- 로우를 컬럼으로

CREATE TABLE ex7_2 AS
  SELECT department_id,
         listagg(emp_name, ',') WITHIN GROUP (ORDER BY emp_name) as empnames
  FROM employees
 WHERE department_id IS NOT NULL
  GROUP BY department_id;
  
  
SELECT *
FROM ex7_2;

-- 컬럼을 로우로
  
SELECT empnames,
       DECODE(level, 1, 1, instr(empnames, ',', 1, level-1)) st,
       INSTR(empnames, ',', 1, level) ed,
       LEVEL as lvl
 FROM ( SELECT empnames || ',' as empnames,
               LENGTH(empnames) ori_len,
               LENGTH(REPLACE(empnames, ',', '')) new_len
          FROM ex7_2
         WHERE department_id = 90
       )
 CONNECT BY LEVEL <= ori_len - new_len + 1;
 
 
SELECT empnames,
       DECODE(level, 1, 1, INSTR(empnames, ',', 1, LEVEL-1)) start_pos,
       INSTR(empnames, ',', 1, LEVEL) end_pos,
       LEVEL as lvl
  FROM (  SELECT empnames || ',' as empnames,
                 LENGTH(empnames) ori_len,
                 LENGTH(REPLACE(empnames, ',', '')) new_len
            FROM ex7_2
           WHERE department_id = 90
        )
  CONNECT BY LEVEL <= ori_len - new_len + 1; 
  
  
SELECT REPLACE(SUBSTR(empnames, start_pos, end_pos - start_pos), ',', '') AS emp
FROM ( SELECT empnames,
              DECODE(level, 1, 1, INSTR(empnames, ',', 1, level-1)) start_pos,
              INSTR(empnames, ',', 1, LEVEL) end_pos,
              LEVEL as lvl
      FROM (  SELECT empnames || ',' as empnames,
                     LENGTH(empnames) ori_len,
                     LENGTH(REPLACE(empnames, ',', '')) new_len
                FROM ex7_2
               WHERE department_id = 90
           )
      CONNECT BY LEVEL <= ori_len - new_len + 1
) ;
                  
  
-- WITH 절
  
SELECT b2.*
FROM ( SELECT period, region, sum(loan_jan_amt) jan_amt
         FROM kor_loan_status 
         GROUP BY period, region
      ) b2,      
      ( SELECT b.period,  MAX(b.jan_amt) max_jan_amt
         FROM ( SELECT period, region, sum(loan_jan_amt) jan_amt
                  FROM kor_loan_status 
                 GROUP BY period, region
              ) b,
              ( SELECT MAX(PERIOD) max_month
                  FROM kor_loan_status
                 GROUP BY SUBSTR(PERIOD, 1, 4)
              ) a
         WHERE b.period = a.max_month
         GROUP BY b.period
      ) c   
 WHERE b2.period = c.period
   AND b2.jan_amt = c.max_jan_amt
 ORDER BY 1;


WITH b2 AS ( SELECT period, region, sum(loan_jan_amt) jan_amt
               FROM kor_loan_status 
              GROUP BY period, region
           ),
     c AS ( SELECT b.period,  MAX(b.jan_amt) max_jan_amt
              FROM ( SELECT period, region, sum(loan_jan_amt) jan_amt
                      FROM kor_loan_status 
                     GROUP BY period, region
                   ) b,
                   ( SELECT MAX(PERIOD) max_month
                       FROM kor_loan_status
                      GROUP BY SUBSTR(PERIOD, 1, 4)
                   ) a
             WHERE b.period = a.max_month
             GROUP BY b.period
           )
SELECT b2.*
  FROM b2, c
 WHERE b2.period = c.period
   AND b2.jan_amt = c.max_jan_amt
 ORDER BY 1;           
           
           
-- 순환 서브쿼리
           
SELECT department_id, LPAD(' ' , 3 * (LEVEL-1)) || department_name, LEVEL
  FROM departments
  START WITH parent_id IS NULL
  CONNECT BY PRIOR department_id  = parent_id;
  
WITH recur ( department_id, parent_id, department_name, lvl)
        AS ( SELECT department_id, parent_id, department_name, 1 AS lvl
               FROM departments
              WHERE parent_id IS NULL
              UNION ALL
             SELECT a.department_id, a.parent_id, a.department_name, b.lvl + 1 
               FROM departments a, recur b
              WHERE a.parent_id = b.department_id 
              )             
SELECT department_id, LPAD(' ' , 3 * (lvl-1)) || department_name, lvl
 FROM recur;
 
 
WITH recur ( department_id, parent_id, department_name, lvl)
        AS ( SELECT department_id, parent_id, department_name, 1 AS lvl
               FROM departments
              WHERE parent_id IS NULL
              UNION ALL
             SELECT a.department_id, a.parent_id, a.department_name, b.lvl + 1 
               FROM departments a, recur b
              WHERE a.parent_id = b.department_id 
              )       
SEARCH DEPTH FIRST BY department_id SET order_seq                       
SELECT department_id, LPAD(' ' , 3 * (lvl-1)) || department_name, lvl, order_seq
 FROM recur; 


-- 분석함수

SELECT department_id, emp_name, 
       ROW_NUMBER() OVER (PARTITION BY department_id 
                          ORDER BY emp_name ) dep_rows
  FROM employees;
  
  
SELECT department_id, emp_name, 
       salary,
       RANK() OVER (PARTITION BY department_id 
                    ORDER BY salary ) dep_rank
  FROM employees;
  
SELECT department_id, emp_name, 
       salary,
       DENSE_RANK() OVER (PARTITION BY department_id 
                    ORDER BY salary ) dep_rank
  FROM employees;
  
SELECT *
FROM ( SELECT department_id, emp_name, 
              salary, 
              DENSE_RANK() OVER (PARTITION BY department_id 
                                 ORDER BY salary desc) dep_rank
         FROM employees
     )
WHERE dep_rank <= 3;  
    
    
SELECT department_id, emp_name, 
       salary,
       CUME_DIST() OVER (PARTITION BY department_id 
                         ORDER BY salary ) dep_dist
  FROM employees;    
  
  
SELECT department_id, emp_name, 
       salary
      ,rank() OVER (PARTITION BY department_id 
                         ORDER BY salary ) raking
      ,CUME_DIST() OVER (PARTITION BY department_id 
                         ORDER BY salary ) cume_dist_value
      ,PERCENT_RANK() OVER (PARTITION BY department_id 
                         ORDER BY salary ) percentile
  FROM employees
WHERE department_id = 60;  

SELECT department_id, emp_name, 
       salary
      ,NTILE(4) OVER (PARTITION BY department_id 
                         ORDER BY salary 
                      ) NTILES
  FROM employees
WHERE department_id IN (30, 60) ;

SELECT emp_name, hire_date, salary,
       LAG(salary, 1, 0)  OVER (ORDER BY hire_date) AS prev_sal,
       LEAD(salary, 1, 0) OVER (ORDER BY hire_date) AS next_sal
  FROM employees
 WHERE department_id = 30;
 
SELECT emp_name, hire_date, salary,
       LAG(salary, 2, 0)  OVER (ORDER BY hire_date) AS prev_sal,
       LEAD(salary, 2, 0) OVER (ORDER BY hire_date) AS next_sal
  FROM employees
 WHERE department_id = 30;
 
 
-- Window절
 
SELECT department_id, emp_name, hire_date, salary,
       SUM(salary) OVER (PARTITION BY department_id ORDER BY hire_Date
                         ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                         ) AS all_salary,
       SUM(salary) OVER (PARTITION BY department_id ORDER BY hire_Date
                         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                         ) AS first_current_sal,
       SUM(salary) OVER (PARTITION BY department_id ORDER BY hire_Date
                         ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
                         ) AS current_end_sal
  FROM employees
 WHERE department_id IN (30, 90);
 
SELECT department_id, emp_name, hire_date, salary,
       SUM(salary) OVER (PARTITION BY department_id ORDER BY hire_Date
                         RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                         ) AS all_salary,
       SUM(salary) OVER (PARTITION BY department_id ORDER BY hire_Date
                         RANGE 365 PRECEDING
                         ) AS range_sal1,
       SUM(salary) OVER (PARTITION BY department_id ORDER BY hire_Date
                         RANGE BETWEEN 365 PRECEDING AND CURRENT ROW
                         ) AS range_sal2
  FROM employees
 WHERE department_id = 30; 
 
 
SELECT department_id, emp_name, hire_date, salary,
       FIRST_VALUE(salary) OVER (PARTITION BY department_id ORDER BY hire_Date
                                 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                ) AS all_salary,
       FIRST_VALUE(salary) OVER (PARTITION BY department_id ORDER BY hire_Date
                                 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                                ) AS fr_st_to_current_sal,
       FIRST_VALUE(salary) OVER (PARTITION BY department_id ORDER BY hire_Date
                                 ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
                                ) AS fr_current_to_end_sal
  FROM employees
 WHERE department_id IN (30, 90); 
 
 
 SELECT department_id, emp_name, hire_date, salary,
       LAST_VALUE(salary) OVER (PARTITION BY department_id ORDER BY hire_Date
                                ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                ) AS all_salary,
       LAST_VALUE(salary) OVER (PARTITION BY department_id ORDER BY hire_Date
                                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                                ) AS fr_st_to_current_sal,
       LAST_VALUE(salary) OVER (PARTITION BY department_id ORDER BY hire_Date
                                ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
                                ) AS fr_current_to_end_sal
  FROM employees
 WHERE department_id IN (30, 90); 
 
 
SELECT department_id, emp_name, hire_date, salary,
       NTH_VALUE(salary, 2) OVER (PARTITION BY department_id ORDER BY hire_Date
                                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                 ) AS all_salary,
       NTH_VALUE(salary, 2) OVER (PARTITION BY department_id ORDER BY hire_Date
                                  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                                 ) AS fr_st_to_current_sal,
       NTH_VALUE(salary,2 ) OVER (PARTITION BY department_id ORDER BY hire_Date
                                  ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
                                 ) AS fr_current_to_end_sal
  FROM employees
 WHERE department_id IN (30, 90) ; 
 
-- 기타 분석 함수 

SELECT department_id, emp_name, 
       salary
      ,NTILE(4) OVER (PARTITION BY department_id 
                         ORDER BY salary 
                      ) NTILES
      ,WIDTH_BUCKET(salary, 1000, 10000, 4) widthbuacket
  FROM employees
WHERE department_id = 60; 

WITH basis AS ( SELECT period, region, SUM(loan_jan_amt) jan_amt
                  FROM kor_loan_status
                 GROUP BY period, region
              ), 
    basis2 as ( SELECT period, MIN(jan_amt) min_amt, MAX(jan_amt) max_amt
                  FROM basis
                 GROUP BY period
              )
 SELECT a.period, 
        b.region "최소지역", b.jan_amt "최소금액",
        c.region "최대지역", c.jan_amt "최대금액"
   FROM basis2 a, basis b, basis c
  WHERE a.period  = b.period
    AND a.min_amt = b.jan_amt 
    AND a.period  = c.period
    AND a.max_amt = c.jan_amt
  ORDER BY 1, 2;
 
 
WITH basis AS (
               SELECT period, region, SUM(loan_jan_amt) jan_amt
                 FROM kor_loan_status
                GROUP BY period, region
              )
SELECT a.period, 
       MIN(a.region) KEEP ( DENSE_RANK FIRST ORDER BY jan_amt) "최소지역", 
       MIN(jan_amt) "최소금액", 
       MAX(a.region) keep ( DENSE_RANK LAST ORDER BY jan_amt) "최대지역",
       MAX(jan_amt) "최대금액"
FROM basis a
GROUP BY a.period
ORDER BY 1, 2;

SELECT department_id, emp_name, hire_date, salary,
       ROUND(RATIO_TO_REPORT(salary) OVER (PARTITION BY department_id 
                                ),2) * 100 AS salary_percent
  FROM employees
 WHERE department_id IN (30, 90); 
 
 
-- 다중 테이블 INSERT
-- 여러 개의 INSERT문을 한 방에 처리
CREATE TABLE ex7_3 (
       emp_id    NUMBER,
       emp_name  VARCHAR2(100));


CREATE TABLE ex7_4 (
       emp_id    NUMBER,
       emp_name  VARCHAR2(100));
       
INSERT INTO ex7_3 VALUES (101, '홍길동'); 

INSERT INTO ex7_3 VALUES (102, '김유신');       

INSERT ALL
INTO ex7_3 VALUES (103, '강감찬')
INTO ex7_3 VALUES (104, '연개소문')
SELECT *
FROM DUAL;

INSERT ALL
INTO ex7_3 VALUES (emp_id, emp_name)
SELECT 103 emp_id, '강감찬' emp_name
FROM DUAL
UNION ALL
SELECT 104 emp_id, '연개소문' emp_name
FROM DUAL;


INSERT ALL
INTO ex7_3 VALUES (105, '가가가')
INTO ex7_4 VALUES (105, '나나나')
SELECT *
FROM DUAL;

-- 조건에 따른 다중 INSERT
TRUNCATE TABLE ex7_3;

TRUNCATE TABLE ex7_4;


INSERT ALL
WHEN department_id = 30 THEN
  INTO ex7_3 VALUES (employee_id, emp_name)
WHEN department_id = 90 THEN
  INTO ex7_4 VALUES (employee_id, emp_name)
SELECT department_id, 
       employee_id, emp_name 
FROM  employees;


CREATE TABLE ex7_5 (
       emp_id    NUMBER,
       emp_name  VARCHAR2(100));
       
INSERT ALL
WHEN department_id = 30 THEN
  INTO ex7_3 VALUES (employee_id, emp_name)
WHEN department_id = 90 THEN
  INTO ex7_4 VALUES (employee_id, emp_name)
ELSE
  INTO ex7_5 VALUES (employee_id, emp_name)
SELECT department_id, 
       employee_id, emp_name 
FROM  employees;
       
       
SELECT COUNT(*)
FROM EX7_5;
       
SELECT department_id, employee_id, emp_name,  salary
FROM employees
WHERE department_id = 30;

INSERT ALL
WHEN employee_id < 116 THEN
  INTO ex7_3 VALUES (employee_id, emp_name)
WHEN  salary < 5000 THEN
  INTO ex7_4 VALUES (employee_id, emp_name)
SELECT department_id, employee_id, emp_name,  salary
FROM   employees
WHERE  department_id = 30;  


SELECT *
FROM ex7_3;

SELECT *
FROM ex7_4;

INSERT FIRST
WHEN employee_id < 116 THEN
  INTO ex7_3 VALUES (employee_id, emp_name)
WHEN  salary < 5000 THEN
  INTO ex7_4 VALUES (employee_id, emp_name)
SELECT department_id, employee_id, emp_name,  salary
FROM   employees
WHERE  department_id = 30;   


