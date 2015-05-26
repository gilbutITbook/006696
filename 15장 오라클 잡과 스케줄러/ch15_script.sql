-- 02. DBMS_JOB
-- (1) DBMS_JOB의 프로시저

CREATE TABLE ch15_job_test (
             seq          NUMBER,
             insert_date  DATE);
             
CREATE OR REPLACE PROCEDURE ch15_job_test_proc 
IS
  vn_next_seq  NUMBER;
BEGIN
	-- 다음 순번을 가져온다. 
	SELECT NVL(MAX(seq), 0) + 1
	  INTO vn_next_seq
	  FROM ch15_job_test;
	  
	INSERT INTO ch15_job_test VALUES ( vn_next_seq, SYSDATE);
	
	COMMIT;
	
EXCEPTION WHEN OTHERS THEN
     ROLLBACK;
     DBMS_OUTPUT.PUT_LINE(SQLERRM);
	
END;             


-- 잡 등록 
DECLARE 
  v_job_no NUMBER;
BEGIN
	-- 현재시간 기준 1분에 1번씩 ch15_job_test_proc 프로시저를 실행하는 잡 등록 
	DBMS_JOB.SUBMIT  ( job => v_job_no, what => 'ch15_job_test_proc;', next_date => SYSDATE, interval => 'SYSDATE + 1/60/24' );
	COMMIT;
	-- 시스템에서 자동생성된 잡 번호 출력
	DBMS_OUTPUT.PUT_LINE('v_job_no : ' || v_job_no);
END;

SELECT SEQ, TO_CHAR(INSERT_DATE, 'YYYY-MM-DD HH24:MI:SS')
FROM ch15_job_test;

SELECT job, last_date, last_sec, next_date, next_sec, broken, interval, failures, what
FROM   user_jobs;

-- 잡의 중지, 그리고 재실행 
BEGIN 
 -- 잡의 중지 
 DBMS_JOB.BROKEN(30, TRUE); 
 COMMIT;
END; 

SELECT job, last_date, last_sec, next_date, next_sec, broken, interval, failures, what
FROM   user_jobs;


BEGIN 
 -- 잡 재실행 
 DBMS_JOB.BROKEN(30, FALSE); 
 COMMIT;
END; 

SELECT job, last_date, last_sec, next_date, next_sec, broken, interval, failures, what
FROM   user_jobs;

SELECT SEQ, TO_CHAR(INSERT_DATE, 'YYYY-MM-DD HH24:MI:SS')
FROM ch15_job_test;

-- 잡 속성 변경
BEGIN 
 -- 잡 재실행 
 DBMS_JOB.CHANGE(job => 30, what => 'ch15_job_test_proc;', next_date => SYSDATE, interval => 'SYSDATE + 3/60/24'); 
 COMMIT;
END; 

SELECT job, last_date, last_sec, next_date, next_sec, broken, interval, failures, what
FROM   user_jobs;

SELECT SEQ, TO_CHAR(INSERT_DATE, 'YYYY-MM-DD HH24:MI:SS') AS DATES
FROM ch15_job_test;

-- 잡의 실행 
BEGIN 
 -- 잡 강제실행
 DBMS_JOB.RUN(30);
 COMMIT;
END; 


-- 잡의 삭제
BEGIN 
 -- 잡 삭제
 DBMS_JOB.REMOVE(30);
 COMMIT;
END; 

SELECT job, last_date, last_sec, next_date, next_sec, broken, interval, failures, what
FROM   user_jobs;

-- DBMS_SCHEDULER
-- 프로그램 객체 생성

BEGIN
   DBMS_SCHEDULER.CREATE_PROGRAM (
        program_name => 'my_program1',
        program_type => 'STORED_PROCEDURE',
        program_action => 'ch15_job_test_proc ',
        comments => '첫번째 프로그램');
END;

SELECT program_name, program_type, program_action, number_of_arguments, enabled, comments
FROM USER_SCHEDULER_PROGRAMS;

