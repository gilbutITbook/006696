-- SELECT
SELECT  employee_id, emp_name
FROM employees
WHERE salary > 5000;

SELECT  employee_id, emp_name
FROM employees
WHERE salary > 5000
ORDER BY employee_id;


SELECT  employee_id, emp_name
FROM employees
WHERE salary > 5000
  AND job_id = 'IT_PROG'
ORDER BY employee_id;

SELECT  employee_id, emp_name
FROM employees
WHERE salary > 5000
  AND job_id = 'it_prog'
ORDER BY employee_id;

SELECT  employee_id, emp_name
FROM employees
WHERE salary > 5000
   OR job_id = 'IT_PROG'
ORDER BY employee_id;


SELECT a.employee_id, a.emp_name, a.department_id, 
b.department_name AS dep_name
 FROM employees a, 
       departments b
 WHERE a.department_id = b.department_id;



-- INSERT
CREATE TABLE ex3_1 (
    col1   VARCHAR2(10),
    col2   NUMBER,
    col3   DATE    );
    
INSERT INTO ex3_1 (col1, col2, col3)
VALUES ('ABC', 10, SYSDATE);  

INSERT INTO ex3_1 (col3, col1, col2, )
VALUES (SYSDATE, 'DEF', 20, );  

INSERT INTO ex3_1 (col1, col2, col3)
VALUES ('ABC', 10, 30);  




INSERT INTO ex3_1 
VALUES ('GHI', 10, SYSDATE);  

INSERT INTO ex3_1  (col1, col2 )
VALUES ('GHI', 20);

INSERT INTO ex3_1  
VALUES ('GHI', 30);



CREATE TABLE ex3_2 (
       emp_id    NUMBER,
       emp_name  VARCHAR2(100));
       
INSERT INTO ex3_2 ( emp_id, emp_name )
SELECT employee_id, emp_name
 FROM employees
WHERE salary > 5000;
       
       
INSERT INTO ex3_1 (col1, col2, col3)
VALUES (10, '10', '2014-01-01');



       
-- UPDATE
SELECT *
FROM ex3_1;

UPDATE ex3_1
   SET col2 = 50;
   
SELECT *
FROM ex3_1;

UPDATE ex3_1
   SET col3 = SYSDATE
WHERE col3 = '';


UPDATE ex3_1
   SET col3 = SYSDATE
WHERE col3 IS NULL;


   
-- MERGE

CREATE TABLE ex3_3 (
       employee_id NUMBER, 
       bonus_amt   NUMBER DEFAULT 0);

INSERT INTO ex3_3 (employee_id)
SELECT e.employee_id 
  FROM employees e, sales s
 WHERE e.employee_id = s.employee_id
   AND s.SALES_MONTH BETWEEN '200010' AND '200012'
 GROUP BY e.employee_id;
 
SELECT * 
  FROM ex3_3 
 ORDER BY employee_id;  
 
  
 
 SELECT employee_id, manager_id, salary, salary * 0.01
   FROM employees 
  WHERE employee_id IN (  SELECT employee_id
                            FROM ex3_3 ); 
 
 SELECT employee_id, manager_id, salary, salary * 0.001
   FROM employees 
  WHERE employee_id NOT IN (  SELECT employee_id
                                FROM ex3_3 )
    AND manager_id = 146; 
 

MERGE INTO ex3_3 d
     USING (SELECT employee_id, salary, manager_id
              FROM employees
             WHERE manager_id = 146) b
        ON (d.employee_id = b.employee_id)
 WHEN MATCHED THEN 
      UPDATE SET d.bonus_amt = d.bonus_amt + b.salary * 0.01
 WHEN NOT MATCHED THEN 
      INSERT (d.employee_id, d.bonus_amt) VALUES (b.employee_id, b.salary *.001)
       WHERE (b.salary < 8000);
       

 SELECT * 
  FROM ex3_3 
 ORDER BY employee_id;  
 
 
