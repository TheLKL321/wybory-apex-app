-- tables
-- Table: Czlonek_Komisji
CREATE TABLE Czlonek_Komisji (
    Uzytkownik_id varchar(20) NOT NULL,
    CONSTRAINT Czlonek_Komisji_pk PRIMARY KEY (Uzytkownik_id)
);

-- Table: Glos
CREATE TABLE Glos (
    Wyborca_indeks varchar(6) NOT NULL,
    Wybory_nazwa varchar(100) NOT NULL,
    Kandydat_indeks varchar(6) NOT NULL,
    CONSTRAINT Glos_pk PRIMARY KEY (Wyborca_indeks, Wybory_nazwa)
);

-- Table: Kandydat
CREATE TABLE Kandydat (
    Wyborca_indeks varchar(6) NOT NULL,
    CHECK (REGEXP_LIKE(Wyborca_indeks, '\d{6}')),
    CONSTRAINT Kandydat_pk PRIMARY KEY (Wyborca_indeks)
);

-- Table: Uzytkownik
CREATE TABLE Uzytkownik (
    id varchar(20) NOT NULL,
    haslo varchar(100) NOT NULL,
    CONSTRAINT Uzytkownik_pk PRIMARY KEY (id)
);

-- Table: Wyborca
CREATE TABLE Wyborca (
    Uzytkownik_id varchar(20) NOT NULL,
    nr_indeksu varchar(6) NOT NULL,
    CHECK (REGEXP_LIKE(nr_indeksu, '\d{6}')),
    CONSTRAINT Wyborca_pk PRIMARY KEY (nr_indeksu)
);

-- Table: Wybory
CREATE TABLE Wybory (
    nazwa_wyborow varchar(100) NOT NULL,
    liczba_posad int NOT NULL,
    termin_zgl date NOT NULL,
    termin_rozp date NOT NULL,
    termin_zak date NOT NULL,
    czy_opublikowane char(1) NOT NULL,
    CONSTRAINT Wybory_pk PRIMARY KEY (nazwa_wyborow)
);

-- foreign keys
-- Reference: Glos_Wybory (table: Glos)
ALTER TABLE Glos ADD CONSTRAINT Glos_Wybory FOREIGN KEY (Wybory_nazwa)
    REFERENCES Wybory (nazwa_wyborow);

-- Reference: Kandydat_Glos (table: Glos)
ALTER TABLE Glos ADD CONSTRAINT Kandydat_Glos FOREIGN KEY (Kandydat_indeks)
    REFERENCES Kandydat (Wyborca_indeks);

-- Reference: Uzytkownik_Czlonek_Komisji (table: Czlonek_Komisji)
ALTER TABLE Czlonek_Komisji ADD CONSTRAINT Uzytkownik_Czlonek_Komisji FOREIGN KEY (Uzytkownik_id)
    REFERENCES Uzytkownik (id);

-- Reference: Uzytkownik_Wyborca (table: Wyborca)
ALTER TABLE Wyborca ADD CONSTRAINT Uzytkownik_Wyborca FOREIGN KEY (Uzytkownik_id)
    REFERENCES Uzytkownik (id);

-- Reference: Wyborca_Glos (table: Glos)
ALTER TABLE Glos ADD CONSTRAINT Wyborca_Glos FOREIGN KEY (Wyborca_indeks)
    REFERENCES Wyborca (nr_indeksu);

-- Reference: Wyborca_Kandydat (table: Kandydat)
ALTER TABLE Kandydat ADD CONSTRAINT Wyborca_Kandydat FOREIGN KEY (Wyborca_indeks)
    REFERENCES Wyborca (nr_indeksu);

