from Config import Config


class Election:
    def __init__(self, annee: int, tour: int):
        self.annee = annee
        self.tour = tour

    def to_sql(self) -> str:
        return """
            MERGE INTO """ + Config.TABLE_ELECTION + """ t
            USING
                (SELECT 1 "one" FROM DUAL)
            ON
                (t.""" + Config.TABLE_ELECTION_ID + """ = '""" + self.get_id() + """')
            WHEN NOT MATCHED THEN
                INSERT (""" + Config.TABLE_ELECTION_ID + """, """ + Config.TABLE_ELECTION_ANNEE + """ , """ + Config.TABLE_ELECTION_TOUR + """ )
                    VALUES ('""" + Config.val_to_str(self.get_id()) + """', """ + Config.val_to_str(self.annee) + """,""" + Config.val_to_str(self.tour) + """) 
            ;
            """

    def get_id(self) -> str:
        return Config.val_to_str(str(self.annee) + "t" +  str(self.tour))
