

CREATE OR REPLACE Procedure DropTypes IS
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE TeamTY FORCE';
    EXECUTE IMMEDIATE 'DROP TYPE FacilityTY FORCE';
    EXECUTE IMMEDIATE 'DROP TYPE EmployeeTY FORCE';
    EXECUTE IMMEDIATE 'DROP TYPE CustomerTY FORCE';
    EXECUTE IMMEDIATE 'DROP TYPE AccountTY FORCE';
    EXECUTE IMMEDIATE 'DROP TYPE ContractTY FORCE';
    EXECUTE IMMEDIATE 'DROP TYPE FeedbackTY FORCE';
END;
/
--drop all table

CREATE OR REPLACE Procedure DropTables IS
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Facility CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Team CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Employee CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Customer CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Account CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Contract CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Feedback CASCADE CONSTRAINTS';
END;
/

CREATE OR REPLACE Procedure CreateTypes IS
BEGIN
    EXECUTE IMMEDIATE 'CREATE OR REPLACE TYPE TeamTY AS OBJECT (
        Code VARCHAR2(20),
        Name VARCHAR2(50),
        Uptime INTEGER
    )';

    EXECUTE IMMEDIATE 'CREATE OR REPLACE TYPE FacilityTY AS OBJECT (
        Name VARCHAR2(50),
        Location VARCHAR2(100),
        Type VARCHAR2(20),
        EfficiencyScore NUMBER,
        MaxOutputEnergy NUMBER,
        SumOutputEnergy NUMBER,
        Team REF TeamTY
    )';

    EXECUTE IMMEDIATE 'CREATE OR REPLACE TYPE EmployeeTY AS OBJECT (
        FC VARCHAR2(20),
        Name VARCHAR2(50),
        Surname VARCHAR2(50),
        DoB DATE,
        DoH DATE,
        Manager CHAR(1),
        Team REF TeamTY
    )';


    EXECUTE IMMEDIATE 'CREATE OR REPLACE TYPE CustomerTY AS OBJECT (
        Code VARCHAR2(20),
        Name VARCHAR2(50),
        Surname VARCHAR2(50),
        Email VARCHAR2(100),
        Type VARCHAR2(20),
        DoB DATE
    )';


    EXECUTE IMMEDIATE 'CREATE OR REPLACE TYPE AccountTY AS OBJECT (
        Code VARCHAR2(20),
        Customer REF CustomerTY
    )';


    EXECUTE IMMEDIATE 'CREATE OR REPLACE TYPE ContractTY AS OBJECT (
        ID VARCHAR2(20),
        Active CHAR(1),
        Type VARCHAR2(20),
        Start_Date DATE,
        Cost NUMBER,
        EnergyPlan NUMBER,
        Duration NUMBER,
        Account REF AccountTY,
        Facility REF FacilityTY
    )';


    EXECUTE IMMEDIATE 'CREATE OR REPLACE TYPE FeedbackTY AS OBJECT (
        Code VARCHAR2(20),
        Message VARCHAR2(200),
        Score INTEGER,
        Account REF AccountTY ,
        Team REF TeamTY
    )';
END;
/

