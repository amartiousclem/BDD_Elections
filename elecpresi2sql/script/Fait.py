from Candidat import Candidat
from Circonscription import Circonscription
from Election import Election
from Config import Config


class Fait:
    def __init__(
            self,
            election: Election,
            cironscription: Circonscription,
            candidat: Candidat,
            vote: int,
            nom_parti: str
    ):
        self.election = election
        self.circonscription = cironscription
        self.candidat = candidat
        self.vote = vote
        self.nom_parti = nom_parti

    def to_sql(self) -> str:
        return """
            MERGE INTO """ + Config.TABLE_FAIT + """ t
            USING
                (SELECT 1 "one" FROM DUAL)
            ON
                (
                    t.""" + Config.TABLE_FAIT_IDELECTION + """ = '""" + self.election.get_id() + """'
                    AND t.""" + Config.TABLE_FAIT_IDCIRCONSCRIPTION + """ = '""" + self.circonscription.get_id() + """'
                    AND t.""" + Config.TABLE_FAIT_IDCANDIDAT + """ = '""" + self.candidat.get_id() + """'
                )
            WHEN NOT MATCHED THEN
                INSERT 
                    (
                        """ + Config.TABLE_FAIT_IDELECTION + """, 
                        """ + Config.TABLE_FAIT_IDCIRCONSCRIPTION + """, 
                        """ + Config.TABLE_FAIT_IDCANDIDAT + """, 
                        """ + Config.TABLE_FAIT_NBVOTE + """, 
                        """ + Config.TABLE_FAIT_PARTI_POLITIQUE + """
                    )
                VALUES 
                    (
                        '""" + Config.val_to_str(self.election.get_id()) + """', 
                        '""" + Config.val_to_str(self.circonscription.get_id()) + """', 
                        '""" + Config.val_to_str(self.candidat.get_id()) + """', 
                        """ + Config.val_to_str(self.vote) + """, 
                        '""" + Config.val_to_str(self.nom_parti) + """'
                    )
            ;
            """

