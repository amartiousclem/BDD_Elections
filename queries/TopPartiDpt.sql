SELECT nomdpt, parti_politique, sum(nbvote) as votes,
	DENSE_RANK() OVER (PARTITION BY nomdpt ORDER BY sum(nbvote) desc) rank
FROM (Fait JOIN CIRCONSCRIPTION C2 on C2.CIRC_EL_ID = FAIT.ID_CIRC) JOIN ELECTION E2 on E2.ELECTION_ID = FAIT.ID_ELECTION
WHERE E2.ELECTION_TOUR = 1
GROUP BY (nomdpt, parti_politique);
