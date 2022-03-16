from Config import Config


class SQLManager:

    @staticmethod
    def _remove_tables_to_sql() -> str:
        return """
        DROP MATERIALIZED VIEW """ + Config.MVIEW_INFOSELECTIONDPT + """;
        DROP MATERIALIZED VIEW """ + Config.MVIEW_VOTESCANDIDATNATIONAL + """;
        DROP MATERIALIZED VIEW """ + Config.MVIEW_INFOSELECTIONNATIONAL + """;
        DROP TABLE """ + Config.TABLE_CANDIDAT + """ CASCADE CONSTRAINTS; 
        DROP TABLE """ + Config.TABLE_ELECTION + """ CASCADE CONSTRAINTS; 
        DROP TABLE """ + Config.TABLE_CIRCONSCRIPTION + """ CASCADE CONSTRAINTS; 
        DROP TABLE """ + Config.TABLE_FAIT + """ CASCADE CONSTRAINTS; 
        """

    @staticmethod
    def _tables_to_sql() -> str:
        """Génère le script SQL permettant la génération des tables.
        """

        results = ""

        results = results + """
         CREATE TABLE """ + Config.TABLE_CANDIDAT + """(
            """ + Config.TABLE_CANDIDAT_ID + """ VARCHAR2(500),
            """ + Config.TABLE_CANDIDAT_NOM + """ VARCHAR2(500),
            """ + Config.TABLE_CANDIDAT_PRENOM + """ VARCHAR2(500),
            PRIMARY KEY (""" + Config.TABLE_CANDIDAT_ID + """)
        );
        """

        results = results + """
         CREATE TABLE """ + Config.TABLE_ELECTION + """(
            """ + Config.TABLE_ELECTION_ID + """ VARCHAR2(500),
            """ + Config.TABLE_ELECTION_ANNEE + """ NUMBER(4,0),
            """ + Config.TABLE_ELECTION_TOUR + """ NUMBER(1,0),
            PRIMARY KEY (""" + Config.TABLE_ELECTION_ID + """)
        );
        """

        results = results + """
         CREATE TABLE """ + Config.TABLE_CIRCONSCRIPTION + """(
            """ + Config.TABLE_CIRCONSCRIPTION_ID + """ VARCHAR2(500),
            """ + Config.TABLE_CIRCONSCRIPTION_NUMDPT + """ VARCHAR2(500),
            """ + Config.TABLE_CIRCONSCRIPTION_NOMDPT + """ VARCHAR2(500),
            """ + Config.TABLE_CIRCONSCRIPTION_NUMCIRC + """ NUMBER(4,0),
            """ + Config.TABLE_CIRCONSCRIPTION_INSCRITS + """ NUMBER(20,0),
            """ + Config.TABLE_CIRCONSCRIPTION_VOTANTS + """ NUMBER(20,0),
            """ + Config.TABLE_CIRCONSCRIPTION_EXPRIMES + """ NUMBER(20,0),
            """ + Config.TABLE_CIRCONSCRIPTION_BLANCSETNULS + """ NUMBER(20,0),
            PRIMARY KEY (""" + Config.TABLE_CIRCONSCRIPTION_ID + """)
        );
        """

        results = results + """
         CREATE TABLE """ + Config.TABLE_FAIT + """(
            """ + Config.TABLE_FAIT_IDELECTION + """ VARCHAR2(500),
            """ + Config.TABLE_FAIT_IDCIRCONSCRIPTION + """ VARCHAR2(500),
            """ + Config.TABLE_FAIT_IDCANDIDAT + """ VARCHAR2(500),
            """ + Config.TABLE_FAIT_NBVOTE + """ NUMBER(20,0),
            """ + Config.TABLE_FAIT_PARTI_POLITIQUE + """ VARCHAR2(500),
            PRIMARY KEY 
                (
                    """ + Config.TABLE_FAIT_IDELECTION + """,
                    """ + Config.TABLE_FAIT_IDCIRCONSCRIPTION + """,
                    """ + Config.TABLE_FAIT_IDCANDIDAT + """
                ),
            FOREIGN KEY (""" + Config.TABLE_FAIT_IDELECTION + """) REFERENCES """ + Config.TABLE_ELECTION + """(""" + Config.TABLE_ELECTION_ID + """),
            FOREIGN KEY (""" + Config.TABLE_FAIT_IDCIRCONSCRIPTION + """) REFERENCES """ + Config.TABLE_CIRCONSCRIPTION + """(""" + Config.TABLE_CIRCONSCRIPTION_ID + """),
            FOREIGN KEY (""" + Config.TABLE_FAIT_IDCANDIDAT + """) REFERENCES """ + Config.TABLE_CANDIDAT + """(""" + Config.TABLE_CANDIDAT_ID + """)
        );
        """

        return results

    @staticmethod
    def _data_to_sql(faits):
        candidats = set()
        elections = set()
        circonscriptions = set()
        for fait in faits:
            candidats.add(fait.candidat)
            elections.add(fait.election)
            circonscriptions.add(fait.circonscription)
        result = ""

        for candidat in candidats:
            result = result + candidat.to_sql()

        for election in elections:
            result = result + election.to_sql()

        for circonscription in circonscriptions:
            result = result + circonscription.to_sql()

        for fait in faits:
            result = result + fait.to_sql()

        return result

    @staticmethod
    def _mview_sql() -> str:
        return """
create materialized view """ + Config.MVIEW_INFOSELECTIONDPT + """
refresh COMPLETE ON COMMIT
as
SELECT
  ce.""" + Config.TABLE_ELECTION_ID + """ AS """+ Config.MVIEW_INFOSELECTIONDPT_IDELECTION +""",
  ce.""" + Config.TABLE_ELECTION_ANNEE + """ AS """ +Config.MVIEW_INFOSELECTIONDPT_ELECTIONANNEE +""",
  ce.""" + Config.TABLE_ELECTION_TOUR + """ AS """ + Config.MVIEW_INFOSELECTIONDPT_ELECTIONTOUR  + """,
  ce.""" + Config.TABLE_CIRCONSCRIPTION_NUMDPT + """ AS """ + Config.MVIEW_INFOSELECTIONDPT_NUMDPT+""",
  SUM(ce.""" + Config.TABLE_CIRCONSCRIPTION_EXPRIMES + """) - SUM(ce.""" + Config.TABLE_CIRCONSCRIPTION_BLANCSETNULS + """) AS """ + Config.MVIEW_INFOSELECTIONDPT_VOTESVALIDETOTAL+""", 
  SUM(ce.""" + Config.TABLE_CIRCONSCRIPTION_BLANCSETNULS + """) as """ + Config.MVIEW_INFOSELECTIONDPT_BLANCSETNULTOTAL +""",
  SUM(ce.""" + Config.TABLE_CIRCONSCRIPTION_EXPRIMES + """) as """ +Config.MVIEW_INFOSELECTIONDPT_VOTESTOTAL +""",
  SUM(ce.""" + Config.TABLE_CIRCONSCRIPTION_INSCRITS + """) as """ + Config.MVIEW_INFOSELECTIONDPT_INSCRITSTOTAL +""",
  (
    SUM(ce.""" + Config.TABLE_CIRCONSCRIPTION_INSCRITS + """) - SUM(ce.""" + Config.TABLE_CIRCONSCRIPTION_EXPRIMES + """)
  ) as """ + Config.MVIEW_INFOSELECTIONDPT_ABSTENTION +"""
FROM
  (
    SELECT
      DISTINCT c.*,
      e.*
    FROM
      """ + Config.TABLE_FAIT + """ f,
      """ + Config.TABLE_CIRCONSCRIPTION + """ c,
      """ + Config.TABLE_ELECTION + """ e
    WHERE
      f.""" + Config.TABLE_FAIT_IDCIRCONSCRIPTION + """ = c.""" + Config.TABLE_CIRCONSCRIPTION_ID + """
      AND f.""" + Config.TABLE_FAIT_IDELECTION + """ = e.""" + Config.TABLE_ELECTION_ID + """
  ) ce
GROUP BY
  (
    ce.""" + Config.TABLE_ELECTION_ID + """,
    ce.""" + Config.TABLE_ELECTION_ANNEE + """,
    ce.""" + Config.TABLE_ELECTION_TOUR + """,
    ce.""" + Config.TABLE_CIRCONSCRIPTION_NUMDPT + """
  );

create materialized view """ + Config.MVIEW_INFOSELECTIONNATIONAL + """
refresh COMPLETE ON COMMIT
as
SELECT
""" + Config.MVIEW_INFOSELECTIONDPT_IDELECTION+""" AS id_election ,
""" + Config.MVIEW_INFOSELECTIONDPT_ELECTIONANNEE +""" AS election_annee,
""" + Config.MVIEW_INFOSELECTIONDPT_ELECTIONTOUR+"""  AS election_tour,
SUM(""" + Config.MVIEW_INFOSELECTIONDPT_VOTESVALIDETOTAL+""") AS VOTES_VALIDE_TOTAL,
SUM(""" +Config.MVIEW_INFOSELECTIONDPT_BLANCSETNULTOTAL +""") as BLANCS_ET_NULS_TOTAL,
(SUM(""" + Config.MVIEW_INFOSELECTIONDPT_VOTESTOTAL+""") + SUM(""" + Config.MVIEW_INFOSELECTIONDPT_BLANCSETNULTOTAL+""")) as VOTES_TOTAL,
SUM(""" + Config.MVIEW_INFOSELECTIONDPT_INSCRITSTOTAL+""") as INSCRITS_TOTAL,
(SUM(""" + Config.MVIEW_INFOSELECTIONDPT_INSCRITSTOTAL+""") - (SUM(""" + Config.MVIEW_INFOSELECTIONDPT_VOTESTOTAL+""") + SUM(""" + Config.MVIEW_INFOSELECTIONDPT_BLANCSETNULTOTAL+"""))) as ABSTENTION
FROM
INFOS_ELECTIONS_DEPARTEMENT
GROUP BY  (
    """ +Config.MVIEW_INFOSELECTIONDPT_IDELECTION +""",
    """ + Config.MVIEW_INFOSELECTIONDPT_ELECTIONANNEE+""" ,
    """ + Config.MVIEW_INFOSELECTIONDPT_ELECTIONTOUR +"""
    );



create materialized view """ + Config.MVIEW_VOTESCANDIDATNATIONAL + """
refresh COMPLETE ON COMMIT
as
SELECT
       f.""" + Config.TABLE_FAIT_IDELECTION + """ as """ + Config.MVIEW_VOTESCANDIDATNATIONAL_IDELECTION + """,
       e.""" + Config.TABLE_ELECTION_ANNEE + """ as """ + Config.MVIEW_VOTESCANDIDATNATIONAL_ANNEE + """,
       e.""" + Config.TABLE_ELECTION_TOUR + """ as """ + Config.MVIEW_VOTESCANDIDATNATIONAL_TOUR + """,
       f.""" + Config.TABLE_FAIT_IDCANDIDAT + """  as """ + Config.MVIEW_VOTESCANDIDATNATIONAL_IDCANDIDAT + """,
       SUM(""" + Config.TABLE_FAIT_NBVOTE + """) as """ + Config.MVIEW_VOTESCANDIDATNATIONAL_VOTES + """
FROM
    """ + Config.TABLE_FAIT + """ f,
    """ + Config.TABLE_ELECTION + """ e
WHERE
    f.""" + Config.TABLE_FAIT_IDELECTION + """  = e.""" + Config.TABLE_ELECTION_ID + """
GROUP BY  (
   f.""" + Config.TABLE_FAIT_IDELECTION + """,
   """ + Config.TABLE_ELECTION_ANNEE + """,
   """ + Config.TABLE_ELECTION_TOUR + """,
   """ + Config.TABLE_FAIT_IDCANDIDAT + """
)
"""

    @staticmethod
    def to_sql(faits):
        return (
                SQLManager._remove_tables_to_sql()
                + SQLManager._tables_to_sql()
                + SQLManager._data_to_sql(faits)
                + SQLManager._mview_sql()
        )
