-- 15장 연습문제 


1. DBMS_STATS 패키지의 GATHER_TABLE_STATS 프로시저는 테이블과 컬럼의 통계정보를 수집하는 프로시저이다. 
   테이블 통계정보란 테이블에 대한 각종 정보를 취합한 정보로 이는 오라클 내부엔진(옵티마이저)가 SQL 실행계획을 만들대 참조하는 정보이다. 
   GATHER_TABLE_STATS 프로시저의 사용법은 다음과 같다. 
   
   EXEC DBMS_STATS.GATHER_TABLE_STATS ( 소유자명, 테이블명 );
   
   USER_TABLES 시스템 뷰를 읽어 각 테이블에 대해 통계정보를 생성하는 프로시저를 ch15__example1_prc란 이름으로 만들어보자. 
   
   
<정답>

CREATE OR REPLACE PROCEDURE ch15__example1_prc 
IS 
  vs_owner   VARCHAR2(30) := 'ORA_USER'; -- 오라클설치 환경에 따라 소유자명은 다름...
  vs_tab_nm  VARCHAR2(100);
BEGIN

  FOR C_TAB IN ( SELECT TABLE_NAME
                   FROM USER_TABLES 
                )
  LOOP
    vs_tab_nm := C_TAB.TABLE_NAME;
    
    DBMS_STATS.GATHER_TABLE_STATS ( vs_owner, vs_tab_nm );

  END LOOP;

END; 
   
   
2. DBMS_JOB 패키지를 사용해 매일 오후 5시에 한 번씩 테이블 통계정보를 생성하는 잡을 만들어보자. 


<정답>

DECLARE 
  v_job_no NUMBER;
BEGIN
  
  DBMS_JOB.SUBMIT  ( 
    job       => v_job_no, 
    what      => 'ch15__example1_prc;', 
    next_date =>  SYSDATE, 
    interval  => 'TRUNC(SYSDATE) + 17/24' );

  COMMIT;
  
END;  
  

3. 2와 같은 작업을 만드는데 이번에는 DBMS_SCHEDULER 패키지를 사용해(잡 패키지만 사용해) 만들어보자. 

<정답>
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
       job_name        => 'MY_EX_JOB1',
       job_type        => 'STORED_PROCEDURE',
       job_action      => 'ch15__example1_prc ',
       repeat_interval => 'FREQ=DAILY; INTERVAL=1; BYHOUR=17;',
       comments        => '연습문제15-3' );
END;



4. 3과 동일한 잡을 만드는데 이번에는 프로그램 객체, 스케줄 객체를 사용해 만들어보자. 

<정답>

BEGIN
   DBMS_SCHEDULER.CREATE_PROGRAM (
        program_name   => 'MY_EX_PRG1',
        program_type   => 'STORED_PROCEDURE',
        program_action => 'ch15__example1_prc ',
        comments       => '연습문제15-4');
END;

BEGIN
   DBMS_SCHEDULER.CREATE_SCHEDULE (
        schedule_name   => 'MY_EX_SCH1',
        start_date      => NULL,
        repeat_interval => 'FREQ=DAILY; INTERVAL=1; BYHOUR=17;',
        end_date        => NULL,
        comments        => '연습문제15-4');
END;


BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
       job_name            => 'MY_EX_JOB2',
       program_name        => 'MY_EX_PRG1',
       schedule_name       => 'MY_EX_SCH1',
       comments            => '연습문제15-4' );
END;
