---#################################################################################################################################à
---CONNECT AS SYSTEM

-- USER SQL
CREATE USER YELLOWCOM IDENTIFIED BY yellowcom
DEFAULT TABLESPACE "USERS";

-- QUOTAS

-- ROLES
GRANT "CONNECT" TO YELLOWCOM ;

-- QUOTAS
ALTER USER YELLOWCOM QUOTA UNLIMITED ON "USERS";

-- ROLES
ALTER USER YELLOWCOM DEFAULT ROLE "CONNECT";


-- SYSTEM PRIVILEGES



GRANT DROP ANY TRIGGER TO YELLOWCOM ;
GRANT CREATE TRIGGER TO YELLOWCOM ;
GRANT CREATE ANY PROCEDURE TO YELLOWCOM ;
GRANT CREATE VIEW TO YELLOWCOM ;
GRANT CREATE TABLE TO YELLOWCOM ;
GRANT DROP ANY TABLE TO YELLOWCOM ;
GRANT CREATE TYPE TO YELLOWCOM ;
GRANT CREATE TABLESPACE TO YELLOWCOM ;
GRANT DROP ANY TYPE TO YELLOWCOM ;
GRANT DROP ANY INDEX TO YELLOWCOM ;
GRANT CREATE USER TO YELLOWCOM ;
GRANT DROP ANY VIEW TO YELLOWCOM ;
GRANT CREATE ANY VIEW TO YELLOWCOM ;
GRANT CREATE ANY TRIGGER TO YELLOWCOM ;
GRANT CREATE ANY TABLE TO YELLOWCOM ;
GRANT CREATE ANY TYPE TO YELLOWCOM ;

---#################################################################################################################################à
---CONNECT AS YELLOWCOM

--CREATE OF TYPES--
DROP TABLE Contract;
DROP TABLE Customer;
DROP TABLE Invoice;
DROP TABLE Operation;
DROP TABLE Promotion;
DROP TABLE TariffPlan;
DROP TYPE TariffPlanType FORCE;
DROP TYPE CustomerType FORCE;
DROP TYPE ContractType FORCE;
DROP TYPE CallType FORCE;
DROP TYPE CallTypeNT FORCE;
DROP TYPE ClaimType FORCE;
DROP TYPE InternetConnectionType FORCE;
DROP TYPE InternetConnectionTypeNT FORCE;
DROP TYPE InvoiceType FORCE;
DROP TYPE OperationType FORCE;
DROP TYPE OperationDetailType FORCE;
DROP TYPE PromotionType FORCE;
DROP TYPE RechargeableType FORCE;
DROP TYPE SubscriptionBasedType FORCE;
DROP TYPE SubscriptionTariffPlanType FORCE;
DROP TYPE TextType FORCE;
DROP TYPE TextTypeNT FORCE;
/
CREATE OR REPLACE TYPE ContractType;
/
CREATE OR REPLACE TYPE TariffPlanType;
/
CREATE OR REPLACE TYPE CustomerType AS OBJECT
( name VARCHAR2(25),
  surname VARCHAR2(25),
  fiscalCode VARCHAR2(16),
  dateOfBirth DATE);
/
CREATE OR REPLACE TYPE ContractType AS OBJECT
( codeContract VARCHAR2(20),
  customer ref CustomerType,
  telephone VARCHAR2(13),
  tariffPlan ref TariffPlanType) NOT FINAL;
/
CREATE OR REPLACE TYPE SubscriptionBasedType UNDER ContractType
(  IBAN CHAR(22) );
/
CREATE OR REPLACE TYPE RechargeableType UNDER ContractType
(  credit NUMBER );
/
CREATE OR REPLACE TYPE TariffPlanType AS OBJECT 
(  tariffPlanCode varchar(20),
   callPrice NUMBER,
   internationalCallPrice NUMBER(9,2),
   videoCallPrice NUMBER(9,2),
   smsPrice NUMBER(9,2),
   mmsPrice NUMBER(9,2),
   internetPrice NUMBER(9,2)) NOT FINAL;
