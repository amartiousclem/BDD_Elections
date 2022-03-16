SELECT
       election_annee,
       election_tour,
       INSCRITS_TOTAL,
       ABSTENTION,
       ROUND((ABSTENTION / INSCRITS_TOTAL), 3) as ratio
FROM
     INFOS_ELECTIONS_NATIONAL
ORDER BY
    election_annee, election_tour, ratio DESC
;