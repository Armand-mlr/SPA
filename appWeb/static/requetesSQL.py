requetes = {
    "sql_countH" : """
        SELECT COUNT(*) FROM Refuge 
        WHERE LOWER(ville) LIKE LOWER(%s) 
        OR codePostal LIKE %s 
        OR LOWER(nom) LIKE LOWER(%s)
    """,

    "sql_data1H" : """
        SELECT * FROM Refuge 
        WHERE LOWER(ville) LIKE LOWER(%s) 
        OR codePostal LIKE %s 
        OR LOWER(nom) LIKE LOWER(%s) 
        ORDER BY nom ASC LIMIT %s OFFSET %s 
    """,

    "sql_data2H" : """
        SELECT * FROM Refuge 
        ORDER BY nom ASC 
        LIMIT %s OFFSET %s
    """,

    "sql_countR" : """
        SELECT COUNT(*) as total 
        FROM Animal A JOIN Heberge H ON A.id = H.idAnimal 
        WHERE H.idRefuge = %s AND H.dateDepart IS NULL
    """,

    "sql_animauxR" : """
        SELECT A.* FROM Animal A 
        JOIN Heberge H ON A.id = H.idAnimal 
        WHERE H.idRefuge = %s AND H.dateDepart IS NULL 
        ORDER BY A.nom LIMIT %s OFFSET %s
    """,

    "sql_animalAR" : """
        SELECT A.* FROM Animal A 
        JOIN Heberge H ON A.id = H.idAnimal 
        WHERE H.idRefuge = %s AND H.dateDepart IS NULL 
    """,

    "sql_refugeD" : """
        SELECT R.*, EA.fonction FROM EstAffecte EA 
        JOIN Refuge R ON EA.idRefuge = R.idRefuge 
        WHERE EA.idEmploye = %s 
        ORDER BY EA.dateAffectation DESC LIMIT 1
    """,

    "sql_colleguesD" : """
        SELECT E.nom, E.prenom, EA.fonction, E.telephoneEmploye 
        FROM EstAffecte EA JOIN Employe E ON EA.idEmploye = E.idEmploye 
        WHERE EA.idRefuge = %s AND EA.idEmploye != %s
    """,

    "sql_vaccins_globalD" : """
        SELECT V.*, R.nom AS nom_refuge, R.idRefuge
        FROM V_Animaux_A_Vacciner V
        JOIN Heberge H ON V.idAnimal = H.idAnimal
        JOIN Refuge R ON H.idRefuge = R.idRefuge
        WHERE H.dateDepart IS NULL
        ORDER BY V.dateProchainRappel ASC
        LIMIT 50
    """,
    
    "sql_vaccins_localD" : """
        SELECT V.* FROM V_Animaux_A_Vacciner V
        JOIN Heberge H ON V.idAnimal = H.idAnimal
        WHERE H.idRefuge = %s AND H.dateDepart IS NULL
        ORDER BY V.dateProchainRappel ASC
    """,

    "sql_dataD" : """
        SELECT R.*, Emp.nom AS nom_gerant, Emp.prenom AS prenom_gerant,
            COUNT(H.idAnimal) AS nb_animaux,
            (R.capaciteAccueil - COUNT(H.idAnimal)) AS places_libres
        FROM Refuge R
        LEFT JOIN Employe Emp ON R.idEmploye = Emp.idEmploye
        LEFT JOIN Heberge H ON R.idRefuge = H.idRefuge AND H.dateDepart IS NULL
        GROUP BY R.idRefuge, Emp.idEmploye
        ORDER BY R.nom ASC
    """,

    "sql_animaux2" : """
        SELECT A.* FROM Animal A
        JOIN Heberge H ON A.id = H.idAnimal
        WHERE H.idRefuge = %s AND H.dateDepart IS NULL
        ORDER BY A.nom
    """,

    "base_queryP" : """
        FROM Animal A
        JOIN Heberge H ON A.id = H.idAnimal
        WHERE H.idRefuge = %s
    """,

    "sql_animal2S" : """
        SELECT A.*, F.nomFourriere 
        FROM Animal A
        LEFT JOIN Fourriere F ON A.idFourriere = F.idFourriere
        WHERE A.id = %s
    """,

    "sql_historique_soinsS" : """
        SELECT S.typeSoin, DS.dateSoin, DS.dateProchainRappel, E.nom as nom_veto
        FROM DonneSoin DS
        JOIN Soin S ON DS.idSoin = S.idSoin
        LEFT JOIN Employe E ON DS.idEmploye = E.idEmploye
        WHERE DS.idAnimal = %s
        ORDER BY DS.dateSoin DESC
    """,
    
    "sql_animalNP" : """
        INSERT INTO Animal (nom, espece, race, age, sexe, signeDistinctif, statut, daterecueil, idFourriere)
        VALUES (%s, %s, %s, %s, %s, %s, 'Disponible', %s, %s)
        RETURNING id
    """,

    "sql_hebergeNP" : """
        INSERT INTO Heberge (idAnimal, idRefuge, dateArrive, dateDepart)
        VALUES (%s, %s, CURRENT_DATE, NULL)
    """,

    "sql_get_filters_options": """
        SELECT DISTINCT A.espece, A.race , A.sexe
        FROM Animal A
        JOIN Heberge H ON A.id = H.idAnimal
        WHERE H.idRefuge = %s AND H.dateDepart IS NULL
        ORDER BY A.race
    """,

    "base_query_animaux": """
        FROM Animal A 
        JOIN Heberge H ON A.id = H.idAnimal 
        WHERE H.idRefuge = %s AND H.dateDepart IS NULL
    """,

    "sql_all_especes": """
        SELECT DISTINCT espece FROM Animal ORDER BY espece
    """,

    "sql_especes_refuge": """
        SELECT DISTINCT A.espece 
        FROM Animal A 
        JOIN Heberge H ON A.id = H.idAnimal 
        WHERE H.idRefuge = %s AND H.dateDepart IS NULL
        ORDER BY A.espece
    """,

   
    "base_races_refuge": """
        SELECT DISTINCT A.race 
        FROM Animal A 
        JOIN Heberge H ON A.id = H.idAnimal 
        WHERE H.idRefuge = %s AND H.dateDepart IS NULL
    """,
}