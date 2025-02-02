-- Indexes Creation

CREATE INDEX Employee_DoB_Index ON Employee(Dob); 




--INDEX TEST
SET AUTOTRACE ON

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



