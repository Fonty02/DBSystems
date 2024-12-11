DECLARE
    messagge VARCHAR2(20);

BEGIN
    messagge := 'Hello World';
    DBMS_OUTPUT.PUT_LINE(messagge);
END;
/


/* A PLSQL block has 3 section:
//anonymous block
DECLARE
    <statements>
BEGIN
    <commands>
EXCPETION
    <exception handling>
END;

Puoi anche dare un nome al blocco PLSQL
DECLARE
    <statements>
BEGIN
    <commands>
EXCPETION
    <exception handling>
END block_name;

e per eseguire il blocco PLSQL
EXECUTE block_name;


EXAMPLE OF CURSOR
*/

/*
I cursori sono utilizzati per recuperare righe da una tabella in modo iterativo.

DECLARE CURSOR author_cursor IS
    SELECT * FROM Authors;
    Author author_cursor%ROWTYPE;


Author.name -> accedo al campo name della tabella Authors
Possiamo anche dichiarare un variabile dello stesso tipo della colonna name in automatico
DECLARE varAuthors Authors.name%TYPE;

In questo modo se la colonna name cambia tipo, la variabile varAuthors cambia tipo in automatico
*/


/*
DECLARE
ValueCode Works.Code&TYPE;
ValueDescription Works.Description%TYPE;
CURSOR C is
SELECT description, code FROM Works WHERE code=ValueCode;

BEGIN
    ValueCode:='111';
    OPEN C; //Apro il cursore
    FETCH C INTO ValueDescription; // La FETCH esegue C e mette i valori in nella variabile ValueDescription (il primo)
    DBMS_OUTPUT.PUT_LINE(ValueDescription);
    CLOSE C; //Chiudo il cursore
END;


L alternativa SENZA CURSORE
BEGIN
    ValueCode:='111';
    SELECT description INTO ValueDescription FROM Works WHERE code=ValueCode;
    DBMS_OUTPUT.PUT_LINE(ValueDescription);
END;
*/



/*

CONDITIONAL LOGIC -> IF, FOR, LOOP, WHILE

DECLARE
ValueCode Works.Code&TYPE;
ValueDescription Works.Description%TYPE;
CURSOR C is
SELECT description, code FROM Works WHERE name like ValueName;

BEGIN
    ValueName:='%work%';
    OPEN C;
    LOOP (con il loop scorro)
        FETCH C INTO ValueDescription, ValueCode;  //prendi l-iesimo valore che trovi
        EXIT WHEN C%NOTFOUND;  //Se non trova niente esce
        DBMS_OUTPUT.PUT_LINE(ValueDescription);
    END LOOP;
    CLOSE C;
END;

Alcune keyword utili:
%FOUND -> il cursore ha trovato almeno una riga
%NOTFOUND -> il cursore non ha trovato nessuna riga
%ROWCOUNT -> il numero di righe trovate dal cursore fino ad ora
%IsOPEN -> il cursore è aperto



CYCLE FOR
<WITHOUT CURSOR>
Declare
    IndexNumber INTEGER(2);
BEGIN
    FOR IndexNumber IN 1..8 LOOP
        UPDATE Works set Name=lower(Name) WHERE Code like '11'||IndexNumber;
    END LOOP;
END;
<WITH CURSOR>
DECLARE
    CURSOR C is
    SELECT * FROM Works;
BEGIN
    FOR pair in c LOOP
        DBMS_OUTPUT.PUT_LINE(pair.name||' '||pair.description);
    END LOOP;




WHILE LOOP
DECLARE
IndexWorks INTEGER(2);
BEGIN
    IndexWorks:=1;
    WHILE IndexWorks<=8 LOOP
       UPDATE Works set Name=upper(Name) WHERE Code like '11'||IndexWorks;
         IndexWorks:=IndexWorks+1;
    END LOOP;
END;



GOTO
<<labelX>>
GOTO labelX;
*/



/*
EXCEPTION HANDLING

BEGIN
    INSERT INTO Authors (Name, Surname) VALUES, DateofBirth, PlaceOfBirth) VALUES ('John', 'Doe', '01/01/1990', 'London');
    INSERT INTO Works (Code, Name, Description) values ('111', 'Work1', 'Description1'); #Darà errore perchè esiste gia

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate value');
        ROLLBACK; //Annulla le operazioni fatte fino ad ora
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Unknown error');
        ROLLBACK;
END;

AFTER HANDLING an exception, we cannot return to the normal flow control, even with a GOTO
*/


/*
CREATE PROCEDURE, CREATE PACKAGE and CREATE FUNCTION

Procedure -> E' un blocco PLSQL che esegue un compito specifico
Function -> E' un blocco PLSQL che ritorna un valore
Package -> E' un insieme di procedure e funzioni

CREATE PACKAGE WorkPackage AS
    PROCEDURE GetWorks;
    FUNCTION GetWorks RETURN Works%ROWTYPE;
END WorkPackage;
/

CREATE PACKAGE BODY WorkPackage AS
    PROCEDURE GetWorks AS
    BEGIN
        SELECT * FROM Works;
    END GetWorks;

    FUNCTION GetWorks RETURN Works%ROWTYPE AS
        Work Works%ROWTYPE;
    BEGIN
        -- Function implementation here
    END GetWorks;
END WorkPackage;
/


//ESEMPIO UTILE -> Creare una funzione per dichiarare i tipi e le tabelle, un altra per popolare la tabella e un altra per stampare i valori

CREATE OR REPLACE PROCEDURE DeclareTypes AS
BEGIN
    EXECUTE IMMEDIATE 'CREATE TYPE arrayPHONE as VARRAY(10) of VARCHAR2(20)';
    EXECUTE IMMEDIATE 'CREATE OR REPLACE TYPE PersonalDataTY AS OBJECT (
        name VARCHAR2(10),
        address VARCHAR2(10),
        DATE_OF_BIRTH DATE,
        MEMBER FUNCTION ComputeAGE(DATE_OF_BIRTH IN DATE) RETURN NUMBER
    )';
    EXECUTE IMMEDIATE 'CREATE OR REPLACE TYPE BODY PersonalDataTY AS
        MEMBER FUNCTION ComputeAGE(DATE_OF_BIRTH IN DATE) RETURN NUMBER IS
        BEGIN
            RETURN (SYSDATE - SELF.DATE_OF_BIRTH) / 365;
        END;
    END;';
END;
/


