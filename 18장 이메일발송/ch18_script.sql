-- 18장. 프로시저로 이메일을 보내자

-- 01.사전 준비사항

BEGIN

DBMS_NETWORK_ACL_ADMIN.CREATE_ACL ( 
          acl => 'my_mail.xml', 
          description => '메일전송용 ACL',
          principal => 'ORA_USER',  -- ORA_USER란 사용자에게 권한 할당
          is_grant => true,
          privilege => 'connect');

  COMMIT;
END; 


BEGIN

DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE ( 
          acl => 'my_mail.xml', 
          principal => 'ORA_USER',  -- ORA_USER란 사용자에게 권한 할당
          is_grant => true,
          privilege => 'resolve');

  COMMIT;
END; 


BEGIN

DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL ( 
          acl => 'my_mail.xml', 
          host => 'localhost',  -- 호스트명
          lower_port => 25 );

  COMMIT;
END; 


SELECT *
FROM DBA_NETWORK_ACLS;


BEGIN
  DBMS_NETWORK_ACL_ADMIN.DROP_ACL(
       acl =>'my_mail.xml');
END;


-- 02. UTL_SMTP를 이용한 메일 전송
-- ① 간단한 메일 전송

DECLARE
  vv_host    VARCHAR2(30) := 'localhost'; -- SMTP 서버명
  vn_port    NUMBER := 25;                -- 포트번호
  vv_domain  VARCHAR2(30) := 'hong.com';
  
  vv_from    VARCHAR2(50) := 'charieh@hong.com';  -- 보내는 주소
  vv_to      VARCHAR2(50) := 'charieh@hong.com';  -- 받는 주소 
  
  c utl_smtp.connection;

  
BEGIN
  c := UTL_SMTP.OPEN_CONNECTION(vv_host, vn_port);

  UTL_SMTP.HELO(c, vv_domain); -- HELO
  
  UTL_SMTP.MAIL(c, vv_from);   -- 보내는사람
  UTL_SMTP.RCPT(c, vv_to);     -- 받는사람  
   
  UTL_SMTP.OPEN_DATA(c); -- 메일본문 작성 시작 
  -- 각 메시지는 <CR><LF>로 분리한다. 이는 UTL_TCP.CRLF 함수를 이용한다. 
  
  UTL_SMTP.WRITE_DATA(c,'From: ' || '"hong2" <charieh@hong.com>' || UTL_TCP.CRLF ); -- 보내는사람
  UTL_SMTP.WRITE_DATA(c,'To: ' || '"hong1" <charieh@hong.com>' || UTL_TCP.CRLF );   -- 받는사람
  UTL_SMTP.WRITE_DATA(c,'Subject: Test' || UTL_TCP.CRLF );                          -- 제목
  UTL_SMTP.WRITE_DATA(c, UTL_TCP.CRLF );                                            -- 한 줄 띄우기
  UTL_SMTP.WRITE_DATA(c,'THIS IS SMTP_TEST1 ' || UTL_TCP.CRLF );                    -- 본문 
  
  UTL_SMTP.CLOSE_DATA(c); -- 메일 본문 작성 종료
  
  -- 종료
  UTL_SMTP.QUIT(c);


EXCEPTION 
  WHEN UTL_SMTP.INVALID_OPERATION THEN
       dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.TRANSIENT_ERROR THEN
       dbms_output.put_line(' Temporary e-mail issue - try again'); 
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.PERMANENT_ERROR THEN
       dbms_output.put_line(' Permanent Error Encountered.'); 
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN OTHERS THEN 
     dbms_output.put_line(sqlerrm);
     UTL_SMTP.QUIT(c);
END;

-- ② 한글 메일 전송

-- 한글이 깨지는 경우 
DECLARE
  vv_host    VARCHAR2(30) := 'localhost'; -- SMTP 서버명
  vn_port    NUMBER := 25;                -- 포트번호
  vv_domain  VARCHAR2(30) := 'hong.com';
  
  vv_from    VARCHAR2(50) := 'charieh@hong.com';  -- 보내는 주소
  vv_to      VARCHAR2(50) := 'charieh@hong.com';  -- 받는 주소 
  
  c utl_smtp.connection;

  
