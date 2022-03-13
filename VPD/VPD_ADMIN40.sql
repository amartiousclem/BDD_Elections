-- Script exemple de création de VPD avec un contexte d'application
-- Patricia Serrano Alvarado
-- set serveroutput on
-- SET ECHO ON

PROMPT *** Suppression de tous les elements 
EXECUTE DBMS_RLS.DROP_POLICY('ADMIN40','CLIENTS_BANQUE','CLIENTS_POLICY');
DROP TABLE EMPLOYES_BANQUE;
DROP TABLE CLIENTS_BANQUE;
DROP ROLE ADMIN40_CLIENT;
DROP ROLE ADMIN40_CONSEILLER;

PROMPT *** Création d'une table renseignant de l'information qui sera stockée dans un contexte d'application
CREATE TABLE EMPLOYES_BANQUE(
utilisateur VARCHAR2(20) PRIMARY KEY,
agence VARCHAR2(20)
);

-- Insertion de tuples qui permettront de garder dans le contexte d'application l'agence d'un employé de la banque
INSERT INTO EMPLOYES_BANQUE VALUES ('USER1','Nantes');
INSERT INTO EMPLOYES_BANQUE VALUES ('USER2','Grenoble');

PROMPT *** Création de la table sur la quelle la VPD va s'appliquer
CREATE TABLE CLIENTS_BANQUE(
utilisateur VARCHAR2(20) PRIMARY KEY, 
nom VARCHAR2(20), 
agence VARCHAR2(20)
);

-- Insertion de tuples qui permettront de tester les différents droits d'accès
INSERT INTO CLIENTS_BANQUE VALUES ('USER3','LE BLANC','Nantes');
INSERT INTO CLIENTS_BANQUE VALUES ('USER4','LE PETIT','Nantes');
INSERT INTO CLIENTS_BANQUE VALUES ('USER5','L INCONNU','Grenoble');


PROMPT *** Le contexte d'application suivant permet de stocker de manière sécurisé, sur le SGBD, le rôle de l'utilisateur et son agence

CREATE OR REPLACE CONTEXT banque_ctx USING set_banque_ctx_pkg;

CREATE OR REPLACE PACKAGE set_banque_ctx_pkg IS
	PROCEDURE set_ban;
END;
/

CREATE OR REPLACE PACKAGE BODY set_banque_ctx_pkg IS
	PROCEDURE set_ban IS
		role_var VARCHAR2(20);
		agence_var VARCHAR2(20);
    BEGIN

    -- Requête permettant de récupérer le rôle de l'utilisateur qui est connecté
		SELECT granted_role INTO role_var
		FROM DBA_ROLE_PRIVS 
		WHERE granted_role like 'ADMIN40%' AND GRANTEE=user 
		AND ROWNUM=1;

	-- Initialisation de la variable role du contexte
		DBMS_SESSION.SET_CONTEXT('banque_ctx', 'role_nom', role_var);

	-- Requête pour récupérer l'agence de l'employé qui est connecté
		SELECT agence INTO agence_var
		FROM ADMIN40.EMPLOYES_BANQUE 
		WHERE utilisateur=user;

	-- Initialisation de la variable role du contexte
		DBMS_SESSION.SET_CONTEXT('banque_ctx', 'agence', agence_var);
		
	-- Si pas de données alors NULL
		EXCEPTION
			WHEN NO_DATA_FOUND THEN NULL;

     END set_ban;
END set_banque_ctx_pkg;
/
SHOW ERROR;

PROMPT *** Création des rôles et attribution des droits
CREATE ROLE ADMIN40_CLIENT;
CREATE ROLE ADMIN40_CONSEILLER;

-- Droits pour les employes
GRANT SELECT ON EMPLOYES_BANQUE TO ADMIN40_CONSEILLER;
GRANT ALL ON CLIENTS_BANQUE TO ADMIN40_CONSEILLER;
GRANT EXECUTE ON set_banque_ctx_pkg to ADMIN40_CONSEILLER;

-- Droits pour les clients
GRANT SELECT ON CLIENTS_BANQUE TO ADMIN40_CLIENT;
GRANT EXECUTE ON set_banque_ctx_pkg to ADMIN40_CLIENT;


PROMPT *** Création de la fonction qui crée le prédicat qui sera ajouté aux requêtes utilisateur
CREATE OR REPLACE FUNCTION Auth_Clients_banque(
	SCHEMA_VAR IN VARCHAR2,
	TABLE_VAR IN VARCHAR2)
	RETURN VARCHAR2
	IS
		return_val VARCHAR2(400);
		le_role VARCHAR2(40);
		agence_var VARCHAR2(40);
	BEGIN
		le_role :=SYS_CONTEXT('banque_ctx','role_nom');
		IF le_role = 'ADMIN40_CLIENT' THEN
			return_val := 'utilisateur = user';
		ELSE
			return_val := 'agence=SYS_CONTEXT(''banque_ctx'', ''agence'')';
		END IF;
		RETURN return_val;
	END Auth_Clients_banque;
/
SHOW ERROR;

BEGIN
	DBMS_RLS.ADD_POLICY (
		OBJECT_SCHEMA => 'ADMIN40',
		OBJECT_NAME => 'CLIENTS_BANQUE',
		POLICY_NAME => 'CLIENTS_POLICY',
		FUNCTION_SCHEMA => 'ADMIN40',
		POLICY_FUNCTION => 'AUTH_CLIENTS_BANQUE',
		STATEMENT_TYPES => 'SELECT, UPDATE, DELETE'
	);
END;
/

PROMPT *** Attribution des droits aux utilisateurs
GRANT ADMIN40_CONSEILLER to USER1, USER2;
GRANT ADMIN40_CLIENT to USER3, USER4, USER5;


COMMIT;

-- Pour les tests du contexte sous USERX
-- IMPORTANT : les utilisateurs doivent se reconnecter
-- EXECUTE admin40.set_banque_ctx_pkg.set_ban;
-- SELECT sys_context('banque_ctx','role_nom') FROM DUAL;

-- Pour les tests des droits d'accès
-- SELECT * FROM ADMIN40.CLIENTS_BANQUE;
-- INSERT INTO ADMIN40.CLIENTS_BANQUE VALUES ('USER6','LE NOUVEAU','Nantes');
-- DELETE FROM ADMIN40.CLIENTS_BANQUE WHERE utilisateur='USER5';
-- COMMIT;
