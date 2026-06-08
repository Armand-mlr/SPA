# 🐾 ProjetSPA — Gestion des refuges de la SPA

Application web de coordination des refuges de la **SPA** (Société Protectrice des Animaux) : suivi des animaux depuis leur arrivée jusqu'à leur adoption ou leur décès, historique des transferts entre refuges, gestion des soins vétérinaires et des adoptions.

Projet réalisé dans le cadre du cours de **Bases de données** (L2 Maths-Info, Université Gustave Eiffel).

![Python](https://img.shields.io/badge/Python-3.10+-3776AB?logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-000000?logo=flask&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18-4169E1?logo=postgresql&logoColor=white)
![Leaflet](https://img.shields.io/badge/Leaflet-OpenStreetMap-199900?logo=leaflet&logoColor=white)

> ℹ️ **Note d'archivage.** Ce dépôt a été créé *a posteriori*, après la finalisation et le rendu du projet : à l'époque, le code n'était pas versionné sur GitHub. Il s'agit donc d'une mise en ligne de la version finale rendue, à titre d'archive et de portfolio. Le code n'est pas hébergé en ligne — voir la section [Installation & lancement](#-installation--lancement) pour le faire tourner en local.

---

## 📋 Sommaire

- [Aperçu](#-aperçu)
- [Fonctionnalités](#-fonctionnalités)
- [Stack technique](#-stack-technique)
- [Structure du projet](#-structure-du-projet)
- [Prérequis](#-prérequis)
- [Installation & lancement](#-installation--lancement)
- [Comptes de démonstration](#-comptes-de-démonstration)
- [Modèle de données](#-modèle-de-données)
- [Points techniques notables](#-points-techniques-notables)
- [Pistes d'amélioration](#-pistes-damélioration)
- [Auteurs](#-auteurs)

---

## 🔎 Aperçu

Le site répond à **deux cadres d'utilisation** :

- **Partie publique** — Le grand public consulte la carte des refuges partenaires et la liste des animaux disponibles à l'adoption.
- **Partie administration (espace staff)** — Les employés, après authentification, gèrent les pensionnaires, les soins, les transferts et les adoptions, et suivent les alertes de rappels de vaccins.

L'entité centrale du modèle est l'**Animal**, dont on conserve tout l'historique : son refuge d'origine (fourrière), tous les refuges par lesquels il est passé (table `Heberge` datée), ses soins (association ternaire Animal × Employé × Type de soin) et son éventuelle adoption.

---

## ✨ Fonctionnalités

### Partie publique
- **Carte interactive** (Leaflet + OpenStreetMap) affichant tous les refuges, avec mise en surbrillance au clic sur un marqueur.
- **Recherche** par ville ou code postal, avec correspondance partielle (ex. `75` retourne tous les refuges parisiens).
- **Consultation d'un refuge** : liste paginée des animaux présents, avec filtres par espèce, race, sexe et tranche d'âge.

### Espace staff (authentifié)
- **Tableau de bord** : refuge de l'employé, collègues, alertes vétérinaires (rappels de vaccins), liste de tous les refuges et **Top 5 des refuges les plus actifs en transferts sortants**.
- **Gestion des pensionnaires** : liste paginée et triable, fiche détaillée d'un animal avec son historique de soins.
- **Actions sensibles** (protégées, voir ci-dessous) :
  - **Ajout d'un pensionnaire** (création automatique de l'hébergement dans le refuge de l'employé) ;
  - **Saisie d'un soin** avec date de rappel ;
  - **Transfert** d'un animal vers un autre refuge (clôture automatique de l'hébergement courant + création du nouvel hébergement) ;
  - **Adoption** (transaction sur 3 tables : `Animal`, `Heberge`, `Adoption`).
- **Double authentification** : toute action critique (ajout, soin, transfert, adoption) exige de **ressaisir login + mot de passe** dans une fenêtre modale avant validation.

---

## 🛠 Stack technique

| Couche | Technologie |
|---|---|
| Backend | Python 3 · **Flask** |
| Base de données | **PostgreSQL** (dump généré avec PostgreSQL 18) |
| Connecteur BDD | **psycopg2** |
| Sécurité mots de passe | `werkzeug.security` — hachage **pbkdf2:sha256** |
| Frontend | HTML5 · CSS3 · JavaScript |
| Carte | **Leaflet.js** + OpenStreetMap (sans API, gratuit) |

---

## 📁 Structure du projet

```
.
├── app.py                  # Serveur Flask principal — point d'entrée
├── db.py                   # Connexion psycopg2 à PostgreSQL (à configurer)
├── dump.sql                # Dump complet de la base : structure + données + vues
├── spa.sql                 # Script de création annoté (schéma, contraintes CHECK, données)
├── generateSQl.py          # Utilitaire one-shot de hachage des mots de passe employés
├── templates/              # Templates Jinja2 (pages HTML)
│   ├── home.html               # Accueil + carte + recherche
│   ├── refuge_detail.html      # Détail public d'un refuge
│   ├── login.html              # Connexion staff
│   ├── dashboard.html          # Tableau de bord
│   ├── admin_refuge_detail.html# Détail d'un refuge (vue staff)
│   ├── pensionnaires.html      # Liste des pensionnaires
│   ├── staff_animal_detail.html# Fiche animal + historique de soins
│   ├── nouveau_pensionnaire.html
│   ├── nouveau_soin.html
│   ├── adoption.html
│   └── transfert.html
├── static/                 # Fichiers statiques
│   ├── requetesSQL.py          # Bibliothèque des requêtes SQL (importée par app.py)
│   ├── css/ · js/ · images/    # Styles, scripts (carte), médias
│   └── ...
├── rapport.pdf             # Rapport final du projet
├── Consignes.pdf           # Sujet — consignes générales
└── SPA.pdf                 # Sujet — énoncé « Refuges de la SPA »
```

> ⚠️ Le fichier `static/requetesSQL.py` est importé via `import static.requetesSQL`. L'application doit donc **être lancée depuis la racine du projet** pour que cet import se résolve correctement.

---

## ✅ Prérequis

- **Python 3.10+**
- **PostgreSQL** installé et le service démarré (le dump a été produit avec PostgreSQL 18 ; une version récente est recommandée car le dump utilise des commandes `psql` introduites en v18).
- `pip` (et idéalement la possibilité de créer un environnement virtuel).

---

## 🚀 Installation & lancement

Rien n'étant hébergé, voici la marche à suivre pour exécuter l'application **en local**.

### 1. Cloner le dépôt

```bash
git clone https://github.com/<votre-compte>/<nom-du-repo>.git
cd <nom-du-repo>
```

### 2. Créer la base de données et l'utilisateur PostgreSQL

Connectez-vous à PostgreSQL (en tant que `postgres` par exemple) et créez un utilisateur + une base :

```sql
CREATE USER spa_user WITH PASSWORD 'votre_mot_de_passe';
CREATE DATABASE spa OWNER spa_user;
```

### 3. Importer le schéma et les données

Le dump est **complet** : il crée les tables, les vues et insère toutes les données de démonstration.

```bash
psql -U spa_user -d spa -f dump.sql
```

> 💡 Alternative : `spa.sql` contient le **script de création annoté** (types, contraintes `CHECK` détaillées et jeux de données) si vous préférez repartir du schéma source plutôt que du dump `pg_dump`.

### 4. Configurer la connexion

Ouvrez **`db.py`** et renseignez vos paramètres de connexion (le mot de passe y est masqué par `'xxxxx'` dans la version publiée) :

```python
conn = psycopg2.connect(
    dbname='spa',                 # le nom de votre base
    host='localhost',
    user='spa_user',              # votre utilisateur
    password='votre_mot_de_passe',# votre mot de passe
    port=5432,
    cursor_factory=psycopg2.extras.NamedTupleCursor
)
```

### 5. Installer les dépendances Python

```bash
# (optionnel mais recommandé) environnement virtuel
python -m venv venv
source venv/bin/activate        # Windows : venv\Scripts\activate

pip install Flask psycopg2-binary
```

> `werkzeug` (utilisé pour le hachage des mots de passe) est installé automatiquement avec Flask.
> Vous pouvez aussi figer les dépendances dans un `requirements.txt` :
> ```
> Flask
> psycopg2-binary
> ```

### 6. Lancer le serveur

```bash
python app.py
```

L'application est alors disponible sur :

```
http://127.0.0.1:5005
```

---

## 🔐 Comptes de démonstration

Les données sont **fictives** et destinées au test. Pour accéder à l'espace staff (`/login`), vous pouvez utiliser, par exemple :

| Rôle | Login | Mot de passe | Refuge |
|---|---|---|---|
| Gérant | `jdupont` | `ParisChef2025!` | Paris |
| Gérant | `cmartin` | `LyonGerant69!` | Lyon |
| Vétérinaire | `plaurent` | `Stethoscope75` | Paris |
| Soigneur | `smichel` | `Croquettes75!` | Paris |

> Ces mots de passe en clair proviennent du script utilitaire `generateSQl.py`, qui a servi **une seule fois** à hacher les mots de passe avant insertion. En base, seuls les hachages (pbkdf2:sha256) sont stockés. Pour les **actions sensibles**, la double authentification vous demandera de **ressaisir ces mêmes identifiants**.

---

## 🗄 Modèle de données

Le schéma s'articule autour de l'entité **Animal** et privilégie la **traçabilité historique**.

**10 tables** : `Employe`, `Refuge`, `Animal`, `Fourriere`, `Particulier`, `Soin`, `Heberge`, `EstAffecte`, `DonneSoin`, `Adoption`.

Points clés :

- **`Heberge`** — clé primaire triple `(idAnimal, idRefuge, dateArrive)`. La colonne `dateDepart` vaut `NULL` tant que l'animal est présent dans le refuge → c'est le pilier de l'historique des déplacements et des transferts.
- **`DonneSoin`** — association ternaire `Animal × Employé × Soin`, avec date du soin et date de prochain rappel (pour les vaccins).
- **`EstAffecte`** — un employé peut occuper plusieurs fonctions dans plusieurs refuges (`fonction`, `dateAffectation`).
- **`Employe`** — champs `login` et `motdepasse`, ce dernier stocké **haché** (jamais en clair).
- **Contraintes `CHECK`** traduisant les règles métier : statuts d'animal (`Disponible`, `Adopté`, `En Soins`, `Décédé`), sexe (`M`/`F`/`I`), `capaciteAccueil > 0`, cohérence des dates (`dateDepart > dateArrive`, `dateProchainRappel > dateSoin`, dates non futures), formats de téléphone et de code postal, etc.

**2 vues SQL** :

- `V_Animaux_A_Vacciner` — animaux ayant un rappel de vaccin planifié, triés par échéance.
- `V_Top5_Refuges_Transferts_Sortants` — Top 5 des refuges ayant réalisé le plus de transferts sortants sur les 2 dernières années (fenêtre glissante via `CURRENT_DATE - INTERVAL '2 year'`).

---

## 💡 Points techniques notables

- **Adoption transactionnelle** — opération sur 3 tables (`Animal` → statut `Adopté`, clôture de l'`Heberge` courant, insertion dans `Adoption`), avec `commit`/`rollback` pour garantir l'atomicité. Le particulier est réutilisé s'il existe déjà (recherche par téléphone) ou créé sinon.
- **Pagination & tri côté serveur** — via `LIMIT`/`OFFSET` calculés selon la page, et `ORDER BY` dynamique **sécurisé par liste blanche** de colonnes (protection contre l'injection SQL).
- **Sécurité** — hachage `pbkdf2:sha256` (`werkzeug.security`) + **double authentification** sur les routes sensibles, via la fonction `verifier_securite_hash()` appelée avant toute écriture critique.
- **Recherche & carte** — recherche large par `LIKE` sur plusieurs colonnes ; le backend sérialise en **JSON** les coordonnées GPS (`lat`, `lon`) des refuges filtrés, injectées dans Leaflet pour positionner les marqueurs dynamiquement.

---

## 🔮 Pistes d'amélioration

- Upload de photos pour les fiches animaux (stockage local ou S3).
- Gestion des stocks de nourriture et de médicaments par refuge.
- Système de rôles granulaire (Bénévole / Vétérinaire / Gérant).
- Alertes e-mail automatiques à l'approche des rappels de vaccins.
- Prise de rendez-vous en ligne (rencontre avec un animal) traitée depuis le dashboard.
- Exploitation plus poussée de la table `Adoption` pour gérer les retours/ré-adoptions sans redondance.

---

## 👥 Auteurs

Projet réalisé en binôme — **L2 Maths-Info, Université Gustave Eiffel** — Décembre 2025.

- **Armand Mulier**
- **Ramy Metahri**

**Répartition synthétique** : Armand — accueil & mini-carte, pensionnaires & fiches animaux, formulaires d'actions (ajout / soin / adoption / transfert), système de hachage ; Ramy — détail public d'un refuge, login & gestion de session, tableau de bord et ses onglets. Conception du MCD/MLD, cahier des charges et logique/esthétique du site menés en commun.