/
CREATE OR REPLACE TYPE SubscriptionTariffPlanType UNDER TariffPlanType 
(  callLimit NUMBER(5),
   smsLimit NUMBER(5),
   mmsLimit NUMBER(5),
   internetLimit NUMBER(3),
   subscriptionPrice NUMBER(3) );
/
CREATE OR REPLACE TYPE PromotionType AS OBJECT
(  name VARCHAR2(25),
   startDate DATE,
   endDate DATE,
   tariffPlan TariffPlanType );
/   
CREATE OR REPLACE TYPE OperationDetailType AS OBJECT 
(  name VARCHAR2(20) ) NOT FINAL;
/
CREATE OR REPLACE TYPE OperationType AS OBJECT
(  datetime DATE,
   contract ref ContractType,
   details OperationDetailType,
   data BLOB ) NOT FINAL; 
/
CREATE OR REPLACE TYPE CallType UNDER OperationDetailType 
(  durationCall NUMBER,
   telephone VARCHAR2(13) );
/
CREATE OR REPLACE TYPE TextType UNDER OperationDetailType
(  telephone VARCHAR2(13) );
/
CREATE OR REPLACE TYPE InternetConnectionType UNDER OperationDetailType
(  amountOfData NUMBER(10) );
/
CREATE OR REPLACE TYPE CallTypeNT AS TABLE OF REF OperationType;
/
CREATE OR REPLACE TYPE TextTypeNT AS TABLE OF REF OperationType;
/
CREATE OR REPLACE TYPE InternetConnectionTypeNT AS TABLE OF REF OperationType;
/
CREATE OR REPLACE TYPE InvoiceType AS OBJECT
(  dateInvoice DATE,
   customer CustomerType,
   callTotal NUMBER,
   textTotal NUMBER,
   internetTotal NUMBER,
   calls CallTypeNT,
   texts TextTypeNT,
   internet InternetConnectionTypeNT );
/   
CREATE OR REPLACE TYPE ClaimType AS OBJECT
(  dateClaim DATE,
   reason VARCHAR(50),
   claim ref InvoiceType,
   reimbursement NUMBER(5,2) );
/
--CREATE OF TABLES--
CREATE TABLE Customer of CustomerType 
(  fiscalCode PRIMARY KEY,
   name NOT NULL,
   surname NOT NULL);
/
CREATE TABLE Contract of ContractType
( customer NOT NULL,
  telephone NOT NULL,
  codeContract PRIMARY KEY);
/
CREATE TABLE TariffPlan of TariffPlanType
( tariffPlanCode PRIMARY KEY );
/
CREATE TABLE Promotion of PromotionType 
( name NOT NULL,
  startDate NOT NULL );
/
CREATE TABLE Operation of OperationType 
( datetime NOT NULL );
/
CREATE TABLE Invoice of InvoiceType(
  dateInvoice NOT NULL,
  customer NOT NULL )
