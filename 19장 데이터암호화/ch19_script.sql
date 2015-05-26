-- 19장. 프로시저로 이메일을 보내자
-- 01. 데이터 암호화
-- (2) DBMS_CRYPTO 패키지

conn SYS/hong AS SYSDBA;

grant execute on DBMS_CRYPTO to public;

-- (4) 암호화 실습

DECLARE
  input_string  VARCHAR2 (200) := 'The Oracle';  -- 암호화할 VARCHAR2 데이터
  output_string VARCHAR2 (200); -- 복호화된 VARCHAR2 데이터 

  encrypted_raw RAW (2000); -- 암호화된 데이터 
  decrypted_raw RAW (2000); -- 복호화할 데이터 

  num_key_bytes NUMBER := 256/8; -- 암호화 키를 만들 길이 (256 비트, 32 바이트)
  key_bytes_raw RAW (32);        -- 암호화 키 

  -- 암호화 슈트 
  encryption_type PLS_INTEGER; 
  
BEGIN
	 -- 암호화 슈트 설정
	 encryption_type := DBMS_CRYPTO.ENCRYPT_AES256 + -- 256비트 키를 사용한 AES 암호화 
	                    DBMS_CRYPTO.CHAIN_CBC +      -- CBC 모드 
	                    DBMS_CRYPTO.PAD_PKCS5;       -- PKCS5로 이루어진 패딩
	
   DBMS_OUTPUT.PUT_LINE ('원본 문자열: ' || input_string);

   -- RANDOMBYTES 함수를 사용해 암호화 키 생성 
   key_bytes_raw := DBMS_CRYPTO.RANDOMBYTES (num_key_bytes);
   
   -- ENCRYPT 함수로 암호화를 한다. 원본 문자열을 UTL_I18N.STRING_TO_RAW를 사용해 RAW 타입으로 변환한다. 
   encrypted_raw := DBMS_CRYPTO.ENCRYPT ( src => UTL_I18N.STRING_TO_RAW (input_string, 'AL32UTF8'),   
                                          typ => encryption_type,
                                          key => key_bytes_raw
                                        );
                                        
   -- 암호화된 RAW 데이터를 한번 출력해보자
   DBMS_OUTPUT.PUT_LINE('암호화된 RAW 데이터: ' || encrypted_raw);                                     
   -- 암호화 한 데이터를 다시 복호화 ( 암호화했던 키와 암호화 슈트는 동일하게 사용해야 한다. )
   decrypted_raw := DBMS_CRYPTO.DECRYPT ( src => encrypted_raw,
                                          typ => encryption_type,
                                          key => key_bytes_raw
                                        );
   
   -- 복호화된 RAW 타입 데이터를 UTL_I18N.RAW_TO_CHAR를 사용해 다시 VARCHAR2로 변환 
   output_string := UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');
   -- 복호화된 문자열 출력 
   DBMS_OUTPUT.PUT_LINE ('복호화된 문자열: ' || output_string);
END;


-- HASH, MAC 함수
DECLARE

  input_string  VARCHAR2 (200) := 'The Oracle';  -- 입력 VARCHAR2 데이터
  input_raw     RAW(128);                        -- 입력 RAW 데이터 

  encrypted_raw RAW (2000); -- 암호화 데이터 
  
  key_string VARCHAR2(8) := 'secret';  -- MAC 함수에서 사용할 비밀 키
  raw_key RAW(128) := UTL_RAW.CAST_TO_RAW(CONVERT(key_string,'AL32UTF8','US7ASCII')); -- 비밀키를 RAW 타입으로 변환
  
BEGIN
	-- VARCHAR2를 RAW 타입으로 변환
	input_raw := UTL_I18N.STRING_TO_RAW (input_string, 'AL32UTF8');
	
	
	DBMS_OUTPUT.PUT_LINE('----------- HASH 함수 -------------');
	encrypted_raw := DBMS_CRYPTO.HASH( src => input_raw,
                                     typ => DBMS_CRYPTO.HASH_SH1);
                                     
  DBMS_OUTPUT.PUT_LINE('입력 문자열의 해시값 : ' || RAWTOHEX(encrypted_raw));   
    
  
  DBMS_OUTPUT.PUT_LINE('----------- MAC 함수 -------------'); 
  encrypted_raw := DBMS_CRYPTO.MAC( src => input_raw,
                                    typ => DBMS_CRYPTO.HMAC_MD5,
                                    key => raw_key);   
                                    
  DBMS_OUTPUT.PUT_LINE('MAC 값 : ' || RAWTOHEX(encrypted_raw));
END;


-- 현장 노하우
DECLARE
  vv_ddl VARCHAR2(1000); -- 패키지 소스를 저장하는 변수
BEGIN
	-- 패키지 소스를 vv_ddl에 설정
  vv_ddl := 'CREATE OR REPLACE PACKAGE ch19_wrap_pkg IS
                pv_key_string VARCHAR2(30) := ''OracleKey'';
             END ch19_wrap_pkg;';
             
        
  -- CREATE_WRAPPED 프로시저를 사용하면 패키지 소스를 숨기는 것과 동시에 컴파일도 수행한다. 
  DBMS_DDL.CREATE_WRAPPED ( vv_ddl );
      
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE(SQLERRM);
END ;


BEGIN
  DBMS_OUTPUT.PUT_LINE(ch19_wrap_pkg.pv_key_string);
END;

-- 02. 나만의 유틸리티 프로그램 만들기
-- (1) 소스 검색

CREATE OR REPLACE PACKAGE my_util_pkg IS
    -- 프로그램 소스 검색 프로시저 
    PROCEDURE program_search_prc (ps_src_text IN VARCHAR2);
END my_util_pkg;


CREATE OR REPLACE PACKAGE BODY my_util_pkg IS

  -- 프로그램 소스 검색 프로시저
  PROCEDURE program_search_prc (ps_src_text IN VARCHAR2)
  IS
    vs_search VARCHAR2(100);
    vs_name   VARCHAR2(1000);
  BEGIN
    -- 찾을 키워드 앞뒤에 '%'를 붙인다. 
    vs_search := '%' || NVL(ps_src_text, '%') || '%';
    
    -- dba_source에서 입력된 키워드로 소스를 검색한다. 
    -- 입력 키워드가 대문자 혹은 소문자가 될 수 있으므로 UPPER, LOWER 함수를 이용해 검색한다. 
    FOR C_CUR IN ( SELECT name, type, line, text
                     FROM user_source
                    WHERE text like UPPER(vs_search) 
                       OR text like LOWER(vs_search)
                    ORDER BY name, type, line
                  )
    LOOP
       -- 프로그램 이름과 줄번호를 가져와 출력한다. 
       vs_name := C_CUR.name || ' - ' || C_CUR.type || ' - ' || C_Cur.line || ' : ' || REPLACE(C_CUR.text, CHR(10), '');
       DBMS_OUTPUT.PUT_LINE( vs_name);
    END LOOP;
  	
  END program_search_prc;