BEGIN
  c := UTL_SMTP.OPEN_CONNECTION(vv_host, vn_port);

  UTL_SMTP.HELO(c, vv_domain); -- HELO
  
  UTL_SMTP.MAIL(c, vv_from);   -- 보내는사람
  UTL_SMTP.RCPT(c, vv_to);     -- 받는사람  
   
  UTL_SMTP.OPEN_DATA(c); -- 메일본문 작성 시작 
  -- 각 메시지는 <CR><LF>로 분리한다. 이는 UTL_TCP.CRLF 함수를 이용한다. 
  
  UTL_SMTP.WRITE_DATA(c,'From: ' || '"hong2" <charieh@hong.com>' || UTL_TCP.CRLF ); -- 보내는사람
  UTL_SMTP.WRITE_DATA(c,'To: ' || '"hong1" <charieh@hong.com>' || UTL_TCP.CRLF );   -- 받는사람
  UTL_SMTP.WRITE_DATA(c,'Subject: Test' || UTL_TCP.CRLF );                          -- 제목
  UTL_SMTP.WRITE_DATA(c, UTL_TCP.CRLF );                                            -- 한 줄 띄우기
  UTL_SMTP.WRITE_DATA(c,'한글 메일 테스트' || UTL_TCP.CRLF );                       -- 본문을 한글로...
  
  UTL_SMTP.CLOSE_DATA(c); -- 메일 본문 작성 종료
  
  -- 종료
  UTL_SMTP.QUIT(c);


EXCEPTION 
  WHEN UTL_SMTP.INVALID_OPERATION THEN
       dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.TRANSIENT_ERROR THEN
       dbms_output.put_line(' Temporary e-mail issue - try again'); 
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.PERMANENT_ERROR THEN
       dbms_output.put_line(' Permanent Error Encountered.'); 
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN OTHERS THEN 
     dbms_output.put_line(sqlerrm);
     UTL_SMTP.QUIT(c);
END;

-- 한글 깨짐을 없애기 위해 WRITE_RAW_DATA를 사용한다. 
DECLARE
  vv_host    VARCHAR2(30) := 'localhost'; -- SMTP 서버명
  vn_port    NUMBER := 25;                -- 포트번호
  vv_domain  VARCHAR2(30) := 'hong.com';
  
  vv_from    VARCHAR2(50) := 'charieh@hong.com';  -- 보내는 주소
  vv_to      VARCHAR2(50) := 'charieh@hong.com';  -- 받는 주소 
  
  c utl_smtp.connection;

  
BEGIN
  c := UTL_SMTP.OPEN_CONNECTION(vv_host, vn_port);

  UTL_SMTP.HELO(c, vv_domain); -- HELO
  
  UTL_SMTP.MAIL(c, vv_from);   -- 보내는사람
  UTL_SMTP.RCPT(c, vv_to);     -- 받는사람  
   
  UTL_SMTP.OPEN_DATA(c); -- 메일본문 작성 시작 
  -- 각 메시지는 <CR><LF>로 분리한다. 이는 UTL_TCP.CRLF 함수를 이용한다. 
  
  UTL_SMTP.WRITE_DATA(c,'From: ' || '"hong2" <charieh@hong.com>' || UTL_TCP.CRLF ); -- 보내는사람
  UTL_SMTP.WRITE_DATA(c,'To: ' || '"hong1" <charieh@hong.com>' || UTL_TCP.CRLF );   -- 받는사람
  UTL_SMTP.WRITE_DATA(c,'Subject: Test' || UTL_TCP.CRLF );                          -- 제목
  UTL_SMTP.WRITE_DATA(c, UTL_TCP.CRLF );                                            -- 한 줄 띄우기
  -- 본문을 한글로 작성하고, 이를 RAW 타입으로 변환한다. 
  UTL_SMTP.WRITE_RAW_DATA(c, UTL_RAW.CAST_TO_RAW('한글 메일 테스트' || UTL_TCP.CRLF)  );
  
  UTL_SMTP.CLOSE_DATA(c); -- 메일 본문 작성 종료
  
  -- 종료
  UTL_SMTP.QUIT(c);