CREATE OR REPLACE Procedure CreateTables IS
BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE Team OF TeamTY (
        Code PRIMARY KEY,
        CONSTRAINT chk_uptime CHECK (Uptime BETWEEN 6 AND 8),
        Name NOT NULL,
        Uptime NOT NULL
    )';
    

    EXECUTE IMMEDIATE 'CREATE TABLE Facility OF FacilityTY (
        Name PRIMARY KEY,
        CONSTRAINT chk_facility_type CHECK (Type IN (''wind'', ''solar'', ''hydro'', ''nuclear'')),
        CONSTRAINT chk_max_output_energy CHECK (MaxOutputEnergy >= 0),
        CONSTRAINT chk_sum_output_energy CHECK (SumOutputEnergy >= 0),
        Location NOT NULL,
        Type NOT NULL,
        MaxOutputEnergy NOT NULL,
        EfficiencyScore NOT NULL,
        Team REFERENCES Team ON DELETE SET NULL
    )';
    


    EXECUTE IMMEDIATE 'CREATE TABLE Employee OF EmployeeTY (
        FC PRIMARY KEY,
        CONSTRAINT chk_manager CHECK (Manager IN (''Y'', ''N'')),
        Name NOT NULL,
        Surname NOT NULL,
        DoB NOT NULL,
        DoH NOT NULL,
        Manager NOT NULL,
        CONSTRAINT chk_doh_after_dob CHECK (DoH > DoB),
        Team REFERENCES Team ON DELETE SET NULL
    )';

    EXECUTE IMMEDIATE 'CREATE TABLE Customer OF CustomerTY (
        Code PRIMARY KEY,
        CONSTRAINT chk_customer_type CHECK (Type IN (''Commercial'', ''Residential'')),
        Name NOT NULL,
        Surname NOT NULL,
        Email NOT NULL,
        Type NOT NULL,
        DoB NOT NULL
    )';

    EXECUTE IMMEDIATE 'CREATE TABLE Account OF AccountTY (
        Code PRIMARY KEY,
        Customer NOT NULL REFERENCES Customer ON DELETE CASCADE
    )';

    EXECUTE IMMEDIATE 'CREATE TABLE Contract OF ContractTY (
        ID PRIMARY KEY,
        CONSTRAINT chk_contract_type CHECK (Type IN (''Commercial'', ''Residential'')),
        CONSTRAINT chk_energy_plan CHECK (EnergyPlan IN (2500, 4500, 10000)),
        CONSTRAINT chk_active CHECK (Active IN (''Y'', ''N'')),
        CONSTRAINT chk_cost CHECK (Cost >= 0),
        CONSTRAINT chk_duration CHECK (Duration >= 1),
        Start_Date NOT NULL,
        Cost NOT NULL,
        EnergyPlan NOT NULL,
        Duration NOT NULL,
        Active NOT NULL,
        Account NOT NULL REFERENCES Account ON DELETE CASCADE,
        Facility NOT NULL REFERENCES Facility ON DELETE CASCADE,
        Type NOT NULL

    )';
    -- Tabella Feedback
   EXECUTE IMMEDIATE ' CREATE TABLE Feedback OF FeedbackTY (
        Code PRIMARY KEY,
        CONSTRAINT chk_feedback_score CHECK (Score BETWEEN 1 AND 5),
        Message NOT NULL,
        Score NOT NULL,
        Account REFERENCES Account ON DELETE SET NULL,
        Team NOT NULL  REFERENCES Team ON DELETE CASCADE
    )';
END;
/

CREATE OR REPLACE Procedure SchemaCreation IS
BEGIN
     DropTypes;
     DropTables;
     CreateTypes;
     CreateTables;
END;
/