END my_util_pkg;

-- 부서테이블 검색
BEGIN
  my_util_pkg.program_search_prc ('departments');
END;

-- (2) 객체 검색
-- 패키지 본문 
CREATE OR REPLACE PACKAGE BODY my_util_pkg IS

  -- 프로그램 소스 검색 프로시저
  PROCEDURE program_search_prc (ps_src_text IN VARCHAR2)
  IS
    vs_search VARCHAR2(100);
    vs_name   VARCHAR2(1000);
  BEGIN
    ...  

  -- 객체검색 프로시저 
  PROCEDURE object_search_prc (ps_obj_name IN VARCHAR2)
  IS
    vs_search VARCHAR2(100);
    vs_name   VARCHAR2(1000);
  BEGIN
    -- 찾을 키워드 앞뒤에 '%'를 붙인다. 
    vs_search := '%' || NVL(ps_obj_name, '%') || '%';
    
    -- referenced_name 입력된 키워드로 참조객체를 검색한다.  
    -- user_dependencies에는 모두 대문자로 데이터가 들어가 있으므로 UPPER 함수를 이용해 검색한다. 
    FOR C_CUR IN ( SELECT name, type
                     FROM user_dependencies
                    WHERE referenced_name LIKE UPPER(vs_search) 
                    ORDER BY name, type
                  )
    LOOP
       -- 프로그램 이름과 줄번호를 가져와 출력한다. 
       vs_name := C_CUR.name || ' - ' || C_CUR.type ;
       DBMS_OUTPUT.PUT_LINE( vs_name);
    END LOOP;
  	
  END object_search_prc;  
END my_util_pkg;

-- 부서테이블을 참조하는 객체 검색
BEGIN
  my_util_pkg.object_search_prc ('departments');
END;


-- (3) 테이블 레이아웃 출력

  -- 테이블 Layout 출력
  PROCEDURE table_layout_prc ( ps_table_name IN VARCHAR2)
  IS
    vs_table_name VARCHAR2(50) := UPPER(ps_table_name);
    vs_owner      VARCHAR2(50);
    vs_columns    VARCHAR2(300);
  BEGIN
  	BEGIN
  	  -- TABLE이 있는지 검색 
  	  SELECT OWNER
  	    INTO vs_owner
  	    FROM ALL_TABLES
    	 WHERE TABLE_NAME = vs_table_name;
  	
  	EXCEPTION WHEN NO_DATA_FOUND THEN
  	     DBMS_OUTPUT.PUT_LINE(vs_table_name || '라는 테이블이 존재하지 않습니다');
  	     RETURN;
    END;
    
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('테이블: ' || vs_table_name || ' , 소유자 : ' || vs_owner);
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
  	
  	-- 컬럼정보 검색 및 출력 
    FOR C_CUR IN ( SELECT column_name, data_type, data_length, nullable, data_default 
                     FROM ALL_TAB_COLS
                    WHERE table_name = vs_table_name
                    ORDER BY column_id;
                  )
    LOOP
       -- 컬럼 정보를 출력한다. 줄을 맞춰 출력되도록 RPAD 함수를 사용한다.  
       vs_columns := RPAD(C_CUR.column_name, 20) || RPAD(C_CUR.data_type, 15) || RPAD(C_CUR.data_length, 5) || RPAD(C_CUR.nullable, 2) || RPAD(C_CUR.data_default, 10);
       DBMS_OUTPUT.PUT_LINE( vs_columns);
    END LOOP;  	
  	
  END table_layout_prc;
  
-- table_layout_prc 프로시저 실행
BEGIN
  -- 부서 테이블명 입력 
  my_util_pkg.table_layout_prc ('departments');  
END;



-- (4) 컬럼값을 세로로 출력

  PROCEDURE print_col_value_prc ( ps_query IN VARCHAR2 )
  IS
      l_theCursor     INTEGER DEFAULT DBMS_SQL.OPEN_CURSOR;
      l_columnValue   VARCHAR2(4000);
      l_status        INTEGER;
      l_descTbl       DBMS_SQL.DESC_TAB;
      l_colCnt        NUMBER;
  BEGIN
      -- 쿼리구문이 p_query 매개변수에 들어오므로 이를 파싱한다. 
      DBMS_SQL.PARSE(  l_theCursor,  ps_query, DBMS_SQL.NATIVE );
      
      -- DESCRIBE_COLUMN 프로시저 : 커서에 대한 컬럼정보를 DBMS_SQL.DESC_TAB 형 변수에 넣는다. 
      DBMS_SQL.DESCRIBE_COLUMNS  ( l_theCursor, l_colCnt, l_descTbl );
  
      -- 선택된 컬럼 개수만큼 루프를 돌며 DEFINE_COLUMN 프로시저를 호출해 컬럼을 정의한다. 
      FOR i IN 1..l_colCnt 
      LOOP
          DBMS_SQL.DEFINE_COLUMN (l_theCursor, i, l_columnValue, 4000);
      END LOOP;
  
      -- 실행 
      l_status := DBMS_SQL.EXECUTE(l_theCursor);
  
      WHILE ( DBMS_SQL.FETCH_ROWS (l_theCursor) > 0 ) 
      LOOP
          -- 컬럼 개수만큼 다시 루프를 돌면서 컬럼 값을 l_columnValue 변수에 담는다.
          -- DBMS_SQL.DESC_TAB 형 변수인 l_descTbl.COL_NAME은 컬럼 명칭이 있고 
          -- l_columnValue에는 컬럼 값이 들어있다. 
          FOR i IN 1..l_colCnt 
          LOOP
            DBMS_SQL.COLUMN_VALUE ( l_theCursor, i, l_columnValue );
            DBMS_OUTPUT.PUT_LINE  ( rpad( l_descTbl(i).COL_NAME, 30 ) || ': ' || l_columnValue );
          END LOOP;
          DBMS_OUTPUT.PUT_LINE( '-----------------' );
      END LOOP;
  
      DBMS_SQL.CLOSE_CURSOR (l_theCursor);
  
  END print_col_value_prc;


-- print_col_value_prc 프로시저 실행
BEGIN
  -- 부서 테이블 조회  
  my_util_pkg.print_col_value_prc ('select * from departments where rownum < 3');  
END;

-- (5) 이메일 전송

