SELECT f.id_election,
       numpdpt,
       f.id_candidat,
       Sum(nbvote),
       Rank()
         OVER (
           partition BY f.id_election, numpdpt
           ORDER BY Sum(nbvote) DESC ) rank
FROM   fait f,
       circonscription c,
        -- candidats battu au 1er tour
       (SELECT *
        FROM   (SELECT vote_candidat_national.id_election,
                       vote_candidat_national.election_annee,
                       vote_candidat_national.id_candidat,
                       Rank()
                         OVER (
                           partition BY election_annee
                           ORDER BY votes DESC ) rank,
                       vote_candidat_national.votes
                FROM   vote_candidat_national
                WHERE  vote_candidat_national.election_tour = 1)
        WHERE  rank > 2) t
WHERE  f.id_circ = c.circ_el_id
       AND f.id_election = t.id_election
       AND f.id_candidat = t.id_candidat
GROUP  BY f.id_election,
          f.id_candidat,
          numpdpt
ORDER  BY f.id_election,
          numpdpt,
          rank