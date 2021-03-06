-- Score des candidats si l'on considérait le vote blanc et l'abstention
SELECT
       t1.ID_ELECTION,
       t1.ID_CANDIDAT,
       ROUND((t1.VOTES/(t2.VOTES_VALIDE_TOTAL)),2) as SCORE,
       ROUND((t1.VOTES/(t2.VOTES_TOTAL)),2) as SCORE_AVEC_BLANC,
       ROUND((t1.VOTES/t2.INSCRITS_TOTAL),2) as SCORE_AVEC_ABSTENTION_ET_BLANC
FROM
    VOTE_CANDIDAT_NATIONAL t1,
    INFOS_ELECTIONS_NATIONAL t2
    WHERE t1.ID_ELECTION = t2.ID_ELECTION
    ORDER BY t2.ELECTION_ANNEE, t2.ELECTION_TOUR, SCORE DESC