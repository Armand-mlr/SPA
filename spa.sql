
/* Animal (id, nom, espece, race, age, sexe, signeDistinctif, statut,daterecueil, idFourriere ,dateAdoption)
 * Heberge(idAnimal, idRefuge, dateArrive, dateDepart)
 * Refuge (idRefuge, matricule, codePostal, telephoneRefuge, capaciteAccueil, idEmploye)
 * Employe (idEmploye, matricule, nom, prenom, adresse, telephoneEmplye, dateNaissance, numeroSecu, dateEmbauche, login, motdepasse)
 * Soin (idSoin, typeSoin, description)
 * Fourriere (idFourriere, nomFourriere, Adresse, telephoneFourriere)
 * Particulier (idParticulier, nom, prenom, adresse, telephoneParticulier)
 * EstAffecte (idEmploye, idRefuge, dateAffectation , fonction)
 * DonneSoin (idSoin, idEmploye, idAnimal, dateSoin ,dateProchainRappel)

 Fk : IdFourriere dans Animal references Fourriere(idFourriere)
      : IdEmploye dans Refuge references Employe(idEmploye)
      : IdEmploye dans EstAffecte references Employe(idEmploye)
      : IdRefuge dans EstAffecte references Refuge(idRefuge)
      : IdAnimal dans Heberge references Animal(id)
      : IdRefuge dans Heberge references Refuge(idRefuge)
      : IdSoin dans DonneSoin references Soin(idSoin)
      : IdEmploye dans DonneSoin references Employe(idEmploye)
      : IdAnimal dans DonneSoin references Animal(id)
 */

-- Suppression des tables dans l'ordre inverse des dépendances pour éviter les erreurs
DROP TABLE IF EXISTS DonneSoin CASCADE;
DROP TABLE IF EXISTS EstAffecte CASCADE;
DROP TABLE IF EXISTS Heberge CASCADE;
DROP TABLE IF EXISTS Adoption CASCADE;
DROP TABLE IF EXISTS Particulier CASCADE;
DROP TABLE IF EXISTS Animal CASCADE;
DROP TABLE IF EXISTS Fourriere CASCADE;
DROP TABLE IF EXISTS Soin CASCADE;
DROP TABLE IF EXISTS Refuge CASCADE;
DROP TABLE IF EXISTS Employe CASCADE;
DROP VIEW IF EXISTS V_Animaux_A_Vacciner CASCADE;
DROP VIEW IF EXISTS V_Top5_Refuges_Transferts_Sortants CASCADE;

---
--- 1. TABLES INDEPENDANTES
---

CREATE TABLE Employe (
    idEmploye SERIAL PRIMARY KEY,
    matricule VARCHAR(50) UNIQUE NOT NULL,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    adresse TEXT,
    telephoneEmploye VARCHAR(15) CHECK (telephoneEmploye ~ '^[0-9]{10,15}$'),
    dateNaissance DATE NOT NULL CHECK (dateNaissance < CURRENT_DATE),
    numeroSecu VARCHAR(20) UNIQUE,
    dateEmbauche DATE NOT NULL CHECK (dateEmbauche <= CURRENT_DATE),
    login VARCHAR(50) UNIQUE NOT NULL,
    motdepasse VARCHAR(255) NOT NULL
);