EXCEPTION 
  WHEN UTL_SMTP.INVALID_OPERATION THEN
       dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.TRANSIENT_ERROR THEN
       dbms_output.put_line(' Temporary e-mail issue - try again'); 
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.PERMANENT_ERROR THEN
       dbms_output.put_line(' Permanent Error Encountered.'); 
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN OTHERS THEN 
     dbms_output.put_line(sqlerrm);
     UTL_SMTP.QUIT(c);
END;


-- 보내는사람, 받는사람, 제목, 본문 전체를 한글로 한다. 
DECLARE
  vv_host    VARCHAR2(30) := 'localhost'; -- SMTP 서버명
  vn_port    NUMBER := 25;                -- 포트번호
  vv_domain  VARCHAR2(30) := 'hong.com';
  
  vv_from    VARCHAR2(50) := 'charieh@hong.com';  -- 보내는 주소
  vv_to      VARCHAR2(50) := 'charieh@hong.com';  -- 받는 주소 
  vv_text    VARCHAR2(300);
  
  c utl_smtp.connection;

  
BEGIN
  c := UTL_SMTP.OPEN_CONNECTION(vv_host, vn_port);

  UTL_SMTP.HELO(c, vv_domain); -- HELO
  
  UTL_SMTP.MAIL(c, vv_from);   -- 보내는사람
  UTL_SMTP.RCPT(c, vv_to);     -- 받는사람  
   
  UTL_SMTP.OPEN_DATA(c); -- 메일본문 작성 시작 
  
  vv_text := 'From: ' || '"홍길동" <charieh@hong.com>' || UTL_TCP.CRLF;            -- 보내는사람
  vv_text :=  vv_text || 'To: ' || '"홍길동" <charieh@hong.com>' || UTL_TCP.CRLF;  -- 받는 사람
  vv_text :=  vv_text || 'Subject: 한글제목' || UTL_TCP.CRLF;                         -- 제목
  vv_text :=  vv_text || UTL_TCP.CRLF;                                            -- 한 줄 띄우기
  vv_text :=  vv_text || '한글 메일 테스트' || UTL_TCP.CRLF;                      -- 메일본문
    

  -- 본문 전체를 한번에 RAW 타입으로 변환 후 메일내용 작성 
  UTL_SMTP.WRITE_RAW_DATA(c, UTL_RAW.CAST_TO_RAW(vv_text)  ); 
  
  UTL_SMTP.CLOSE_DATA(c); -- 메일 본문 작성 종료
  
  -- 종료
  UTL_SMTP.QUIT(c);


EXCEPTION 
  WHEN UTL_SMTP.INVALID_OPERATION THEN
       dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.TRANSIENT_ERROR THEN
       dbms_output.put_line(' Temporary e-mail issue - try again'); 
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.PERMANENT_ERROR THEN
       dbms_output.put_line(' Permanent Error Encountered.'); 
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN OTHERS THEN 
     dbms_output.put_line(sqlerrm);
     UTL_SMTP.QUIT(c);
END;


-- (3) HTML 메일 보내기
DECLARE
  vv_host    VARCHAR2(30) := 'localhost'; -- SMTP 서버명
  vn_port    NUMBER := 25;                -- 포트번호
  vv_domain  VARCHAR2(30) := 'hong.com';  
  vv_from    VARCHAR2(50) := 'charieh@hong.com';  -- 보내는 주소
  vv_to      VARCHAR2(50) := 'charieh@hong.com';  -- 받는 주소 
  
  c utl_smtp.connection;
  vv_html    VARCHAR2(200); -- HTML 메시지를 담을 변수