-- 스케줄 객체 생성

BEGIN
   DBMS_SCHEDULER.CREATE_SCHEDULE (
        schedule_name => 'my_schedule1',
        start_date => NULL,
        repeat_interval => 'FREQ=MINUTELY; INTERVAL=1',
        end_date => NULL,
        comments => '1분마다 수행');
END;


SELECT schedule_name, schedule_type, start_date, repeat_interval, end_date, comments
FROM USER_SCHEDULER_SCHEDULES;

-- 잡 객체 생성(버전1)

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
       job_name            => 'my_job1',
       job_type            => 'STORED_PROCEDURE',
       job_action          => 'ch15_job_test_proc ',
       repeat_interval     => 'FREQ=MINUTELY; INTERVAL=1',
       comments            => '버전1 잡객체' );
END;

SELECT job_name, job_style, job_type, job_action, repeat_interval, enabled, auto_drop, state, comments
FROM USER_SCHEDULER_JOBS;

TRUNCATE TABLE ch15_job_test;

-- MY_JOB1 활성화

BEGIN
  DBMS_SCHEDULER.ENABLE ('my_job1');
END;  

SELECT job_name, job_style, job_type, job_action, repeat_interval, enabled, auto_drop, state, comments
FROM USER_SCHEDULER_JOBS;


SELECT SEQ, TO_CHAR(INSERT_DATE, 'YYYY-MM-DD HH24:MI:SS')
FROM ch15_job_test;


SELECT log_id, log_date, job_name, operation, status
FROM USER_SCHEDULER_JOB_LOG;

SELECT log_date, job_name, status, error#, req_start_date, actual_start_date, run_duration
FROM USER_SCHEDULER_JOB_RUN_DETAILS;

-- 버전 2 잡 객체 생성

BEGIN
  DBMS_SCHEDULER.DISABLE ('my_job1');
END;  

TRUNCATE TABLE ch15_job_test;

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
       job_name            => 'my_job2',
       program_name        => 'MY_PROGRAM1',
       schedule_name       => 'MY_SCHEDULE1',
       comments            => '버전2 잡 객체' );
END;


SELECT job_name, program_name, job_type, job_action, schedule_name, schedule_type, repeat_interval,  enabled, auto_drop, state, comments
FROM USER_SCHEDULER_JOBS;


-- my_job2 활성화 
BEGIN
  DBMS_SCHEDULER.ENABLE ('my_job2');
END;  

SELECT SEQ, TO_CHAR(INSERT_DATE, 'YYYY-MM-DD HH24:MI:SS')
FROM ch15_job_test;

-- my_program1 활성화 
BEGIN
  DBMS_SCHEDULER.ENABLE ('my_program1');
END;  

SELECT SEQ, TO_CHAR(INSERT_DATE, 'YYYY-MM-DD HH24:MI:SS')
FROM ch15_job_test;


SELECT log_date, job_name, status, error#, req_start_date, actual_start_date, run_duration
FROM USER_SCHEDULER_JOB_RUN_DETAILS
WHERE JOB_NAME = 'MY_JOB2';

-- 외부 프로그램 실행
TRUNCATE TABLE ch15_job_test;

SELECT SEQ, TO_CHAR(INSERT_DATE, 'YYYY-MM-DD HH24:MI:SS')
FROM ch15_job_test;

-- 잡 객체 생성
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
       job_name            => 'MY_EX_JOB1',   -- 잡 명
       job_type            => 'EXECUTABLE',   -- 외부 실행파일
       number_of_arguments => 2,              -- 매개변수가 2개라는 의미
       job_action          => 'c:\windows\system32\cmd.exe',   -- 윈도우의 CMD.EXE를 실행
       repeat_interval     => 'FREQ=MINUTELY; INTERVAL=1',     -- 1분에 1회씩 수행
       comments            => '외부파일 실행 잡객체' );        -- 잡 설명 
       
      DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE('MY_EX_JOB1',1,'/c');                     -- 매개변수1
      DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE('MY_EX_JOB1',2,'c:\scheduler_test.bat');  -- 매개변수2 (실제 배치파일)
      
      DBMS_SCHEDULER.ENABLE ('MY_EX_JOB1'); -- 잡 활성화 
