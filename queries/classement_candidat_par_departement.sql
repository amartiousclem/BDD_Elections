 SELECT   f.id_election    AS id_election,
         e.election_annee AS election_annee,
         e.election_tour  AS election_tour,
         c.numpdpt,
         f.id_candidat                                                                     AS id_candidat,
         Sum(nbvote)                                                                       AS votes,
         Dense_rank() OVER (partition BY f.id_election, numpdpt ORDER BY Sum(nbvote) DESC) AS rank
FROM     fait f,
         election e,
         circonscription c
WHERE    f.id_election = e.election_id
AND      c.circ_el_id = f.id_circ
GROUP BY ( f.id_election, election_annee, election_tour, c.numpdpt, id_candidat )
order BY f.id_election,
         c.numpdpt,
         rank;