CREATE OR REPLACE PACKAGE my_util_pkg IS
    -- 1. 프로그램 소스 검색 프로시저 
    PROCEDURE program_search_prc (ps_src_text IN VARCHAR2);
    
    -- 2. 객체검색 프로시저 
    PROCEDURE object_search_prc (ps_obj_name IN VARCHAR2);    
    
    -- 3. 테이블 Layout 출력
    PROCEDURE table_layout_prc ( ps_table_name IN VARCHAR2);
    
    -- 4. 컬럼 값을 세로로 출력 
    PROCEDURE print_col_value_prc ( ps_query IN VARCHAR2 );
    
    -- 이메일 전송과 관련된 패키지 상수
    pv_host   VARCHAR2(10)  := 'localhost';  -- SMTP 서버명
    pn_port   NUMBER        := 25;           -- 포트번호
    pv_domain VARCHAR2(30) := 'hong.com';   -- 도메인명
    
    pv_boundary VARCHAR2(50) := 'DIFOJSLKDWFEFO.WEFOWJFOWE';  -- boundary text
    pv_directory VARCHAR2(50) := 'SMTP_FILE'; --파일이 있는 디렉토리명     
    
    -- 5. 이메일 전송  
    PROCEDURE email_send_prc ( ps_query IN VARCHAR2 );
    
END my_util_pkg;

PROCEDURE email_send_prc ( ps_from    IN VARCHAR2,  -- 보내는 사람
                             ps_to      IN VARCHAR2,  -- 받는 사람
                             ps_subject IN VARCHAR2,  -- 제목
                             ps_body    IN VARCHAR2,  -- 본문 
                             ps_content IN VARCHAR2  DEFAULT 'text/plain;', -- Content-Type
                             ps_file_nm IN VARCHAR2   -- 첨부파일 
                           )
  IS
    vc_con utl_smtp.connection;
    
    v_bfile        BFILE;       -- 파일을 담을 변수 
    vn_bfile_size  NUMBER := 0; -- 파일크기 
    
    v_temp_blob    BLOB := EMPTY_BLOB; -- 파일을 옮겨담을 BLOB 타입 변수
    vn_blob_size   NUMBER := 0;        -- BLOB 변수 크기 
    vn_amount      NUMBER := 54;       -- 54 단위로 파일을 잘라 메일에 붙이기 위함
    v_tmp_raw      RAW(54);            -- 54 단위로 자른 파일내용이 담긴 RAW 타입변수 
    vn_pos         NUMBER := 1; --파일 위치를 담는 변수 
    
  BEGIN
  	
    vc_con := UTL_SMTP.OPEN_CONNECTION(pv_host, pn_port);

    UTL_SMTP.HELO(vc_con, pv_domain); -- HELO  
    UTL_SMTP.MAIL(vc_con, ps_from);   -- 보내는사람
    UTL_SMTP.RCPT(vc_con, ps_to);     -- 받는사람  	
    
    UTL_SMTP.OPEN_DATA(vc_con); -- 메일본문 작성 시작 
    UTL_SMTP.WRITE_DATA(vc_con,'MIME-Version: 1.0' || UTL_TCP.CRLF ); -- MIME 버전  
    
    UTL_SMTP.WRITE_DATA(vc_con,'Content-Type: multipart/mixed; boundary="' || pv_boundary || '"' || UTL_TCP.CRLF); 
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW('From: ' || ps_from || UTL_TCP.CRLF) ); -- 보내는사람
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW('To: ' || ps_to || UTL_TCP.CRLF) );   -- 받는사람
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW('Subject: ' || ps_subject || UTL_TCP.CRLF) ); -- 제목
    UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF );  -- 한 줄 띄우기  
  	
    -- 메일 본문 
    UTL_SMTP.WRITE_DATA(vc_con, '--' || pv_boundary || UTL_TCP.CRLF );
    UTL_SMTP.WRITE_DATA(vc_con, 'Content-Type: ' || ps_content || UTL_TCP.CRLF );
    UTL_SMTP.WRITE_DATA(vc_con, 'charset=euc-kr' || UTL_TCP.CRLF );
    UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF );
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW(ps_body || UTL_TCP.CRLF)  );
    UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF );

    -- 첨부파일이 있다면 ...
    IF ps_file_nm IS NOT NULL THEN  
    
        UTL_SMTP.WRITE_DATA(vc_con, '--' || pv_boundary || UTL_TCP.CRLF ); 
        -- 파일의 Content-Type은 application/octet-stream
        UTL_SMTP.WRITE_DATA(vc_con,'Content-Type: application/octet-stream; name="' || ps_file_nm || '"' || UTL_TCP.CRLF);
        UTL_SMTP.WRITE_DATA(vc_con,'Content-Transfer-Encoding: base64' || UTL_TCP.CRLF);
        UTL_SMTP.WRITE_DATA(vc_con,'Content-Disposition: attachment; filename="' || ps_file_nm || '"' || UTL_TCP.CRLF);

        UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF);
        
        -- 파일처리 시작
        -- 파일을 읽어 BFILE 변수인 v_bfile에 담는다. 
        v_bfile := BFILENAME(pv_directory, ps_file_nm); 
        -- v_bfile 담은 파일을 읽기전용으로 연다. 
        DBMS_LOB.OPEN(v_bfile, DBMS_LOB.LOB_READONLY); 
        -- v_bfile에 담긴 파일의 크기를 가져온다. 
        vn_bfile_size := DBMS_LOB.GETLENGTH(v_bfile);
        
        -- v_bfile를 BLOB 변수인 v_temp_blob에 담기 위해 초기화 
        DBMS_LOB.CREATETEMPORARY(v_temp_blob, TRUE);
        -- v_bfile에 담긴 파일을 v_temp_blob 로 옮긴다. 
        DBMS_LOB.LOADFROMFILE(v_temp_blob, v_bfile, vn_bfile_size);
        -- v_temp_blob의 크기를 구한다. 
        vn_blob_size := DBMS_LOB.GETLENGTH(v_temp_blob);    
        
        -- vn_pos 초기값은 1, v_temp_blob 크기보다 작은 경우 루프 
        WHILE vn_pos < vn_blob_size 
        LOOP
            -- v_temp_blob에 담긴 파일을 vn_amount(54)씩 잘라  v_tmp_raw에 담는다. 
            DBMS_LOB.READ(v_temp_blob, vn_amount, vn_pos, v_tmp_raw);
            -- 잘라낸 v_tmp_raw를 메일에 첨부한다. 
            UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_ENCODE.BASE64_ENCODE ( v_tmp_raw));
            UTL_SMTP.WRITE_DATA(vc_con,  UTL_TCP.CRLF );            

            v_tmp_raw := NULL;
            vn_pos := vn_pos + vn_amount;
        END LOOP;
        
        DBMS_LOB.FREETEMPORARY(v_temp_blob); -- v_temp_blob 메모리 해제
        DBMS_LOB.FILECLOSE(v_bfile); -- v_bfile 닫기         

    END IF; -- 첨부파일 처리 종료 
    
    -- 맨 마지막 boundary에는 앞과 뒤에 '--'를 반드시 붙여야 한다.
    UTL_SMTP.WRITE_DATA(vc_con, '--' ||  pv_boundary || '--' || UTL_TCP.CRLF );   
    
    UTL_SMTP.CLOSE_DATA(vc_con); -- 메일 본문 작성 종료  
    UTL_SMTP.QUIT(vc_con);       -- 메일 세션 종료
    

  
  EXCEPTION 
    WHEN UTL_SMTP.INVALID_OPERATION THEN
         dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
         dbms_output.put_line(sqlerrm);
         UTL_SMTP.QUIT(vc_con);
    WHEN UTL_SMTP.TRANSIENT_ERROR THEN
         dbms_output.put_line(' Temporary e-mail issue - try again'); 
         UTL_SMTP.QUIT(vc_con);
    WHEN UTL_SMTP.PERMANENT_ERROR THEN
         dbms_output.put_line(' Permanent Error Encountered.'); 
         dbms_output.put_line(sqlerrm);
         UTL_SMTP.QUIT(vc_con);
    WHEN OTHERS THEN 
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(vc_con);
    	
  END email_send_prc;