-- Popolamento del database
CREATE OR REPLACE PROCEDURE PopulateDatabase(
    p_num_customers IN NUMBER,
    p_num_accounts IN NUMBER,
    p_num_contracts IN NUMBER,
    p_num_feedbacks IN NUMBER
) IS
BEGIN
    -- Popola Team
    FOR i IN 1..100 LOOP
        INSERT INTO Team VALUES (
            TeamTY(
                'Team' || TO_CHAR(i),
                'TeamName' || TO_CHAR(i),
                ROUND(DBMS_RANDOM.VALUE(6, 8))
            )
        );
    END LOOP;


    -- Popola Employee per ogni team con 5 dipendenti (il primo è Manager)
    FOR team_id IN 1..100 LOOP
        DECLARE
            v_employee_code VARCHAR2(20);
            v_team_code     VARCHAR2(20) := 'Team' || TO_CHAR(team_id);
            v_dob           DATE;
            v_doh           DATE;
            v_manager       CHAR(1):= 'Y';
        BEGIN
            -- Genera un codice univoco per l'impiegato
            v_employee_code := 'FC' || TO_CHAR((team_id - 1) * 5 + team_id);
            
            -- Genera la data di nascita (tra 18 e 60 anni fa)
            v_dob := ADD_MONTHS(SYSDATE, -ROUND(DBMS_RANDOM.VALUE(18*12, 60*12)));
            
            -- Genera la data di assunzione (dopo la data di nascita)
            v_doh := v_dob + ROUND(DBMS_RANDOM.VALUE(18*365, 60*365));
            -- Inserimento dell'impiegato
            INSERT INTO Employee VALUES (
                EmployeeTY(
                    v_employee_code,
                    'Name' || v_employee_code,
                    'Surname' || v_employee_code,
                    v_dob,
                    v_doh,
                    v_manager,
                    (SELECT REF(t) FROM Team t WHERE t.Code = v_team_code)
                )
            );
        END;
    END LOOP;  

    -- Popola Facility
    FOR i IN 1..100 LOOP
        INSERT INTO Facility VALUES (
            FacilityTY(
                'Facility' || TO_CHAR(i),
                'Location' || TO_CHAR(i),
                CASE MOD(i, 4)
                    WHEN 0 THEN 'wind'
                    WHEN 1 THEN 'solar'
                    WHEN 2 THEN 'hydro'
                    WHEN 3 THEN 'nuclear'
                END,
                100,
                900000000,
                0,
                (SELECT REF(t) FROM Team t WHERE t.Code = 'Team' || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1, 100))))
            )
        );
    END LOOP;

    
    
    
    -- Popola Customer
    FOR i IN 1..p_num_customers LOOP
        DECLARE
            v_dob DATE;
        BEGIN
            -- Genera la data di nascita tra 18 e 60 anni fa (maggiorenne garantito)
            v_dob := ADD_MONTHS(SYSDATE, -ROUND(DBMS_RANDOM.VALUE(18*12, 60*12)));

            -- Inserimento del Customer
            INSERT INTO Customer VALUES (
                CustomerTY(
                    'Customer' || TO_CHAR(i),
                    'Name' || TO_CHAR(i),
                    'Surname' || TO_CHAR(i),
                    'email' || TO_CHAR(i) || '@example.com',
                    CASE WHEN MOD(i, 2) = 0 THEN 'Commercial' ELSE 'Residential' END,
                    v_dob
                )
            );
        END;
    END LOOP;

    -- Popola Account
    FOR i IN 1..p_num_accounts LOOP
        INSERT INTO Account VALUES (
            AccountTY(
                'Account' || TO_CHAR(i),
                (SELECT REF(c) FROM Customer c WHERE c.Code = 'Customer' ||  TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1, p_num_customers))))
            )
        );
    END LOOP;

    -- Popola Contract
    FOR i IN 1..p_num_contracts LOOP
        DECLARE
            v_account_code VARCHAR2(20);
            v_customer_type VARCHAR2(20);
            v_start_date DATE;
            v_duration NUMBER;
            v_end_date DATE;
            v_active CHAR(1);
        BEGIN
            -- Seleziona un account casuale
            v_account_code := 'Account' || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1, p_num_accounts)));

            -- Recupera il tipo di cliente associato all'account
            SELECT c.Type 
            INTO v_customer_type
            FROM Account a
            JOIN Customer c ON DEREF(a.Customer).Code = c.Code
            WHERE a.Code = v_account_code;

            -- Genera la data di inizio del contratto
            v_start_date := SYSDATE;

            -- Genera la durata del contratto (tra 1 e 12 mesi)
            v_duration := ROUND(DBMS_RANDOM.VALUE(1, 12));

            -- Calcola la data di fine contratto
            v_end_date := ADD_MONTHS(v_start_date, v_duration);

            -- Determina se il contratto è ancora attivo
            IF v_end_date >= SYSDATE THEN
                v_active := 'Y';
            ELSE
                v_active := 'N';
            END IF;

            -- Inserimento del contratto con la logica aggiornata
            INSERT INTO Contract VALUES (
                ContractTY(
                    'Contract' || TO_CHAR(i),
                    v_active,  -- 'Y' se attivo, 'N' se scaduto
                    v_customer_type,  -- Tipo coerente con il cliente
                    v_start_date,
                    DBMS_RANDOM.VALUE(100, 1000),
                    CASE MOD(i, 3)
                        WHEN 0 THEN 2500
                        WHEN 1 THEN 4500
                        WHEN 2 THEN 10000
                    END,
                    v_duration,  -- Durata del contratto (in mesi)
                    (SELECT REF(a) FROM Account a WHERE a.Code = v_account_code),
                    (SELECT REF(f) FROM Facility f WHERE f.Name = 'Facility' || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1, 100))))
                )
            );
        END;
    END LOOP;

    -- Popola Feedback
    FOR i IN 1..p_num_feedbacks LOOP
        INSERT INTO Feedback VALUES (
            FeedbackTY(
                'Feedback' || TO_CHAR(i),
                'Message' || TO_CHAR(i),
                ROUND(DBMS_RANDOM.VALUE(1, 5)),
                (SELECT REF(a) FROM Account a WHERE a.Code = 'Account' || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1, p_num_accounts)))),
                (SELECT REF(t) FROM Team t WHERE t.Code = 'Team' || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1, 100))))
            )
        );
    END LOOP;