NESTED TABLE calls STORE AS CallOperationNT_TAB,
NESTED TABLE texts STORE AS TextOperationNT_TAB,
NESTED TABLE internet STORE AS InternetConnectionNT_TAB;
/
INSERT INTO TariffPlan VALUES (TariffPlanType('Standard Plan', 0.50, 1.00, 1.50, 0.22, 0.80, 1.20));
INSERT INTO TariffPlan VALUES (TariffPlanType('Fedelity Plan', 0.30, 0.90, 1.30, 0.10, 0.70, 1.00));
INSERT INTO TariffPlan VALUES (SubscriptionTariffPlanType('AllInclusive Plan', 0.50, 1.00, 1.50, 0.22, 0.80, 1.20, 1000, 1000, 100, 50, 15));
INSERT INTO TariffPlan VALUES (SubscriptionTariffPlanType('Vip Plan', 0.50, 1.00, 1.50, 0.22, 0.80, 1.20, 10000, 10000, 100, 200, 25));
INSERT INTO TariffPlan VALUES (TariffPlanType('Fedelity Plan 2', 0.30, 0.90, 1.30, 0.10, 0.70, 1.00));
commit work;
/
INSERT INTO Customer VALUES ('Lapolla', 'Michele', 'LPLMHL96M12A225B', '13-NOV-96');
INSERT INTO Customer VALUES ('Vincenzo', 'Digeno', 'DGNVCN96L12A232B', '12-DEC-96');
INSERT INTO Customer VALUES ('Michele', 'Giorgio', 'MDKMHL96M12A225B', '11-JAN-96');
/
INSERT INTO Contract VALUES (RechargeableType('JKHSDGSA', (SELECT ref(cs) FROM Customer cs WHERE cs.fiscalCode = 'LPLMHL96M12A225B'), '3278494566', NULL, 15));
INSERT INTO Contract VALUES (RechargeableType('VKHSDGSA', (SELECT ref(cs) FROM Customer cs WHERE cs.fiscalCode = 'MDKMHL96M12A225B'), '3258494566', NULL, 15));
INSERT INTO Contract VALUES (RechargeableType('FJKHSDGSA', (SELECT ref(cs) FROM Customer cs WHERE cs.fiscalCode = 'MDKMHL96M12A225B'), '3578494566', NULL, 15));
INSERT INTO Contract VALUES (RechargeableType('DJKHSDGSA', (SELECT ref(cs) FROM Customer cs WHERE cs.fiscalCode = 'LPLMHL96M12A225B'), '3276494566', NULL, 25));
INSERT INTO Contract VALUES (RechargeableType('HJKHSDGSA', (SELECT ref(cs) FROM Customer cs WHERE cs.fiscalCode = 'MDKMHL96M12A225B'), '3278494766', NULL, 35));
INSERT INTO Contract VALUES (RechargeableType('SJKHSDGSA', (SELECT ref(cs) FROM Customer cs WHERE cs.fiscalCode = 'LPLMHL96M12A225B'), '3278494666', NULL, 35));
INSERT INTO Contract VALUES (RechargeableType('ZJJJKHSDGSA', (SELECT ref(cs) FROM Customer cs WHERE cs.fiscalCode = 'MDKMHL96M12A225B'), '3278494166', NULL, 45));
INSERT INTO Contract VALUES (RechargeableType('PJKHSDGSA', (SELECT ref(cs) FROM Customer cs WHERE cs.fiscalCode = 'LPLMHL96M12A225B'), '3278494266', NULL, 55));
INSERT INTO Contract VALUES (RechargeableType('ABKHSDGSA', (SELECT ref(cs) FROM Customer cs WHERE cs.fiscalCode = 'DGNVCN96L12A232B'), '3278494366', NULL, 65));
INSERT INTO Contract VALUES (RechargeableType('AXHSDGSA', (SELECT ref(cs) FROM Customer cs WHERE cs.fiscalCode = 'LPLMHL96M12A225B'), '3278494366', NULL, 75));
INSERT INTO Contract VALUES (RechargeableType('ACHSDGSA', (SELECT ref(cs) FROM Customer cs WHERE cs.fiscalCode = 'DGNVCN96L12A232B'), '3278494966', NULL, 95));
INSERT INTO Contract VALUES (RechargeableType('AFGDAD', (SELECT ref(cs) FROM Customer cs WHERE cs.fiscalCode = 'MDKMHL96M12A225B'), '3278694266', NULL, 100));
INSERT INTO Contract VALUES (RechargeableType('AKSDADH', (SELECT ref(cs) FROM Customer cs WHERE cs.fiscalCode = 'DGNVCN96L12A232B'), '3278694766', NULL, 50));
INSERT INTO Contract VALUES (SubscriptionBasedType('SDDLSH', (SELECT ref(cs) FROM Customer cs WHERE cs.fiscalCode = 'DGNVCN96L12A232B'), '3278690466', NULL,'IT60X05428111123'));
/
UPDATE Contract SET tariffplan = (SELECT ref(tp) FROM TariffPlan tp WHERE tp.tariffplancode = 'Standard Plan') WHERE codecontract='AKSDADH';
UPDATE Contract SET tariffplan = (SELECT ref(tp) FROM TariffPlan tp WHERE tp.tariffplancode = 'Fedelity Plan') WHERE codecontract='FJKHSDGSA';
UPDATE Contract SET tariffplan = (SELECT ref(tp) FROM TariffPlan tp WHERE tp.tariffplancode = 'AllInclusive Plan') WHERE codecontract='ACHSDGSA';
UPDATE Contract SET tariffplan = (SELECT ref(tp) FROM TariffPlan tp WHERE tp.tariffplancode = 'Vip Plan') WHERE codecontract='ABKHSDGSA';
/
INSERT INTO Operation VALUES ('13-NOV-96',  (SELECT ref(ct) FROM Contract ct WHERE ct.codecontract = 'JKHSDGSA'), CallType('Call', 10, '+3932485785'),  NULL);
INSERT INTO Operation VALUES ('24-NOV-99', (SELECT ref(ct) FROM Contract ct WHERE ct.codecontract = 'JKHSDGSA'), TextType('Text','+3932485785'), NULL);
INSERT INTO Operation VALUES ('13-NOV-99', (SELECT ref(ct) FROM Contract ct WHERE ct.codecontract = 'JKHSDGSA'), TextType('Text','+3932485785'), NULL);
INSERT INTO Operation VALUES ('14-NOV-99', (SELECT ref(ct) FROM Contract ct WHERE ct.codecontract = 'AKSDADH'), CallType('Call', 1, '+3932485785'), NULL);
INSERT INTO Operation VALUES ('15-NOV-99', (SELECT ref(ct) FROM Contract ct WHERE ct.codecontract = 'ACHSDGSA'), TextType('Text','+3932485785'), NULL);
INSERT INTO Operation VALUES ('16-NOV-99', (SELECT ref(ct) FROM Contract ct WHERE ct.codecontract = 'ACHSDGSA'), InternetConnectionType('Internet', 30), NULL);
/
/**
Create a procedure that automatically and randomly populates the table Customer
**/
CREATE OR REPLACE PROCEDURE populateCustomer as
BEGIN
  FOR i IN 1..400000  LOOP 
    INSERT INTO Customer VALUES (
      dbms_random.string('L',16), 
      dbms_random.string('L',10), 
      dbms_random.string('L',10), 
      (SELECT TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE '1910-01-01','J'), TO_CHAR(DATE '1999-12-31', 'J'))), 'J') FROM DUAL));
  END LOOP;