DECLARE
  vv_html VARCHAR2(1000);
BEGIN
  vv_html := '<HTML> <HEAD>
   <TITLE>HTML 테스트</TITLE>
 </HEAD>
 <BDOY>
    <p>이 메일은 <b>HTML</b> <i>버전</i> 으로 </p>
    <p> <strong>my_util_pkg</strong> 패키지의 email_send_prc 프로시저를 사용해 보낸 메일입니다. </p>
 </BODY>
</HTML>';

  -- 이메일전송 
  my_util_pkg.email_send_prc ( ps_from => 'charieh@hong.com'
                               ,ps_to => 'charieh@hong.com'
                               ,ps_subject =>  '테스트 메일'
                               ,ps_body => vv_html
                               ,ps_content => 'text/html;'
                               ,ps_file_nm => 'hong1.txt'
                               );
END;



-- (6) 비밀번호 관리
-- 비밀번호 생성
  FUNCTION fn_create_pass ( ps_input IN VARCHAR2,
                            ps_add   IN VARCHAR2 )
           RETURN RAW
  IS
    v_raw     RAW(32747);
    v_key_raw RAW(32747);
    v_input_string VARCHAR2(100);
  BEGIN
    -- 키 값을 가진 ch19_wrap_pkg 패키지의 pv_key_string 상수를 가져와 RAW 타입으로 변환한다. 
    v_key_raw := UTL_RAW.CAST_TO_RAW(ch19_wrap_pkg.pv_key_string );
    
    -- 좀 더 보안을 강화하기 위해 두 개의 입력 매개변수와 특수문자인 $%를 조합해 
    -- MAC 함수의 첫 번째 매개변수로 넘긴다.  
    v_input_string := ps_input || '$%' || ps_add;
    
    -- MAC 함수를 사용해 입력 문자열을 RAW 타입으로 변환한다. 
    v_raw := DBMS_CRYPTO.MAC (src => UTL_RAW.CAST_TO_RAW(v_input_string)
                             ,typ => DBMS_CRYPTO.HMAC_SH1
                             ,key => v_key_raw);
                             
    RETURN v_raw;
  END fn_create_pass;
  
-- 비밀번호 체크
  FUNCTION fn_check_pass ( ps_input IN VARCHAR2,
                           ps_add   IN VARCHAR2,
                           p_raw    IN RAW ) 
           RETURN VARCHAR2
  IS
    v_raw     RAW(32747);
    v_key_raw RAW(32747);
    v_input_string VARCHAR2(100);
    
    v_rtn VARCHAR2(10) := 'N';
  BEGIN  
    -- 키 값을 가진 ch19_wrap_pkg 패키지의 pv_key_string 상수를 가져와 RAW 타입으로 변환한다. 
    v_key_raw := UTL_RAW.CAST_TO_RAW(ch19_wrap_pkg.pv_key_string );
    
    -- 좀 더 보안을 강화하기 위해 두 개의 입력 매개변수와 특수문자인 $%를 조합해 
    -- MAC 함수의 첫 번째 매개변수로 넘긴다.  
    v_input_string := ps_input || '$%' || ps_add;
    
    -- MAC 함수를 사용해 입력 문자열을 RAW 타입으로 변환한다. 
    v_raw := DBMS_CRYPTO.MAC (src => UTL_RAW.CAST_TO_RAW(v_input_string)
                             ,typ => DBMS_CRYPTO.HMAC_SH1
                             ,key => v_key_raw);
                             
    IF v_raw = p_raw THEN
       v_rtn := 'Y';
    ELSE
       v_rtn := 'N';    
    END IF;
                             
    RETURN v_rtn;
  END fn_check_pass;  
  
-- 테이블 생성
CREATE TABLE ch19_user ( user_id   VARCHAR2(50),   -- 사용자아이디
                         user_name VARCHAR2(100),  -- 사용자명
                         pass      RAW(2000));     -- 비밀번호 
  
-- 비밀번호 생성 테스트 
DECLARE
  vs_pass VARCHAR2(20);
BEGIN
  -- 홍길동이라는 사람이 패스워드를 HONG 이라고 입력했다고 가정한다. 
  vs_pass := 'HONG';
  
  -- ch19_user 테이블에서 홍길동을 찾아내 입력된 패스워드와 이 사용자의 아이디를 
  -- fn_create_pass 매개변수로 넘겨 결과값을 받아 pass 컬럼에 저장한다. 
  UPDATE ch19_user
     SET pass = my_util_pkg.fn_create_pass (vs_pass , user_id)
  WHERE user_id = 'gdhong';

  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
  COMMIT;

END ;


SELECT *
FROM ch19_user;

-- 비밀번호 체크
DECLARE
  vs_pass VARCHAR2(20);
  v_raw raw(32747);
  
BEGIN
  -- 홍길동이라는 사람이 패스워드를 HONG 이라고 입력했다고 가정한다. 
  vs_pass := 'HONG';
  -- 테이블에서 홍길동의 패스워드를 가져와 v_raw 변수에 담는다. 
  SELECT pass
    INTO v_raw
    FROM ch19_user
   WHERE user_id = 'gdhong';
  
  -- 입력한 패스워드와 아이디를 통해 비밀번호를 체크한다. 
  IF my_util_pkg.fn_check_pass(vs_pass, 'gdhong', v_raw) = 'Y' THEN
     DBMS_OUTPUT.PUT_LINE('아이디와 비밀번호가 맞아요');
  ELSE
     DBMS_OUTPUT.PUT_LINE('아이디와 비밀번호가 달라요');
  END IF;