END;
/



BEGIN
    SchemaCreation;
END;
/


CREATE OR REPLACE TRIGGER trg_employee_manager
FOR INSERT OR UPDATE ON Employee
COMPOUND TRIGGER
    v_team REF TeamTY;
    v_count NUMBER;
    status CHAR(1);
BEFORE EACH ROW IS
BEGIN
    v_team := :new.Team;
    status:=:new.Manager;
END BEFORE EACH ROW;
AFTER STATEMENT IS
BEGIN
    IF status = 'Y' THEN
        SELECT COUNT(*) INTO v_count
        FROM Employee
        WHERE (DEREF(Team)).Code = (DEREF(v_team)).Code
        AND Manager = 'Y';

        IF v_count > 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Errore: Esiste già un manager per il team');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Operazione eseguita con successo');
        END IF;
    END IF;
END AFTER STATEMENT;
END trg_employee_manager;
/





CREATE OR REPLACE TRIGGER trg_contract_type
    BEFORE INSERT OR UPDATE ON Contract
    FOR EACH ROW
DECLARE
     v_customer_type VARCHAR2(20);
BEGIN
     SELECT DEREF(a.Customer).Type
         INTO v_customer_type
         FROM Account a
         WHERE a.Code = (DEREF(:NEW.Account)).Code;

     IF :NEW.Type = v_customer_type THEN
            DBMS_OUTPUT.PUT_LINE('Operation Completed');
     ELSE
            RAISE_APPLICATION_ERROR(-20003, 'Error: Contract type and customer type mismatch');
     END IF;
END;

/


CREATE OR REPLACE TRIGGER trg_deactivate_old_contracts
FOR INSERT ON Contract
FOLLOWS trg_contract_type
COMPOUND TRIGGER

    -- Variabili locali per memorizzare Account e Facility
    v_account REF AccountTY;
    v_facility REF FacilityTY;
    v_contract_id VARCHAR2(20); -- Memorizza ID del contratto appena inserito

    -- Azione BEFORE EACH ROW per memorizzare i valori
    BEFORE EACH ROW IS
    BEGIN
        -- Salviamo Account, Facility e ID del contratto nella fase BEFORE
        v_account := :NEW.Account;
        v_facility := :NEW.Facility;
        v_contract_id := :NEW.ID;
        IF :NEW.Active = 'N' THEN
            -- Check if contract's end date is in the past
            IF ADD_MONTHS(:NEW.Start_Date, :NEW.Duration) < SYSDATE THEN
                DBMS_OUTPUT.PUT_LINE('You are inserting an expired contract');
            ELSE
                DBMS_OUTPUT.PUT_LINE('Errore di inserimento, il contratto verrà registrato come attivo');
                :NEW.Active := 'Y';
            END IF;
        END IF;
    END BEFORE EACH ROW;
    -- Azione AFTER STATEMENT per eseguire l'aggiornamento
    AFTER STATEMENT IS
    BEGIN
        -- Una volta completato l'inserimento, disattiviamo i contratti precedenti
        FOR rec IN (
            SELECT ID
            FROM Contract
            WHERE Active = 'Y'
            AND Account = v_account
            AND Facility = v_facility
            AND ID <> v_contract_id -- Escludiamo il contratto appena inserito
        ) LOOP
            UPDATE Contract
            SET Active = 'N'
            WHERE ID = rec.ID;

            DBMS_OUTPUT.PUT_LINE('Disattivato il contratto ');
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('Trigger trg_deactivate_old_contracts eseguito con successo.');
    END AFTER STATEMENT;

