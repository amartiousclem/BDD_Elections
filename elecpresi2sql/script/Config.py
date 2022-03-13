class Config:
    TABLE_CANDIDAT = "Candidat"
    TABLE_CANDIDAT_ID = "candidat_id"
    TABLE_CANDIDAT_NOM = "candidat_nom"
    TABLE_CANDIDAT_PRENOM = "candidat_prenom"

    TABLE_ELECTION = "Election"
    TABLE_ELECTION_ID = "election_id"
    TABLE_ELECTION_ANNEE = "election_annee"
    TABLE_ELECTION_TOUR = "election_tour"

    TABLE_CIRCONSCRIPTION = "Circonscription"
    TABLE_CIRCONSCRIPTION_ID = "circ_el_id"
    TABLE_CIRCONSCRIPTION_NUMDPT = "numpdpt"
    TABLE_CIRCONSCRIPTION_NOMDPT = "nomdpt"
    TABLE_CIRCONSCRIPTION_NUMCIRC = "numcirc"
    TABLE_CIRCONSCRIPTION_INSCRITS = "inscrits"
    TABLE_CIRCONSCRIPTION_VOTANTS = "votants"
    TABLE_CIRCONSCRIPTION_EXPRIMES = "exprimes"
    TABLE_CIRCONSCRIPTION_BLANCSETNULS = "blancs_et_nuls"

    TABLE_FAIT = "Fait"
    TABLE_FAIT_IDELECTION = "id_election"
    TABLE_FAIT_IDCIRCONSCRIPTION = "id_circ"
    TABLE_FAIT_IDCANDIDAT = "id_candidat"
    TABLE_FAIT_NBVOTE = "nbvote"
    TABLE_FAIT_PARTI_POLITIQUE = "parti_politique"


    @staticmethod
    def val_to_str(val) -> str:
        string = str(val)
        # https://stackoverflow.com/a/9596819
        string = string.replace("'", "''")
        return string