CREATE TABLE Soin (
    idSoin SERIAL PRIMARY KEY,
    typeSoin VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE Fourriere (
    idFourriere SERIAL PRIMARY KEY,
    nomFourriere VARCHAR(100) NOT NULL,
    Adresse TEXT NOT NULL,
    telephoneFourriere VARCHAR(15) CHECK (telephoneFourriere ~ '^[0-9]{10,15}$')
);

CREATE TABLE Particulier (
    idParticulier SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    adresse TEXT,
    telephoneParticulier VARCHAR(15) CHECK (telephoneParticulier ~ '^[0-9]{10,15}$')
);

---
--- 2. TABLES DEPENDANTES (Avec ON DELETE / ON UPDATE)
---

CREATE TABLE Refuge (
    idRefuge SERIAL PRIMARY KEY,
    nom VARCHAR(50) UNIQUE NOT NULL,
    ville VARCHAR(100) NOT NULL,
    codePostal VARCHAR(5) NOT NULL CHECK (codePostal ~ '^[0-9]{5}$'),
    telephoneRefuge VARCHAR(15) CHECK (telephoneRefuge ~ '^[0-9]{10,15}$'),
    capaciteAccueil INT NOT NULL CHECK (capaciteAccueil > 0),
    -- Si on supprime l'employé gérant, le refuge reste mais le champ devient NULL
    idEmploye INT REFERENCES Employe(idEmploye) ON DELETE SET NULL ON UPDATE CASCADE,
    lat DECIMAL(10, 7),
    lon DECIMAL(10, 7)
);

CREATE TABLE Animal (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    espece VARCHAR(50) NOT NULL,
    race VARCHAR(50),
    age INT CHECK (age >= 0 AND age <= 100),
    sexe CHAR(1) CHECK (sexe IN ('M', 'F', 'I')) NOT NULL,
    signeDistinctif TEXT,
    statut VARCHAR(50) NOT NULL CHECK (statut IN ('Disponible', 'Adopté', 'En Soins', 'Décédé')),
    daterecueil DATE NOT NULL CHECK (daterecueil <= CURRENT_DATE),
    -- Si la fourrière ferme (suppression), on garde l'animal mais on vide le champ
    idFourriere INT REFERENCES Fourriere(idFourriere) ON DELETE SET NULL ON UPDATE CASCADE
);

---
--- 3. TABLES D'ASSOCIATION (Le coeur de la logique)
---

CREATE TABLE Heberge (
    idAnimal INT REFERENCES Animal(id) ON DELETE CASCADE ON UPDATE CASCADE,
    idRefuge INT REFERENCES Refuge(idRefuge) ON DELETE CASCADE ON UPDATE CASCADE,
    dateArrive DATE NOT NULL,
    dateDepart DATE,
    PRIMARY KEY (idAnimal, idRefuge, dateArrive),
    CHECK (dateDepart IS NULL OR dateDepart > dateArrive)
    -- NOTE : Ici ON DELETE CASCADE est crucial. Si on supprime un animal,
    -- son historique d'hébergement doit disparaitre pour ne pas laisser de données fantômes.
);

CREATE TABLE EstAffecte (
    idEmploye INT REFERENCES Employe(idEmploye) ON DELETE CASCADE ON UPDATE CASCADE,
    idRefuge INT REFERENCES Refuge(idRefuge) ON DELETE CASCADE ON UPDATE CASCADE,
    dateAffectation DATE NOT NULL CHECK (dateAffectation <= CURRENT_DATE),
    fonction VARCHAR(100) NOT NULL,
    PRIMARY KEY (idEmploye, idRefuge, dateAffectation)
    -- Si un employé est viré (supprimé), son historique d'affectation est supprimé aussi.
);

CREATE TABLE DonneSoin (
    idSoin INT REFERENCES Soin(idSoin) ON DELETE RESTRICT ON UPDATE CASCADE, 
    -- RESTRICT : On interdit de supprimer un type de soin (ex: Vaccination) si des animaux l'ont reçu.
    
    idEmploye INT REFERENCES Employe(idEmploye) ON DELETE SET NULL ON UPDATE CASCADE,
    -- SET NULL : Si l'employé part, on garde la trace du soin mais sans l'auteur (ou garde l'ID si on ne supprime pas l'employé mais le désactive).
    
    idAnimal INT REFERENCES Animal(id) ON DELETE CASCADE ON UPDATE CASCADE,
    -- CASCADE : Si l'animal n'existe plus, ses soins n'ont plus lieu d'être archivés dans ce contexte.
    
    dateSoin DATE NOT NULL CHECK (dateSoin <= CURRENT_DATE),
    dateProchainRappel DATE,
    PRIMARY KEY (idSoin, idEmploye, idAnimal, dateSoin),
    CHECK (dateProchainRappel IS NULL OR dateProchainRappel > dateSoin)
);


CREATE TABLE Adoption (
    idAdoption SERIAL PRIMARY KEY,
    idAnimal INT REFERENCES Animal(id) ON DELETE CASCADE ON UPDATE CASCADE UNIQUE NOT NULL,
    idParticulier INT REFERENCES Particulier(idParticulier) ON DELETE RESTRICT ON UPDATE CASCADE,
    dateAdoption DATE NOT NULL CHECK (dateAdoption <= CURRENT_DATE)
);

---
--- 4. VUES
---

CREATE VIEW V_Animaux_A_Vacciner AS
SELECT A.id AS idAnimal, A.nom AS nomAnimal, A.espece, A.race, A.sexe, S.typeSoin, S.description AS descriptionSoin, DS.dateProchainRappel
FROM Animal AS A
JOIN DonneSoin AS DS ON A.id = DS.idAnimal
JOIN Soin AS S ON DS.idSoin = S.idSoin
WHERE S.typeSoin = 'Vaccination'
AND DS.dateProchainRappel IS NOT NULL
ORDER BY DS.dateProchainRappel ASC;

CREATE VIEW V_Top5_Refuges_Transferts_Sortants AS
SELECT R.idRefuge,R.nom AS nomRefuge, COUNT(H.idAnimal) AS nombreTransfertsSortants
FROM Refuge R
NATURAL JOIN Heberge H
WHERE H.dateDepart IS NOT NULL AND H.dateDepart >= (CURRENT_DATE - INTERVAL '2 year')
GROUP BY R.idRefuge, R.nom
ORDER BY nombreTransfertsSortants DESC
LIMIT 5;

-------------------
--Enregistrements--
-------------------

---
--- 1. FOURRIERES (10)
---
INSERT INTO Fourriere (nomFourriere, Adresse, telephoneFourriere) VALUES
('Fourriere Paris Centre', '12 Rue du Chenil, Paris', '0144556677'),
('Fourriere Lyon Sud', '45 Avenue Berthelot, Lyon', '0478990011'),
('Fourriere Marseille Nord', '8 Impasse des Oliviers, Marseille', '0491223344'),
('Fourriere Bordeaux Lac', 'Zone Industrielle Nord, Bordeaux', '0556112233'),
('Fourriere Toulouse Purpan', 'Route de Bayonne, Toulouse', '0561445566'),
('Fourriere Nantes Est', 'Chemin des Vignes, Nantes', '0240112233'),
('Fourriere Strasbourg Robertsau', 'Quai Jacoutot, Strasbourg', '0388112233'),
('Fourriere Lille Moulins', 'Boulevard de Belfort, Lille', '0320112233'),
('Fourriere Montpellier Prés', 'Avenue de la Mer, Montpellier', '0467112233'),
('Fourriere Rennes Cleunay', 'Rue de la Vilaine, Rennes', '0299112233');

---
--- 2. SOINS (Types variés)
---
INSERT INTO Soin (typeSoin, description) VALUES
('Vaccination', 'Vaccins essentiels (Carré, Leucose, Rage, etc.)'),
('Vermifugation', 'Traitement antiparasitaire interne'),
('Stérilisation', 'Ovariectomie ou castration'),
('Identification', 'Pose de puce électronique ou tatouage'),
('Chirurgie Orthopédique', 'Réparation de fractures ou ligaments'),
('Soins Dentaires', 'Détartrage et extraction'),
('Toilettage Sanitaire', 'Tonte pour animaux aux poils emmêlés/malades'),
('Rééducation', 'Physiothérapie suite à un accident'),
('Traitement Antibiotique', 'Pour infections bactériennes'),
('Bilan Sanguin', 'Analyse complète pour animaux âgés');

---
--- 3. PARTICULIERS (20 - Futurs adoptants)
---
INSERT INTO Particulier (nom, prenom, adresse, telephoneParticulier) VALUES
('Lemoine', 'Paul', '10 Rue de la Paix, Paris', '0611223344'),
('Dubois', 'Julie', '5 Avenue Foch, Lyon', '0622334455'),
('Vasseur', 'Marc', '12 Boulevard Michelet, Marseille', '0633445566'),
('Leroy', 'Sophie', '8 Rue Sainte-Catherine, Bordeaux', '0644556677'),
('Morel', 'Antoine', '3 Place du Capitole, Toulouse', '0655667788'),
('Fournier', 'Emma', '20 Rue Crébillon, Nantes', '0666778899'),
('Girard', 'Lucas', '7 Place Kléber, Strasbourg', '0677889900'),
('Bonnet', 'Chloé', '15 Grand Place, Lille', '0688990011'),
('Roux', 'Thomas', '9 Place de la Comédie, Montpellier', '0699001122'),
('Vincent', 'Lea', '4 Place des Lices, Rennes', '0600112233'),
('Guerin', 'Nicolas', '11 Rue Royale, Versailles', '0612121212'),
('Boyer', 'Camille', '66 Route 66, Melun', '0613131313'),
('Garnier', 'Hugo', '77 Allée des Cygnes, Annecy', '0614141414'),
('Chevalier', 'Manon', '88 Impasse des Lilas, Tours', '0615151515'),
('Blanc', 'Alexandre', '99 Boulevard Gambetta, Nice', '0616161616'),
('Gauthier', 'Sarah', '22 Rue de la République, Avignon', '0617171717'),
('Perrin', 'Mathieu', '33 Cours Mirabeau, Aix', '0618181818'),
('Morin', 'Elodie', '44 Quai Perdonnet, Vevey', '0619191919'),
('Mathieu', 'Clement', '55 Rue de Siam, Brest', '0620202020'),
('Clement', 'Charlotte', '101 Champs Elysées, Paris', '0621212121');

---
--- 4. EMPLOYES (25)
---
INSERT INTO Employe (matricule, nom, prenom, adresse, telephoneEmploye, dateNaissance, numeroSecu, dateEmbauche, login, motdepasse) VALUES
('M001', 'Dupont', 'Jean', 'Paris', '0601010101', '1980-05-15', '1800575001001', '2010-01-01', 'jdupont', 'pbkdf2:sha256:1000000$anNw17IMZTfr1No9$6e95d72026bed39b69915cddcd9bcb733a297fa1445af8e7f718709e4008df0e'),
('M002', 'Martin', 'Claire', 'Lyon', '0602020202', '1985-06-20', '2850669001002', '2012-02-01', 'cmartin', 'pbkdf2:sha256:1000000$tHVXtgEb1T6Yp0P6$17f6fc1bda30311f38491c63b80eaae8a936de4554a7a7a74518b0732061783a'),
('M003', 'Bernard', 'Luc', 'Marseille', '0603030303', '1978-03-10', '1780313001003', '2008-05-15', 'lbernard', 'pbkdf2:sha256:1000000$O1JTIczNnrJfWEa3$f1d140e5eb4467e6dd6d4ccdf70c33ca6dda524d16540e150c3771b4b43a5bf7'),
('M004', 'Petit', 'Emma', 'Bordeaux', '0604040404', '1990-11-25', '2901133001004', '2015-09-01', 'epetit', 'pbkdf2:sha256:1000000$Mra3biOyRWM6HVyP$6f4750988db54bbaa69d8c7c4ed8c8c91702ea23d58f587e79ff84599ea2f243'),
('M005', 'Robert', 'Hugo', 'Toulouse', '0605050505', '1982-08-30', '1820831001005', '2011-03-20', 'hrobert', 'pbkdf2:sha256:1000000$nSCueIYJSfW4jS2Y$5c0ecce23a17b535717dcab88ca52e77071a7844420aec09b207a4d23b811c6d'),
('M006', 'Richard', 'Ines', 'Nantes', '0606060606', '1995-02-14', '2950244001006', '2018-07-01', 'irichard', 'pbkdf2:sha256:1000000$sxqeUs9kK5UFz3Ny$ec8ea0684f351a2aab0634f6a2af79c3783b9839cd8e8456e29b935667adfbfb'),
('M007', 'Durand', 'Tom', 'Strasbourg', '0607070707', '1988-12-05', '1881267001007', '2014-10-10', 'tdurand', 'pbkdf2:sha256:1000000$4ik7TSXpcq2oMXsJ$2a7c79e29cf00d44a9abf6d74ac77e942bf8f327464667c2e746b105bf1868e6'),
('M008', 'Lefebvre', 'Lea', 'Lille', '0608080808', '1992-04-18', '2920459001008', '2016-01-05', 'llefebvre', 'pbkdf2:sha256:1000000$knlCzWxHAWrIlDuE$79fa289c13567998eab1494680c245ff4acd62ecde700c80669d54554f14ec9a'),
('M009', 'Moreau', 'Louis', 'Montpellier', '0609090909', '1975-09-22', '1750934001009', '2005-06-30', 'lmoreau', 'pbkdf2:sha256:1000000$JRVtP730pWpADCa1$5502e8b7b900cd9d71fe4e1dd07a22a719cd0a8a6b978c694331164e203e5fd2'),
('M010', 'Simon', 'Jade', 'Rennes', '0610101010', '1993-07-08', '2930735001010', '2017-11-15', 'jsimon', 'pbkdf2:sha256:1000000$LJu3UzpizDSIe5j1$bdee1713424da606d70d5f7fc3ce8bc8e0c87a9f62890b657cb7fd0de15c4d4f'),
('V001', 'Laurent', 'Pierre', 'Paris', '0701010101', '1984-01-15', '1840175001111', '2015-05-20', 'plaurent', 'pbkdf2:sha256:1000000$MvOSLOrJfkIlJWKJ$6f3fa4877916d7327198a0b065190243be1348f2d46bf6e21fb8cbeb894a893d'),
('S001', 'Michel', 'Sarah', 'Paris', '0702020202', '1998-03-12', '2980375001222', '2020-09-01', 'smichel', 'pbkdf2:sha256:1000000$bNbBUA4OtAY9t9w7$312db924cbc9dd8ad93985cde20c918e74dd14c60e015ced86e3c5455b5c9b44'),
('V002', 'Garcia', 'David', 'Lyon', '0703030303', '1986-07-30', '1860769001333', '2016-02-15', 'dgarcia', 'pbkdf2:sha256:1000000$yPKfFgxmwUvBb91A$7ea059fab493a47b5c33e4f82c12cff0404989f39302647753bad7ce01b25b8f'),
('S002', 'David', 'Julie', 'Lyon', '0704040404', '1999-12-05', '2991269001444', '2021-01-10', 'jdavid', 'pbkdf2:sha256:1000000$xV5OiLWN99q9uC55$e0695bc11a1dc0a40b9aa34898eb2ce585090d53bc6ee9e77dc27e51bb34fd5e'),
('S003', 'Bertrand', 'Paul', 'Marseille', '0705050505', '1997-05-25', '1970513001555', '2019-11-20', 'pbertrand', 'pbkdf2:sha256:1000000$nsmQdgtvOXLtc3Ww$95d33bd45635fc5095ea33703fcbe868e0c3831084a8a02f2cbea03af8e763fb'),
('V003', 'Rousseau', 'Anna', 'Bordeaux', '0706060606', '1989-09-14', '2890933001666', '2017-04-05', 'arousseau', 'pbkdf2:sha256:1000000$mbDqfIgTQXYqiqKS$cc8e988a5c3ecbf669ed69263bc3cb753223d0fd37b4ca6efb35da7cb27a1e41'),
('S004', 'Vincent', 'Leo', 'Toulouse', '0707070707', '2000-02-28', '1000231001777', '2022-06-15', 'lvincent', 'pbkdf2:sha256:1000000$087nQhjyu3N5kDtn$4a09e63045640b043e3a51fcd21347b1fac3ca2f25683a134adf2bbd32e198f5'),
('S005', 'Muller', 'Eva', 'Nantes', '0708080808', '1996-08-10', '2960844001888', '2019-03-01', 'emuller', 'pbkdf2:sha256:1000000$Uh8ZHiX4TxxqPyzV$638c10ad0133828f887b5a43a8394f8588302eae7cd0786d5515a86b2591e144'),
('V004', 'Lambert', 'Nathan', 'Strasbourg', '0709090909', '1983-11-03', '1831167001999', '2014-08-20', 'nlambert', 'pbkdf2:sha256:1000000$9PxiNc8YzckGpAFi$a88df28b6fea3f49be26358de2641212b2ed1b18ed69b271133c3235cdf91f1c'),
('S006', 'Faure', 'Zoe', 'Lille', '0710101010', '2001-04-12', '2010459002000', '2023-01-05', 'zfaure', 'pbkdf2:sha256:1000000$C7iIzVby6Hx22PtY$0f05f7a521d3ba5176ec6732e538d53909ec40525b1e9b6527775f1c3aba4649'),
('S007', 'Andre', 'Gabin', 'Montpellier', '0711111111', '1995-10-22', '1951034002111', '2018-12-10', 'gandre', 'pbkdf2:sha256:1000000$jtXslLPVIUZQM1sE$c43c45b81fb3bea1f45796fd9f093cb4440a2bdce88bbc361f6b16cf2d7ae0da'),
('V005', 'Mercier', 'Lola', 'Rennes', '0712121212', '1991-06-18', '2910635002222', '2016-09-25', 'lmercier', 'pbkdf2:sha256:1000000$d9buHKVx2eAuZp7p$a85bc2dba89ae78b3e454074c151e100446011ec1727485471cb2e752e246b0e'),
('S008', 'Blanc', 'Arthur', 'Paris', '0713131313', '1994-03-08', '1940375002333', '2017-05-15', 'ablanc', 'pbkdf2:sha256:1000000$RWu7GPFjaBa99wMz$6fd615e47533f5637acc8cf38492094ba14e264ac9bb92497f78f8e1093e0682'),
('S009', 'Guerin', 'Romane', 'Lyon', '0714141414', '1999-01-30', '2990169002444', '2020-11-01', 'rguerin', 'pbkdf2:sha256:1000000$JbWXV4ESnlIOjpDN$a1f5465fe0c528560b6ad7ba06dcacdda15d7dc67b435fc9ceccada5e5ba1463'),
('S010', 'Boyer', 'Jules', 'Marseille', '0715151515', '2002-07-15', '1020713002555', '2023-08-20', 'jboyer', 'pbkdf2:sha256:1000000$RdiasQAjRgI783rl$ec4fee69401720860742057b560062647aa8d2dc2969f282261178a9e39afeaf');

---
--- 5. REFUGES (10) - Avec les ID des employés gérants (1 à 10)
---
INSERT INTO Refuge (nom, ville, codePostal, telephoneRefuge, capaciteAccueil, idEmploye, lat, lon) VALUES
('Refuge de l''Espoir', 'Paris', '75012', '0144001122', 100, 1, 48.8412, 2.4005),
('SPA Lyon Centre', 'Lyon', '69002', '0478001122', 80, 2, 45.7579, 4.8320),
('Abri Marseillais', 'Marseille', '13008', '0491001122', 90, 3, 43.2798, 5.3857),
('Refuge Bordelais', 'Bordeaux', '33000', '0556001122', 70, 4, 44.8378, -0.5792),
('Oasis Toulouse', 'Toulouse', '31000', '0561001122', 85, 5, 43.6047, 1.4442),
('Refuge Nantais', 'Nantes', '44000', '0240001122', 60, 6, 47.2184, -1.5536),
('Arche de Strasbourg', 'Strasbourg', '67000', '0388001122', 75, 7, 48.5734, 7.7521),
('Refuge du Nord', 'Lille', '59000', '0320001122', 65, 8, 50.6292, 3.0573),
('Soleil Montpellier', 'Montpellier', '34000', '0467001122', 95, 9, 43.6108, 3.8767),
('Refuge Breton', 'Rennes', '35000', '0299001122', 55, 10, 48.1173, -1.6778);

---
--- 6. ANIMAUX (50) - Diversité MAXIMALE
---
INSERT INTO Animal (nom, espece, race, age, sexe, signeDistinctif, statut, daterecueil, idFourriere) VALUES
-- CHIENS (60)
('Rex', 'Chien', 'Berger Allemand', 5, 'M', 'Oreille gauche tombante', 'Disponible', '2023-01-10', 1),
('Bella', 'Chien', 'Labrador', 3, 'F', 'Tache blanche poitrail', 'Adopté', '2023-02-15', 2), 
('Rocky', 'Chien', 'Boxer', 4, 'M', 'Queue écourtée', 'Disponible', '2023-03-20', 3),
('Luna', 'Chien', 'Husky', 2, 'F', 'Yeux vairons', 'En Soins', '2023-04-25', 4),
('Max', 'Chien', 'Golden Retriever', 6, 'M', 'Cicatrice patte avant', 'Disponible', '2023-05-30', 5),
('Daisy', 'Chien', 'Beagle', 1, 'F', 'Très vocale', 'Adopté', '2023-06-05', 6), 
('Charlie', 'Chien', 'Cocker', 7, 'M', 'Poils longs dorés', 'Décédé', '2022-12-01', 7),
('Lola', 'Chien', 'Chihuahua', 8, 'F', 'Manque une dent', 'Disponible', '2023-08-10', 8),
('Buddy', 'Chien', 'Border Collie', 2, 'M', 'Hyperactif', 'Disponible', '2023-09-15', 9),
('Sadie', 'Chien', 'Rottweiler', 5, 'F', 'Queue longue', 'Adopté', '2023-10-20', 10), 
('Zeus', 'Chien', 'Doberman', 3, 'M', 'Oreilles droites', 'En Soins', '2023-11-25', 1),
('Ruby', 'Chien', 'Caniche', 9, 'F', 'Pelage gris', 'Disponible', '2023-12-30', 2),
('Duke', 'Chien', 'Dogue Allemand', 4, 'M', 'Très grand', 'Adopté', '2024-01-05', 3), 
('Molly', 'Chien', 'Shih Tzu', 6, 'F', 'Borgne', 'Disponible', '2024-02-10', 4),
('Bear', 'Chien', 'Terre-Neuve', 2, 'M', 'Aime l''eau', 'Disponible', '2024-03-15', 5),
('Tyson', 'Chien', 'Staffordshire', 4, 'M', 'Musclé', 'Disponible', '2023-06-12', 1),
('Princesse', 'Chien', 'Yorkshire', 7, 'F', 'Petit noeud rose', 'Disponible', '2023-07-01', 2),
('Volt', 'Chien', 'Berger Blanc Suisse', 2, 'M', 'Poil très blanc', 'Disponible', '2023-08-15', 3),
('Hatchi', 'Chien', 'Akita Inu', 5, 'M', 'Fidèle', 'En Soins', '2023-09-10', 4),
('Lady', 'Chien', 'Cavalier King Charles', 3, 'F', 'Oreilles longues', 'Disponible', '2023-10-05', 5),
('Marley', 'Chien', 'Labrador Chocolat', 6, 'M', 'Très joueur', 'Disponible', '2023-11-20', 6),
('Snoopy', 'Chien', 'Beagle', 4, 'M', 'Dort sur le toit', 'Adopté', '2023-01-20', 7),
('Lassie', 'Chien', 'Colley', 3, 'F', 'Poils longs', 'Disponible', '2023-02-14', 8),
('Scooby', 'Chien', 'Dogue Allemand', 2, 'M', 'Peureux', 'Disponible', '2023-03-30', 9),
('Beethoven', 'Chien', 'Saint-Bernard', 5, 'M', 'Bave un peu', 'Disponible', '2023-04-12', 10),
('Pongo', 'Chien', 'Dalmatien', 3, 'M', '101 taches', 'Disponible', '2023-05-18', 1),
('Perdita', 'Chien', 'Dalmatien', 3, 'F', 'Collier bleu', 'Disponible', '2023-05-18', 1),
('Idéfix', 'Chien', 'Westie', 8, 'M', 'Tout petit', 'Adopté', '2023-06-25', 2),
('Milou', 'Chien', 'Fox Terrier', 4, 'M', 'Très intelligent', 'Disponible', '2023-07-14', 3),
('Bill', 'Chien', 'Cocker Anglais', 2, 'M', 'Oreilles tombantes', 'Disponible', '2023-08-05', 4),
('Rantaplan', 'Chien', 'Chien de berger', 6, 'M', 'Un peu bête', 'Disponible', '2023-09-01', 5),
('Pluto', 'Chien', 'Saint-Hubert', 5, 'M', 'Flair exceptionnel', 'Disponible', '2023-10-10', 6),
('Goofy', 'Chien', 'Bruno du Jura', 7, 'M', 'Maladroit', 'En Soins', '2023-11-15', 7),
('Balto', 'Chien', 'Husky', 3, 'M', 'Aime la neige', 'Disponible', '2023-12-01', 8),
('Croc-Blanc', 'Chien', 'Loup Tchécoslovaque', 4, 'M', 'Regard perçant', 'Disponible', '2024-01-05', 9),
('Belle', 'Chien', 'Montagne des Pyrénées', 3, 'F', 'Très protectrice', 'Disponible', '2024-01-20', 10),
('Sebastien', 'Chien', 'Berger des Pyrénées', 2, 'M', 'Vif', 'Adopté', '2024-02-01', 1),
('Froufrou', 'Chien', 'Caniche Royal', 5, 'F', 'Pompons aux pattes', 'Disponible', '2024-02-15', 2),
('Brutus', 'Chien', 'Bulldog Anglais', 4, 'M', 'Ronfle', 'Disponible', '2024-03-01', 3),
('César', 'Chien', 'West Highland', 6, 'M', 'Blanc immaculé', 'Disponible', '2024-03-10', 4),
('Pollux', 'Chien', 'Bobtail', 7, 'M', 'Poils devant les yeux', 'Disponible', '2024-03-20', 5),
('Cubitus', 'Chien', 'Bobtail', 5, 'M', 'Gros nounours', 'Disponible', '2024-03-25', 6),
('Pif', 'Chien', 'Epagneul Breton', 3, 'M', 'Tache marron', 'Disponible', '2024-04-01', 7),
('Hercule', 'Chien', 'Basset Hound', 4, 'M', 'Pattes courtes', 'Disponible', '2024-04-05', 8),
('Gromit', 'Chien', 'Beagle', 5, 'M', 'Intelligent', 'Disponible', '2024-04-10', 9),
('Odie', 'Chien', 'Jack Russell', 2, 'M', 'Langue pendante', 'Disponible', '2024-04-15', 10),
('Satanas', 'Chien', 'Levrier Afghan', 4, 'M', 'Très rapide', 'Disponible', '2024-04-20', 1),
('Diabolo', 'Chien', 'Bâtard', 3, 'M', 'Rire étrange', 'Disponible', '2024-04-25', 2),
('Scoubidou', 'Chien', 'Dogue Allemand', 5, 'M', 'Gourmand', 'Disponible', '2024-04-30', 3),
('Volt', 'Chien', 'Berger Allemand', 2, 'M', 'Éclair sur le flanc', 'Disponible', '2024-05-01', 4),
('Patch', 'Chien', 'Dalmatien', 1, 'M', 'Tache sur l''oeil', 'Disponible', '2024-05-05', 5),
('Lucky', 'Chien', 'Dalmatien', 1, 'M', 'Chanceux', 'Disponible', '2024-05-05', 6),
('Rolly', 'Chien', 'Dalmatien', 1, 'M', 'Rondouillard', 'Disponible', '2024-05-05', 7),
('Penny', 'Chien', 'Dalmatien', 1, 'F', 'Timide', 'Disponible', '2024-05-05', 8),
('Freckles', 'Chien', 'Dalmatien', 1, 'M', 'Taches de rousseur', 'Disponible', '2024-05-05', 9),
('Pepper', 'Chien', 'Dalmatien', 1, 'F', 'Épicée', 'Disponible', '2024-05-05', 10),
('Jewel', 'Chien', 'Dalmatien', 1, 'F', 'Précieuse', 'Disponible', '2024-05-05', 1),
('Dipstick', 'Chien', 'Dalmatien', 1, 'M', 'Queue noire', 'Disponible', '2024-05-05', 2),
('Wizzer', 'Chien', 'Dalmatien', 1, 'M', 'Inquiet', 'Disponible', '2024-05-05', 3),
('Fidget', 'Chien', 'Dalmatien', 1, 'M', 'Agité', 'Disponible', '2024-05-05', 4),

-- CHATS (60)
('Simba', 'Chat', 'Européen', 3, 'M', 'Roux tigré', 'Disponible', '2023-01-12', 6),
('Nala', 'Chat', 'Siamois', 2, 'F', 'Yeux bleus intenses', 'Adopté', '2023-02-18', 7), 
('Leo', 'Chat', 'Maine Coon', 5, 'M', 'Poids 10kg', 'Disponible', '2023-03-22', 8),
('Mimi', 'Chat', 'Persan', 4, 'F', 'Face plate', 'En Soins', '2023-04-28', 9),
('Tigrou', 'Chat', 'Bengal', 1, 'M', 'Taches léopard', 'Disponible', '2023-06-02', 10),
('Kitty', 'Chat', 'Sphynx', 6, 'F', 'Sans poils', 'Adopté', '2023-07-08', 1), 
('Felix', 'Chat', 'Gouttière', 8, 'M', 'Noir et blanc', 'Décédé', '2022-11-15', 2),
('Lily', 'Chat', 'Sacré de Birmanie', 3, 'F', 'Gants blancs', 'Disponible', '2023-09-12', 3),
('Garfield', 'Chat', 'Exotic Shorthair', 7, 'M', 'Dort tout le temps', 'Disponible', '2023-10-18', 4),
('Zoe', 'Chat', 'Chartreux', 2, 'F', 'Yeux or', 'Adopté', '2023-11-22', 5), 
('Oreo', 'Chat', 'Ragdoll', 4, 'M', 'Mou comme une poupée', 'En Soins', '2023-12-28', 6),
('Cleo', 'Chat', 'Abyssin', 5, 'F', 'Pelage lièvre', 'Disponible', '2024-01-08', 7),
('Shadow', 'Chat', 'Bombay', 2, 'M', 'Tout noir', 'Adopté', '2024-02-12', 8), 
('Mia', 'Chat', 'Norvégien', 3, 'F', 'Fourrure épaisse', 'Disponible', '2024-03-18', 9),
('Gribouille', 'Chat', 'Angora Turc', 6, 'M', 'Yeux vairons', 'Disponible', '2024-04-22', 10),
('Minette', 'Chat', 'Européen', 2, 'F', 'Tricolore', 'Disponible', '2023-05-10', 5),
('Grisou', 'Chat', 'Chartreux', 4, 'M', 'Gris uniforme', 'Disponible', '2023-06-15', 6),
('Salem', 'Chat', 'Noir', 100, 'M', 'Parle (parfois)', 'Disponible', '2023-07-20', 7),
('Chipie', 'Chat', 'Ecaille de tortue', 3, 'F', 'Caractère fort', 'En Soins', '2023-08-25', 8),
('Caline', 'Chat', 'Sacré de Birmanie', 5, 'F', 'Très douce', 'Disponible', '2023-09-30', 9),
('Mimi', 'Chat', 'Gouttière', 1, 'F', 'Tigrée', 'Disponible', '2023-10-15', 10),
('Berlioz', 'Chat', 'Angora', 2, 'M', 'Joueur de piano', 'Disponible', '2023-11-05', 1),
('Toulouse', 'Chat', 'Gouttière', 2, 'M', 'Peintre', 'Disponible', '2023-11-05', 1),
('Marie', 'Chat', 'Angora', 2, 'F', 'Nœud rose', 'Disponible', '2023-11-05', 1),
('Duchesse', 'Chat', 'Angora', 5, 'F', 'Distinguée', 'Adopté', '2023-11-05', 1),
('O''Malley', 'Chat', 'Gouttière', 6, 'M', 'Charmeur', 'Disponible', '2023-11-10', 2),
('Lucifer', 'Chat', 'Noir', 4, 'M', 'Sournois', 'Disponible', '2023-12-01', 3),
('Figaro', 'Chat', 'Noir et Blanc', 3, 'M', 'Danseur', 'Disponible', '2023-12-15', 4),
('Gédéon', 'Chat', 'Roux', 5, 'M', 'Associé à un renard', 'Disponible', '2024-01-01', 5),
('Cheshire', 'Chat', 'Tigré Violet', 10, 'M', 'Sourire effrayant', 'En Soins', '2024-01-10', 6),
('Azrael', 'Chat', 'Roux', 4, 'M', 'Oreille abîmée', 'Disponible', '2024-01-20', 7),
('Tom', 'Chat', 'Gris et Blanc', 6, 'M', 'Malchanceux', 'Disponible', '2024-02-01', 8),
('Sylvestre', 'Chat', 'Noir et Blanc', 7, 'M', 'Zézaye', 'Disponible', '2024-02-15', 9),
('Garfield', 'Chat', 'Exotic Shorthair', 8, 'M', 'Aime les lasagnes', 'Disponible', '2024-03-01', 10),
('Hello Kitty', 'Chat', 'Bobtail Japonais', 2, 'F', 'Nœud rouge', 'Adopté', '2024-03-10', 1),
('Choupette', 'Chat', 'Sacré de Birmanie', 3, 'F', 'Héritière', 'Disponible', '2024-03-20', 2),
('Grumpy', 'Chat', 'Snowshoe', 4, 'F', 'Air grincheux', 'Disponible', '2024-04-01', 3),
('Nyan', 'Chat', 'Arc-en-ciel', 1, 'M', 'Volant', 'Disponible', '2024-04-05', 4),
('Keyboard', 'Chat', 'Roux', 5, 'M', 'Joue du synthé', 'Disponible', '2024-04-10', 5),
('Lil Bub', 'Chat', 'Perma-Kitten', 3, 'F', 'Langue sortie', 'En Soins', '2024-04-15', 6),
('Maru', 'Chat', 'Scottish Fold', 6, 'M', 'Aime les boîtes', 'Disponible', '2024-04-20', 7),
('Venus', 'Chat', 'Chimère', 4, 'F', 'Visage bicolore', 'Disponible', '2024-04-25', 8),
('Snoopybabe', 'Chat', 'Exotic Shorthair', 2, 'M', 'Yeux ronds', 'Disponible', '2024-04-30', 9),
('Hamilton', 'Chat', 'Hipster', 3, 'M', 'Moustache blanche', 'Disponible', '2024-05-01', 10),
('Colonel Meow', 'Chat', 'Himalayen', 5, 'M', 'Poils très longs', 'Décédé', '2024-01-15', 1),
('Puss', 'Chat', 'Roux', 4, 'M', 'Bottes', 'Disponible', '2024-05-05', 2),
('Kitty Softpaws', 'Chat', 'Noir et Blanc', 3, 'F', 'Pattes de velours', 'Disponible', '2024-05-05', 3),
('Snowbell', 'Chat', 'Persan Blanc', 6, 'M', 'Prétentieux', 'Disponible', '2024-05-05', 4),
('Mr. Tinkles', 'Chat', 'Persan', 5, 'M', 'Méchant', 'Disponible', '2024-05-05', 5),
('Sassy', 'Chat', 'Himalayen', 4, 'F', 'Bavarde', 'Disponible', '2024-05-05', 6),
('D.C.', 'Chat', 'Siamois', 3, 'M', 'Agent secret', 'Disponible', '2024-05-05', 7),
('Binx', 'Chat', 'Noir', 22, 'M', 'Immortel', 'Disponible', '2024-05-05', 8),
('Salem', 'Chat', 'Noir', 5, 'M', 'Sorcière', 'Disponible', '2024-05-05', 9),
('Luna', 'Chat', 'Noir', 2, 'F', 'Lune sur le front', 'Disponible', '2024-05-05', 10),
('Artemis', 'Chat', 'Blanc', 2, 'M', 'Lune sur le front', 'Disponible', '2024-05-05', 1),
('Diana', 'Chat', 'Gris', 1, 'F', 'Lune sur le front', 'Disponible', '2024-05-05', 2),
('Meowth', 'Chat', 'Pokémon', 5, 'M', 'Pièce sur la tête', 'Disponible', '2024-05-05', 3),
('Persian', 'Chat', 'Pokémon', 6, 'M', 'Bijou rouge', 'Disponible', '2024-05-05', 4),
('Skitty', 'Chat', 'Pokémon', 2, 'F', 'Queue en fleur', 'Disponible', '2024-05-05', 5),
('Delcatty', 'Chat', 'Pokémon', 4, 'F', 'Collier violet', 'Disponible', '2024-05-05', 6),

-- NAC & INSOLITES (20 - Diversité)
('Panpan', 'Lapin', 'Nain', 1, 'M', 'Grandes oreilles', 'Disponible', '2023-05-01', 1),
('Coco', 'Perroquet', 'Gris du Gabon', 25, 'M', 'Parle beaucoup', 'Disponible', '2023-05-15', 2),
('Speedy', 'Tortue', 'Hermann', 50, 'F', 'Carapace abîmée', 'Adopté', '2023-06-01', 3), 
('Slinky', 'Furet', 'Putoisé', 2, 'M', 'Très joueur', 'Disponible', '2023-06-15', 4),
('Pepito', 'Cochon d''Inde', 'Rosette', 1, 'M', 'Poils en épi', 'Disponible', '2023-07-01', 5),
('Riri', 'Hamster', 'Doré', 1, 'F', 'Joue gonflées', 'Adopté', '2023-07-15', 6), 
('Kaa', 'Serpent', 'Python Royal', 5, 'I', 'Mange des souris', 'En Soins', '2023-08-01', 7),
('Iggy', 'Iguane', 'Vert', 3, 'M', 'Aime la chaleur', 'Disponible', '2023-08-15', 8),
('Babe', 'Cochon', 'Nain Vietnamien', 2, 'F', 'Très propre', 'Disponible', '2023-09-01', 9),
('Biquette', 'Chèvre', 'Alpine', 4, 'F', 'Cornes courbes', 'Adopté', '2023-09-15', 10), 
('Jojo', 'Pigeon', 'Voyageur', 2, 'M', 'Bague rouge', 'Disponible', '2023-10-01', 1),
('Flash', 'Escargot', 'Géant d''Afrique', 1, 'I', 'Très lent', 'Disponible', '2023-10-15', 2),
('Spike', 'Hérisson', 'Africain', 2, 'M', 'Piques blancs', 'Adopté', '2023-11-01', 3), 
('Bernard', 'Rat', 'Husky', 1, 'M', 'Intelligent', 'Disponible', '2023-11-15', 4),
('Bianca', 'Souris', 'Blanche', 1, 'F', 'Yeux rouges', 'Disponible', '2023-12-01', 5),
('Choco', 'Octodon', 'Chilien', 3, 'M', 'Queue pinceau', 'Disponible', '2023-12-15', 6),
('Pompom', 'Chinchilla', 'Gris standard', 4, 'F', 'Douceur extrême', 'Adopté', '2024-01-01', 7), 
('Zaza', 'Gerbille', 'Mongolie', 1, 'F', 'Creuse tout le temps', 'Disponible', '2024-01-15', 8),
('Fifi', 'Canari', 'Jaune', 2, 'M', 'Chanteur', 'Disponible', '2024-02-01', 9),
('Glouglou', 'Dindon', 'Noir', 1, 'M', 'Fait la roue', 'Disponible', '2024-02-15', 10),
('Bugs', 'Lapin', 'Garenne', 3, 'M', 'Mange des carottes', 'Disponible', '2023-04-01', 7),
('Lola', 'Lapin', 'Bélier', 2, 'F', 'Joueuse de basket', 'Disponible', '2023-04-15', 8),
('Roger', 'Lapin', 'Blanc', 4, 'M', 'Salopette rouge', 'Disponible', '2023-05-01', 9),
('Panpan', 'Lapin', 'Gris', 1, 'M', 'Tape du pied', 'Disponible', '2023-05-15', 10),
('Judy', 'Lapin', 'Garenne', 3, 'F', 'Policière', 'Disponible', '2023-06-01', 1),
('Snowball', 'Lapin', 'Blanc', 2, 'M', 'Mignon mais dangereux', 'Disponible', '2023-06-15', 2),
('Pierre', 'Lapin', 'Veste bleue', 2, 'M', 'Voleur de légumes', 'Disponible', '2023-07-01', 3),
('Jeannot', 'Lapin', 'Veste rouge', 2, 'M', 'Suiveur', 'Disponible', '2023-07-01', 3),
('Coton', 'Lapin', 'Angora', 1, 'F', 'Boule de poils', 'Disponible', '2023-07-15', 4),
('Noisette', 'Ecureuil', 'Roux', 2, 'M', 'Rapide', 'Disponible', '2023-08-01', 5),
('Alvin', 'Tamias', 'Rayé', 3, 'M', 'Chanteur', 'Disponible', '2023-08-15', 6),
('Simon', 'Tamias', 'Rayé', 3, 'M', 'Intello', 'Disponible', '2023-08-15', 6),
('Theodore', 'Tamias', 'Rayé', 3, 'M', 'Gourmand', 'Disponible', '2023-08-15', 6),
('Tic', 'Ecureuil', 'Marron', 5, 'M', 'Nez noir', 'Disponible', '2023-09-01', 7),
('Tac', 'Ecureuil', 'Marron', 5, 'M', 'Nez rouge', 'Disponible', '2023-09-01', 7),
('Denver', 'Iguane', 'Vert', 10, 'M', 'Guitare', 'Disponible', '2023-09-15', 8),
('Pascal', 'Caméléon', 'Vert', 2, 'M', 'Change de couleur', 'Disponible', '2023-10-01', 9),
('Kermit', 'Grenouille', 'Verte', 5, 'M', 'Journaliste', 'Disponible', '2023-10-15', 10),
('Miss Piggy', 'Cochon', 'Rose', 4, 'F', 'Star', 'Disponible', '2023-11-01', 1),
('Babe', 'Cochon', 'Rose', 1, 'M', 'Berger', 'Adopté', '2023-11-15', 2),
('Wilbur', 'Cochon', 'Rose', 1, 'M', 'Araignée amie', 'Disponible', '2023-12-01', 3),
('Pua', 'Cochon', 'Tacheté', 1, 'M', 'Compagnon de voyage', 'Disponible', '2023-12-15', 4),
('Heihei', 'Coq', 'Bicolore', 2, 'M', 'Stupide', 'Disponible', '2024-01-01', 5),
('Zazu', 'Oiseau', 'Calao', 10, 'M', 'Majordome', 'Disponible', '2024-01-15', 6),
('Iago', 'Perroquet', 'Rouge', 8, 'M', 'Bruyant', 'Disponible', '2024-02-01', 7),
('Blu', 'Perroquet', 'Ara Bleu', 3, 'M', 'Ne sait pas voler', 'Disponible', '2024-02-15', 8),
('Jewel', 'Perroquet', 'Ara Bleu', 3, 'F', 'Libre', 'Disponible', '2024-02-15', 8),
('Nigel', 'Cacatoès', 'Blanc', 15, 'M', 'Méchant', 'En Soins', '2024-03-01', 9),
('Hedwig', 'Chouette', 'Harfang', 4, 'F', 'Courrier', 'Disponible', '2024-03-15', 10),
('Errol', 'Hibou', 'Gris', 12, 'M', 'Fatigué', 'Disponible', '2024-04-01', 1);

---
--- 7. ADOPTIONS (13) - Uniquement pour les animaux avec statut 'Adopté'
---
INSERT INTO Adoption (idAnimal, idParticulier, dateAdoption) VALUES
(2, 1, '2023-04-01'),  -- Bella (Chien)
(6, 2, '2023-07-15'),  -- Daisy (Chien)
(10, 3, '2023-11-01'), -- Sadie (Chien)
(13, 4, '2024-02-01'), -- Duke (Chien)
(17, 5, '2023-03-01'), -- Nala (Chat)
(21, 6, '2023-08-01'), -- Kitty (Chat)
(25, 7, '2023-12-01'), -- Zoe (Chat)
(28, 8, '2024-03-01'), -- Shadow (Chat)
(33, 9, '2023-06-15'), -- Speedy (Tortue)
(36, 10, '2023-08-01'),-- Riri (Hamster)
(40, 11, '2023-10-01'),-- Biquette (Chèvre)
(43, 12, '2023-11-15'),-- Spike (Hérisson)
(47, 13, '2024-01-20');-- Pompom (Chinchilla)

---
--- 8. HEBERGE (Historique de placement - Tous les animaux doivent être quelque part)
---
-- On place les animaux dans les refuges (ID Refuge 1 à 10)
INSERT INTO Heberge (idAnimal, idRefuge, dateArrive, dateDepart) VALUES
-- Refuge 1 (Paris)
(1, 1, '2023-01-11', NULL),
(11, 1, '2023-11-26', NULL),
(21, 1, '2023-07-09', '2023-08-01'), -- Adopté
(31, 1, '2023-05-02', NULL),
(41, 1, '2023-10-02', NULL),
(51, 1, '2023-06-12', NULL), 
(61, 1, '2023-05-18', NULL), 
(71, 1, '2024-04-20', NULL), 
(81, 1, '2024-05-05', NULL),
(91, 1, '2023-11-05', NULL), 
(101, 1, '2023-11-05', '2023-12-01'), -- Adopté
(111, 1, '2024-03-10', NULL), 
(121, 1, '2024-05-05', NULL), 
(131, 1, '2024-01-15', NULL), 
(141, 1, '2023-06-01', NULL),
(151, 1, '2023-11-01', NULL), 
(161, 1, '2024-04-01', NULL),

-- Refuge 2 (Lyon)
(2, 2, '2023-02-16', '2023-04-01'), -- Adopté
(12, 2, '2023-12-31', NULL),
(22, 2, '2022-11-16', '2022-11-20'), -- Décédé
(32, 2, '2023-05-16', NULL),
(42, 2, '2023-10-16', NULL),
(52, 2, '2023-07-01', NULL), 
(62, 2, '2023-05-18', NULL), 
(72, 2, '2024-04-25', NULL), 
(82, 2, '2024-05-05', NULL),
(92, 2, '2023-05-10', NULL), 
(102, 2, '2023-11-10', NULL), 
(112, 2, '2024-03-20', NULL), 
(122, 2, '2024-05-05', NULL),
(132, 2, '2024-05-05', NULL), 
(142, 2, '2023-06-15', NULL), 
(152, 2, '2023-11-15', '2023-12-01'), -- Adopté
(162, 2, '2024-01-01', NULL),

-- Refuge 3 (Marseille)
(3, 3, '2023-03-21', NULL),
(13, 3, '2024-01-06', '2024-02-01'), -- Adopté
(23, 3, '2023-09-13', NULL),
(33, 3, '2023-06-02', '2023-06-15'), -- Adopté
(43, 3, '2023-11-02', '2023-11-15'), -- Adopté
(53, 3, '2023-08-15', NULL), 
(63, 3, '2023-06-25', '2023-07-01'), -- Adopté
(73, 3, '2024-04-30', NULL), 
(83, 3, '2024-05-05', NULL), 
(93, 3, '2023-06-15', NULL), 
(103, 3, '2023-12-01', NULL),
(113, 3, '2024-04-01', NULL), 
(123, 3, '2024-05-05', NULL), 
(133, 3, '2024-05-05', NULL), 
(143, 3, '2023-07-01', NULL),
(153, 3, '2023-12-01', NULL), 
(163, 3, '2024-02-01', NULL),

-- Refuge 4 (Bordeaux)
(4, 4, '2023-04-26', NULL),
(14, 4, '2024-02-11', NULL),
(24, 4, '2023-10-19', NULL),
(34, 4, '2023-06-16', NULL),
(44, 4, '2023-11-16', NULL),
(54, 4, '2023-09-10', NULL), 
(64, 4, '2023-07-14', NULL), 
(74, 4, '2024-05-01', NULL), 
(84, 4, '2024-05-05', NULL),
(94, 4, '2023-07-20', NULL), 
(104, 4, '2023-12-15', NULL), 
(114, 4, '2024-04-05', NULL), 
(124, 4, '2024-05-05', NULL),
(134, 4, '2024-05-05', NULL), 
(144, 4, '2023-07-01', NULL), 
(154, 4, '2023-12-15', NULL), 
(164, 4, '2024-02-15', NULL),

-- Refuge 5 (Toulouse)
(5, 5, '2023-05-31', NULL),
(15, 5, '2024-03-16', NULL),
(25, 5, '2023-11-23', '2023-12-01'), -- Adopté
(35, 5, '2023-07-02', NULL),
(45, 5, '2023-12-02', NULL),
(55, 5, '2023-10-05', NULL), 
(65, 5, '2023-08-05', NULL), 
(75, 5, '2024-05-05', NULL), 
(85, 5, '2024-05-05', NULL),
(95, 5, '2023-08-25', NULL), 
(105, 5, '2024-01-01', NULL), 
(115, 5, '2024-04-10', NULL), 
(125, 5, '2024-05-05', NULL),
(135, 5, '2024-05-05', NULL), 
(145, 5, '2023-07-15', NULL), 
(155, 5, '2024-01-01', NULL), 
(165, 5, '2024-02-15', NULL),

-- Refuge 6 (Nantes)
(6, 6, '2023-06-06', '2023-07-15'), -- Adopté
(16, 6, '2023-01-13', NULL),
(26, 6, '2023-12-29', NULL),
(36, 6, '2023-07-16', '2023-08-01'), -- Adopté
(46, 6, '2023-12-16', NULL),
(56, 6, '2023-11-20', NULL), 
(66, 6, '2023-09-01', NULL), 
(76, 6, '2024-05-05', NULL), 
(86, 6, '2024-05-05', NULL),
(96, 6, '2023-09-30', NULL), 
(106, 6, '2024-01-10', NULL), 
(116, 6, '2024-04-15', NULL), 
(126, 6, '2024-05-05', NULL),
(136, 6, '2024-05-05', NULL), 
(146, 6, '2023-08-01', NULL), 
(156, 6, '2024-01-15', NULL), 
(166, 6, '2024-03-01', NULL),

-- Refuge 7 (Strasbourg)
(7, 7, '2022-11-01', '2022-12-01'), -- Décédé
(17, 7, '2023-02-19', '2023-03-01'), -- Adopté
(27, 7, '2024-01-09', NULL),
(37, 7, '2023-08-02', NULL),
(47, 7, '2024-01-02', '2024-01-20'), -- Adopté
(57, 7, '2023-01-20', '2023-02-01'), -- Adopté
(67, 7, '2023-10-10', NULL), 
(77, 7, '2024-05-05', NULL), 
(87, 7, '2024-05-05', NULL),
(97, 7, '2023-10-15', NULL), 
(107, 7, '2024-01-20', NULL), 
(117, 7, '2024-04-20', NULL), 
(127, 7, '2024-05-05', NULL),
(137, 7, '2024-05-05', NULL), 
(147, 7, '2023-08-15', NULL), 
(157, 7, '2024-02-01', NULL), 
(167, 7, '2024-03-15', NULL),

-- Refuge 8 (Lille)
(8, 8, '2023-08-11', NULL),
(18, 8, '2023-03-23', NULL),
(28, 8, '2024-02-13', '2024-03-01'), -- Adopté
(38, 8, '2023-08-16', NULL),
(48, 8, '2024-01-16', NULL),
(58, 8, '2023-02-14', NULL), 
(68, 8, '2023-11-15', NULL), 
(78, 8, '2024-05-05', NULL), 
(88, 8, '2024-05-05', NULL),
(98, 8, '2023-11-05', NULL), 
(108, 8, '2024-02-01', NULL), 
(118, 8, '2024-04-25', NULL), 
(128, 8, '2024-05-05', NULL),
(138, 8, '2024-05-05', NULL), 
(148, 8, '2023-08-15', NULL), 
(158, 8, '2024-02-15', NULL), 
(168, 8, '2024-04-01', NULL),

-- Refuge 9 (Montpellier)
(9, 9, '2023-09-16', NULL),
(19, 9, '2023-04-29', NULL),
(29, 9, '2024-03-19', NULL),
(39, 9, '2023-09-02', NULL),
(49, 9, '2024-02-02', NULL),
(59, 9, '2023-03-30', NULL), 
(69, 9, '2023-12-01', NULL), 
(79, 9, '2024-05-05', NULL), 
(89, 9, '2024-05-05', NULL),
(99, 9, '2023-11-05', NULL), 
(109, 9, '2024-02-15', NULL), 
(119, 9, '2024-04-30', NULL), 
(129, 9, '2024-05-05', NULL),
(139, 9, '2024-05-05', NULL), 
(149, 9, '2023-08-15', NULL), 
(159, 9, '2024-03-01', NULL), 
(169, 9, '2023-04-01', NULL),

-- Refuge 10 (Rennes)
(10, 10, '2023-10-21', '2023-11-01'), -- Adopté
(20, 10, '2023-06-03', NULL),
(30, 10, '2024-04-23', NULL),
(40, 10, '2023-09-16', '2023-10-01'), -- Adopté
(50, 10, '2024-02-16', NULL),
(60, 10, '2023-04-12', NULL), 
(70, 10, '2024-01-05', NULL), 
(80, 10, '2024-05-05', NULL), 
(90, 10, '2024-05-05', NULL),
(100, 10, '2023-11-05', '2023-12-01'), -- Adopté
(110, 10, '2024-03-01', NULL), 
(120, 10, '2024-05-01', NULL), 
(130, 10, '2024-01-15', NULL), 
(140, 10, '2024-05-05', NULL), 
(150, 10, '2023-09-01', NULL),
(160, 10, '2023-11-01', NULL), 
(170, 10, '2024-04-15', NULL);

---
--- 9. ESTAFFECTE (Les contrats de travail)
---
INSERT INTO EstAffecte (idEmploye, idRefuge, dateAffectation, fonction) VALUES
-- Gérants déjà définis
(1, 1, '2010-01-01', 'Directeur'),
(2, 2, '2012-02-01', 'Directeur'),
(3, 3, '2008-05-15', 'Directeur'),
(4, 4, '2015-09-01', 'Directeur'),
(5, 5, '2011-03-20', 'Directeur'),
(6, 6, '2018-07-01', 'Directeur'),
(7, 7, '2014-10-10', 'Directeur'),
(8, 8, '2016-01-05', 'Directeur'),
(9, 9, '2005-06-30', 'Directeur'),
(10, 10, '2017-11-15', 'Directeur'),
-- Vétos et Soigneurs affectés
(11, 1, '2015-05-20', 'Vétérinaire'), -- Pierre à Paris
(12, 1, '2020-09-01', 'Soigneur'),    -- Sarah à Paris
(13, 2, '2016-02-15', 'Vétérinaire'), -- David à Lyon
(14, 2, '2021-01-10', 'Soigneur'),    -- Julie à Lyon
(15, 3, '2019-11-20', 'Soigneur'),    -- Paul à Marseille
(16, 4, '2017-04-05', 'Vétérinaire'), -- Anna à Bordeaux
(17, 5, '2022-06-15', 'Soigneur'),    -- Leo à Toulouse
(18, 6, '2019-03-01', 'Soigneur'),    -- Eva à Nantes
(19, 7, '2014-08-20', 'Vétérinaire'), -- Nathan à Strasbourg
(20, 8, '2023-01-05', 'Soigneur'),    -- Zoe à Lille
(21, 9, '2018-12-10', 'Soigneur'),    -- Gabin à Montpellier
(22, 10, '2016-09-25', 'Vétérinaire'),-- Lola à Rennes
(23, 1, '2017-05-15', 'Soigneur'),    -- Arthur à Paris (Renfort)
(24, 2, '2020-11-01', 'Soigneur'),    -- Romane à Lyon (Renfort)
(25, 3, '2023-08-20', 'Soigneur');    -- Jules à Marseille (Renfort)

---
--- 10. DONNESOIN (Historique médical)
---
INSERT INTO DonneSoin (idSoin, idEmploye, idAnimal, dateSoin, dateProchainRappel) VALUES
-- Vaccins (Avec rappels)
(1, 11, 1, '2023-01-12', '2024-01-12'), -- Pierre vaccine Rex
(1, 13, 2, '2023-02-17', '2024-02-17'), -- David vaccine Bella
(1, 11, 3, '2023-03-22', '2024-03-22'),
(1, 16, 4, '2023-04-27', '2024-04-27'),
(1, 11, 16, '2023-01-14', '2024-01-14'), -- Chat Simba
(1, 13, 17, '2023-02-20', '2024-02-20'),

-- Stérilisations (Pas de rappel)
(3, 11, 1, '2023-01-20', NULL),
(3, 13, 16, '2023-01-25', NULL),
(3, 16, 4, '2023-05-01', NULL),

-- Soins divers
(2, 12, 1, '2023-01-15', '2023-04-15'), -- Vermifuge Rex
(2, 14, 2, '2023-02-18', '2023-05-18'), -- Vermifuge Bella
(4, 11, 1, '2023-01-11', NULL), -- Puce Rex
(5, 11, 4, '2023-05-10', NULL), -- Chirurgie Husky (En soins)
(6, 13, 19, '2023-05-01', '2024-05-01'), -- Détartrage Mimi
(8, 12, 5, '2023-06-15', NULL), -- Rééducation Max
(9, 16, 26, '2024-01-02', NULL), -- Antibio Oreo
(10, 19, 7, '2022-11-05', NULL),-- Bilan sanguin Charlie (Décédé)

(1, 11, 20, '2025-11-01', '2026-11-01'), -- Pierre vaccine Balto
(1, 13, 21, '2025-11-05', '2026-11-05'), -- David vaccine Croc-Blanc
(1, 16, 22, '2025-11-15', '2026-11-15'), -- Anna vaccine Belle
(1, 19, 23, '2025-11-20', '2026-11-20'), -- Nathan vaccine Sebastien
(1, 22, 24, '2025-12-01', '2026-12-01'), -- Lola vaccine Froufrou
(1, 11, 25, '2025-12-05', '2026-12-05'),
(1, 13, 27, '2025-12-10', '2026-12-10'),
(1, 16, 28, '2025-10-15', '2026-10-15'),
(1, 19, 29, '2025-10-25', '2026-10-25'),
(1, 22, 30, '2025-12-12', '2026-12-12'),

-- 2. VERMIFUGES (Rappels début 2026)
(2, 12, 31, '2025-11-10', '2026-02-10'), -- Sarah vermifuge Odie
(2, 14, 32, '2025-11-12', '2026-02-12'), -- Julie vermifuge Satanas
(2, 15, 33, '2025-11-25', '2026-02-25'), -- Paul vermifuge Diabolo
(2, 17, 34, '2025-12-01', '2026-03-01'), -- Leo vermifuge Scoubidou
(2, 18, 35, '2025-12-05', '2026-03-05'), -- Eva vermifuge Volt
(2, 20, 36, '2025-12-08', '2026-03-08'),
(2, 21, 37, '2025-10-30', '2026-01-30'),
(2, 23, 38, '2025-11-20', '2026-02-20'),
(2, 24, 39, '2025-12-11', '2026-03-11'),
(2, 25, 40, '2025-12-13', '2026-03-13'),

-- 3. SOINS PONCTUELS (Antibiotiques, Plaies - Pas de rappel)
(9, 11, 41, '2025-11-05', NULL), -- Antibio pour Pepper
(9, 13, 42, '2025-11-15', NULL),
(9, 16, 43, '2025-12-02', NULL),
(9, 19, 44, '2025-12-09', NULL),
(9, 22, 45, '2025-12-14', NULL), -- Soin très récent
(7, 12, 46, '2025-11-20', NULL), -- Coupe griffes
(7, 14, 47, '2025-11-25', NULL),
(7, 15, 48, '2025-12-05', NULL),
(7, 17, 49, '2025-12-10', NULL),
(7, 18, 50, '2025-12-12', NULL),

-- 4. CHIRURGIES & STÉRILISATIONS (Faits récemment)
(5, 11, 51, '2025-10-01', NULL), -- Chirurgie Minette
(5, 13, 52, '2025-11-01', NULL),
(3, 16, 53, '2025-11-15', NULL), -- Stérilisation Salem
(3, 19, 54, '2025-12-01', NULL),
(3, 22, 55, '2025-12-08', NULL),

-- 5. BILANS DE SANTÉ (Annuels)
(10, 11, 56, '2025-11-01', '2026-11-01'), -- Bilan Mimi
(10, 13, 57, '2025-11-10', '2026-11-10'),
(10, 16, 58, '2025-12-01', '2026-12-01'),
(10, 19, 59, '2025-12-05', '2026-12-05'),
(10, 22, 60, '2025-09-15', '2026-09-15'),

-- 6. DÉTARTRAGES & RÉÉDUCATION
(6, 11, 61, '2025-10-20', '2026-10-20'), -- Détartrage O'Malley
(6, 13, 62, '2025-11-30', '2026-11-30'),
(8, 12, 63, '2025-11-10', NULL), -- Rééducation Figaro
(8, 14, 63, '2025-11-17', NULL), -- Séance suivante
(8, 12, 63, '2025-11-24', NULL),
(8, 14, 63, '2025-12-01', NULL),
(8, 12, 63, '2025-12-08', NULL),

-- 7. QUELQUES RAPPELS URGENTS (Dates passées ou très proches pour tester les alertes)
(2, 20, 64, '2025-06-01', '2025-09-01'), -- Retard Vermifuge Gédéon
(1, 16, 65, '2024-12-10', '2025-12-10'), -- Rappel vaccin imminent Cheshire
(1, 11, 66, '2024-12-15', '2025-12-15'); -- Rappel vaccin imminent Azrael