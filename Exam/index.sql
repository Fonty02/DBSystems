
--INDEX TEST
SET AUTOTRACE ON

--AUTOTRACE
INSERT INTO CUSTOMER
VALUES (
CustomerTY
(
    'CustomerTrace', 
    'NameTrace', 
    'SurnameTrace', 
    'ciao@gmail.com',
    'Commercial',
    TO_DATE('1985-01-01','YYYY-MM-DD')
)
);

--Operation2

INSERT INTO Contract
VALUES (
ContractTY(
    'ContractTestIndex', 
    'Y', 
    'Commercial', 
    TO_DATE('2023-01-01','YYYY-MM-DD'), 
    100, 
    2500, 
    1, 
    (SELECT REF(a) FROM Account a WHERE a.Code = 'AccountTest'), 
    (SELECT REF(f) FROM Facility f WHERE f.Name = 'FacilityTest3')
)
);



--Operation 3

SELECT COUNT(*) AS v_count_facility
    FROM Facility
    WHERE Name = 'Facility1';

SELECT COUNT(*) AS v_count_team
    FROM Team
    WHERE Code = 'Team1';

--Operation 4
SELECT DEREF(e.Team).Code AS team_code
              FROM Employee e
             WHERE e.Manager = 'Y'
             AND e.Team IS NOT NULL
             ORDER BY e.DoB ASC
             FETCH FIRST 1 ROWS ONLY;



--Operation 5
SELECT Name, EfficiencyScore
        FROM Facility
       ORDER BY EfficiencyScore DESC;



--EXPLAIN PLAN


--Operation1
EXPLAIN PLAN FOR
INSERT INTO CUSTOMER
VALUES (
CustomerTY
(
    'CustomerTrace', 
    'NameTrace', 
    'SurnameTrace', 
    'ciao@gmail.com',
    'Commercial',
    TO_DATE('1985-01-01','YYYY-MM-DD')
)
);
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Operation2
EXPLAIN PLAN FOR
INSERT INTO Contract
VALUES (
ContractTY(
    'ContractTestIndex', 
    'Y', 
    'Commercial', 
    TO_DATE('2023-01-01','YYYY-MM-DD'), 
    100, 
    2500, 
    1, 
    (SELECT REF(a) FROM Account a WHERE a.Code = 'AccountTest'), 
    (SELECT REF(f) FROM Facility f WHERE f.Name = 'FacilityTest3')
)
);
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


--Operation 3
EXPLAIN PLAN FOR
SELECT COUNT(*) AS v_count_facility
    FROM Facility
    WHERE Name = 'Facility1';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

EXPLAIN PLAN FOR
SELECT COUNT(*) AS v_count_team
    FROM Team
    WHERE Code = 'Team1';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


--Operation 4
EXPLAIN PLAN FOR
SELECT DEREF(e.Team).Code AS team_code
              FROM Employee e
             WHERE e.Manager = 'Y'
             AND e.Team IS NOT NULL
             ORDER BY e.DoB ASC
             FETCH FIRST 1 ROWS ONLY;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


--Operation 5
EXPLAIN PLAN FOR
SELECT Name, EfficiencyScore
        FROM Facility
       ORDER BY EfficiencyScore DESC;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
