EXECUTE ADMI21.electionpresi_pkg.set_val_in_context;

-- seul le compte de l'utilisateur
select * from admi21.compte_candidat;

-- 1 ligne changée
update admi21.candidat set CANDIDAT_NOM='0_NOM_UPDATED' ;
commit;
select * from admi21.candidat WHERE CANDIDAT_NOM='0_NOM_UPDATED';

-- 1 ligne changée
update admi21.candidat set CANDIDAT_PRENOM='0_PRENOM_UPDATED' ;
commit;
select * from admi21.candidat WHERE CANDIDAT_PRENOM='0_PRENOM_UPDATED';

-- parti politique modifiée uniquement pour le candidat courant
update admi21.fait set PARTI_POLITIQUE='0_PP';
commit;
SELECT DISTINCT ID_CANDIDAT FROM admi21.FAIT WHERE PARTI_POLITIQUE='0_PP';