END;


SELECT SEQ, TO_CHAR(INSERT_DATE, 'YYYY-MM-DD HH24:MI:SS')
FROM ch15_job_test;


SELECT log_date, job_name, status, error#, req_start_date, actual_start_date, run_duration
FROM USER_SCHEDULER_JOB_RUN_DETAILS
WHERE JOB_NAME = 'MY_EX_JOB1';


-- 체인

CREATE TABLE ch15_changed_object ( 
    
    OBJECT_NAME      VARCHAR2(128),   -- 객체 명
    OBJECT_TYPE      VARCHAR2(50),    -- 객체 유형
    CREATED          DATE,            -- 객체 생성일자
    LAST_DDL_TIME    DATE,            -- 객체 변경일자
    STATUS           VARCHAR2(7),     -- 객체 상태
    CREATION_DATE    DATE             -- 생성일자
     );
     
     
CREATE OR REPLACE PROCEDURE ch15_check_objects_prc 
IS
  vn_cnt  NUMBER := 0;
BEGIN
	
	-- 일주일간 변경된 객체 중 ch15_changed_object에 없는 객체만 찾는다. 
	-- 왜냐하면 이전 프로시저 수행 시 변경된 객체가 있으면 이미 ch15_changed_object에 입력됐기 때문 
	SELECT COUNT(*)
	INTO   vn_cnt
  FROM USER_OBJECTS a
  WHERE LAST_DDL_TIME BETWEEN SYSDATE - 7
                          AND SYSDATE
    AND NOT EXISTS ( SELECT 1
                       FROM ch15_changed_object b
                      WHERE a.object_name = b.object_name);                

  -- 변경된 객체가 없으면 RAISE_APPLICATION_ERROR를 발생시켜 에러코드를 넘긴다. 
  -- 에러코드를 넘기는 이유는 룰에서 처리하기 위함이다.                           
  IF vn_cnt = 0 THEN
     RAISE_APPLICATION_ERROR(-20001, '변경된 객체 없음');  
  END IF;                         
	
	
END;     


CREATE OR REPLACE PROCEDURE ch15_make_objects_prc
IS 

BEGIN 
	
	INSERT INTO ch15_changed_object (
	            object_name, object_type, 
	            created,     last_ddl_time,
	            status,      creation_date )
  SELECT object_name, object_type, 
         created,     last_ddl_time,
         status,      SYSDATE
   FROM  USER_OBJECTS a
  WHERE LAST_DDL_TIME BETWEEN SYSDATE - 7
                          AND SYSDATE
    AND NOT EXISTS ( SELECT 1
                       FROM ch15_changed_object b
                      WHERE a.object_name = b.object_name);     	   
                      
  COMMIT;
  
EXCEPTION WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
      RAISE_APPLICATION_ERROR(-20002, SQLERRM);
      ROLLBACK;
END;

-- 프로그램 객체 생성
BEGIN
	 -- ch15_check_objects_prc에 대한 프로그램 객체 생성
   DBMS_SCHEDULER.CREATE_PROGRAM (
        program_name   => 'MY_CHAIN_PROG1',
        program_type   => 'STORED_PROCEDURE',
        program_action => 'ch15_check_objects_prc',
        comments       => '첫번째 체인 프로그램');
        
	 -- ch15_make_objects_prc에 대한 프로그램 객체 생성        
   DBMS_SCHEDULER.CREATE_PROGRAM (
        program_name   => 'MY_CHAIN_PROG2',
        program_type   => 'STORED_PROCEDURE',
        program_action => 'ch15_make_objects_prc',
        comments       => '두번째 체인 프로그램'); 
        
   -- 프로그램 객체 활성화      
   DBMS_SCHEDULER.ENABLE ('MY_CHAIN_PROG1');   
   DBMS_SCHEDULER.ENABLE ('MY_CHAIN_PROG2');   
           