MERGE INTO ex3_3 d
     USING (SELECT employee_id, salary, manager_id
              FROM employees
             WHERE manager_id = 146) b
        ON (d.employee_id = b.employee_id)
 WHEN MATCHED THEN 
      UPDATE SET d.bonus_amt = d.bonus_amt + b.salary * 0.01
      DELETE WHERE (B.employee_id = 161)
 WHEN NOT MATCHED THEN 
      INSERT (d.employee_id, d.bonus_amt) VALUES (b.employee_id, b.salary *.001)
      WHERE (b.salary < 8000);

 SELECT * 
  FROM ex3_3 
 ORDER BY employee_id;  
 
 

 -- DELETE
 DELETE ex3_3;
 
  SELECT * 
  FROM ex3_3 
 ORDER BY employee_id;  
 
SELECT partition_name
  FROM user_tab_partitions
 WHERE table_name = 'SALES';

-- COMMIT, ROLLBACK, TRUNCATE
CREATE TABLE ex3_4 (
       employee_id NUMBER);


INSERT INTO ex3_4 VALUES (100);

SELECT *
  FROM ex3_4;
  
TRUNCATE TABLE ex3_4;



-- 의사컬럼
SELECT ROWNUM, employee_id
  FROM employees;

SELECT ROWNUM, employee_id
FROM employees
WHERE ROWNUM < 5;

SELECT ROWNUM, employee_id, ROWID
FROM employees
WHERE ROWNUM < 5;


-- 연산자
SELECT employee_id || '-' || emp_name AS employee_info
  FROM employees
 WHERE ROWNUM < 5;
 
-- 표현식
 SELECT employee_id, salary, 
         CASE WHEN salary <= 5000 THEN 'C등급'
            WHEN salary > 5000 AND salary <= 15000 THEN 'B등급'
            ELSE 'A등급'
       END AS salary_grade
  FROM employees;
  
-- 조건식
-- 비교조건식

SELECT employee_id, salary 
  FROM employees
WHERE salary = ANY (2000, 3000, 4000)
ORDER BY employee_id;
   
SELECT employee_id, salary 
  FROM employees
WHERE salary = 2000
   OR salary = 3000
   OR salary = 4000
ORDER BY employee_id;   
 
SELECT employee_id, salary 
  FROM employees
WHERE salary = ALL (2000, 3000, 4000)
ORDER BY employee_id;

SELECT employee_id, salary 
  FROM employees
WHERE salary = SOME (2000, 3000, 4000)
ORDER BY employee_id;

-- 논리조건식
SELECT employee_id, salary 
  FROM employees
WHERE NOT ( salary >= 2500)
ORDER BY employee_id;

-- BETWEEN AND 조건식
SELECT employee_id, salary 
  FROM employees
WHERE salary BETWEEN 2000 AND 2500
ORDER BY employee_id;

-- IN 조건식
SELECT employee_id, salary 
  FROM employees
WHERE salary IN (2000, 3000, 4000)
ORDER BY employee_id;

SELECT employee_id, salary 
  FROM employees
WHERE salary NOT IN (2000, 3000, 4000)
ORDER BY employee_id;


-- EXISTS 조건식
SELECT department_id, department_name
  FROM departments a
 WHERE EXISTS ( SELECT * 
                 FROM employees b
                WHERE a.department_id = b.department_id
                  AND b.salary > 3000)
ORDER BY a.department_name;

-- LIKE 조건식
SELECT emp_name
  FROM employees
 WHERE emp_name LIKE 'A%'
 ORDER BY emp_name;
 
SELECT emp_name
  FROM employees
 WHERE emp_name LIKE 'Al%'
 ORDER BY emp_name; 
 
CREATE TABLE ex3_5 (
     names VARCHAR2(30));
     
   
INSERT INTO ex3_5 VALUES ('홍길동');

INSERT INTO ex3_5 VALUES ('홍길용');

INSERT INTO ex3_5 VALUES ('홍길상');

INSERT INTO ex3_5 VALUES ('홍길상동');


SELECT *
  FROM ex3_5
 WHERE names LIKE '홍길%';
 
 SELECT *
  FROM ex3_5
 WHERE names LIKE '홍길_'; 