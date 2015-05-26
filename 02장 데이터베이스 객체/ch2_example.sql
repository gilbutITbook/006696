--
1. 다음과 같은 구조의 테이블을 생성해 보자.
- 테이블 : ORDERS
- 컬럼 :   ORDER_ID	    NUMBER(12,0)
           ORDER_DATE   DATE 
           ORDER_MODE	  VARCHAR2(8 BYTE)
           CUSTOMER_ID	NUMBER(6,0)
           ORDER_STATUS	NUMBER(2,0)
           ORDER_TOTAL	NUMBER(8,2)
           SALES_REP_ID	NUMBER(6,0)
           PROMOTION_ID	NUMBER(6,0)
- 제약사항 : 기본키는 ORDER_ID  
             ORDER_MODE에는 'direct', 'online'만 입력가능
             ORDER_TOTAL의 디폴트 값은 0
             
<정답>
            
  CREATE TABLE ORDERS (
           ORDER_ID	    NUMBER(12,0),
           ORDER_DATE   DATE ,
           ORDER_MODE	  VARCHAR2(8 BYTE),
           CUSTOMER_ID	NUMBER(6,0),
           ORDER_STATUS	NUMBER(2,0) DEFAULT 0,
           ORDER_TOTAL	NUMBER(8,2),
           SALES_REP_ID	NUMBER(6,0),
           PROMOTION_ID	NUMBER(6,0),
           CONSTRAINT PK_ORDER PRIMARY KEY (ORDER_ID),
           CONSTRAINT CK_ORDER_MODE CHECK (ORDER_MODE in ('direct','online'))
           ); 



2. 다음과 같은 구조의 테이블을 생성해 보자.
- 테이블 : ORDER_ITEMS 
- 컬럼 :   ORDER_ID	    NUMBER(12,0)
           LINE_ITEM_ID NUMBER(3,0) 
           PRODUCT_ID   NUMBER(3,0) 
           UNIT_PRICE   NUMBER(8,2) 
           QUANTITY     NUMBER(8,0)
- 제약사항 : 기본키는 ORDER_ID와 LINE_ITEM_ID
             UNIT_PRICE, QUANTITY 의 디폴트 값은 0
             
<정답>
            
  CREATE TABLE ORDER_ITEMS (
           ORDER_ID	    NUMBER(12,0),
           LINE_ITEM_ID NUMBER(3,0) ,
           ORDER_MODE	  VARCHAR2(8 BYTE),
           PRODUCT_ID   NUMBER(3,0), 
           UNIT_PRICE   NUMBER(8,2) DEFAULT 0, 
           QUANTITY     NUMBER(8,0) DEFAULT 0,
           CONSTRAINT PK_ORDER_ITEMS PRIMARY KEY (ORDER_ID, LINE_ITEM_ID)
           ); 
           
3. 다음과 같은 구조의 테이블을 생성해 보자.
- 테이블 : PROMOTIONS
- 컬럼 :   PROMO_ID	    NUMBER(6,0)
           PROMO_NAME   VARCHAR2(20) 
- 제약사항 : 기본키는 PROMO_ID

<정답>

  CREATE TABLE PROMOTIONS (
           PROMO_ID	    NUMBER(12,0),
           PROMO_NAME	  VARCHAR2(8 BYTE),
           CONSTRAINT PK_PROMOTIONS PRIMARY KEY (PROMO_ID)
           ); 


4. FLOAT 타입의 경우, 괄호안에 지정하는 수는 이진수 기준 자릿수라고 했다.
   FLOAT(126)의 경우 126 * 0.30103 = 37.92978 이 되어 NUMBER 타입의 38자리와 같다.
   그런데 왜 0.30103을 곱하는 것일까?
   
<정답>
이진수를 십진수로 변환하는 것이다. 10진수 기준으로 LOG(2)의 값이 바로 0.30103 이다.
즉, 10에다 0.30103 제곱을 하면 2가 나오는 것이다.


5. 최소값 1, 최대값 99999999, 1000부터 시작해서 1씩 증가하는 ORDERS_SEQ 라는 시퀀스를 만들어보자.

<정답>

CREATE SEQUENCE ORDERS_SEQ  
MINVALUE 1 
MAXVALUE 99999999
INCREMENT BY 1 
START WITH 1000 
NOCACHE  
NOORDER  
NOCYCLE ;
    