END trg_deactivate_old_contracts;
/




CREATE OR REPLACE TRIGGER trg_energy_plan
BEFORE INSERT OR DELETE OR UPDATE OF Active ON Contract
FOR EACH ROW
DECLARE
    v_facility_name Facility.Name%TYPE;
    v_current_sum NUMBER;
    v_max_output NUMBER;
BEGIN
    -- Ottieni il nome della Facility associata al contratto
    IF INSERTING OR UPDATING THEN
        SELECT f.Name INTO v_facility_name FROM Facility f WHERE REF(f) = :NEW.Facility;
    ELSE
        SELECT f.Name INTO v_facility_name FROM Facility f WHERE REF(f) = :OLD.Facility;
    END IF;

    -- Blocca la riga della Facility per evitare race conditions
    SELECT SumOutputEnergy, MaxOutputEnergy 
    INTO v_current_sum, v_max_output 
    FROM Facility 
    WHERE Name = v_facility_name 
    FOR UPDATE;

    -- Gestione INSERT: aggiungi EnergyPlan a SumOutputEnergy
    IF INSERTING THEN
        IF v_current_sum + :NEW.EnergyPlan > v_max_output THEN
            RAISE_APPLICATION_ERROR(-20001, 'SumOutputEnergy supera MaxOutputEnergy per la Facility ' || v_facility_name);
        ELSE
            UPDATE Facility 
            SET SumOutputEnergy = v_current_sum + :NEW.EnergyPlan 
            WHERE Name = v_facility_name;
        END IF;
    
    -- Gestione DELETE: sottrai EnergyPlan da SumOutputEnergy
    ELSIF DELETING THEN
        UPDATE Facility 
        SET SumOutputEnergy = v_current_sum - :OLD.EnergyPlan 
        WHERE Name = v_facility_name;
    
    -- Gestione UPDATE: sottrai solo se Active passa da Y a N
    ELSIF UPDATING THEN
        IF :OLD.Active = 'Y' AND :NEW.Active = 'N' THEN
            UPDATE Facility 
            SET SumOutputEnergy = v_current_sum - :OLD.EnergyPlan 
            WHERE Name = v_facility_name;
        END IF;
    END IF;
END trg_energy_plan;
/






CREATE OR REPLACE TRIGGER trg_efficiency_score
BEFORE UPDATE ON Facility
FOR EACH ROW
BEGIN
    IF :NEW.SumOutputEnergy = 0 THEN
        :NEW.EfficiencyScore := 100;
    ELSE
        :NEW.EfficiencyScore := 100 * :NEW.SumOutputEnergy / :NEW.MaxOutputEnergy;
    END IF;
END trg_efficiency_score;
/
SET SERVEROUTPUT OFF
/
BEGIN
    PopulateDatabase(
        p_num_customers => 10000,
        p_num_accounts  => 20000,
        p_num_contracts => 30000,
        p_num_feedbacks => 7500
    );
END;
/


SET SERVEROUTPUT ON
/

--test trigger for employeeManager

INSERT INTO Employee VALUES (
    EmployeeTY(
        'FC00000021',
        'Mario',
        'Rossi',
        TO_DATE('1985-01-01', 'YYYY-MM-DD'),
        TO_DATE('2020-01-01', 'YYYY-MM-DD'),
        'Y',
        (SELECT REF(t) FROM Team t WHERE t.Code = 'Team1')
    )
);

INSERT INTO Employee VALUES (
    EmployeeTY(
        'FC00000022',
        'Luca',
        'Bianchi',
        TO_DATE('1985-01-01', 'YYYY-MM-DD'),
        TO_DATE('2020-01-01', 'YYYY-MM-DD'),
        'Y',
        (SELECT REF(t) FROM Team t WHERE t.Code = 'Team1')
    )
);


