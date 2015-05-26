
1. 다음과 같은 기능을 수행하는 프로시저를 만들어 보자. 

   (1) 프로시저명 : ch13_exam_crt_table_proc
   (2) 매개변수   : 테이블명 (pv_src_table )
   (3) 내용       : - 매개변수로 넘어온 테이블과 동일한 구조의 테이블을 생성하는데, 새로 생성하는 테이블명은 기존 테이블명에 '_NEW'를 붙여 생성한다. 
                    - NDS 방식으로 만든다. 

<정답>

CREATE OR REPLACE PROCEDURE ch13_exam_crt_table_proc ( pv_src_table IN VARCHAR2 )
IS
  vs_sql       VARCHAR2(1000);
  vs_new_table VARCHAR2(100) := pv_src_table || '_NEW';
BEGIN
	-- 테이블 생성
	vs_sql := 'CREATE TABLE ' || vs_new_table || ' AS SELECT * FROM ' || pv_src_table;
	
	EXECUTE IMMEDIATE vs_sql;
	
END;



2. ch13_exam_crt_table_proc 프로시저에서 생성할 테이블이 이미 있으면 생성하지 않도록 수정해 보자. 


<정답>

CREATE OR REPLACE PROCEDURE ch13_exam_crt_table_proc ( pv_src_table IN VARCHAR2 )
IS
  vs_sql       VARCHAR2(1000);
  vs_new_table VARCHAR2(100) := pv_src_table || '_NEW';
BEGIN
	
	-- 테이블 생성
	vs_sql := 'CREATE TABLE ' || vs_new_table || ' AS SELECT * FROM ' || pv_src_table;
	
	EXECUTE IMMEDIATE vs_sql;
	
EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
	
END;

3. ch13_physicist 테이블에 대한 복사본 테이블을 만들고 복사본 데이터를 지운 다음, 
   다시 ch13_physicist 테이블의 데이터를 선택해 변수에 담은 다음 이 변수를 이용해 복사본 테이블에 데이터를 넣는 익명블록을 만들어 보자. 
   
  
<정답>
DECLARE 
  -- 커서타입 선언
  TYPE query_physicist  IS REF CURSOR;
  -- 커서 변수 선언
  myPhysicist  query_physicist;
  -- 반환값을 받을 레코드 선언
  empPhysicist  ch13_physicist%ROWTYPE;
  
  vs_new_table  VARCHAR2(50) := 'ch13_physicist_new';
  vs_insert_sql VARCHAR2(1000);
  vs_select_sql VARCHAR2(1000);

BEGIN
	-- 신규 테이블 생성
	ch13_exam_crt_table_proc ('ch13_physicist');
	-- 데이터 삭제
	EXECUTE IMMEDIATE  'TRUNCATE TABLE ' || vs_new_table;
	
	-- 먼저 원천 테이블 데이터를 선택한다. 
  vs_select_sql := 'SELECT * FROM ch13_physicist';
  
  OPEN myPhysicist  FOR  vs_select_sql;
  
  --루프를 돌며 커서변수에 담긴 값을 출력한다.
  LOOP
    FETCH myPhysicist  INTO  empPhysicist;
    EXIT WHEN myPhysicist%NOTFOUND;	
    
    -- 새로운 테이블에 INSERT 한다. 
    vs_insert_sql := 'INSERT INTO ' || vs_new_table || ' VALUES ( ' || empPhysicist.ids || ',' || '''' || empPhysicist.names || '''' || ',' || 
                     'TO_DATE(' || '''' || empPhysicist.birth_dt || '''' ||  ' ))';
                     
    EXECUTE IMMEDIATE vs_insert_sql;                 
  END LOOP;
  -- 커서를 닫는다
  CLOSE myPhysicist;
  
  COMMIT;
  
END;  

	
4. 3 번에서 작성한 익명블록을 DBMS_SQL 패키지로 변환해 작성해보자. 

<정답>

DECLARE 
  vn_ids        ch13_physicist.ids%TYPE;
  vs_names      ch13_physicist.names%TYPE;
  vd_birth_dt   ch13_physicist.birth_dt%TYPE;
  
  vs_new_table  VARCHAR2(50) := 'ch13_physicist_new';
  vs_insert_sql VARCHAR2(1000);
  vs_select_sql VARCHAR2(1000);
  
  vn_sel_cur_id NUMBER := DBMS_SQL.OPEN_CURSOR(); 
  vn_ins_cur_id NUMBER := DBMS_SQL.OPEN_CURSOR(); 
  
  vn_sel_return NUMBER;
  vn_ins_return NUMBER;