BEGIN
  c := UTL_SMTP.OPEN_CONNECTION(vv_host, vn_port);

  UTL_SMTP.HELO(c, vv_domain); -- HELO  
  UTL_SMTP.MAIL(c, vv_from);   -- 보내는사람
  UTL_SMTP.RCPT(c, vv_to);     -- 받는사람  
   
  UTL_SMTP.OPEN_DATA(c); -- 메일본문 작성 시작 
  UTL_SMTP.WRITE_DATA(c,'MIME-Version: 1.0' || UTL_TCP.CRLF ); -- MIME 버전
  -- Content-Type: HTML 형식, 한글을 사용하므로 문자셋은 euc-kr
  UTL_SMTP.WRITE_DATA(c,'Content-Type: text/html; charset="euc-kr"' || UTL_TCP.CRLF ); 
  
  UTL_SMTP.WRITE_RAW_DATA(c, UTL_RAW.CAST_TO_RAW('From: ' || '"홍길동" <charieh@hong.com>' || UTL_TCP.CRLF) ); -- 보내는사람
  UTL_SMTP.WRITE_RAW_DATA(c, UTL_RAW.CAST_TO_RAW('To: ' || '"홍길동" <charieh@hong.com>' || UTL_TCP.CRLF) );   -- 받는사람
  UTL_SMTP.WRITE_RAW_DATA(c, UTL_RAW.CAST_TO_RAW('Subject: HTML 테스트 메일' || UTL_TCP.CRLF) );               -- 제목
  UTL_SMTP.WRITE_DATA(c, UTL_TCP.CRLF );                                            -- 한 줄 띄우기
  
  -- HTML 본문을 작성
  vv_html := '<HEAD>
   <TITLE>HTML 테스트</TITLE>
 </HEAD>
 <BDOY>
    <p>이 메일은 <b>HTML</b> <i>버전</i> 으로 </p>
    <p>작성된 <strong>메일</strong>입니다. </p>
 </BODY>
</HTML>';

  -- 메일 본문 
  UTL_SMTP.WRITE_RAW_DATA(c, UTL_RAW.CAST_TO_RAW(vv_html || UTL_TCP.CRLF)  );
  
  UTL_SMTP.CLOSE_DATA(c); -- 메일 본문 작성 종료  
  UTL_SMTP.QUIT(c);       -- 메일 세션 종료

EXCEPTION 
  WHEN UTL_SMTP.INVALID_OPERATION THEN
       dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.TRANSIENT_ERROR THEN
       dbms_output.put_line(' Temporary e-mail issue - try again'); 
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.PERMANENT_ERROR THEN
       dbms_output.put_line(' Permanent Error Encountered.'); 
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN OTHERS THEN 
     dbms_output.put_line(sqlerrm);
     UTL_SMTP.QUIT(c);
END;


--(4) 첨부파일 보내기
--① 파일 처리

-- Directory 객체 생성
CREATE OR REPLACE DIRECTORY SMTP_FILE AS 'C:\ch18_file';

-- ② UTL_FILE 패키지

CREATE OR REPLACE FUNCTION fn_get_raw_file ( p_dir   VARCHAR2,
                                             p_file  VARCHAR2)
    RETURN RAW
IS
    vf_buffer RAW(32767);
    vf_raw    RAW(32767); --반환할 파일 
    
    vf_type  UTL_FILE.FILE_TYPE;