END ;

  
 -- (7) 데이터 암호화
 -- 암호화키 재생성
DECLARE
  vv_ddl VARCHAR2(1000); -- 패키지 소스를 저장하는 변수
BEGIN
-- 패키지 소스를 vv_ddl에 설정
    vv_ddl := 'CREATE OR REPLACE PACKAGE ch19_wrap_pkg IS
                pv_key_string  CONSTANT VARCHAR2(30) := ''OracleKey'';
                key_bytes_raw  CONSTANT RAW(32) := ''1181C249F0F9C3343E8FF2BCCF370D3C9F70E973531DEC1C5066B54F27A507DB'';  
             END ch19_wrap_pkg;';             
        
  -- CREATE_WRAPPED 프로시저를 사용하면 패키지 소스를 숨기는 것과 동시에 컴파일도 수행한다. 
  DBMS_DDL.CREATE_WRAPPED ( vv_ddl );
      
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE(SQLERRM);
END ;


  /* 8. 암호화 함수 **************************************************************************************************************************/    
  FUNCTION fn_encrypt ( ps_input_string IN VARCHAR2 )
           RETURN RAW
  IS 
    encrypted_raw RAW(32747);
    v_key_raw RAW(32747);         -- 암호화 키    
    encryption_type PLS_INTEGER;  -- 암호화 슈트    
  BEGIN
    -- 암호화 키 값을 가져온다. 
    v_key_raw := ch19_wrap_pkg.key_bytes_raw;  
    
	  -- 암호화 슈트 설정
	  encryption_type := DBMS_CRYPTO.ENCRYPT_AES256 + -- 256비트 키를 사용한 AES 암호화 
	                     DBMS_CRYPTO.CHAIN_CBC +      -- CBC 모드 
	                     DBMS_CRYPTO.PAD_PKCS5;       -- PKCS5로 이루어진 패딩 
         
    -- ENCRYPT 함수로 암호화를 한다. 매개변수로 들어온 문자열을 UTL_I18N.STRING_TO_RAW를 사용해 RAW 타입으로 변환한다.               
    encrypted_raw := DBMS_CRYPTO.ENCRYPT ( src => UTL_I18N.STRING_TO_RAW (ps_input_string, 'AL32UTF8'),   
                                           typ => encryption_type,
                                           key => v_key_raw
                                          );
                       
     RETURN encrypted_raw;
  END fn_encrypt;
  
  
  /* 9. 복호화 함수 **************************************************************************************************************************/      
  FUNCTION fn_decrypt ( prw_encrypt IN RAW )
           RETURN VARCHAR2
  IS
    vs_return VARCHAR2(100);
    v_key_raw RAW(32747);         -- 암호화 키    
    encryption_type PLS_INTEGER;  -- 암호화 슈트  
    decrypted_raw   RAW (2000);   -- 복호화 데이터 
  BEGIN
    -- 암호화 키 값을 가져온다. 
    v_key_raw := ch19_wrap_pkg.key_bytes_raw;    
    
	  -- 암호화 슈트 설정
	  encryption_type := DBMS_CRYPTO.ENCRYPT_AES256 + -- 256비트 키를 사용한 AES 암호화 
	                     DBMS_CRYPTO.CHAIN_CBC +      -- CBC 모드 
	                     DBMS_CRYPTO.PAD_PKCS5;       -- PKCS5로 이루어진 패딩  
                       
    -- 매개변수로 들어온 RAW 타입 데이터를 다시 복호화 ( 암호화했던 키와 암호화 슈트는 동일하게 사용해야 한다. )
    decrypted_raw := DBMS_CRYPTO.DECRYPT ( src => prw_encrypt,
                                           typ => encryption_type,
                                           key => v_key_raw
                                         );               
     -- 복호화된 RAW 타입 데이터를 UTL_I18N.RAW_TO_CHAR를 사용해 다시 VARCHAR2로 변환 
     vs_return := UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');
     
     RETURN vs_return;
  END fn_decrypt;  
  
-- 암호화 테스트
BEGIN
  -- 홍길동의 전화번호를 암호화한 뒤 저장한다. 
  UPDATE ch19_user
     SET phone_number = my_util_pkg.fn_encrypt('010-0000-0001')
   WHERE user_id = 'gdhong';
   
  COMMIT;
END;  

-- 복호화 테스트
DECLARE 
  v_raw RAW(2000);
  vs_phone_number VARCHAR2(50);
BEGIN
  -- 홍길동의 전화번호를 가져온다. 
  SELECT phone_number
    INTO v_raw
    FROM ch19_user
   WHERE user_id = 'gdhong';
  
  -- RAW 타입의 전화번호를 복호화 함수에 넣어 원래 문자형태의 전화번호를 얻는다. 
  vs_phone_number := my_util_pkg.fn_decrypt(v_raw);
  DBMS_OUTPUT.PUT_LINE('전화번호 : ' || vs_phone_number);
END;


-- ● MY_UTIL_PKG 소스
CREATE OR REPLACE PACKAGE my_util_pkg IS
    -- 1. 프로그램 소스 검색 프로시저 
    PROCEDURE program_search_prc (ps_src_text IN VARCHAR2);
    
    -- 2. 객체검색 프로시저 
    PROCEDURE object_search_prc (ps_obj_name IN VARCHAR2);    
    
    -- 3. 테이블 Layout 출력
    PROCEDURE table_layout_prc ( ps_table_name IN VARCHAR2);
    
    -- 4. 컬럼 값을 세로로 출력 
    PROCEDURE print_col_value_prc ( ps_query IN VARCHAR2 );
    
    -- 이메일 전송과 관련된 패키지 상수
    pv_host VARCHAR2(10)  := 'localhost';  -- SMTP 서버명
    pn_port NUMBER        := 25;           -- 포트번호
    pv_domain VARCHAR2(30) := 'hong.com';   -- 도메인명
    
    pv_boundary VARCHAR2(50) := 'DIFOJSLKDWFEFO.WEFOWJFOWE';  -- boundary text
    pv_directory VARCHAR2(50) := 'SMTP_FILE'; --파일이 있는 디렉토리명   
        
    -- 5. 이메일 전송  
    PROCEDURE email_send_prc ( ps_from    IN VARCHAR2,  
                               ps_to      IN VARCHAR2,  
                               ps_subject IN VARCHAR2, 
                               ps_body    IN VARCHAR2,  
                               ps_content IN VARCHAR2  DEFAULT 'text/plain;', 
                               ps_file_nm IN VARCHAR2  
                             );  
                             
                             
    -- 6. 비밀번호 생성
    FUNCTION fn_create_pass ( ps_input IN VARCHAR2,
                              ps_add   IN VARCHAR2 )
             RETURN RAW;
                              
    -- 7. 비밀번호 확인   
    FUNCTION fn_check_pass ( ps_input IN VARCHAR2,
                             ps_add   IN VARCHAR2,
                             p_raw    IN RAW )  
             RETURN VARCHAR2;       
             
    -- 8. 암호화 함수
    FUNCTION fn_encrypt ( ps_input_string IN VARCHAR2 )
             RETURN RAW;
             
    -- 9. 복호화 함수
    FUNCTION fn_decrypt ( prw_encrypt IN RAW )
             RETURN VARCHAR2;
  
