-- Drop all
DROP TABLE COMPTE_CANDIDAT;
DROP ROLE ADMI21_CITOYEN;
DROP ROLE ADMI21_CANDIDAT;
/

EXECUTE DBMS_RLS.DROP_POLICY('ADMI21','CANDIDAT','CANDIDAT_POLICY');
EXECUTE DBMS_RLS.DROP_POLICY('ADMI21','COMPTE_CANDIDAT','COMPTE_CANDIDAT_POLICY');
EXECUTE DBMS_RLS.DROP_POLICY('ADMI21','FAIT','FAIT_POLICY');
/

-- Création d'une table de relation (1,1) : Compte Oracle -- CANDIDAT
CREATE TABLE COMPTE_CANDIDAT(
user_account VARCHAR2(20) PRIMARY KEY,
candidat VARCHAR2(20)
--, FOREIGN KEY (candidat) REFERENCES candidat(CANDIDAT_ID)
);
/

INSERT INTO COMPTE_CANDIDAT VALUES ('ADMI43','MACRONEmmanuel');
INSERT INTO COMPTE_CANDIDAT VALUES ('ADMI22','LE PENMarine');
/

CREATE OR REPLACE CONTEXT electionpresi_ctx USING electionpresi_pkg;
/

create or replace package electionpresi_pkg as
    PROCEDURE set_val_in_context;
end electionpresi_pkg;
/

create or replace package body electionpresi_pkg as
    PROCEDURE set_val_in_context IS
        role VARCHAR2(20);
        candidat_id VARCHAR2(500);
    BEGIN
        SELECT GRANTED_ROLE INTO role FROM USER_ROLE_PRIVS WHERE ROWNUM=1;
        DBMS_SESSION.SET_CONTEXT('electionpresi_ctx', 'role', role);

        IF role = 'ADMI21_CANDIDAT' THEN
            SELECT candidat into candidat_id FROM ADMI21.COMPTE_CANDIDAT WHERE ROWNUM=1 AND user_account=user;
            DBMS_SESSION.SET_CONTEXT('electionpresi_ctx', 'candidat_id', candidat_id);
        end if;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
    END set_val_in_context;
end electionpresi_pkg;
/

create or replace function update_candidat_policy(
SCHEMA_VAR IN VARCHAR2,
TABLE_VAR IN VARCHAR2
) return varchar
is
    return_value VARCHAR2(500);
    role VARCHAR2(500);
    BEGIN
    role :=SYS_CONTEXT('electionpresi_ctx','role');
    IF role = 'ADMI21_CANDIDAT' THEN
        return_value := 'candidat_id = SYS_CONTEXT(''electionpresi_ctx'',''candidat_id'')';
    END IF;
    RETURN return_value;
end update_candidat_policy;
/

create or replace function select_compte_candidat_policy(
SCHEMA_VAR IN VARCHAR2,
TABLE_VAR IN VARCHAR2
) return varchar
is
    return_value VARCHAR2(500);

    BEGIN
    return_value := 'user_account = user';
    RETURN return_value;
end select_compte_candidat_policy;
/

create or replace function update_fait_policy(
SCHEMA_VAR IN VARCHAR2,
TABLE_VAR IN VARCHAR2
) return varchar
is
    return_value VARCHAR2(500);
    role VARCHAR2(500);
    BEGIN
    role :=SYS_CONTEXT('electionpresi_ctx','role');
    IF role = 'ADMI21_CANDIDAT' THEN
        return_value := 'ID_CANDIDAT = SYS_CONTEXT(''electionpresi_ctx'',''candidat_id'')';
    END IF;
    RETURN return_value;
end update_fait_policy;
/

BEGIN
    DBMS_RLS.ADD_POLICY (
        OBJECT_SCHEMA => 'ADMI21',
        OBJECT_NAME => 'CANDIDAT',
        POLICY_NAME => 'CANDIDAT_POLICY',
        FUNCTION_SCHEMA => 'ADMI21',
        POLICY_FUNCTION => 'update_candidat_policy',
        STATEMENT_TYPES => 'UPDATE'
    );
END;
/

BEGIN
    DBMS_RLS.ADD_POLICY (
        OBJECT_SCHEMA => 'ADMI21',
        OBJECT_NAME => 'FAIT',
        POLICY_NAME => 'FAIT_POLICY',
        FUNCTION_SCHEMA => 'ADMI21',
        POLICY_FUNCTION => 'update_fait_policy',
        STATEMENT_TYPES => 'UPDATE'
    );
END;
/

BEGIN
    DBMS_RLS.ADD_POLICY (
        OBJECT_SCHEMA => 'ADMI21',
        OBJECT_NAME => 'COMPTE_CANDIDAT',
        POLICY_NAME => 'COMPTE_CANDIDAT_POLICY',
        FUNCTION_SCHEMA => 'ADMI21',
        POLICY_FUNCTION => 'select_compte_candidat_policy',
        STATEMENT_TYPES => 'select'
    );
END;
/


CREATE ROLE ADMI21_CITOYEN;
GRANT SELECT ON CANDIDAT TO ADMI21_CITOYEN;
GRANT SELECT ON CIRCONSCRIPTION TO ADMI21_CITOYEN;
GRANT SELECT ON ELECTION TO ADMI21_CITOYEN;
GRANT SELECT ON FAIT TO ADMI21_CITOYEN;
GRANT SELECT ON INFOS_ELECTIONS_DEPARTEMENT TO ADMI21_CITOYEN;
GRANT SELECT ON INFOS_ELECTIONS_NATIONAL TO ADMI21_CITOYEN;
GRANT SELECT ON VOTE_CANDIDAT_NATIONAL TO ADMI21_CITOYEN;
GRANT EXECUTE ON electionpresi_pkg to ADMI21_CITOYEN;

CREATE ROLE ADMI21_CANDIDAT;
GRANT ADMI21_CITOYEN TO ADMI21_CANDIDAT;
GRANT SELECT ON COMPTE_CANDIDAT TO ADMI21_CANDIDAT;
GRANT UPDATE (CANDIDAT_NOM) ON CANDIDAT TO ADMI21_CANDIDAT;
GRANT UPDATE (CANDIDAT_PRENOM) ON CANDIDAT TO ADMI21_CANDIDAT;
GRANT UPDATE (PARTI_POLITIQUE) ON FAIT TO ADMI21_CANDIDAT;

GRANT ADMI21_CANDIDAT TO ADMI22;
GRANT ADMI21_CANDIDAT TO ADMI43;