END;
/
/**
Create a procedure that automatically and randomly populates the table Contract
**/
CREATE OR REPLACE PROCEDURE populateContract AS 
BEGIN
  FOR i IN 1..50 LOOP
    INSERT INTO Contract VALUES (
      RechargeableType(
      DBMS_RANDOM.STRING('U', 10),
      (SELECT * FROM (SELECT REF(T) FROM Customer T ORDER BY dbms_random.value) WHERE rownum < 2),
      (SELECT (TRUNC(dbms_random.value(1, 10),9)*1000000000) FROM dual),
      (SELECT * FROM (SELECT REF(T) FROM TariffPlan T ORDER BY dbms_random.value) WHERE rownum < 2),
      (SELECT (TRUNC(dbms_random.value(1, 10),2)*10) FROM dual)));
    END LOOP;
END;
/
/**
Create a procedure that automatically and randomly populates the table Operation
with call operation
**/
CREATE OR REPLACE PROCEDURE populateCallOperation AS 
BEGIN
  FOR i IN 1..400 LOOP
    INSERT INTO Operation VALUES (
      (select (sysdate - (select trunc(dbms_random.value(0,9)*1, 0) from dual)) from dual) ,
      (SELECT * FROM (SELECT REF(T) FROM Contract T ORDER BY dbms_random.value) WHERE rownum < 2),
      CallType('Call', (SELECT (TRUNC((dbms_random.value(0, 9)*10),2)) FROM dual),(SELECT (TRUNC(dbms_random.value(1, 10),9)*1000000000) FROM dual)), NULL);
    END LOOP;