BEGIN
	-- 신규 테이블 생성
	ch13_exam_crt_table_proc ('ch13_physicist');
	-- 데이터 삭제
	EXECUTE IMMEDIATE  'TRUNCATE TABLE ' || vs_new_table;
	
	-- 먼저 원천 테이블 데이터를 선택한다. 
  vs_select_sql := 'SELECT * FROM ch13_physicist';
  
  DBMS_SQL.PARSE (vn_sel_cur_id, vs_select_sql, DBMS_SQL.NATIVE);  
  
  DBMS_SQL.DEFINE_COLUMN ( vn_sel_cur_id, 1, vn_ids);
  DBMS_SQL.DEFINE_COLUMN ( vn_sel_cur_id, 2, vs_names, 80);   
  DBMS_SQL.DEFINE_COLUMN ( vn_sel_cur_id, 3, vd_birth_dt);
  
  vn_sel_return := DBMS_SQL.EXECUTE (vn_sel_cur_id);
  
  -- INSERT문 처리
  vs_insert_sql := 'INSERT INTO ' || vs_new_table || ' VALUES (:a, :b, :c)';
  DBMS_SQL.PARSE (vn_ins_cur_id, vs_insert_sql, DBMS_SQL.NATIVE);
  
  LOOP
    -- 결과건수가 없으면 루프를 빠져나간다. 
    IF DBMS_SQL.FETCH_ROWS (vn_sel_cur_id) = 0 THEN
       EXIT;
    END IF;
    
    --  패치된 결과값 받아오기 
    DBMS_SQL.COLUMN_VALUE ( vn_sel_cur_id, 1, vn_ids);
    DBMS_SQL.COLUMN_VALUE ( vn_sel_cur_id, 2, vs_names);
    DBMS_SQL.COLUMN_VALUE ( vn_sel_cur_id, 3, vd_birth_dt);
    
    -- INSERT문 바인드 변수 처리 
    DBMS_SQL.BIND_VARIABLE ( vn_ins_cur_id, ':a', vn_ids);
    DBMS_SQL.BIND_VARIABLE ( vn_ins_cur_id, ':b', vs_names);
    DBMS_SQL.BIND_VARIABLE ( vn_ins_cur_id, ':c', vd_birth_dt);
    
    -- INSERT문 실행
    vn_ins_return := DBMS_SQL.EXECUTE (vn_ins_cur_id);
    
  END LOOP;
  
  -- 커서 닫기
  DBMS_SQL.CLOSE_CURSOR (vn_sel_cur_id);  -- select 문 커서  
  DBMS_SQL.CLOSE_CURSOR (vn_ins_cur_id);  -- insert 문 커서 
  
  
END;  
  

5. 4 번에서 작성한 익명블록의 코드를 좀 더 간편하게 줄여보자. (힌트: BULK DML 형태로 작성할 것)

<정답>

DECLARE 
  vc_cur          SYS_REFCURSOR;  -- 커서변수
  vn_ids_array    DBMS_SQL.NUMBER_TABLE;
  vs_name_array   DBMS_SQL.VARCHAR2_TABLE;
  vd_dt_array     DBMS_SQL.DATE_TABLE;
  
  vs_new_table  VARCHAR2(50) := 'ch13_physicist_new';
  vs_insert_sql VARCHAR2(1000);
  vs_select_sql VARCHAR2(1000);
  
  vn_sel_cur_id NUMBER := DBMS_SQL.OPEN_CURSOR(); 
  vn_ins_cur_id NUMBER := DBMS_SQL.OPEN_CURSOR(); 
  
  vn_sel_return NUMBER;
  vn_ins_return NUMBER;

BEGIN
	-- 신규 테이블 생성
	ch13_exam_crt_table_proc ('ch13_physicist');
	-- 데이터 삭제
	EXECUTE IMMEDIATE  'TRUNCATE TABLE ' || vs_new_table;
	
	-- 먼저 원천 테이블 데이터를 선택한다. 
  vs_select_sql := 'SELECT * FROM ch13_physicist';
  
  DBMS_SQL.PARSE (vn_sel_cur_id, vs_select_sql, DBMS_SQL.NATIVE);  
  
  vn_sel_return := DBMS_SQL.EXECUTE (vn_sel_cur_id);
  
  -- DBMS_SQL.TO_REFCURSOR를 사용해 커서로 변환 
  vc_cur := DBMS_SQL.TO_REFCURSOR ( vn_sel_cur_id );
  
  -- 변환한 커서를 사용해 결과를 패치하고 결과 출력
  FETCH vc_cur  BULK COLLECT INTO vn_ids_array, vs_name_array, vd_dt_array;
  
  -- INSERT문 처리
  vs_insert_sql := 'INSERT INTO ' || vs_new_table || ' VALUES (:a, :b, :c)';
  DBMS_SQL.PARSE (vn_ins_cur_id, vs_insert_sql, DBMS_SQL.NATIVE);
  
  -- 바인드 배열 연결 
  DBMS_SQL.BIND_ARRAY ( vn_ins_cur_id, ':a', vn_ids_array);
  DBMS_SQL.BIND_ARRAY ( vn_ins_cur_id, ':b', vs_name_array);
  DBMS_SQL.BIND_ARRAY ( vn_ins_cur_id, ':c', vd_dt_array);
  
  -- INSERT문 실행
  vn_ins_return := DBMS_SQL.EXECUTE (vn_ins_cur_id);
  
  -- 커서 닫기
  
  CLOSE vc_cur; -- SELECT문 커서   
  DBMS_SQL.CLOSE_CURSOR (vn_ins_cur_id);  -- insert 문 커서
  
  COMMIT;  
  
END;  