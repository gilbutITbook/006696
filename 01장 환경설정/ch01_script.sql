-- 테이블 스페이스 생성

CREATE TABLESPACE myts DATAFILE 
 'C:\app\chongs\oradata\myoracle\myts.dbf' SIZE 100M AUTOEXTEND ON NEXT 5M;
 
 
-- 사용자 생성
CREATE USER ora_user IDENTIFIED BY hong 
DEFAULT TABLESPACE MYTS
TEMPORARY TABLESPACE TEMP;

-- DBA 롤 부여
GRANT DBA TO ora_user;

