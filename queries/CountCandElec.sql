SELECT id_candidat, COUNT(DISTINCT CONCAT(ID_ELECTION, id_candidat)) as nb
FROM (Fait JOIN Election ON FAIT.ID_ELECTION = ELECTION.ELECTION_ID)
WHERE election_tour = 1
GROUP BY ROLLUP(id_candidat);SELECT id_candidat, COUNT(DISTINCT CONCAT(ID_ELECTION, id_candidat)) as nb
FROM (Fait JOIN Election ON FAIT.ID_ELECTION = ELECTION.ELECTION_ID)
WHERE election_tour = 1
GROUP BY ROLLUP(id_candidat);
