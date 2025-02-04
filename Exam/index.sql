
--INDEX TEST
SET AUTOTRACE ON

--Operation1
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

SELECT COUNT(*) INTO v_count_facility
    FROM Facility
    WHERE Name = p_facility_name;

SELECT COUNT(*) INTO v_count_team
    FROM Team
    WHERE Code = p_team_code;

--Operation 4
SELECT DEREF(e.Team).Code AS team_code
              FROM Employee e
             WHERE e.Manager = 'Y'
             ORDER BY e.DoB ASC
             FETCH FIRST 1 ROWS ONLY;



--Operation 5
SELECT Name, EfficiencyScore
        FROM Facility
       ORDER BY EfficiencyScore DESC;


