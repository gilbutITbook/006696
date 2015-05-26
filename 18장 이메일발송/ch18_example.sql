<연습문제>

● 이번 장은 연습문제가 1개 뿐인데, 그 이유는 이 문제에는 이번 장에서 배운 모든 내용이 집약되어 있기 때문이다.  

1. UTL_SMTP에 비해 UTL_MAIL 패키지의 사용법이 쉽다는 것은 자명한 사실이다. UTL_MAIL.SEND_ATTACH_RAW 프로시저와 동일한 매개변수와 동일한 기능을  
하는 프로시저를 만들어보자 만들어보자. 단, UTL_SMTP에 내장된 서브 프로그램만을 사용해야 한다. 

<정답>


    
CREATE OR REPLACE PROCEDURE ch18_send_mail ( ps_from    IN VARCHAR2,  -- 보내는 사람
                                             ps_to      IN VARCHAR2,  -- 받는 사람
                                             ps_subject IN VARCHAR2,  -- 제목
                                             ps_body    IN VARCHAR2,  -- 본문 
                                             ps_content IN VARCHAR2  DEFAULT 'text/plain;', -- Content-Type
                                             ps_file_nm IN VARCHAR2   -- 첨부파일 
                                          )    
 IS
    vc_con utl_smtp.connection;
     
    vv_host    VARCHAR2(30)   := 'localhost'; -- SMTP 서버명
    vn_port    NUMBER := 25;                -- 포트번호
    vv_domain  VARCHAR2(30)   := 'hong.com';
    vv_directory VARCHAR2(30) := 'SMTP_FILE';
    vv_boundary VARCHAR2(50) := 'DIFOJSLKDWFEFO.WEFOWJFOWE';  -- boundary text
   
    vf_file_buff  RAW(32767);   -- 실제 파일을 담을 RAW타입 변수 
    vf_temp_buff  RAW(54);
    vn_file_len   NUMBER := 0;  -- 파일 길이
    
    -- 한 줄당 올 수 있는 BASE64 변환된 데이터 최대 길이 
    vn_base64_max_len  NUMBER := 54; --76 * (3/4);
    vn_pos             NUMBER := 1; --파일 위치를 담는 변수 
    -- 파일을 한 줄씩 자를 때 사용할 단위 바이트 수 
    vn_divide          NUMBER := 0;  
  BEGIN
  	
    vc_con := UTL_SMTP.OPEN_CONNECTION(vv_host, vn_port);

    UTL_SMTP.HELO(vc_con, vv_domain); -- HELO  
    UTL_SMTP.MAIL(vc_con, ps_from);   -- 보내는사람
    UTL_SMTP.RCPT(vc_con, ps_to);     -- 받는사람  	
    
    UTL_SMTP.OPEN_DATA(vc_con); -- 메일본문 작성 시작 
    UTL_SMTP.WRITE_DATA(vc_con,'MIME-Version: 1.0' || UTL_TCP.CRLF ); -- MIME 버전  
    
    UTL_SMTP.WRITE_DATA(vc_con,'Content-Type: multipart/mixed; boundary="' || vv_boundary || '"' || UTL_TCP.CRLF); 
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW('From: ' || ps_from || UTL_TCP.CRLF) ); -- 보내는사람
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW('To: ' || ps_to || UTL_TCP.CRLF) );   -- 받는사람
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW('Subject: ' || ps_subject || UTL_TCP.CRLF) ); -- 제목
    UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF );  -- 한 줄 띄우기  
  	
    -- 메일 본문 
    UTL_SMTP.WRITE_DATA(vc_con, '--' || vv_boundary || UTL_TCP.CRLF );
    UTL_SMTP.WRITE_DATA(vc_con, 'Content-Type: ' || ps_content || UTL_TCP.CRLF );
    UTL_SMTP.WRITE_DATA(vc_con, 'charset=euc-kr' || UTL_TCP.CRLF );
    UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF );
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW(ps_body || UTL_TCP.CRLF)  );
    UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF );
    
    -- 첨부파일이 있다면 ...
    IF ps_file_nm IS NOT NULL THEN  
    
        UTL_SMTP.WRITE_DATA(vc_con, '--' || vv_boundary || UTL_TCP.CRLF ); 
        -- 파일의 Content-Type은 application/octet-stream
        UTL_SMTP.WRITE_DATA(vc_con,'Content-Type: application/octet-stream; name="' || ps_file_nm || '"' || UTL_TCP.CRLF);
        UTL_SMTP.WRITE_DATA(vc_con,'Content-Transfer-Encoding: base64' || UTL_TCP.CRLF);
        UTL_SMTP.WRITE_DATA(vc_con,'Content-Disposition: attachment; filename="' || ps_file_nm || '"' || UTL_TCP.CRLF);
        
      
        UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF);
      
        
        -- fn_get_raw_file 함수를 사용해 실제 파일을 읽어온다. 
        vf_file_buff := fn_get_raw_file(vv_directory, ps_file_nm);
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
          UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_ENCODE.BASE64_ENCODE ( vf_temp_buff));
          UTL_SMTP.WRITE_DATA(vc_con,  UTL_TCP.CRLF ); 
          
          -- vn_pos는 vn_base64_max_len 값 단위로 증가
          vn_pos := vn_pos + vn_divide;
        END LOOP;
    
    END IF; -- 첨부파일 처리 종료 
    
    -- 맨 마지막 boundary에는 앞과 뒤에 '--'를 반드시 붙여야 한다.
    UTL_SMTP.WRITE_DATA(vc_con, '--' ||  vv_boundary || '--' || UTL_TCP.CRLF );   
    
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
    	
  END;

       
       
       
-- 프로시저 실행
BEGIN
	
	ch18_send_mail ( ps_from    => 'charieh@hong.com'
                  ,ps_to      => 'charieh@hong.com'
                  ,ps_subject => '연습문제'
                  ,ps_body    => 'Test mail'
                  ,ps_content => 'text/plain;'
                  ,ps_file_nm => 'ch18_txt_file.txt'
                 )   
END;       
