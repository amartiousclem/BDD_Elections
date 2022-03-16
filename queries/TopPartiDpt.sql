SELECT nomdpt, parti_politique, sum(nbvote) as votes,
	DENSE_RANK() OVER (PARTITION BY nomdpt ORDER BY sum(nbvote) desc) rank
FROM Fait NATURAL JOIN Circonscription
GROUP BY (nomdpt, parti_politique);