END;
/
/**
Create a procedure that automatically and randomly populates the table Operation
with text operation
**/
CREATE OR REPLACE PROCEDURE populateTextOperation AS 
BEGIN
  FOR i IN 1..400 LOOP
    INSERT INTO Operation VALUES (
      (select (sysdate - (select trunc(dbms_random.value(0,9)*1, 0) from dual)) from dual) ,
      (SELECT * FROM (SELECT REF(T) FROM Contract T ORDER BY dbms_random.value) WHERE rownum < 2),
      TextType('Text',(SELECT (TRUNC(dbms_random.value(1, 10),9)*1000000000) FROM dual)), NULL);
    END LOOP;
END;
/
/**
Create a procedure that automatically and randomly populates the table Operation
with internet operation
**/
CREATE OR REPLACE PROCEDURE populateInternetOperation AS 
BEGIN
  FOR i IN 1..400 LOOP
    INSERT INTO Operation VALUES (
      (select (sysdate - (select trunc(dbms_random.value(0,9)*10, 0) from dual)) from dual) ,
      (SELECT * FROM (SELECT REF(T) FROM Contract T ORDER BY dbms_random.value) WHERE rownum < 2),
      InternetConnectionType('Internet', (SELECT (TRUNC((dbms_random.value(0, 9)*100),2)) FROM dual)), NULL);
    END LOOP;
END;
/
/**
Create a procedure that automatically and randomly populates the table Invoice
**/
CREATE OR REPLACE PROCEDURE populateInvoice AS 
callTable CallTypeNT := CallTypeNT();
textTable TextTypeNT := TextTypeNT();
internetTable InternetConnectionTypeNT := InternetConnectionTypeNT();
totalCall NUMBER := 0;
totalText NUMBER := 0;
totalInternet NUMBER := 0;

cursor contractCursor is
SELECT *
FROM Contract ct
WHERE value(ct) is of (SubscriptionBasedType);
BEGIN
  FOR cts IN contractCursor LOOP
   SELECT ref(op) bulk collect into callTable
   from Operation op
   where op.details is of (CallType) 
   AND deref(op.contract).codeContract LIKE cts.codeContract
   AND op.datetime < (select sysdate from dual)
   AND op.datetime > (select sysdate-31 from dual);
   
   SELECT ref(op) bulk collect into textTable
   from Operation op
   where op.details is of (TextType) 
   AND deref(op.contract).codeContract LIKE cts.codeContract
   AND op.datetime < (select sysdate from dual)
   AND op.datetime > (select sysdate-31 from dual);
   
   SELECT ref(op) bulk collect into internetTable
   from Operation op
   where op.details is of (InternetConnectionType) 
   AND deref(op.contract).codeContract LIKE cts.codeContract
   AND op.datetime < (select sysdate from dual)
   AND op.datetime > (select sysdate-31 from dual);
   
   SELECT SUM(TREAT(op.details AS CallType).durationCall) INTO totalCall
   FROM Operation op
   WHERE deref(op.contract).codeContract LIKE cts.codeContract
   AND op.datetime < (select sysdate from dual)
   AND op.datetime > (select sysdate-31 from dual);
   
   totalText := textTable.COUNT;
   
   SELECT SUM(TREAT(op.details AS InternetConnectionType).amountOfData) INTO totalInternet
   FROM Operation op
   WHERE deref(op.contract).codeContract LIKE cts.codeContract
   AND op.datetime < (select sysdate from dual)
   AND op.datetime > (select sysdate-31 from dual);
   
   INSERT INTO Invoice VALUES(
    (select sysdate from dual), 
    deref(cts.customer), 
    totalCall  * (SELECT ct.tariffPlan.callPrice from Contract ct WHERE ct.codeContract LIKE cts.codeContract), 
    totalText  * (SELECT ct.tariffPlan.smsPrice from Contract ct WHERE ct.codeContract LIKE cts.codeContract), 
    totalInternet  * (SELECT ct.tariffPlan.internetPrice from Contract ct WHERE ct.codeContract LIKE cts.codeContract),
    callTable, 
    textTable, 
    internetTable);
  END LOOP;
