SELECT nomdpt, parti_politique, sum(nbvote) as votes,
	DENSE_RANK() OVER (PARTITION BY nomdpt ORDER BY sum(nbvote) desc) rank
FROM Fait JOIN CIRCONSCRIPTION C2 on C2.CIRC_EL_ID = FAIT.ID_CIRC
GROUP BY (nomdpt, parti_politique);
