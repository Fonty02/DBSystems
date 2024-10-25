--CREATE TYPES

CREATE OR REPLACE TYPE CustomerType AS OBJECT (
    name VARCHAR2(25),
    surname VARCHAR2(25),
    fiscalCode VARCHAR2(16),
    dateOfBirth DATE
);
/


CREATE OR REPLACE TYPE TariffPlanType AS OBJECT(
    tariffPlanCode varchar(20),
    callPrice NUMBER,
    internationalCallPrice NUMBER(9,2),
    videoCallPrice NUMBER(9,2),
    smsPrice NUMBER(9,2),
    mmsPrice NUMBER(9,2),
    internetPrice NUMBER(9,2)
)
NOT FINAL
/

CREATE OR REPLACE TYPE SubscriptionTariffPlan UNDER TariffPlanType (
    callLimit NUMBER(5),
    smsLimit NUMBER(5),
    mmsLimit NUMBER(3),
    internetLimit NUMBER(3),
    subscriptionPrice NUMBER(3));


/
CREATE OR REPLACE TYPE ContractType AS OBJECT (
    codeContract VARCHAR2(20),
    telephone VARCHAR2(13),
    customer REF CustomerType,
    tariffPlan REF TariffPlanType
)
NOT FINAL;

/
CREATE OR REPLACE TYPE OperationType AS OBJECT (
    datetime DATE,
    data BLOB,
    contract REF ContractType
)
NOT FINAL
;
/
CREATE OR REPLACE TYPE CallType UNDER OperationType (
    duration NUMBER,
    telephone VARCHAR2(13)
);
/
CREATE OR REPLACE TYPE TextType UNDER OperationType (
    telephone VARCHAR2(13)
);
/
CREATE OR REPLACE TYPE InternetType UNDER OperationType (
    amoountOfData NUMBER(10)
);
/
CREATE OR REPLACE TYPE CallTypeNT AS TABLE OF CallType;
/
CREATE OR REPLACE TYPE TextTypeNT AS TABLE OF TextType;
/
CREATE OR REPLACE TYPE InternetTypeNT as TABLE OF InternetType;
/
CREATE OR REPLACE TYPE InvoiceType AS OBJECT (
    dateTime DATE,
    customer CustomerType,
    callTotal NUMBER(5, 2),
    textTotal NUMBER(5, 2),
    internetTotal NUMBER(5, 2),
    calls CallTypeNT,
    texts TextTypeNT,
    internets InternetTypeNT);
/

CREATE OR REPLACE TYPE ClaimType AS OBJECT (
    dateTime DATE,
    reason VARCHAR2(50),
    reinbursement NUMBER(5, 2),
    invoice REF InvoiceType
);

/
CREATE OR REPLACE TYPE SubscriptionBased UNDER ContractType (
    iban CHAR(27)
);
/
CREATE OR REPLACE TYPE RechargeableType UNDER ContractType (
    credit NUMBER
);
/



CREATE OR REPLACE TYPE PromotionType AS OBJECT (
    name VARCHAR2(25),
    startDate DATE,
    endDate DATE,
    tariffPlan TariffPlanType,
    contract ref ContractType
);
/


CREATE TABLE Customers OF CustomerType(
    PRIMARY KEY(fiscalCode),
    name NOT NULL,
    surname NOT NULL
)
/
CREATE TABLE TariffPlans OF TariffPlanType(
    PRIMARY KEY(tariffPlanCode)
)
/
CREATE TABLE SubscriptionTariffPlans OF SubscriptionTariffPlan;

CREATE TABLE Contracts OF ContractType(
   PRIMARY KEY(codeContract),
   customer NOT NULL,
   telephone NOT NULL
)
/


CREATE TABLE Operations OF OperationType(
    dateTime NOT NULL
)
/
CREATE TABLE Calls OF CallType
/

CREATE TABLE Texts OF TextType
/

CREATE TABLE Internets OF InternetType
/

CREATE TABLE Invoices OF InvoiceType(
    dateTime NOT NULL,
    customer NOT NULL)
NESTED TABLE calls STORE AS calls_tab,
NESTED TABLE texts STORE AS texts_tab,
NESTED TABLE internets STORE AS internets_tab
/

CREATE TABLE Claims OF ClaimType
/

CREATE TABLE SubscriptionBasedContracts OF SubscriptionBased
/

