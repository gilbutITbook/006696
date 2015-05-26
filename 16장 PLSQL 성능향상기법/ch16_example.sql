-- 16장 연습문제 


1. RESULT CACHE 절에서 V$RESULT_CACHE_STATISTICS 시스템뷰를 조회했을 때 'Find Count' 항목의 값이 107988 이었다. 
   이 숫자가 어떻게 나오게 된 것인지 설명해보자. 
   
<정답>
첨부 엑셀 파일 참조. 


2. JOBS 테이블에서 JOB_ID 값을 매개변수로 받아 JOB_TITLE을 반환하는 RESULT CACHE 기능을 이용한 함수를 만들어 보자. 

<정답>

CREATE OR REPLACE FUNCTION fn_get_jobtitle_rsltcache ( pv_job_id VARCHAR2 )
     RETURN VARCHAR2
     RESULT_CACHE
     RELIES_ON ( JOBS )
IS
   vs_job_title  JOBS.JOB_TITLE%TYPE;
BEGIN
	
	SELECT job_title
	  INTO vs_job_title
	  FROM JOBS
	 WHERE job_id = pv_job_id;
	 
  RETURN vs_job_title;
  
EXCEPTION WHEN OTHERS THEN
  RETURN '';	
	
END;


3. 3번에서 만든 함수를 이용해 EMP_BULK 테이블의 JOB_TITLE 컬럼 값을 갱신하는 익명블록을 만들어보자. 


<정답>

DECLARE
  vn_cnt        NUMBER := 0;
  vd_sysdate    DATE;
vn_total_time NUMBER := 0;  

BEGIN
  vd_sysdate := SYSDATE;
  -- RESULT CACHE 기능이 탑재된 함수 호출
  UPDATE emp_bulk
     SET job_title = fn_get_jobtitle_rsltcache ( job_id )
   WHERE bulk_id BETWEEN 1 AND 1000;
  
  vn_cnt := SQL%ROWCOUNT;
  
  COMMIT;

  -- 총 소요시간 계산 (초로 계산하기 위해 * 60 * 60 * 24을 곱함)
  vn_total_time := (SYSDATE - vd_sysdate) * 60 * 60 * 24;
  
 -- UPDATE 건수 출력
  DBMS_OUTPUT.PUT_LINE('전체건수 : ' || vn_cnt);
  -- 총 소요시간 출력
  DBMS_OUTPUT.PUT_LINE('소요시간 : ' || vn_total_time);  

END;



   