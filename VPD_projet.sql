-- Script exemple de création de VPD avec un contexte d'application
-- Patricia Serrano Alvarado
-- set serveroutput on
-- SET ECHO ON

DROP ROLE ADMIN_CANDIDAT;


PROMPT *** Le contexte d'application suivant permet de stocker de manière sécurisé, sur le SGBD, le rôle de l'utilisateur et son agence

CREATE OR REPLACE CONTEXT candidat_ctx USING set_candidat_ctx_pkg;

CREATE OR REPLACE PACKAGE set_candidat_ctx_pkg IS
	PROCEDURE set_candidat;
END;
/

CREATE OR REPLACE PACKAGE BODY set_candidat_ctx_pkg IS
	PROCEDURE set_candidat IS
		role_var VARCHAR2(20);
		candidat_var VARCHAR2(20);
    BEGIN

    -- Requête permettant de récupérer le rôle de l'utilisateur qui est connecté
		SELECT granted_role INTO role_var
		FROM DBA_ROLE_PRIVS 
		WHERE granted_role ='ADMIN_CANDIDAT' AND GRANTEE=user 
		AND ROWNUM=1;
		
	-- Si pas de données alors NULL
		EXCEPTION
			WHEN NO_DATA_FOUND THEN NULL;

     END set_candidat;
END set_candidat_ctx_pkg;
/
SHOW ERROR;

PROMPT *** Création des rôles et attribution des droits
CREATE ROLE ADMIN_CANDIDAT;

-- Droits pour les clients
GRANT SELECT, UPDATE ON Candidat TO ADMIN_CANDIDAT;
GRANT EXECUTE ON set_candidat_ctx_pkg to ADMIN_CANDIDAT;


PROMPT *** Création de la fonction qui crée le prédicat qui sera ajouté aux requêtes utilisateur
CREATE OR REPLACE FUNCTION Auth_Candidat(
	SCHEMA_VAR IN VARCHAR2,
	TABLE_VAR IN VARCHAR2)
	RETURN VARCHAR2
	IS
		return_val VARCHAR2(400);
		le_role VARCHAR2(40);
	BEGIN
		le_role :=SYS_CONTEXT('candidat_ctx','role_nom');
		IF le_role = 'ADMIN_CANDIDAT' THEN
			IF user = 'ADMI43' THEN
				return_val := 'candidat_id = ''MELENCHONJean-Luc''';
			ELSE 
				return_val := 'candidat_id = ''MACRONEmmanuel''';
			END IF;		
		END IF;
		dbms_output.Put_line(return_val);
		RETURN return_val;
	END Auth_Candidat;
/
SHOW ERROR;

PROMPT *** AJout de la politique sur la table candidat

BEGIN
	DBMS_RLS.DROP_POLICY(
		object_name => 'CANDIDAT',
		policy_name => 'CANDIDAT_POLICY'
	);
	
	DBMS_RLS.ADD_POLICY (
		OBJECT_NAME => 'CANDIDAT',
		POLICY_NAME => 'CANDIDAT_POLICY',
		POLICY_FUNCTION => 'AUTH_CANDIDAT',
		STATEMENT_TYPES => 'UPDATE'
	);
END;
/

PROMPT *** Attribution des droits aux utilisateurs
GRANT ADMIN_CANDIDAT to ADMI43;
-- GRANT ADMIN40_CLIENT to USER3, USER4, USER5;


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