END;
/
/**
A procedure that prints name and surname of each customer and the
total number of customers
**/
CREATE OR REPLACE PROCEDURE printCustomerDetails AS 
  CURSOR customerCursor IS (SELECT * FROM Customer);
  counter NUMBER;
BEGIN 
  FOR customer IN customerCursor LOOP
    dbms_output.put_line(customer.name || ' - ' || customer.surname);
  END LOOP;
  SELECT count(*) INTO counter FROM Customer;
  dbms_output.put_line('Number of customers: ' || counter);
END;
/
/**
A procedure that prints the number of text messages sent by a customer given as input,
grouped by the number.
**/
create or replace
PROCEDURE printCustomerTexts(fc IN VARCHAR2) AS
 result NUMBER;
 numberOfTexts NUMBER;
 noCustomerFound EXCEPTION;
 type contracts_array IS VARRAY(10000) OF ContractType;
 contracts_values contracts_array;
 CURSOR c1 IS
 SELECT value(ct) 
 FROM Contract ct 
 WHERE  ct.customer.fiscalcode LIKE fc;
 BEGIN
  SELECT count(*) INTO result FROM Customer cu WHERE cu.fiscalCode LIKE fc;
  IF result = 0 THEN 
   RAISE noCustomerFound;
  ELSE
  OPEN c1;
  FETCH c1 BULK collect INTO contracts_values;
  CLOSE c1;
   FOR i IN contracts_values.FIRST .. contracts_values.LAST
   LOOP
     SELECT count(*) INTO numberOfTexts 
     FROM Operation op 
     WHERE op.details IS OF (TextType) AND
     deref(op.contract).codeContract = contracts_values(i).codeContract;
     DBMS_OUTPUT.PUT_LINE('Number of text messages from number ' || contracts_values(i).telephone || ' are: ' || numberOfTexts);
   END LOOP;
  END IF;
  EXCEPTION WHEN noCustomerFound THEN
   DBMS_OUTPUT.PUT_LINE('Error - No customer found');
 END;
/
/**
A function that 
- returns the traffic expense (in euros) in the last year 
  for a customer given as input;
- print the three most frequently called numbers;
- print statistics.
**/
CREATE OR REPLACE FUNCTION expenseLastYear(cf IN VARCHAR2) 
RETURN NUMBER AS
totalExpense NUMBER (11,2);
totalCall NUMBER;
totalText NUMBER;
totalInternet NUMBER;
total NUMBER;
BEGIN
 SELECT SUM(inv.callTotal) INTO totalCall
 FROM Invoice inv
 WHERE inv.dateInvoice <= (select sysdate from dual) 
       AND inv.dateInvoice > (select sysdate-365 from dual)
       AND inv.customer.fiscalCode LIKE cf;
 
 
 SELECT count(*) INTO totalText 
 FROM Operation op
 WHERE op.details is of (TextType)
       AND op.datetime <= (select sysdate from dual) 
       AND op.datetime > (select sysdate-365 from dual)
       AND op.contract.customer.fiscalCode LIKE cf;
 
 SELECT SUM(TREAT(op.details AS InternetConnectionType).amountOfData) INTO totalInternet 
 FROM Operation op
 WHERE op.datetime <= (select sysdate from dual) 
       AND op.datetime > (select sysdate-365 from dual)
       AND op.contract.customer.fiscalCode LIKE cf;
 
 FOR ops IN 
    (SELECT SUM(TREAT(op.details AS CallType).durationCall) as duration, TREAT(op.details AS CallType).telephone as tp
     FROM Operation op
     WHERE op.datetime > (select sysdate-365 from dual)
           AND op.contract.customer.fiscalCode LIKE cf
           AND ROWNUM <= 5
     GROUP BY TREAT(op.details AS CallType).telephone
     ORDER BY duration DESC)
     LOOP
      DBMS_OUTPUT.PUT_LINE ('Number: ' || ops.tp);
     END LOOP;
     
     SELECT TRUNC( (totalCall + totalText + totalInternet), 2) INTO total FROM dual;
     DBMS_OUTPUT.PUT_LINE ('Percent of call: ' || (totalCall/total)*100);
     DBMS_OUTPUT.PUT_LINE ('Percent of text: ' || (totalText/total)*100);
     DBMS_OUTPUT.PUT_LINE ('Percent of internet: ' || (totalInternet/total)*100);
 RETURN(total);
