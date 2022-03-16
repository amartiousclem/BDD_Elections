SELECT
       election_annee,
       election_tour,
       numdpt,
       INSCRITS_TOTAL,
       ABSTENTION,
       ROUND((ABSTENTION / INSCRITS_TOTAL), 3) as ratio
FROM
     INFOS_ELECTIONS_DEPARTEMENT
ORDER BY
    election_annee, election_tour, numdpt, ratio DESC
;