--test trigger for energyPlan


INSERT INTO Facility
VALUES (
FacilityTY(
    'FacilityTest', 
    'LocationTest', 
    'wind', 
    100, 
    2, 
    0, 
    (SELECT REF(t) FROM Team t WHERE t.Code = 'Team1')
)
);


INSERT INTO Contract
VALUES (
ContractTY(
    'ContractTest', 
    'Y', 
    'Commercial', 
    TO_DATE('2023-01-01','YYYY-MM-DD'), 
    100, 
    2500, 
    1, 
    (SELECT REF(a) FROM Account a WHERE a.Code = 'Account1'), 
    (SELECT REF(f) FROM Facility f WHERE f.Name = 'FacilityTest')
)
);

--test trigger for deactivateOldContracts

INSERT INTO Facility VALUES (
    FacilityTY(
        'FacilityTest2', 
        'LocationTest', 
        'wind', 
        100, 
        10000000, 
        0, 
        (SELECT REF(t) FROM Team t WHERE t.Code = 'Team1')
    )
);

INSERT INTO Contract
VALUES (
ContractTY(
    'ContractTest2', 
    'N', 
    'Commercial', 
    TO_DATE('2023-01-01','YYYY-MM-DD'), 
    100, 
    2500, 
    1, 
    (SELECT REF(a) FROM Account a WHERE a.Code = 'Account1'), 
    (SELECT REF(f) FROM Facility f WHERE f.Name = 'FacilityTest2')
)
);

SELECT Contract.ID, Contract.ACTIVE FROM Contract WHERE Facility=(SELECT REF(f) FROM Facility f WHERE f.Name = 'FacilityTest2');

INSERT INTO Contract
VALUES (
ContractTY(
    'ContractTest3', 
    'Y', 
    'Commercial', 
    TO_DATE('2023-01-01','YYYY-MM-DD'), 
    100, 
    2500, 
    1, 
    (SELECT REF(a) FROM Account a WHERE a.Code = 'Account1'), 
    (SELECT REF(f) FROM Facility f WHERE f.Name = 'FacilityTest2')
)
);

SELECT Contract.ID, Contract.ACTIVE FROM Contract WHERE Facility=(SELECT REF(f) FROM Facility f WHERE f.Name = 'FacilityTest2');

/
--test trigger for contractType



INSERT INTO FACILITY
VALUES (
FacilityTY(
    'FacilityTest3', 
    'LocationTest', 
    'wind', 
    100, 
    10000000, 
    0, 
    (SELECT REF(t) FROM Team t WHERE t.Code = 'Team1')
)
);

INSERT INTO CUSTOMER
VALUES (
CustomerTY(
    'CustomerTest', 
    'NameTest', 
    'SurnameTest', 
    'email@test.com',
    'Commercial',
    TO_DATE('1985-01-01','YYYY-MM-DD')
    )
);

INSERT INTO Account
VALUES (
AccountTY(
    'AccountTest', 
    (SELECT REF(c) FROM Customer c WHERE c.Code = 'CustomerTest')
)
);

INSERT INTO Contract
VALUES (
ContractTY(
    'ContractTest3', 
    'Y', 
    'Residential', 
    TO_DATE('2023-01-01','YYYY-MM-DD'), 
    100, 
    2500, 
    1, 
    (SELECT REF(a) FROM Account a WHERE a.Code = 'AccountTest'), 
    (SELECT REF(f) FROM Facility f WHERE f.Name = 'FacilityTest3')
)
);


SELECT COUNT(*) FROM Contract;
SELECT COUNT(*) FROM Customer;
SELECT COUNT(*) FROM Facility;
SELECT COUNT(*) FROM EMPLOYEE;
SELECT COUNT(*) FROM Team;
SELECT COUNT(*) FROM Feedback; 


SELECT MAXOUTPUTENERGY, SUMOUTPUTENERGY, EfficiencyScore FROM Facility FETCH FIRST 10 ROWS ONLY;