-- procedures, functions, triggers
CREATE OR REPLACE TRIGGER terminCorrect 
BEFORE INSERT OR UPDATE ON Wybory 
FOR EACH ROW 
BEGIN 
    IF :NEW.termin_rozp > :NEW.termin_zgl THEN 
        raise_application_error(-20000,'Termin rozpoczęcia musi być przed terminem zgłoszenia'); 
    ELSIF :NEW.termin_zgl > :NEW.termin_zak THEN 
        raise_application_error(-20000,'Termin zgłoszenia musi być przed terminem zakończenia'); 
    END IF; 
END; 
/

CREATE OR REPLACE TRIGGER glosCorrect 
BEFORE INSERT OR UPDATE ON Glos 
FOR EACH ROW 
DECLARE
    termin1 date;
    termin2 date;
    ifExists number;
BEGIN 
    SELECT termin_zak INTO termin1 FROM Wybory w WHERE w.nazwa_wyborow = :NEW.Wybory_nazwa;
    SELECT termin_rozp INTO termin2 FROM Wybory w WHERE w.nazwa_wyborow = :NEW.Wybory_nazwa;
    SELECT Count(*) INTO ifExists FROM Kandydat k WHERE k.Wyborca_indeks = :NEW.Kandydat_indeks;
    
    IF termin1 < CURRENT_DATE THEN 
        raise_application_error(-20000,'Termin składania głosów już minął'); 
    ELSIF termin2 > CURRENT_DATE THEN 
        raise_application_error(-20000,'Termin składania głosów jeszcze nie nadszedł'); 
    ELSIF ifExists = 0 THEN 
        raise_application_error(-20000,'Nie ma takiego kandydata'); 
    END IF; 
END; 
/

CREATE OR REPLACE PROCEDURE add_Wyborca(nowe_id VARCHAR, nowe_haslo VARCHAR, nowy_indeks VARCHAR) IS
BEGIN 
	INSERT INTO Uzytkownik
    VALUES (Upper(nowe_id), nowe_haslo);
    INSERT INTO Wyborca
    VALUES (Upper(nowe_id), nowy_indeks);
    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE add_Kandydat(indeks VARCHAR) IS
BEGIN 
    INSERT INTO Kandydat
    VALUES (indeks);
    COMMIT;
END; 
/

CREATE OR REPLACE PROCEDURE add_Wybory(nazwa VARCHAR, posady int, zgl date, rozp date, zak date) IS
BEGIN 
    INSERT INTO Wybory
    VALUES (nazwa, posady, zgl, rozp, zak, 'N');
    COMMIT;
END; 
/

CREATE OR REPLACE PROCEDURE add_Glos(indeks_w VARCHAR, nazwa VARCHAR, indeks_k VARCHAR) IS
BEGIN 
    INSERT INTO Glos
    VALUES (indeks_w, nazwa, indeks_k);
    COMMIT;
END; 
/

CREATE OR REPLACE FUNCTION wynik_Wybory(nazwa VARCHAR) 
RETURN @rtnTable TABLE 
(
    indeks VARCHAR NOT NULL
) AS 
BEGIN 
DECLARE @TempTable TABLE (indeks VARCHAR(6)) 
INSERT INTO @myTable 
SELECT Kandydat_indeks 
FROM 
    (SELECT Kandydat_indeks, Count(*) AS liczba_glosow FROM Glos g WHERE g.Wybory_nazwa = nazwa GROUP BY Kandydat_indeks) 
ORDER BY liczba_glosow 
FETCH FIRST (SELECT liczba_posad FROM Wybory w WHERE w.nazwa_wyborow = nazwa) ROWS ONLY 

--This select returns data
INSERT INTO @rtnTable 
SELECT indeks FROM @mytable 
RETURN 

END; 
/

CREATE OR REPLACE PROCEDURE opublikuj(nazwa VARCHAR) IS
BEGIN 
    UPDATE Wybory
    SET czy_opublikowane = 'Y'
    WHERE nazwa_wyborow = nazwa;
    COMMIT;
END; 
/

INSERT INTO Uzytkownik
VALUES ('ADMIN', 'admin');

INSERT INTO Czlonek_Komisji
VALUES ('ADMIN');
-- End of file.
