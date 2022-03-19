

SELECT
  ID_ELECTION,
  PARTI_POLITIQUE,
  SUM(NBVOTE) as vote,
   -- https://stackoverflow.com/a/26668129
   (case WHEN PARTI_POLITIQUE IS NULL THEN NULL
         ELSE RANK() OVER
               (PARTITION BY ID_ELECTION ORDER BY CASE WHEN PARTI_POLITIQUE IS NULL THEN 1 ELSE 0 END, SUM(NBVOTE) DESC)
    END) as r
FROM
  FAIT
GROUP BY
  ROLLUP (ID_ELECTION, PARTI_POLITIQUE)
ORDER BY
  ID_ELECTION,
  r