BEGIN
	  -- 파일을 바이트모드로 읽는다. 
	  -- p_dir : 디렉토리명, p_file : 파일명, rb: 바이트모드로 읽기
	  vf_type := UTL_FILE.FOPEN ( p_dir, p_file, 'rb');
	  
	  -- 파일이 오픈됐는지 IS_OPEN 함수를 이용해 확인. 
	  IF UTL_FILE.IS_OPEN ( vf_type ) THEN
	     
	     -- 루프를 돌며 파일을 읽는다. 
	     LOOP
	        BEGIN 
	           -- GET_RAW 프로시저로 파일을 읽어 vf_buffer 변수에 담는다.  
	           UTL_FILE.GET_RAW(vf_type, vf_buffer, 32767);
	           -- 반환할 RAW 타입 변수에 vf_buffer를 할당.
	           vf_raw := vf_raw || vf_buffer;
	           
	        EXCEPTION 
	           -- 더 이상 가져올 데이터가 없으면 루프를 빠져나간다. 
	           WHEN NO_DATA_FOUND THEN 
	                EXIT;
	        END;
	     END LOOP;
	  
	      
	  END IF;
	  
	  -- 파일을 닫는다. 
	  UTL_FILE.FCLOSE(vf_type);
	  
	  RETURN vf_raw;
END;  


-- ④ 파일을 첨부해 메일 전송

DECLARE
  vv_host    VARCHAR2(30) := 'localhost'; -- SMTP 서버명
  vn_port    NUMBER := 25;                -- 포트번호
  vv_domain  VARCHAR2(30) := 'hong.com';  
  vv_from    VARCHAR2(50) := 'charieh@hong.com';  -- 보내는 주소
  vv_to      VARCHAR2(50) := 'charieh@hong.com';  -- 받는 주소 
  
  c utl_smtp.connection;
  vv_html      VARCHAR2(200); -- HTML 메시지를 담을 변수
  -- boundary 표시를 위한 변수, unique한 임의의 값을 사용하면 된다. 
  vv_boundary  VARCHAR2(50) := 'DIFOJSLKDFO.WEFOWJFOWE'; 
  
  vv_directory  VARCHAR2(30) := 'SMTP_FILE'; --파일이 있는 디렉토리명 
  vv_filename   VARCHAR2(30) := 'ch18_txt_file.txt';  -- 파일명  
  vf_file_buff  RAW(32767);   -- 실제 파일을 담을 RAW타입 변수 
  vf_temp_buff  RAW(54);
  vn_file_len   NUMBER := 0;  -- 파일 길이
  
  -- 한 줄당 올 수 있는 BASE64 변환된 데이터 최대 길이 
  vn_base64_max_len  NUMBER := 54; --76 * (3/4);
  vn_pos             NUMBER := 1; --파일 위치를 담는 변수 
  -- 파일을 한 줄씩 자를 때 사용할 단위 바이트 수 
  vn_divide          NUMBER := 0;
BEGIN
  c := UTL_SMTP.OPEN_CONNECTION(vv_host, vn_port);

  UTL_SMTP.HELO(c, vv_domain); -- HELO  
  UTL_SMTP.MAIL(c, vv_from);   -- 보내는사람
  UTL_SMTP.RCPT(c, vv_to);     -- 받는사람  
   
  UTL_SMTP.OPEN_DATA(c); -- 메일본문 작성 시작 
  UTL_SMTP.WRITE_DATA(c,'MIME-Version: 1.0' || UTL_TCP.CRLF ); -- MIME 버전
  -- Content-Type: multipart/mixed, boundary 입력 
  UTL_SMTP.WRITE_DATA(c,'Content-Type: multipart/mixed; boundary="' || vv_boundary || '"' || UTL_TCP.CRLF); 
  UTL_SMTP.WRITE_RAW_DATA(c, UTL_RAW.CAST_TO_RAW('From: ' || '"홍길동" <charieh@hong.com>' || UTL_TCP.CRLF) ); -- 보내는사람
  UTL_SMTP.WRITE_RAW_DATA(c, UTL_RAW.CAST_TO_RAW('To: ' || '"홍길동" <charieh@hong.com>' || UTL_TCP.CRLF) );   -- 받는사람
  UTL_SMTP.WRITE_RAW_DATA(c, UTL_RAW.CAST_TO_RAW('Subject: HTML 첨부파일 테스트' || UTL_TCP.CRLF) );             -- 제목
  UTL_SMTP.WRITE_DATA(c, UTL_TCP.CRLF );                                            -- 한 줄 띄우기
  
  -- HTML 본문을 작성
  vv_html := '<HEAD>
   <TITLE>HTML 테스트</TITLE>
 </HEAD>
 <BDOY>
    <p>이 메일은 <b>HTML</b> <i>버전</i> 으로 </p>
    <p>첨부파일까지 들어간 <strong>메일</strong>입니다. </p>
 </BODY>
