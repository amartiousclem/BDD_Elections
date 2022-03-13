-- Evolution du nombre d'inscrits par département

SELECT
t.NOMDPT,
t.NUMCIRC,
t.ELECTION_ANNEE,
SUM(t.INSCRITS) as inscrits,
LAG(SUM(t.INSCRITS),1) over (ORDER BY t.NOMDPT) as inscrits_previous_year,
SUM(t.INSCRITS)-LAG(SUM(t.INSCRITS),1) over (ORDER BY t.NOMDPT)
FROM (
        SELECT DISTINCT e.* ,c.*
        FROM ELECTION e, Fait f, CIRCONSCRIPTION c
        WHERE
        f.ID_ELECTION = e.ELECTION_ID
        AND f.ID_CIRC = c.CIRC_EL_ID
    ) t
WHERE t.ELECTION_TOUR = 1
GROUP BY t.NOMDPT, t.NUMCIRC, t.ELECTION_ANNEE
ORDER BY t.NOMDPT, t.NUMCIRC, t.ELECTION_ANNEE
