SELECT id_candidat, COUNT(DISTINCT id_election) as nb
FROM (Fait NATURAL JOIN Election)
WHERE election_tour = 1
GROUP BY ROLLUP(id_candidat);