END;

-- 체인 생성
BEGIN
  DBMS_SCHEDULER.CREATE_CHAIN (
       chain_name          => 'MY_CHAIN1',
       rule_set_name       => NULL,
       evaluation_interval => NULL,
       comments            => '첫 번째 체인');
END;

-- 스텝 생성
BEGIN
	-- STEP1
	DBMS_SCHEDULER.DEFINE_CHAIN_STEP(
	     chain_name   => 'MY_CHAIN1',
	     step_name    => 'STEP1', 
	     program_name => 'MY_CHAIN_PROG1');
	     
  -- STEP2
	DBMS_SCHEDULER.DEFINE_CHAIN_STEP(
	     chain_name   => 'MY_CHAIN1',
	     step_name    => 'STEP2', 
	     program_name => 'MY_CHAIN_PROG2');
END;

-- 룰 생성

BEGIN
  -- 최초 STEP1을 시작시키는 룰 
  DBMS_SCHEDULER.DEFINE_CHAIN_RULE (
       chain_name => 'MY_CHAIN1',
       condition  => 'TRUE',
       action     => 'START STEP1',
       rule_name  => 'MY_RULE1',
       comments   => 'START 룰' );
		
END;


BEGIN
  -- 두 번째 룰, 일주일간 변경된 객체가 없다면 종료로 빠진다.
  -- 이는 STEP1을 실행해 그 결과로 오류코드를 받았을 때 종료하도록 처리한다. 
  DBMS_SCHEDULER.DEFINE_CHAIN_RULE (
       chain_name => 'MY_CHAIN1',
       condition  => 'STEP1 ERROR_CODE = 20001',
       action     => 'END',
       rule_name  => 'MY_RULE2',
       comments   => '룰2' );
		
END;

BEGIN
  -- STEP1에서 STEP2로 가는 룰
  DBMS_SCHEDULER.DEFINE_CHAIN_RULE (
       chain_name => 'MY_CHAIN1',
       condition  => 'STEP1 SUCCEEDED',
       action     => 'START STEP2',
       rule_name  => 'MY_RULE3',
       comments   => '룰3' );
       
  -- STEP2를 마치로 종료하는 룰 
  DBMS_SCHEDULER.DEFINE_CHAIN_RULE (
       chain_name => 'MY_CHAIN1',
       condition  => 'STEP2 SUCCEEDED',
       action     => 'END',
       rule_name  => 'MY_RULE4',
       comments   => '룰4' );   
END;

-- 잡 객체 생성	
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
       job_name            => 'MY_CHAIN_JOBS',
       job_type            => 'CHAIN',
       job_action          => 'MY_CHAIN1',
       repeat_interval     => 'FREQ=MINUTELY; INTERVAL=1',
       comments            => '체인을 실행하는 잡' );
END;	
	
SELECT *
FROM user_scheduler_chains;

SELECT chain_name, step_name, program_name, step_type, skip, pause
FROM user_scheduler_chain_steps;

SELECT *
FROM user_scheduler_chain_rules;

BEGIN
	-- 체인 활성화
	DBMS_SCHEDULER.ENABLE('MY_CHAIN1');
	
	-- 잡 활성화
	DBMS_SCHEDULER.ENABLE('MY_CHAIN_JOBS');	
	
END;


select log_date, job_subname, operation, status, additional_info
from user_scheduler_job_log
where job_name = 'MY_CHAIN_JOB';

SELECT log_date, job_subname, status, actual_start_date, run_duration, additional_info
FROM user_scheduler_job_run_details
WHERE job_name = 'MY_CHAIN_JOB';


SELECT *
FROM ch15_changed_object
ORDER BY OBJECT_NAME;