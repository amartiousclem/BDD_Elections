from Config import Config
from Election import Election
import string
from unidecode import unidecode

class Circonscription:
    def __init__(self, election: Election, num_dpt: str, nom_dpt: str, num_circ: int, inscrits: int, votants: int,
                 exprimes: int, blancs_et_nuls: int):
        self.numDpt = num_dpt.lstrip('0')
        self.election = election
        # normaliser les noms des départements
        nomDpt = nom_dpt.replace(' ', '-')
            # retirer les accents
        nomDpt = unidecode(nomDpt, "utf-8")
        self.nomDpt = nomDpt
        self.numCirc = num_circ
        self.inscrits = inscrits
        self.votants = votants
        self.exprimes = exprimes
        self.blancs_et_nuls = blancs_et_nuls

    def get_id(self) -> str:
        return Config.val_to_str(self.election.get_id() + "-" + str(self.numDpt) + "_" + str(self.numCirc))

    def to_sql(self) -> str:
        return """
            MERGE INTO """ + Config.TABLE_CIRCONSCRIPTION + """ t
            USING
                (SELECT 1 "one" FROM DUAL)
            ON
                (t.""" + Config.TABLE_CIRCONSCRIPTION_ID + """ = '""" + self.get_id() + """')
            WHEN NOT MATCHED THEN
                INSERT 
                    (
                        """ + Config.TABLE_CIRCONSCRIPTION_ID + """, 
                        """ + Config.TABLE_CIRCONSCRIPTION_NUMDPT + """, 
                        """ + Config.TABLE_CIRCONSCRIPTION_NOMDPT + """, 
                        """ + Config.TABLE_CIRCONSCRIPTION_NUMCIRC + """, 
                        """ + Config.TABLE_CIRCONSCRIPTION_INSCRITS + """, 
                        """ + Config.TABLE_CIRCONSCRIPTION_VOTANTS + """, 
                        """ + Config.TABLE_CIRCONSCRIPTION_EXPRIMES + """, 
                        """ + Config.TABLE_CIRCONSCRIPTION_BLANCSETNULS + """
                    )
                VALUES 
                    (
                        '""" + Config.val_to_str(self.get_id()) + """', 
                        '""" + Config.val_to_str(self.numDpt) + """', 
                        '""" + Config.val_to_str(string.capwords(self.nomDpt)) + """', 
                        """ + Config.val_to_str(self.numCirc) + """, 
                        """ + Config.val_to_str(self.inscrits) + """, 
                        """ + Config.val_to_str(self.votants) + """, 
                        """ + Config.val_to_str(self.exprimes) + """, 
                        """ + Config.val_to_str(self.blancs_et_nuls) + """
                    )
            ;
            """