CREATE TABLE RechargeableContracts OF RechargeableType
/

CREATE TABLE Promotions OF PromotionType
/

--INSERTS

-- Insert data into Customers
INSERT INTO Customers VALUES (
    'John', 'Doe', 'JHNDOE1234567890', TO_DATE('1980-01-01', 'YYYY-MM-DD')
);
INSERT INTO Customers VALUES (
    'Jane', 'Smith', 'JNSMTH0987654321', TO_DATE('1990-02-02', 'YYYY-MM-DD')
);

-- Insert data into TariffPlans
INSERT INTO TariffPlans VALUES (
    'BASIC', 0.10, 0.20, 0.30, 0.05, 0.10, 0.15
);
INSERT INTO TariffPlans VALUES (
    'PREMIUM', 0.05, 0.10, 0.15, 0.02, 0.05, 0.10
);

-- Insert data into SubscriptionTariffPlans
INSERT INTO SubscriptionTariffPlans VALUES (
    'SUB_BASIC', 0.10, 0.20, 0.30, 0.05, 0.10, 0.15, 100, 100, 50, 10, 20
);
INSERT INTO SubscriptionTariffPlans VALUES (
    'SUB_PREMIUM', 0.05, 0.10, 0.15, 0.02, 0.05, 0.10, 200, 200, 100, 20, 40
);

-- Insert data into Contracts
INSERT INTO Contracts VALUES (
    'CONTRACT1', '1234567890123', (SELECT REF(c) FROM Customers c WHERE c.fiscalCode = 'JHNDOE1234567890'), (SELECT REF(t) FROM TariffPlans t WHERE t.tariffPlanCode = 'BASIC')
);
INSERT INTO Contracts VALUES (
    'CONTRACT2', '9876543210987', (SELECT REF(c) FROM Customers c WHERE c.fiscalCode = 'JNSMTH0987654321'), (SELECT REF(t) FROM TariffPlans t WHERE t.tariffPlanCode = 'PREMIUM')
);

-- Insert data into Calls
INSERT INTO Calls VALUES (
    TO_DATE('2023-01-01', 'YYYY-MM-DD'), EMPTY_BLOB(), (SELECT REF(c) FROM Contracts c WHERE c.codeContract = 'CONTRACT1'), 60, '1234567890123'
);
INSERT INTO Calls VALUES (
    TO_DATE('2023-02-01', 'YYYY-MM-DD'), EMPTY_BLOB(), (SELECT REF(c) FROM Contracts c WHERE c.codeContract = 'CONTRACT2'), 120, '9876543210987'
);


-- Insert data into Texts
INSERT INTO Texts VALUES (
    TO_DATE('2023-01-01', 'YYYY-MM-DD'), EMPTY_BLOB(), (SELECT REF(c) FROM Contracts c WHERE c.codeContract = 'CONTRACT1'), '1234567890123'
);
INSERT INTO Texts VALUES (
    TO_DATE('2023-02-01', 'YYYY-MM-DD'), EMPTY_BLOB(), (SELECT REF(c) FROM Contracts c WHERE c.codeContract = 'CONTRACT2'), '9876543210987'
);

-- Insert data into Internets
INSERT INTO Internets VALUES (
    TO_DATE('2023-01-01', 'YYYY-MM-DD'), EMPTY_BLOB(), (SELECT REF(c) FROM Contracts c WHERE c.codeContract = 'CONTRACT1'), 500
);
INSERT INTO Internets VALUES (
    TO_DATE('2023-02-01', 'YYYY-MM-DD'), EMPTY_BLOB(), (SELECT REF(c) FROM Contracts c WHERE c.codeContract = 'CONTRACT2'), 1000
);

-- Insert data into Invoices
INSERT INTO Invoices VALUES (
    TO_DATE('2023-03-01', 'YYYY-MM-DD'), (SELECT VALUE(c) FROM Customers c WHERE c.fiscalCode = 'JHNDOE1234567890'), 10.00, 5.00, 15.00, CallTypeNT(), TextTypeNT(), InternetTypeNT()
);
INSERT INTO Invoices VALUES (
    TO_DATE('2023-04-01', 'YYYY-MM-DD'), (SELECT VALUE(c) FROM Customers c WHERE c.fiscalCode = 'JNSMTH0987654321'), 20.00, 10.00, 30.00, CallTypeNT(), TextTypeNT(), InternetTypeNT()
);

