CREATE TYPE arrayPHONE as VARRAY(10) of VARCHAR2(20);
/
CREATE OR REPLACE TYPE PersonalDataTY AS OBJECT (
  name VARCHAR2(10),
  address VARCHAR2(10),
  DATE_OF_BIRTH DATE,
  MEMBER FUNCTION ComputeAGE(DATE_OF_BIRTH IN DATE) RETURN NUMBER   --anche se non c'è bisogno del parametro, ORACLE richiede che sia specificato
);
/
CREATE OR REPLACE TYPE BODY PersonalDataTY AS
  MEMBER FUNCTION ComputeAGE(DATE_OF_BIRTH IN DATE) RETURN NUMBER IS
  BEGIN
    RETURN (SYSDATE-self.DATE_OF_BIRTH)/365;
  END;
END;
/

CREATE TABLE CustomerTA(
    CF VARCHAR2(20),
    vat_number VARCHAR2(20),
    CUSTOMERTYPE VARCHAR2(20),
    personal_data PersonalDataTY,
    --default telephoneNumber is an empty array
    telephoneNumber arrayPHONE DEFAULT arrayPHONE()
)
/
INSERT INTO CustomerTA (CF, vat_number, CUSTOMERTYPE, personal_data) VALUES ('ABC123', '123', 'Tipo1', PersonalDataTY('John', 'Street 1', TO_DATE('01/01/1990', 'DD/MM/YYYY')));
INSERT INTO CustomerTA VALUES ('DEF456', '456', 'Tipo2', PersonalDataTY('Jane', 'Street 2', TO_DATE('01/01/1991', 'DD/MM/YYYY')), arrayPHONE('1234567890', '0987654321'));
INSERT INTO CustomerTA VALUES ('GHI789', '789', 'Tipo3', PersonalDataTY('Jack', 'Street 3', TO_DATE('01/01/1992', 'DD/MM/YYYY')), arrayPHONE('1234567890', '0987654321', '1234567890'));
/

UPDATE CustomerTA C set C.PERSONAL_DATA.address = 'Street 3' WHERE C.CF = 'ABC123';
SELECT ROUND(C.personal_data.ComputeAGE(C.personal_data.DATE_OF_BIRTH),2) AS Age FROM CustomerTA C;
SELECT C.telephoneNumber FROM CustomerTA C;
/
CREATE TYPE SpouseTY as OBJECT
(
    name VARCHAR2(20),
    weddingDate DATE
);
/
CREATE TYPE baseSpouseNT as TABLE OF SpouseTY;
/
CREATE TABLE Customer1TA(
    name VARCHAR2(20),
    date_of_birth DATE,
    place_of_birth VARCHAR2(20),
    date_of_death DATE,
    place_of_death VARCHAR2(20),
    listSpouse baseSpouseNT
) NESTED TABLE listSpouse STORE AS listSpouseTAB
/

INSERT INTO Customer1TA VALUES
('Paolo Rossi', TO_DATE('01/01/1962', 'DD/MM/YYYY'), 'Milano', null,null,
 baseSpouseNT(
    SpouseTY('Paola Bianchi', TO_DATE('12/05/1980', 'DD/MM/YYYY')), 
    SpouseTY('Franca Verdi', TO_DATE('27/06/1997', 'DD/MM/YYYY'))
    )
);


/


SELECT ES.Name AS nomeSposa from TABLE(Select listSpouse from Customer1TA WHERE date_of_birth<DATE'2006-06-01') ES; --posso farlo solo se è unico
INSERT INTO TABLE(Select listSpouse from Customer1TA WHERE name='Paolo Rossi') VALUES (SpouseTY('Lilinia Blue', TO_DATE('12/10/2002', 'DD/MM/YYYY')));
SELECT C.name AS nomeSposo, ES.Name as nomeSposa FROM Customer1TA C, TABLE(C.listSpouse) ES WHERE C.date_of_birth<DATE'2006-06-01'; --per ogni customer prendo la sua nested table e la scorro

/
DROP TABLE CustomerTA;
DROP TYPE PersonalDataTY;
DROP TYPE arrayPHONE;
DROP TABLE Customer1TA;
DROP TYPE baseSpouseNT;
DROP TYPE SpouseTY;



CREATE TABLE users(
  username VARCHAR2(20),
  password VARCHAR2(20)
)
/

INSERT INTO users VALUES ('Fonty', 'Ciao');
/
SELECT * from users;
/