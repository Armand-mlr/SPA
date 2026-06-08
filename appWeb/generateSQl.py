from werkzeug.security import generate_password_hash

# Tes données brutes (Login : Mot de passe clair)
# J'ai remis toutes tes données ici
employes = [
    # Gérants
    ("M001", "Dupont", "Jean", "Paris", "0601010101", "1980-05-15", "1800575001001", "2010-01-01", "jdupont", "ParisChef2025!"),
    ("M002", "Martin", "Claire", "Lyon", "0602020202", "1985-06-20", "2850669001002", "2012-02-01", "cmartin", "LyonGerant69!"),
    ("M003", "Bernard", "Luc", "Marseille", "0603030303", "1978-03-10", "1780313001003", "2008-05-15", "lbernard", "MarseilleBoss13"),
    ("M004", "Petit", "Emma", "Bordeaux", "0604040404", "1990-11-25", "2901133001004", "2015-09-01", "epetit", "GirondeChef33"),
    ("M005", "Robert", "Hugo", "Toulouse", "0605050505", "1982-08-30", "1820831001005", "2011-03-20", "hrobert", "Capitole31000"),
    ("M006", "Richard", "Ines", "Nantes", "0606060606", "1995-02-14", "2950244001006", "2018-07-01", "irichard", "PetitLu44000"),
    ("M007", "Durand", "Tom", "Strasbourg", "0607070707", "1988-12-05", "1881267001007", "2014-10-10", "tdurand", "AlsaceBoss67!"),
    ("M008", "Lefebvre", "Lea", "Lille", "0608080808", "1992-04-18", "2920459001008", "2016-01-05", "llefebvre", "GrandPlace59!"),
    ("M009", "Moreau", "Louis", "Montpellier", "0609090909", "1975-09-22", "1750934001009", "2005-06-30", "lmoreau", "Comedie34000"),
    ("M010", "Simon", 'Jade', "Rennes", "0610101010", "1993-07-08", "2930735001010", "2017-11-15", "jsimon", "Hermine35000"),
    # Vétérinaires / Soigneurs
    ("V001", "Laurent", "Pierre", "Paris", "0701010101", "1984-01-15", "1840175001111", "2015-05-20", "plaurent", "Stethoscope75"),
    ("S001", "Michel", "Sarah", "Paris", "0702020202", "1998-03-12", "2980375001222", "2020-09-01", "smichel", "Croquettes75!"),
    ("V002", "Garcia", "David", "Lyon", "0703030303", "1986-07-30", "1860769001333", "2016-02-15", "dgarcia", "SanteAnimale69"),
    ("S002", "David", "Julie", "Lyon", "0704040404", "1999-12-05", "2991269001444", "2021-01-10", "jdavid", "GamelleLyon69"),
    ("S003", "Bertrand", "Paul", "Marseille", "0705050505", "1997-05-25", "1970513001555", "2019-11-20", "pbertrand", "Promenade13000"),
    ("V003", "Rousseau", "Anna", "Bordeaux", "0706060606", "1989-09-14", "2890933001666", "2017-04-05", "arousseau", "Vaccin33000!"),
    ("S004", "Vincent", "Leo", "Toulouse", "0707070707", "2000-02-28", "1000231001777", "2022-06-15", "lvincent", "CoussinToulouse"),
    ("S005", "Muller", "Eva", "Nantes", "0708080808", '1996-08-10', "2960844001888", "2019-03-01", "emuller", "JouetNantes44"),
    ("V004", "Lambert", "Nathan", "Strasbourg", "0709090909", '1983-11-03', "1831167001999", "2014-08-20", "nlambert", "Chirurgie67!"),
    ("S006", "Faure", "Zoe", "Lille", "0710101010", "2001-04-12", "2010459002000", "2023-01-05", "zfaure", "DouceurNord59"),
    ("S007", "Andre", 'Gabin', "Montpellier", "0711111111", "1995-10-22", "1951034002111", "2018-12-10", "gandre", "SoleilSoin34"),
    ("V005", "Mercier", "Lola", "Rennes", "0712121212", "1991-06-18", "2910635002222", "2016-09-25", "lmercier", "UrgenceVeto35"),
    ("S008", "Blanc", "Arthur", "Paris", "0713131313", "1994-03-08", "1940375002333", "2017-05-15", "ablanc", "PromenadeParis"),
    ("S009", "Guerin", "Romane", "Lyon", "0714141414", "1999-01-30", "2990169002444", "2020-11-01", "rguerin", "BrossageLyon!"),
    ("S010", "Boyer", "Jules", 'Marseille', "0715151515", "2002-07-15", "1020713002555", "2023-08-20", "jboyer", "LitierePropre13")
]

print("INSERT INTO Employe (matricule, nom, prenom, adresse, telephoneEmploye, dateNaissance, numeroSecu, dateEmbauche, login, motdepasse) VALUES")

lignes_sql = []

for emp in employes:
    # On hache le dernier élément (le mot de passe)
    mdp_hash = generate_password_hash(emp[9], method='pbkdf2:sha256')
    
    # On construit la ligne SQL
    ligne = f"('{emp[0]}', '{emp[1]}', '{emp[2]}', '{emp[3]}', '{emp[4]}', '{emp[5]}', '{emp[6]}', '{emp[7]}', '{emp[8]}', '{mdp_hash}')"
    lignes_sql.append(ligne)

# On joint tout avec des virgules et on ajoute un point-virgule à la fin
print(",\n".join(lignes_sql) + ";")