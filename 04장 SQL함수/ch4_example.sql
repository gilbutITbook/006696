
1. 사원테이블(employees)에는 phone_number라는 컬럼에 사원의 전화번호가 ###.###.#### 형태로 저장되어 있다.
여기서 처음 3자리 숫자 대신 서울 지역번호인 (02)를 붙여 전화번호를 출력하도록 쿼리를 작성해 보자.

<정답>

SELECT employee_id,
       LPAD(SUBSTR(phone_number, 5), 12, '(02)')
  FROM employees;


2. 현재일자 기준으로 사원테이블의 입사일자(hire_date)를 참조해서 근속년수가 10년 이상인 사원을 다음과 같은 형태의 결과를 출력하도록 쿼리를 작성해보자. 
   (근속년수가 많은 사원순서대로 결과를 나오도록 하자)

--------------------------------------
사원번호  사원명  입사일자 근속년수
--------------------------------------


<정답>

SELECT employee_id, emp_name, HIRE_DATE, 
       ROUND((sysdate - hire_date) / 365)
  FROM employees
 WHERE ROUND((sysdate - hire_date) / 365) >= 10
 ORDER BY 3;
 
 
3. 고객 테이블(CUSTOMERS)에는 고객 전화번호(cust_main_phone_number) 컬럼이 있다. 이 컬럼 값은 ###-###-#### 형태인데,
   '-' 대신 '/'로 바꿔 출력하는 쿼리를 작성해 보자.
   
   
<정답>

SELECT cust_name, cust_main_phone_number, 
       REPLACE(cust_main_phone_number, '-', '/') new_phone_number
  FROM customers;


4. 고객 테이블(CUSTOMERS)의 고객 전화번호(cust_main_phone_number) 컬럼을 다른 문자로 대체(일종의 암호화)하도록 쿼리를 작성해 보자.


<정답>

SELECT cust_name, cust_main_phone_number, 
       TRANSLATE(cust_main_phone_number, '0123456789', 'acielsifke') new_phone_number
  FROM customers;
   
   

5. 고객 테이블(CUSTOMERS)에는 고객의 출생년도(cust_year_of_birth) 컬럼이 있다. 현재일 기준으로 이 컬럼을 활용해
   30대, 40대, 50대를 구분해 출력하고, 나머지 연령대는 '기타'로 출력하는 쿼리를 작성해보자. 
   
<정답>

SELECT CUST_NAME, 
       CUST_YEAR_OF_BIRTH, 
       DECODE( TRUNC((TO_CHAR(SYSDATE, 'YYYY') - CUST_YEAR_OF_BIRTH)/10), 3, '30대', 
                                                                          4, '40대',
                                                                          5, '50대',
                                                                          '기타') generation
FROM CUSTOMERS;   

6. 4번 문제는 30~50대 까지만 표시했는데, 전 연령대를 표시하도록 쿼리를 작성하는데, 
   이번에는 DECODE 대신 CASE 표현식을 사용해보자. 
   
<정답>
   
SELECT CUST_NAME, 
       CUST_YEAR_OF_BIRTH, 
       CASE WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - CUST_YEAR_OF_BIRTH)/10)  BETWEEN  1 AND 19 THEN '10대'
            WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - CUST_YEAR_OF_BIRTH)/10)  BETWEEN 20 AND 29 THEN '20대'
            WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - CUST_YEAR_OF_BIRTH)/10)  BETWEEN 30 AND 39 THEN '30대'
            WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - CUST_YEAR_OF_BIRTH)/10)  BETWEEN 40 AND 49 THEN '40대'
            WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - CUST_YEAR_OF_BIRTH)/10)  BETWEEN 50 AND 59 THEN '50대'
            WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - CUST_YEAR_OF_BIRTH)/10)  BETWEEN 60 AND 69 THEN '60대'
            WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - CUST_YEAR_OF_BIRTH)/10)  BETWEEN 70 AND 79 THEN '70대'
          ELSE '기타' END AS new_generation
FROM CUSTOMERS;     