</HTML>';

  -- 메일 본문 
  UTL_SMTP.WRITE_DATA(c, '--' || vv_boundary || UTL_TCP.CRLF );
  UTL_SMTP.WRITE_DATA(c, 'Content-Type: text/html;' || UTL_TCP.CRLF );
  UTL_SMTP.WRITE_DATA(c, 'charset=euc-kr' || UTL_TCP.CRLF );
  UTL_SMTP.WRITE_DATA( c, UTL_TCP.CRLF );
  UTL_SMTP.WRITE_RAW_DATA(c, UTL_RAW.CAST_TO_RAW(vv_html || UTL_TCP.CRLF)  );
  UTL_SMTP.WRITE_DATA( c, UTL_TCP.CRLF );
  
  -- 첨부파일 추가 
  UTL_SMTP.WRITE_DATA(c, '--' || vv_boundary || UTL_TCP.CRLF ); 
  -- 파일의 Content-Type은 application/octet-stream
  UTL_SMTP.WRITE_DATA(c,'Content-Type: application/octet-stream; name="' || vv_filename || '"' || UTL_TCP.CRLF);
  UTL_SMTP.WRITE_DATA(c,'Content-Transfer-Encoding: base64' || UTL_TCP.CRLF);
  UTL_SMTP.WRITE_DATA(c,'Content-Disposition: attachment; filename="' || vv_filename || '"' || UTL_TCP.CRLF);
  

  UTL_SMTP.WRITE_DATA(c, UTL_TCP.CRLF);

  
  -- fn_get_raw_file 함수를 사용해 실제 파일을 읽어온다. 
  vf_file_buff := fn_get_raw_file(vv_directory, vv_filename);
  -- 파일의 총 크기를 가져온다. 
  vn_file_len := DBMS_LOB.GETLENGTH(vf_file_buff);
  
  -- 파일전체 크기가 vn_base64_max_len 보다 작다면, 분할단위수인 vn_divide 값은 파일크기로 설정 
  IF vn_file_len <= vn_base64_max_len THEN
     vn_divide := vn_file_len;
  ELSE -- 그렇지 않다면 BASE64 분할단위인 vn_base64_max_len로 설정 
     vn_divide := vn_base64_max_len;
  END IF;
  
  -- 루프를 돌며 파일을 BASE64로 변환해 한 쭐씩 찍는다. 
  vn_pos := 0;
  WHILE vn_pos < vn_file_len
  LOOP
    
    -- (파일전체크기 - 현재크기)가 분할단위보다 크면 
    IF (vn_file_len - vn_pos) >= vn_divide then 
       vn_divide := vn_divide;
    ELSE -- 그렇지 않으면 분할단위 = (파일전체크기 - 현재크기)
       vn_divide := vn_file_len - vn_pos;
    END IF ;    
    
    -- 파일을 54 단위로 자른다. 
    vf_temp_buff := UTL_RAW.SUBSTR ( vf_file_buff, vn_pos, vn_divide);
    -- BASE64 인코딩을 한 후 파일내용 첨부 
    UTL_SMTP.WRITE_RAW_DATA(c, UTL_ENCODE.BASE64_ENCODE ( vf_temp_buff));
    UTL_SMTP.WRITE_DATA(c,  UTL_TCP.CRLF ); 
    
    -- vn_pos는 vn_base64_max_len 값 단위로 증가
    vn_pos := vn_pos + vn_divide;
  END LOOP;
  
    -- 맨 마지막 boundary에는 앞과 뒤에 '--'를 반드시 붙여야 한다.
  UTL_SMTP.WRITE_DATA(c, '--' ||  vv_boundary || '--' || UTL_TCP.CRLF ); 
  
  UTL_SMTP.CLOSE_DATA(c); -- 메일 본문 작성 종료  
  UTL_SMTP.QUIT(c);       -- 메일 세션 종료