END;
/
/**
A trigger that keep updated the credit associated with a contract (rechargeable)
for an insertion or modification in the table operation (in the lab)
**/
CREATE OR REPLACE
TRIGGER BalanceCredit
AFTER INSERT ON Operation
FOR EACH ROW
DECLARE 
 contractRT RechargeableType;
 stp SubscriptionTariffPlanType;
 tp TariffPlanType;
 callOperation CallType;
 textOperation TextType;
 internetOperation InternetConnectionType;
BEGIN
 SELECT TREAT(DEREF(:new.contract) AS RechargeableType) INTO contractRT
 FROM dual;
 IF contractRT IS NOT NULL 
 THEN
  SELECT TREAT(DEREF(contractRT.tariffPlan) AS SubscriptionTariffPlanType) INTO stp
  FROM dual;
   IF stp IS NULL 
   THEN
    SELECT TREAT(DEREF(contractRT.tariffPlan) AS TariffPlanType) INTO tp
    FROM dual;
    SELECT TREAT(:new.details AS CallType) INTO callOperation --check if it is a call
    FROM dual;
     IF callOperation IS NOT NULL 
     THEN
      contractRT.credit := contractRT.credit - (tp.callPrice * callOperation.durationCall);
      UPDATE Contract ct SET value(ct) = contractRT WHERE ct.codeContract = contractRT.codeContract;
     END IF;
    SELECT TREAT(:new.details AS TextType) INTO textOperation --check if it is a text
    FROM dual;
     IF textOperation IS NOT NULL 
     THEN
      contractRT.credit := contractRT.credit - tp.smsPrice;
      UPDATE Contract ct SET value(ct) = contractRT WHERE ct.codeContract = contractRT.codeContract;
     END IF;
    SELECT TREAT(:new.details AS InternetConnectionType) INTO internetOperation --check if it is a internet operation
    FROM dual;
     IF internetOperation IS NOT NULL 
     THEN
      contractRT.credit := contractRT.credit - (tp.internetPrice * internetOperation.amountOfData);
      UPDATE Contract ct SET value(ct) = contractRT WHERE ct.codeContract = contractRT.codeContract;
     END IF;
   END IF;
 END IF;
END;
/
/**
A trigger that block an insert/update of an 
operation if the credit is less than 0 \80.
**/
CREATE OR REPLACE 
TRIGGER CheckCredit
AFTER INSERT OR UPDATE ON Operation
FOR EACH ROW
DECLARE
 contractRT RechargeableType;
BEGIN
 SELECT TREAT(DEREF(:new.contract) AS RechargeableType) INTO contractRT
 FROM dual;
 IF contractRT IS NOT NULL 
 THEN
  IF contractRT.credit < 0
  THEN 
   RAISE_APPLICATION_ERROR(-20002,'Credit is zero!');
  END IF;
 END IF;
END;
/

execute populateCustomer
execute populateContract
execute populateCalloperation;

execute populateInternetOperation;
execute populateTextOperation;
execute populateInvoice;
commit work;


/**
QUERY OPTIMIZATION
**/


SELECT * FROM Customer cu WHERE cu.surname < 'a';
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY (FORMAT=>'ALL +OUTLINE'));

SELECT * FROM Customer cu WHERE cu.surname < 'a';


CREATE INDEX surname_idx ON Customer(surname);
EXPLAIN FOR
SELECT /*+ INDEX(cu, surname_idx) */ * FROM Customer cu WHERE cu.surname < 'a';
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY (FORMAT=>'ALL +OUTLINE'));
/
/*
delete from Contract;
delete from Customer;
delete from Operation;
delete from Invoice;
commit work;*/
/
/*execute populateCalloperation;
execute populateInternetOperation;
execute populateTextOperation;
execute populateInvoice;
commit work;*/