END my_util_pkg;


-- 패키지 본문
CREATE OR REPLACE PACKAGE BODY my_util_pkg IS

  /* 1. 프로그램 소스 검색 프로시저 *************************************************************************************/
  PROCEDURE program_search_prc (ps_src_text IN VARCHAR2)
  IS
    vs_search VARCHAR2(100);
    vs_name   VARCHAR2(1000);
  BEGIN
    -- 찾을 키워드 앞뒤에 '%'를 붙인다. 
    vs_search := '%' || NVL(ps_src_text, '%') || '%';
    
    -- dba_source에서 입력된 키워드로 소스를 검색한다. 
    -- 입력 키워드가 대문자 혹은 소문자가 될 수 있으므로 UPPER, LOWER 함수를 이용해 검색한다. 
    FOR C_CUR IN ( SELECT name, type, line, text
                     FROM user_source
                    WHERE text like UPPER(vs_search) 
                       OR text like LOWER(vs_search)
                    ORDER BY name, type, line
                  )
    LOOP
       -- 프로그램 이름과 줄번호를 가져와 출력한다. 
       vs_name := C_CUR.name || ' - ' || C_CUR.type || ' - ' || C_Cur.line || ' : ' || REPLACE(C_CUR.text, CHR(10), '');
       DBMS_OUTPUT.PUT_LINE( vs_name);
    END LOOP;
  	
  END program_search_prc;
  

  /* 2. 객체검색 프로시저 *************************************************************************************************/
  PROCEDURE object_search_prc (ps_obj_name IN VARCHAR2)
  IS
    vs_search VARCHAR2(100);
    vs_name   VARCHAR2(1000);
  BEGIN
    -- 찾을 키워드 앞뒤에 '%'를 붙인다. 
    vs_search := '%' || NVL(ps_obj_name, '%') || '%';
    
    -- referenced_name 입력된 키워드로 참조객체를 검색한다.  
    -- user_dependencies에는 모두 대문자로 데이터가 들어가 있으므로 UPPER 함수를 이용해 검색한다. 
    FOR C_CUR IN ( SELECT name, type
                     FROM user_dependencies
                    WHERE referenced_name LIKE UPPER(vs_search) 
                    ORDER BY name, type
                  )
    LOOP
       -- 프로그램 이름과 줄번호를 가져와 출력한다. 
       vs_name := C_CUR.name || ' - ' || C_CUR.type ;
       DBMS_OUTPUT.PUT_LINE( vs_name);
    END LOOP;
  	
  END object_search_prc;  
  
  /* 3. 테이블 Layout 출력 ***********************************************************************************************/
  PROCEDURE table_layout_prc ( ps_table_name IN VARCHAR2)
  IS
    vs_table_name VARCHAR2(50) := UPPER(ps_table_name);
    vs_owner      VARCHAR2(50);
    vs_columns    VARCHAR2(300);
  BEGIN
  	BEGIN
  	  -- TABLE이 있는지 검색 
  	  SELECT OWNER
  	    INTO vs_owner
  	    FROM ALL_TABLES
    	 WHERE TABLE_NAME = vs_table_name;
  	
  	EXCEPTION WHEN NO_DATA_FOUND THEN
  	     DBMS_OUTPUT.PUT_LINE(vs_table_name || '라는 테이블이 존재하지 않습니다');
  	     RETURN;
    END;
    
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('테이블: ' || vs_table_name || ' , 소유자 : ' || vs_owner);
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
  	
  	-- 컬럼정보 검색 및 출력 
    FOR C_CUR IN ( SELECT column_name, data_type, data_length, nullable, data_default 
                     FROM ALL_TAB_COLS
                    WHERE table_name = vs_table_name
                    ORDER BY column_id
                  )
    LOOP
       -- 컬럼 정보를 출력한다. 줄을 맞춰 출력되도록 RPAD 함수를 사용한다.  
       vs_columns := RPAD(C_CUR.column_name, 20) || RPAD(C_CUR.data_type, 15) || RPAD(C_CUR.data_length, 5) || RPAD(C_CUR.nullable, 2) || RPAD(C_CUR.data_default, 10);
       DBMS_OUTPUT.PUT_LINE( vs_columns);
    END LOOP;  	
  	
  END table_layout_prc;
  
  
  /* 4. 컬럼 값을 세로로 출력 *****************************************************************************************************************************************/
  PROCEDURE print_col_value_prc ( ps_query IN VARCHAR2 )
  IS
      l_theCursor     INTEGER DEFAULT DBMS_SQL.OPEN_CURSOR;
      l_columnValue   VARCHAR2(4000);
      l_status        INTEGER;
      l_descTbl       DBMS_SQL.DESC_TAB;
      l_colCnt        NUMBER;
  BEGIN
      -- 쿼리구문이 p_query 매개변수에 들어오므로 이를 파싱한다. 
      DBMS_SQL.PARSE(  l_theCursor,  ps_query, DBMS_SQL.NATIVE );
      
      -- DESCRIBE_COLUMN 프로시저 : 커서에 대한 컬럼정보를 DBMS_SQL.DESC_TAB 형 변수에 넣는다. 
      DBMS_SQL.DESCRIBE_COLUMNS  ( l_theCursor, l_colCnt, l_descTbl );
  
      -- 선택된 컬럼 개수만큼 루프를 돌며 DEFINE_COLUMN 프로시저를 호출해 컬럼을 정의한다. 
      FOR i IN 1..l_colCnt 
      LOOP
          DBMS_SQL.DEFINE_COLUMN (l_theCursor, i, l_columnValue, 4000);
      END LOOP;
  
      -- 실행 
      l_status := DBMS_SQL.EXECUTE(l_theCursor);
  
      WHILE ( DBMS_SQL.FETCH_ROWS (l_theCursor) > 0 ) 
      LOOP
          -- 컬럼 개수만큼 다시 루프를 돌면서 컬럼 값을 l_columnValue 변수에 담는다.
          -- DBMS_SQL.DESC_TAB 형 변수인 l_descTbl.COL_NAME은 컬럼 명칭이 있고 
          -- l_columnValue에는 컬럼 값이 들어있다. 
          FOR i IN 1..l_colCnt 
          LOOP
            DBMS_SQL.COLUMN_VALUE ( l_theCursor, i, l_columnValue );
            DBMS_OUTPUT.PUT_LINE  ( rpad( l_descTbl(i).COL_NAME, 30 ) || ': ' || l_columnValue );
          END LOOP;
          DBMS_OUTPUT.PUT_LINE( '-----------------' );
      END LOOP;
  
      DBMS_SQL.CLOSE_CURSOR (l_theCursor);
  
  END print_col_value_prc;  
  
  /* 5. 이메일 전송 **************************************************************************************************************************/
  PROCEDURE email_send_prc ( ps_from    IN VARCHAR2,  -- 보내는 사람
                             ps_to      IN VARCHAR2,  -- 받는 사람
                             ps_subject IN VARCHAR2,  -- 제목
                             ps_body    IN VARCHAR2,  -- 본문 
                             ps_content IN VARCHAR2  DEFAULT 'text/plain;', -- Content-Type
                             ps_file_nm IN VARCHAR2   -- 첨부파일 
                           )
  IS
    vc_con utl_smtp.connection;
    
    v_bfile        BFILE;       -- 파일을 담을 변수 
    vn_bfile_size  NUMBER := 0; -- 파일크기 
    
    v_temp_blob    BLOB := EMPTY_BLOB; -- 파일을 옮겨담을 BLOB 타입 변수
    vn_blob_size   NUMBER := 0;        -- BLOB 변수 크기 
    vn_amount      NUMBER := 54;       -- 54 단위로 파일을 잘라 메일에 붙이기 위함
    v_tmp_raw      RAW(54);            -- 54 단위로 자른 파일내용이 담긴 RAW 타입변수 
    vn_pos         NUMBER := 1; --파일 위치를 담는 변수 
    
  BEGIN
  	
    vc_con := UTL_SMTP.OPEN_CONNECTION(pv_host, pn_port);

    UTL_SMTP.HELO(vc_con, pv_domain); -- HELO  
    UTL_SMTP.MAIL(vc_con, ps_from);   -- 보내는사람
    UTL_SMTP.RCPT(vc_con, ps_to);     -- 받는사람  	
    
    UTL_SMTP.OPEN_DATA(vc_con); -- 메일본문 작성 시작 
    UTL_SMTP.WRITE_DATA(vc_con,'MIME-Version: 1.0' || UTL_TCP.CRLF ); -- MIME 버전  
    
    UTL_SMTP.WRITE_DATA(vc_con,'Content-Type: multipart/mixed; boundary="' || pv_boundary || '"' || UTL_TCP.CRLF); 
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW('From: ' || ps_from || UTL_TCP.CRLF) ); -- 보내는사람
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW('To: ' || ps_to || UTL_TCP.CRLF) );   -- 받는사람
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW('Subject: ' || ps_subject || UTL_TCP.CRLF) ); -- 제목
    UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF );  -- 한 줄 띄우기  
  	
    -- 메일 본문 
    UTL_SMTP.WRITE_DATA(vc_con, '--' || pv_boundary || UTL_TCP.CRLF );
    UTL_SMTP.WRITE_DATA(vc_con, 'Content-Type: ' || ps_content || UTL_TCP.CRLF );
    UTL_SMTP.WRITE_DATA(vc_con, 'charset=euc-kr' || UTL_TCP.CRLF );
    UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF );
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW(ps_body || UTL_TCP.CRLF)  );
    UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF );

    -- 첨부파일이 있다면 ...
    IF ps_file_nm IS NOT NULL THEN  
    
        UTL_SMTP.WRITE_DATA(vc_con, '--' || pv_boundary || UTL_TCP.CRLF ); 
        -- 파일의 Content-Type은 application/octet-stream
        UTL_SMTP.WRITE_DATA(vc_con,'Content-Type: application/octet-stream; name="' || ps_file_nm || '"' || UTL_TCP.CRLF);
        UTL_SMTP.WRITE_DATA(vc_con,'Content-Transfer-Encoding: base64' || UTL_TCP.CRLF);
        UTL_SMTP.WRITE_DATA(vc_con,'Content-Disposition: attachment; filename="' || ps_file_nm || '"' || UTL_TCP.CRLF);

        UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF);
        
        -- 파일처리 시작
        -- 파일을 읽어 BFILE 변수인 v_bfile에 담는다. 
        v_bfile := BFILENAME(pv_directory, ps_file_nm); 
        -- v_bfile 담은 파일을 읽기전용으로 연다. 
        DBMS_LOB.OPEN(v_bfile, DBMS_LOB.LOB_READONLY); 
        -- v_bfile에 담긴 파일의 크기를 가져온다. 
        vn_bfile_size := DBMS_LOB.GETLENGTH(v_bfile);
        
        -- v_bfile를 BLOB 변수인 v_temp_blob에 담기 위해 초기화 
        DBMS_LOB.CREATETEMPORARY(v_temp_blob, TRUE);
        -- v_bfile에 담긴 파일을 v_temp_blob 로 옮긴다. 
        DBMS_LOB.LOADFROMFILE(v_temp_blob, v_bfile, vn_bfile_size);
        -- v_temp_blob의 크기를 구한다. 
        vn_blob_size := DBMS_LOB.GETLENGTH(v_temp_blob);    
        
        -- vn_pos 초기값은 1, v_temp_blob 크기보다 작은 경우 루프 
        WHILE vn_pos < vn_blob_size 
        LOOP
            -- v_temp_blob에 담긴 파일을 vn_amount(54)씩 잘라  v_tmp_raw에 담는다. 
            DBMS_LOB.READ(v_temp_blob, vn_amount, vn_pos, v_tmp_raw);
            -- 잘라낸 v_tmp_raw를 메일에 첨부한다. 
            UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_ENCODE.BASE64_ENCODE ( v_tmp_raw));
            UTL_SMTP.WRITE_DATA(vc_con,  UTL_TCP.CRLF );            

            v_tmp_raw := NULL;
            vn_pos := vn_pos + vn_amount;
        END LOOP;
        
      DBMS_LOB.FREETEMPORARY(v_temp_blob); -- v_temp_blob 메모리 해제
      DBMS_LOB.FILECLOSE(v_bfile); -- v_bfile 닫기         

    END IF; -- 첨부파일 처리 종료 
    
    -- 맨 마지막 boundary에는 앞과 뒤에 '--'를 반드시 붙여야 한다.
    UTL_SMTP.WRITE_DATA(vc_con, '--' ||  pv_boundary || '--' || UTL_TCP.CRLF );   
    
    UTL_SMTP.CLOSE_DATA(vc_con); -- 메일 본문 작성 종료  
    UTL_SMTP.QUIT(vc_con);       -- 메일 세션 종료
    
  EXCEPTION 
    WHEN UTL_SMTP.INVALID_OPERATION THEN
         dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
         dbms_output.put_line(sqlerrm);
         UTL_SMTP.QUIT(vc_con);
    WHEN UTL_SMTP.TRANSIENT_ERROR THEN
         dbms_output.put_line(' Temporary e-mail issue - try again'); 
         UTL_SMTP.QUIT(vc_con);
    WHEN UTL_SMTP.PERMANENT_ERROR THEN
         dbms_output.put_line(' Permanent Error Encountered.'); 
         dbms_output.put_line(sqlerrm);
         UTL_SMTP.QUIT(vc_con);
    WHEN OTHERS THEN 
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(vc_con);
    	
  END email_send_prc;


  /* 6. 비밀번호 생성 **************************************************************************************************************************/
  FUNCTION fn_create_pass ( ps_input IN VARCHAR2,
                            ps_add   IN VARCHAR2 )
           RETURN RAW
  IS
    v_raw     RAW(32747);
    v_key_raw RAW(32747);
    v_input_string VARCHAR2(100);
  BEGIN
    -- 키 값을 가진 ch19_wrap_pkg 패키지의 pv_key_string 상수를 가져와 RAW 타입으로 변환한다. 
    v_key_raw := UTL_RAW.CAST_TO_RAW(ch19_wrap_pkg.pv_key_string );
    
    -- 좀 더 보안을 강화하기 위해 두 개의 입력 매개변수와 특수문자인 $%를 조합해 
    -- MAC 함수의 첫 번째 매개변수로 넘긴다.  
    v_input_string := ps_input || '$%' || ps_add;
    
    -- MAC 함수를 사용해 입력 문자열을 RAW 타입으로 변환한다. 
    v_raw := DBMS_CRYPTO.MAC (src => UTL_RAW.CAST_TO_RAW(v_input_string)
                             ,typ => DBMS_CRYPTO.HMAC_SH1
                             ,key => v_key_raw);
                             
    RETURN v_raw;
  END fn_create_pass;
  
  /* 7. 비밀번호 확인 **************************************************************************************************************************/
  FUNCTION fn_check_pass ( ps_input IN VARCHAR2,
                           ps_add   IN VARCHAR2,
                           p_raw    IN RAW ) 
           RETURN VARCHAR2
  IS
    v_raw     RAW(32747);
    v_key_raw RAW(32747);
    v_input_string VARCHAR2(100);
    
    v_rtn VARCHAR2(10) := 'N';
  BEGIN  
    -- 키 값을 가진 ch19_wrap_pkg 패키지의 pv_key_string 상수를 가져와 RAW 타입으로 변환한다. 
    v_key_raw := UTL_RAW.CAST_TO_RAW(ch19_wrap_pkg.pv_key_string );
    
    -- 좀 더 보안을 강화하기 위해 두 개의 입력 매개변수와 특수문자인 $%를 조합해 
    -- MAC 함수의 첫 번째 매개변수로 넘긴다.  
    v_input_string := ps_input || '$%' || ps_add;
    
    -- MAC 함수를 사용해 입력 문자열을 RAW 타입으로 변환한다. 
    v_raw := DBMS_CRYPTO.MAC (src => UTL_RAW.CAST_TO_RAW(v_input_string)
                             ,typ => DBMS_CRYPTO.HMAC_SH1
                             ,key => v_key_raw);
                             
    IF v_raw = p_raw THEN
       v_rtn := 'Y';
    ELSE
       v_rtn := 'N';    
    END IF;
                             
    RETURN v_rtn;
  END fn_check_pass;  
  
  /* 8. 암호화 함수 **************************************************************************************************************************/    
  FUNCTION fn_encrypt ( ps_input_string IN VARCHAR2 )
           RETURN RAW
  IS 
    encrypted_raw RAW(32747);
    v_key_raw RAW(32747);         -- 암호화 키    
    encryption_type PLS_INTEGER;  -- 암호화 슈트    
  BEGIN
    -- 암호화 키 값을 가져온다. 
    v_key_raw := ch19_wrap_pkg.key_bytes_raw;  
    
	  -- 암호화 슈트 설정
	  encryption_type := DBMS_CRYPTO.ENCRYPT_AES256 + -- 256비트 키를 사용한 AES 암호화 
	                     DBMS_CRYPTO.CHAIN_CBC +      -- CBC 모드 
	                     DBMS_CRYPTO.PAD_PKCS5;       -- PKCS5로 이루어진 패딩 
         
    -- ENCRYPT 함수로 암호화를 한다. 매개변수로 들어온 문자열을 UTL_I18N.STRING_TO_RAW를 사용해 RAW 타입으로 변환한다.               
    encrypted_raw := DBMS_CRYPTO.ENCRYPT ( src => UTL_I18N.STRING_TO_RAW (ps_input_string, 'AL32UTF8'),   
                                           typ => encryption_type,
                                           key => v_key_raw
                                          );
                       
     RETURN encrypted_raw;
  END fn_encrypt;
  
  /* 9. 복호화 함수 **************************************************************************************************************************/      
  FUNCTION fn_decrypt ( prw_encrypt IN RAW )
           RETURN VARCHAR2
  IS
    vs_return VARCHAR2(100);
    v_key_raw RAW(32747);         -- 암호화 키    
    encryption_type PLS_INTEGER;  -- 암호화 슈트  
    decrypted_raw   RAW (2000);   -- 복호화 데이터 
  BEGIN
    -- 암호화 키 값을 가져온다. 
    v_key_raw := ch19_wrap_pkg.key_bytes_raw;    
    
	  -- 암호화 슈트 설정
	  encryption_type := DBMS_CRYPTO.ENCRYPT_AES256 + -- 256비트 키를 사용한 AES 암호화 
	                     DBMS_CRYPTO.CHAIN_CBC +      -- CBC 모드 
	                     DBMS_CRYPTO.PAD_PKCS5;       -- PKCS5로 이루어진 패딩  
                       
    -- 매개변수로 들어온 RAW 타입 데이터를 다시 복호화 ( 암호화했던 키와 암호화 슈트는 동일하게 사용해야 한다. )
    decrypted_raw := DBMS_CRYPTO.DECRYPT ( src => prw_encrypt,
                                           typ => encryption_type,
                                           key => v_key_raw
                                         );               
     -- 복호화된 RAW 타입 데이터를 UTL_I18N.RAW_TO_CHAR를 사용해 다시 VARCHAR2로 변환 
     vs_return := UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');
     
     RETURN vs_return;
  END fn_decrypt;
  
END my_util_pkg;