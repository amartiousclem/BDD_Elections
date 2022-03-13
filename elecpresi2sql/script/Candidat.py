from Config import Config

class Candidat:
    candidats = dict()

    # Candidat private constructor
    def __init__(self, nom: str, prenom: str):
        self.nom = nom
        self.prenom = prenom

    def get_or_create(nom: str, prenom: str):
        id: str = nom + prenom
        candidat: Candidat = Candidat.candidats.get(id)
        if candidat != None:
            return candidat
        else:
            candidat = Candidat(nom, prenom)
            Candidat.candidats[id] = candidat
            return candidat

    def get_id(self) -> str:
        return Config.val_to_str(self.nom + self.prenom)

    def to_sql(self) -> str:
        return """
            MERGE INTO """ + Config.TABLE_CANDIDAT + """ t
            USING
                (SELECT 1 "one" FROM DUAL)
            ON
                (t.""" + Config.TABLE_CANDIDAT_ID + """ = '""" + self.get_id() + """')
            WHEN NOT MATCHED THEN
                INSERT (""" + Config.TABLE_CANDIDAT_ID + """, """ + Config.TABLE_CANDIDAT_NOM + """, """ + Config.TABLE_CANDIDAT_PRENOM + """ )
                    VALUES ('""" + Config.val_to_str(self.get_id()) + """' ,'""" + Config.val_to_str(
            self.nom) + """', '""" + Config.val_to_str(self.prenom) + """')
            ;
            """
