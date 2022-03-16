-- Scores des candidats par département
SELECT
   t1.ID_ELECTION,
   t1.ID_CANDIDAT,
   t1.NUMPDPT,
   ROUND((t1.VOTES_POUR_CANDIDAT / i.VOTES_VALIDE_TOTAL),2) as SCORE
FROM
(
    -- Récupérer le nombre de vote par département pour chaque candidat
    SELECT
    f.ID_ELECTION,
    c.NUMPDPT,
    f.ID_CANDIDAT,
    SUM(NBVOTE) as VOTES_POUR_CANDIDAT
    FROM
    FAIT f,
    ELECTION e,
    CIRCONSCRIPTION c
    WHERE
    f.ID_ELECTION  = e.ELECTION_ID
    AND c.CIRC_EL_ID = f.ID_CIRC
    GROUP BY  ( f.ID_ELECTION, c.NUMPDPT, ID_CANDIDAT )
) t1, INFOS_ELECTIONS_DEPARTEMENT i
WHERE
      t1.ID_ELECTION = i.ID_ELECTION
      AND t1.NUMPDPT = i.NUMPDPT
ORDER BY t1.ID_ELECTION, t1.NUMPDPT, t1.ID_CANDIDAT
;

