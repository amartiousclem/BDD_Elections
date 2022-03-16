#! /usr/bin/env python3
"""Exemple d'utilsiation
./script/elecpresi2sql.py | sqlplus L3_1/L3@localhost:1521
"""

import pandas as pd
from os import listdir
from os.path import isfile, join
from Config import Config
from Candidat import Candidat
from Circonscription import Circonscription
from Election import Election
from Fait import Fait
from SQLManager import SQLManager
import re

path = "./data"
files = [f for f in listdir(path)]

faits = []

def f(e: Election, x: pd.Series):
    circ: Circonscription = Circonscription(
        e,
        str(x["Code département"]),
        x['département'],
        x["circonscription"],
        x["Inscrits"],
        x["Votants"],
        x["Exprimés"],
        x["Blancs et nuls"]
    )

    votes = x.drop(
        ['Code département', 'département', 'circonscription', 'Inscrits', 'Votants', 'Exprimés', 'Blancs et nuls'])

    for candidatKey in votes.keys():
        nom: str = re.sub(r"\s\(.*\)", "", candidatKey).split(" ", 1)[1].strip()
        prenom: str = re.sub(r"\s\(.*\)", "", candidatKey).split(" ", 1)[0].strip()
        nom_parti: str = re.sub(r".*\(", "", candidatKey).replace(")", "").strip()

        candidat: Candidat = Candidat.get_or_create(nom, prenom)

        fait: Fait = Fait(e, circ, candidat, votes[candidatKey], nom_parti)
        faits.append(fait)


for file in files:
    df = pd.read_csv(path + "/" + file)
    annee = int(re.findall(r"\d+", file)[0])
    tour = int(re.findall(r"\d+", file)[1])
    e: Election = Election(annee, tour)
    for i in range(0, len(df)):
        f(e, df.loc[i])

print(SQLManager.to_sql(faits))
