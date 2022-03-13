-- Score des candidats si l'on considérait le vote blanc et l'abstention

SELECT
       t1.ID_ELECTION,
       t1.ID_CANDIDAT,
       ROUND((t1.VOTES_POUR_CANDIDAT/(t2.VOTES_VALIDE_TOTAL)),2) as SCORE,
       ROUND((t1.VOTES_POUR_CANDIDAT/(t2.VOTES_TOTAL)),2) as SCORE_AVEC_BLANC,
       ROUND((t1.VOTES_POUR_CANDIDAT/t2.INSCRITS_TOTAL),2) as SCORE_AVEC_ABSTENTION_ET_BLANC
FROM
    (
        SELECT f.ID_ELECTION, f.ID_CANDIDAT, SUM(NBVOTE) as VOTES_POUR_CANDIDAT
        FROM
        FAIT f,
        ELECTION e
        WHERE
        f.ID_ELECTION  = e.ELECTION_ID
        GROUP BY  ( f.ID_ELECTION, ID_CANDIDAT )

    ) t1,
    (
        SELECT
        ID_ELECTION,
        SUM(NBVOTE) AS VOTES_VALIDE_TOTAL,
        SUM(c.BLANCS_ET_NULS) as BLANCS_ET_NULS_TOTAL,
        (SUM(NBVOTE) + SUM(c.BLANCS_ET_NULS)) as VOTES_TOTAL,
        SUM(c.INSCRITS) as INSCRITS_TOTAL
        FROM
        FAIT f,
        ELECTION e,
        CIRCONSCRIPTION c
        WHERE
        f.ID_ELECTION  = e.ELECTION_ID
        AND c.CIRC_EL_ID = f.ID_CIRC
        GROUP BY  ( ID_ELECTION)
    ) t2,
    ELECTION e
    WHERE t1.ID_ELECTION = t2.ID_ELECTION
    AND t1.ID_ELECTION = e.ELECTION_ID
;