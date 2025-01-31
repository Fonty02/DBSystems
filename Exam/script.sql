
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
    EXECUTE IMMEDIATE 'DROP TABLE Facility CASCADE CONSTRAINTS FORCE';
    EXECUTE IMMEDIATE 'DROP TABLE Team CASCADE CONSTRAINTS FORCE';
    EXECUTE IMMEDIATE 'DROP TABLE Employee CASCADE CONSTRAINTS FORCE';
    EXECUTE IMMEDIATE 'DROP TABLE Customer CASCADE CONSTRAINTS FORCE';
    EXECUTE IMMEDIATE 'DROP TABLE Account CASCADE CONSTRAINTS FORCE';
    EXECUTE IMMEDIATE 'DROP TABLE Contract CASCADE CONSTRAINTS FORCE';
    EXECUTE IMMEDIATE 'DROP TABLE Feedback CASCADE CONSTRAINTS FORCE';
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
        CONSTRAINT chk_efficiency_score CHECK (EfficiencyScore BETWEEN 0 AND 100),
        CONSTRAINT chk_max_output_energy CHECK (MaxOutputEnergy >= 0),
        Location NOT NULL,
        Type NOT NULL,
        MaxOutputEnergy NOT NULL,
        EfficiencyScore NOT NULL,
        Team NOT NULL REFERENCES Team ON DELETE SET NULL
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
        Team NOT NULL REFERENCES Team ON DELETE SET NULL
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
        Account NOT NULL REFERENCES Account ON DELETE SET NULL,
        Team NOT NULL  REFERENCES Team ON DELETE CASCADE
    )';
END;
/

CREATE OR REPLACE Procedure Population IS
BEGIN
     DropTypes;
     DropTables;
     CreateTypes;
     CreateTables;
END;


BEGIN
    Population;
END;


