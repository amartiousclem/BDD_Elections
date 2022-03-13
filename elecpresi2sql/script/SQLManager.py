from Config import Config


class SQLManager:

    @staticmethod
    def _remove_tables_to_sql() -> str:
        return """
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
    def to_sql(faits):
        return SQLManager._remove_tables_to_sql() + SQLManager._tables_to_sql() + SQLManager._data_to_sql(faits)