EXCEPTION 
  WHEN UTL_SMTP.INVALID_OPERATION THEN
       dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.TRANSIENT_ERROR THEN
       dbms_output.put_line(' Temporary e-mail issue - try again'); 
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.PERMANENT_ERROR THEN
       dbms_output.put_line(' Permanent Error Encountered.'); 
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN OTHERS THEN 
     dbms_output.put_line(sqlerrm);
     UTL_SMTP.QUIT(c);
END;

-- 03. UTL_MAIL 을 이용한 메일 전송
-- (2) UTL_MAIL 패키지를 사용한 메일 전송

BEGIN

   UTL_MAIL.SEND (
       sender     => 'charieh@hong.com',
       recipients => 'charieh@hong.com',
       cc         => null,
       bcc        => null,
       subject    => 'UTL_MAIL 전송 테스트',
       message    => 'UTL_MAIL을 이용해 전송하는 메일입니다',
       mime_type  => 'text/plain; charset=euc-kr',
       priority   => 3,
       replyto    => 'charieh@hong.com');
    
EXCEPTION WHEN OTHERS THEN
   DBMS_OUTPUT.PUT_LINE(sqlerrm);

END;

-- HTML 메일
DECLARE 

  vv_html  VARCHAR2(300);
BEGIN
	
  vv_html := '<HEAD>
   <TITLE>HTML 테스트</TITLE>
 </HEAD>
 <BDOY>
    <p>이 메일은 <b>HTML</b> <i>버전</i> 으로 </p>
    <p> <strong>UTL_MAIL</strong> 패키지를 사용해 보낸 메일입니다. </p>
 </BODY>
</HTML>';

   UTL_MAIL.SEND (
       sender     => 'charieh@hong.com',
       recipients => 'charieh@hong.com',
       cc         => null,
       bcc        => null,
       subject    => 'UTL_MAIL 전송 테스트2',
       message    => vv_html,
       mime_type  => 'text/html; charset=euc-kr',
       priority   => 1,
       replyto    => 'charieh@hong.com');
    
EXCEPTION WHEN OTHERS THEN
   DBMS_OUTPUT.PUT_LINE(sqlerrm);

END;

-- ③ 첨부파일 전송
DECLARE 
  vv_directory  VARCHAR2(30) := 'SMTP_FILE'; --파일이 있는 디렉토리명 
  vv_filename   VARCHAR2(30) := 'ch18_txt_file.txt';  -- 파일명  
  vf_file_buff  RAW(32767);   -- 실제 파일을 담을 RAW타입 변수 
  vv_html  VARCHAR2(300);
  
BEGIN
	
  vv_html := '<HEAD>
   <TITLE>HTML 테스트</TITLE>
 </HEAD>
 <BDOY>
    <p>이 메일은 <b>HTML</b> <i>버전</i> 으로 </p>
    <p> <strong>UTL_MAIL</strong> 패키지를 사용해 보낸 메일입니다. </p>
 </BODY>
</HTML>';

   -- 파일 읽어오기
   vf_file_buff := fn_get_raw_file(vv_directory, vv_filename);

   UTL_MAIL.SEND_ATTACH_RAW (
       sender     => 'charieh@hong.com',
       recipients => 'charieh@hong.com',
       cc         => null,
       bcc        => null,
       subject    => 'UTL_MAIL 파일전송 테스트',
       message    => vv_html,
       mime_type  => 'text/html; charset=euc-kr',
       priority   => 1,
       attachment => vf_file_buff,
       att_inline => TRUE,
       att_mime_type => 'application/octet',
       att_filename  => vv_filename,
       replyto    => 'charieh@hong.com');
    
EXCEPTION WHEN OTHERS THEN
   DBMS_OUTPUT.PUT_LINE(sqlerrm);

END;