-- Insert data into Claims
INSERT INTO Claims VALUES (
    TO_DATE('2023-05-01', 'YYYY-MM-DD'), 'Incorrect billing', 5.00, (SELECT REF(i) FROM Invoices i WHERE i.dateTime = TO_DATE('2023-03-01', 'YYYY-MM-DD'))
);
INSERT INTO Claims VALUES (
    TO_DATE('2023-06-01', 'YYYY-MM-DD'), 'Service disruption', 10.00, (SELECT REF(i) FROM Invoices i WHERE i.dateTime = TO_DATE('2023-04-01', 'YYYY-MM-DD'))
);

-- Insert data into SubscriptionBasedContracts
INSERT INTO SubscriptionBasedContracts VALUES (
    'CONTRACT1', '1234567890123', (SELECT REF(c) FROM Customers c WHERE c.fiscalCode = 'JHNDOE1234567890'), (SELECT REF(t) FROM TariffPlans t WHERE t.tariffPlanCode = 'BASIC'), 'IT60X0542811101000000123456'
);

-- Insert data into RechargeableContracts
INSERT INTO RechargeableContracts VALUES (
    'CONTRACT2', '9876543210987', (SELECT REF(c) FROM Customers c WHERE c.fiscalCode = 'JNSMTH0987654321'), (SELECT REF(t) FROM TariffPlans t WHERE t.tariffPlanCode = 'PREMIUM'), 50.00
);

-- Insert data into Promotions
INSERT INTO Promotions VALUES (
    'Summer Sale', TO_DATE('2023-06-01', 'YYYY-MM-DD'), TO_DATE('2023-08-31', 'YYYY-MM-DD'), (SELECT VALUE(t) FROM TariffPlans t WHERE t.tariffPlanCode = 'BASIC'), (SELECT REF(c) FROM Contracts c WHERE c.codeContract = 'CONTRACT1')
);
INSERT INTO Promotions VALUES (
    'Winter Sale', TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2024-02-28', 'YYYY-MM-DD'), (SELECT VALUE(t) FROM TariffPlans t WHERE t.tariffPlanCode = 'PREMIUM'), (SELECT REF(c) FROM Contracts c WHERE c.codeContract = 'CONTRACT2')
);


INSERT INTO Operations
VALUES (
    CallType(
        TO_DATE('2023-01-01', 'YYYY-MM-DD'), -- datetime
        EMPTY_BLOB(),                        -- data (BLOB vuoto)
        (SELECT REF(c) FROM Contracts c WHERE c.codeContract = 'CONTRACT1'), -- contract REF
        120,                                 -- durata della chiamata
        '1234567890123'                      -- numero di telefono
    )
);



--SELECT o.datetime, deref(o.contract) as CONTRACT FROM Operations o;
--SELECT o.datetime, DEREF(o.contract) AS CONTRACT FROM Operations o WHERE VALUE(o) IS OF (CallType);
SELECT o.datetime
FROM Operations o
WHERE VALUE(o) IS OF (CallType);




--DROP TABLES
DROP TABLE Customers;
DROP TABLE TariffPlans;
DROP TABLE SubscriptionTariffPlans;
DROP TABLE Contracts;
DROP TABLE Operations;
DROP TABLE Calls;
DROP TABLE Texts;
DROP TABLE Internets;
DROP TABLE Invoices;
DROP TABLE Claims;
DROP TABLE SubscriptionBasedContracts;
DROP TABLE RechargeableContracts;
DROP TABLE Promotions;

--DROP TYPES
DROP TYPE PromotionType FORCE;
DROP TYPE RechargeableType FORCE;
DROP TYPE SubscriptionBased FORCE;
DROP TYPE ContractType FORCE;
DROP TYPE ClaimType FORCE;
DROP TYPE InvoiceType FORCE;
DROP TYPE InternetTypeNT FORCE;
DROP TYPE TextTypeNT FORCE;
DROP TYPE CallTypeNT FORCE;
DROP TYPE InternetType FORCE;
DROP TYPE TextType FORCE;
DROP TYPE CallType FORCE;
DROP TYPE OperationType FORCE;
DROP TYPE SubscriptionTariffPlan FORCE;
DROP TYPE TariffPlanType FORCE;
DROP TYPE CustomerType FORCE;

