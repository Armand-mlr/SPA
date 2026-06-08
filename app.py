from flask import Flask, render_template, request, redirect, url_for, session, flash
import db
from datetime import date
import psycopg2.extras 
import math, json
import static.requetesSQL as requetes
from werkzeug.security import check_password_hash

app = Flask(__name__)
app.secret_key = 'Xy9#mK2$pL5@nR8&qS3*wT7!vU4^zV1%aB6(cD9)eF0'

# --- FONCTIONS UTILITAIRES ---
def verifier_securite_hash(cur):
    sec_login = request.form.get('security_login')
    sec_pass = request.form.get('security_password')
    cur.execute("SELECT idEmploye, motdepasse FROM Employe WHERE login = %s", (sec_login,))
    auth_user = cur.fetchone()
    if auth_user and check_password_hash(auth_user['motdepasse'], sec_pass):
        return auth_user
    return None

def curseur(conn):
    return conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

# --- ROUTES ---

@app.route("/")
def home():
    query = request.args.get('query', '').strip() 
    page = request.args.get('page', 1, type=int)
    limit = 8
    offset = (page - 1) * limit
    
    conn = db.connect() 
    refuges = []
    total_pages = 1
    map_data_json = "[]"
    
    if conn:
        try:
            cur = curseur(conn)
            if query:
                search_term = f"%{query}%"
                cur.execute(requetes.requetes["sql_countH"], (search_term, search_term, search_term))
            else:
                cur.execute("SELECT COUNT(*) FROM Refuge")
            
            result_count = cur.fetchone()
            if result_count:
                total_count = list(result_count.values())[0]
            else:
                total_count = 0
            
            total_pages = math.ceil(total_count / limit)
            
            if query:
                cur.execute(requetes.requetes["sql_data1H"], (search_term, search_term, search_term, limit, offset))
            else:
                cur.execute(requetes.requetes["sql_data2H"], (limit, offset))
            refuges = cur.fetchall()

            map_data = []
            for r in refuges:
                if r.get('lat') is not None and r.get('lon') is not None:
                    map_data.append({
                        'id': r['idrefuge'],
                        'nom': r['nom'],
                        'ville': r['ville'],
                        'lat': float(r['lat']),
                        'lon': float(r['lon'])
                    })
            map_data_json = json.dumps(map_data)
            cur.close()
            conn.close()
        except Exception as e:
            print(f"Erreur SQL HOME : {e}")
            refuges = []
    
    return render_template("home.html", 
                           refuges=refuges, 
                           page=page, 
                           total_pages=total_pages, 
                           query=query, 
                           map_data=map_data_json)

@app.route("/refuge/<int:id_refuge>")
def refuge_detail(id_refuge):
    conn = db.connect()
    refuge = None
    animaux = []
    
    # Options par défaut
    liste_options = {'especes': [], 'races': [], 'sexes': []}
    
    page = request.args.get('page', 1, type=int)
    limit = 8 
    offset = (page - 1) * limit

    # On récupère les filtres actuels
    f_espece = request.args.get('espece', '')
    f_race = request.args.get('race', '')
    f_sexe = request.args.get('sexe', '')
    f_age_min = request.args.get('age_min', type=int)
    f_age_max = request.args.get('age_max', type=int)

    if conn:
        try:
            cur = curseur(conn)
            
            cur.execute("SELECT * FROM Refuge WHERE idRefuge = %s", (id_refuge,))
            refuge = cur.fetchone()
            
            if refuge:

        
                cur.execute(requetes.requetes["sql_especes_refuge"], (id_refuge,))
                raw_esp = cur.fetchall()
                liste_options['especes'] = [r['espece'] for r in raw_esp]

           
                sql_races = requetes.requetes["base_races_refuge"]
                params_races = [id_refuge]

                if f_espece:
                    sql_races += " AND A.espece = %s"
                    params_races.append(f_espece)
                
                cur.execute(requetes.requetes["sql_get_filters_options"], (id_refuge,))
                raw_races = cur.fetchall()
                liste_options['races_data'] = [{'race': r['race'], 'espece': r['espece']} 
                                            for r in raw_races if r['race']]

                base_sql = requetes.requetes["base_query_animaux"]
                params = [id_refuge]

                if f_espece:
                    base_sql += " AND A.espece = %s"
                    params.append(f_espece)
                if f_race:
                    base_sql += " AND A.race = %s"
                    params.append(f_race)
                if f_sexe:
                    base_sql += " AND A.sexe = %s"
                    params.append(f_sexe)
                if f_age_min is not None:
                    base_sql += " AND A.age >= %s"
                    params.append(f_age_min)
                if f_age_max is not None:
                    base_sql += " AND A.age <= %s"
                    params.append(f_age_max)
                
                
                final_sql = f"SELECT A.* {base_sql} ORDER BY A.nom LIMIT %s OFFSET %s"
                params.extend([limit, offset])
                
                cur.execute(final_sql, tuple(params))
                animaux = cur.fetchall()

            cur.close()
            conn.close()

        except Exception as e:
            print(f"ERREUR REFUGE DETAIL : {e}")

    if not refuge:
        return redirect(url_for('home'))

    return render_template("refuge_detail.html", 
                           refuge=refuge, 
                           animaux=animaux, 
                           options=liste_options, 
                           filters=request.args,
                           page=page,
                           total_pages=1)


@app.route("/login", methods=["GET", "POST"])
def login():
    error = None
    if request.method == "POST":
        username_form = request.form['login']
        password_form = request.form['password']
        
        conn = db.connect()
        if conn:
            cur = curseur(conn)
            cur.execute("SELECT * FROM Employe WHERE login = %s", (username_form,))
            user = cur.fetchone()
            cur.close()
            conn.close()
            
            if user and check_password_hash(user['motdepasse'], password_form):
                session['user_id'] = user['idemploye']
                session['prenom'] = user['prenom']
                session['nom'] = user['nom']
                session['logged_in'] = True
                return redirect(url_for('dashboard'))
            else:
                error = "Identifiant ou mot de passe incorrect."
        else:
            error = "Erreur de connexion BDD."
    return render_template("login.html", error=error)

@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for('home'))

@app.route("/dashboard")
def dashboard():
    if not session.get('logged_in'):
        return redirect(url_for('login'))
    
    id_employe = session['user_id']
    
    # --- FILTRES ---
    scope = request.args.get('scope', 'local') # 'local' ou 'global'
    care_filter = request.args.get('care_filter', 'vaccins') # 'vaccins' ou 'all'
    
    conn = db.connect() 
    
    mon_refuge = None
    collegues = []
    alertes = []
    tous_les_refuges = []
    top_transfers = []
    
    if conn:
        try:
            cur = curseur(conn) # Utilise ta fonction curseur(conn)
            
            # 1. Mon Refuge & Collègues
            cur.execute(requetes.requetes["sql_refugeD"], (id_employe,))
            mon_refuge = cur.fetchone()
            
            id_refuge = None
            if mon_refuge:
                id_refuge = mon_refuge['idrefuge']
                cur.execute(requetes.requetes["sql_colleguesD"], (id_refuge, id_employe))
                collegues = cur.fetchall()
            
            # 2. Alertes Vétérinaires (CONSTRUCTION DYNAMIQUE)
            # On veut les rappels futurs OU passés non traités (logique de suivi)
            # Ici on prend simple : dateProchainRappel existe
            
            sql_alertes = """
                SELECT DS.dateProchainRappel, S.typeSoin, A.nom as nomAnimal, A.espece, 
                       R.nom as nom_refuge, R.idRefuge
                FROM DonneSoin DS
                JOIN Soin S ON DS.idSoin = S.idSoin
                JOIN Animal A ON DS.idAnimal = A.id
                JOIN Heberge H ON A.id = H.idAnimal
                JOIN Refuge R ON H.idRefuge = R.idRefuge
                WHERE DS.dateProchainRappel IS NOT NULL
                AND H.dateDepart IS NULL  -- Animal toujours présent
            """
            params = []

            # Filtre Scope (Local vs Global)
            if scope == 'local':
                if id_refuge:
                    sql_alertes += " AND H.idRefuge = %s"
                    params.append(id_refuge)
                else:
                    # Cas rare : Admin sans refuge qui demande vue locale -> Pas de résultats
                    sql_alertes += " AND 1=0" 

            # Filtre Type de Soin (Vaccins vs Tout)
            if care_filter == 'vaccins':
                sql_alertes += " AND S.typeSoin = 'Vaccination'"
            
            # Tri par urgence (dates passées en premier)
            sql_alertes += " ORDER BY DS.dateProchainRappel ASC"
            
            cur.execute(sql_alertes, tuple(params))
            alertes = cur.fetchall()
            
            # 3. Liste Complète des Refuges
            cur.execute(requetes.requetes["sql_dataD"])
            tous_les_refuges = cur.fetchall()

            # 4. Top 5 Transferts
            cur.execute("SELECT * FROM V_Top5_Refuges_Transferts_Sortants")
            top_transfers = cur.fetchall()
            
            cur.close()
            conn.close()
        except Exception as e:
            print(f"Erreur SQL Dashboard : {e}")

    return render_template("dashboard.html", 
                           user=session, 
                           refuge=mon_refuge, 
                           collegues=collegues, 
                           alertes=alertes,
                           all_refuges=tous_les_refuges,
                           top_transfers=top_transfers,
                           scope=scope, 
                           care_filter=care_filter, # On passe le filtre au template
                           now=date.today())

@app.route("/admin/refuge/<int:id_refuge>")
def admin_refuge_detail(id_refuge):
    if not session.get('logged_in'):
        return redirect(url_for('login'))

    page_animaux = request.args.get('page_animaux', 1, type=int)
    sort_by = request.args.get('sort_by', 'nom')
    order = request.args.get('order', 'asc')
    limit_animaux = 8
    offset_animaux = (page_animaux - 1) * limit_animaux
    limit_alertes = 8

    conn = db.connect()
    refuge = None
    alertes = []
    animaux = []
    total_pages_animaux = 1
    
    valid_sorts = {
        'nom': 'sub.nom',
        'espece': 'sub.espece',
        'race': 'sub.race',
        'age': 'sub.age',
        'statut': 'sub.statut',
        'datearrive': 'sub.daterecueil'
    }
    col_sql = valid_sorts.get(sort_by, 'sub.nom')
    dir_sql = "DESC" if order == 'desc' else "ASC"

    if conn:
        try:
            cur = curseur(conn)
            cur.execute("SELECT * FROM Refuge WHERE idRefuge = %s", (id_refuge,))
            refuge = cur.fetchone()
            
            base_vaccins = requetes.requetes["sql_vaccins_localD"].strip().rstrip(';')
            cur.execute(f"{base_vaccins} LIMIT {limit_alertes}", (id_refuge,))
            alertes = cur.fetchall()
            
            base_animaux = requetes.requetes["sql_animalAR"].strip().rstrip(';')
            
            cur.execute(f"SELECT COUNT(*) as total FROM ({base_animaux}) AS sub", (id_refuge,))
            total_count = cur.fetchone()['total']
            total_pages_animaux = math.ceil(total_count / limit_animaux)
            
            sql_final = f"""
                SELECT * FROM ({base_animaux}) AS sub
                ORDER BY {col_sql} {dir_sql}
                LIMIT {limit_animaux} OFFSET {offset_animaux}
            """
            cur.execute(sql_final, (id_refuge,))
            animaux = cur.fetchall()
            
            cur.close()
            conn.close()
        except Exception as e:
            print(f"Erreur SQL Admin Refuge : {e}")

    return render_template("admin_refuge_detail.html", 
                           user=session, 
                           refuge=refuge, 
                           alertes=alertes, 
                           animaux=animaux, 
                           now=date.today(),
                           page_animaux=page_animaux,
                           total_pages_animaux=total_pages_animaux,
                           sort_by=sort_by,
                           order=order)

@app.route("/pensionnaires")
def pensionnaires():
    if not session.get('logged_in'):
        return redirect(url_for('login'))
    
    id_employe = session['user_id']
    page = request.args.get('page', 1, type=int)
    filtre = request.args.get('filtre', 'tous')
    sort_by = request.args.get('sort_by', 'defaut') 
    order = request.args.get('order', 'asc') 
    limit = 10
    offset = (page - 1) * limit
    
    conn = db.connect()
    pensionnaires_list = []
    total_pages = 1
    
    if conn:
        try:
            cur = curseur(conn)
            cur.execute("SELECT idRefuge FROM EstAffecte WHERE idEmploye = %s ORDER BY dateAffectation DESC LIMIT 1", (id_employe,))
            aff = cur.fetchone()
            
            if aff:
                id_refuge = aff['idrefuge']
                base_query = requetes.requetes["base_queryP"]
                params = [id_refuge]
                
                if filtre == 'presents':
                    base_query += " AND H.dateDepart IS NULL"
     
                cur.execute(f"SELECT COUNT(*) as total {base_query}", tuple(params))
                total_count = cur.fetchone()['total']
                total_pages = math.ceil(total_count / limit)
                
                sort_mapping = {
                    'nom': 'A.nom', 'espece': 'A.espece', 'race': 'A.race',
                    'statut': 'A.statut', 'date_arrive': 'H.dateArrive', 'date_depart': 'H.dateDepart'
                }
                order_clause = "ORDER BY CASE WHEN H.dateDepart IS NULL THEN 0 ELSE 1 END ASC, H.dateArrive DESC"
                if sort_by in sort_mapping:
                    col_sql = sort_mapping[sort_by]
                    direction = "DESC" if order == 'desc' else "ASC"
                    order_clause = f"ORDER BY {col_sql} {direction}"

                sql_data = f"""
                    SELECT A.*, H.dateArrive, H.dateDepart
                    {base_query}
                    {order_clause}
                    LIMIT %s OFFSET %s
                """
                params.extend([limit, offset])
                cur.execute(sql_data, tuple(params))
                pensionnaires_list = cur.fetchall()
            
            cur.close()
            conn.close()
        except Exception as e:
            print(f"Erreur SQL Pensionnaires : {e}")

    return render_template("pensionnaires.html", 
                           user=session, 
                           animaux=pensionnaires_list,
                           page=page,
                           total_pages=total_pages,
                           filtre=filtre,
                           sort_by=sort_by, 
                           order=order)

@app.route("/staff/animal/<int:id_animal>")
def staff_animal_detail(id_animal):
    if not session.get('logged_in'):
        return redirect(url_for('login'))
        
    conn = db.connect()
    animal = None
    historique_soins = []
    
    if conn:
        cur = curseur(conn)
        cur.execute(requetes.requetes["sql_animal2S"], (id_animal,))
        animal = cur.fetchone()
        cur.execute(requetes.requetes["sql_historique_soinsS"], (id_animal,))
        historique_soins = cur.fetchall()
        cur.close()
        conn.close()

    return render_template("staff_animal_detail.html", user=session, animal=animal, soins=historique_soins)

@app.route("/nouveau_pensionnaire", methods=["GET", "POST"])
def nouveau_pensionnaire():
    if not session.get('logged_in'):
        return redirect(url_for('login'))
    
    conn = db.connect()
    
    # --- PRÉ-CHARGEMENT DES DONNÉES (Pour qu'elles soient là même en cas d'erreur) ---
    fourrieres = []
    liste_options = {'especes': []}
    
    if conn:
        try:
            cur = curseur(conn)
            # 1. Fourrières
            cur.execute("SELECT * FROM Fourriere ORDER BY nomFourriere")
            fourrieres = cur.fetchall()
            
            # 2. Espèces (On suppose que tu as une requête ou une liste fixe)
            # Si tu n'as pas la requête 'sql_all_especes', tu peux mettre une liste en dur pour tester :
            # liste_options['especes'] = ['Chien', 'Chat', 'Lapin', 'Oiseau', 'Autre']
            
            # Si tu utilises ta requête SQL dynamique :
            cur.execute(requetes.requetes["sql_all_especes"]) 
            toutes_especes = cur.fetchall()
            liste_options['especes'] = [r['espece'] for r in toutes_especes]
            
        except Exception as e:
            print(f"Erreur chargement données : {e}")

    # --- TRAITEMENT DU FORMULAIRE (POST) ---
    if request.method == "POST":
        try:
            cur = curseur(conn)
            
            # 1. SÉCURITÉ
            auth_user = verifier_securite_hash(cur) # Ta fonction helper
            
            if not auth_user:
                flash("Échec de sécurité : Identifiants incorrects.", "error")
                # IMPORTANT : On renvoie le template avec les données pré-chargées !
                return render_template("nouveau_pensionnaire.html", 
                                       user=session, 
                                       fourrieres=fourrieres, # On renvoie les fourrières
                                       today=date.today(),
                                       liste_options=liste_options, # On renvoie les espèces
                                       filters=request.form)

            # 2. ENREGISTREMENT
            cur.execute("""
                SELECT idRefuge FROM EstAffecte 
                WHERE idEmploye = %s 
                ORDER BY dateAffectation DESC LIMIT 1
            """, (session['user_id'],))
            affectation = cur.fetchone()
            
            if not affectation:
                flash("Erreur : Vous n'êtes affecté à aucun refuge. Impossible d'ajouter un animal.", "error")
                return redirect(url_for('nouveau_pensionnaire'))
            
            id_refuge = affectation['idrefuge']
            nom = request.form['nom']
            espece = request.form['espece']
            race = request.form.get('race') 
            sexe = request.form['sexe']
            age = request.form.get('age')
            daterecueil = request.form['daterecueil']
            signe = request.form.get('signe_distinctif')
            id_fourriere = request.form.get('id_fourriere')
            if id_fourriere == "": id_fourriere = None 
            
            sql_animal = requetes.requetes["sql_animalNP"]
            cur.execute(sql_animal, (nom, espece, race, age, sexe, signe, daterecueil, id_fourriere))
            new_id_animal = cur.fetchone()['id']
            
            sql_heberge = requetes.requetes["sql_hebergeNP"] 
            cur.execute(sql_heberge, (new_id_animal, id_refuge))
            
            conn.commit()
            flash(f"Succès ! L'animal a été ajouté.", "success")
            return redirect(url_for('pensionnaires'))
            
        except psycopg2.IntegrityError as e:
            conn.rollback()
            if "animal_daterecueil_check" in str(e): 
                flash("Erreur : La date de recueil ne peut pas être dans le futur.", "error")
            else: 
                flash(f"Erreur SQL : {e}", "error")
            
            # En cas d'erreur SQL aussi, on réaffiche la page avec les listes
            return render_template("nouveau_pensionnaire.html", user=session, fourrieres=fourrieres, today=date.today(), liste_options=liste_options, filters=request.form)

        except Exception as e:
            conn.rollback()
            flash(f"Erreur technique : {e}", "error")
            return redirect(url_for('nouveau_pensionnaire'))
            
        finally:
            cur.close()
            conn.close()

    # --- AFFICHAGE SIMPLE (GET) ---
    return render_template("nouveau_pensionnaire.html", 
                           user=session, 
                           fourrieres=fourrieres, 
                           today=date.today(),
                           liste_options=liste_options,
                           filters={})

@app.route("/nouveau_soin", methods=["GET", "POST"])
def nouveau_soin():
    if not session.get('logged_in'): return redirect(url_for('login'))
    conn = db.connect()
    
    if request.method == "POST":
        try:
            cur = curseur(conn)
            auth_user = verifier_securite_hash(cur)
            if not auth_user:
                flash("Identifiants incorrects.", "error")
                return redirect(url_for('nouveau_soin'))
            
            cur.execute("""
                INSERT INTO DonneSoin (idSoin, idEmploye, idAnimal, dateSoin, dateProchainRappel)
                VALUES (%s, %s, %s, %s, %s)
            """, (request.form['id_soin'], auth_user['idemploye'], request.form['id_animal'], request.form['date_soin'], request.form.get('date_rappel') or None))
            conn.commit()
            flash("Soin enregistré.", "success")
            return redirect(url_for('staff_animal_detail', id_animal=request.form['id_animal']))
        except Exception as e:
            conn.rollback()
            flash(f"Erreur : {e}", "error")
            return redirect(url_for('nouveau_soin'))
        finally:
            cur.close()
            conn.close()

    animaux = []
    types_soins = []
    preselected_animal = request.args.get('id_animal', type=int)
    if conn:
        try:
            cur = curseur(conn)
            cur.execute("SELECT idRefuge FROM EstAffecte WHERE idEmploye = %s ORDER BY dateAffectation DESC LIMIT 1", (session['user_id'],))
            aff = cur.fetchone()
            if aff:
                cur.execute("""
                    SELECT A.id, A.nom, A.espece 
                    FROM Animal A JOIN Heberge H ON A.id = H.idAnimal
                    WHERE H.idRefuge = %s AND H.dateDepart IS NULL ORDER BY A.nom
                """, (aff['idrefuge'],))
                animaux = cur.fetchall()
            cur.execute("SELECT * FROM Soin ORDER BY typeSoin")
            types_soins = cur.fetchall()
            cur.close()
            conn.close()
        except Exception: pass
    return render_template("nouveau_soin.html", user=session, animaux=animaux, soins=types_soins, selected_id=preselected_animal, today=date.today())

@app.route("/adoption", methods=["GET", "POST"])
def adoption():
    if not session.get('logged_in'): return redirect(url_for('login'))
    conn = db.connect()
    
    if request.method == "POST":
        try:
            cur = curseur(conn)
            auth_user = verifier_securite_hash(cur)
            if not auth_user:
                flash("Identifiants incorrects.", "error")
                return redirect(url_for('adoption'))

            id_animal = request.form['id_animal']
            tel_p = request.form['tel_particulier']
            date_adoption = request.form['date_adoption']

            cur.execute("SELECT idParticulier FROM Particulier WHERE telephoneParticulier = %s", (tel_p,))
            part = cur.fetchone()
            if part: id_part = part['idparticulier']
            else:
                cur.execute("INSERT INTO Particulier (nom, prenom, adresse, telephoneParticulier) VALUES (%s, %s, %s, %s) RETURNING idParticulier", 
                            (request.form['nom_particulier'], request.form['prenom_particulier'], request.form['adresse_particulier'], tel_p))
                id_part = cur.fetchone()['idparticulier']

            cur.execute("UPDATE Animal SET statut = 'Adopté' WHERE id = %s", (id_animal,))
            cur.execute("UPDATE Heberge SET dateDepart = %s WHERE idAnimal = %s AND dateDepart IS NULL", (date_adoption, id_animal))
            cur.execute("INSERT INTO Adoption (idAnimal, idParticulier, dateAdoption) VALUES (%s, %s, %s)", (id_animal, id_part, date_adoption))
            conn.commit()
            flash("Adoption enregistrée !", "success")
            return redirect(url_for('pensionnaires'))
        except Exception as e:
            conn.rollback()
            flash(f"Erreur : {e}", "error")
            return redirect(url_for('adoption'))
        finally:
            cur.close()
            conn.close()

    animaux_dispo = []
    if conn:
        cur = curseur(conn)
        cur.execute("SELECT idRefuge FROM EstAffecte WHERE idEmploye = %s ORDER BY dateAffectation DESC LIMIT 1", (session['user_id'],))
        aff = cur.fetchone()
        if aff:
            cur.execute("""
                SELECT A.id, A.nom, A.espece, A.race 
                FROM Animal A JOIN Heberge H ON A.id = H.idAnimal
                WHERE H.idRefuge = %s AND H.dateDepart IS NULL AND A.statut = 'Disponible' ORDER BY A.nom
            """, (aff['idrefuge'],))
            animaux_dispo = cur.fetchall()
        cur.close()
        conn.close()
    return render_template("adoption.html", user=session, animaux=animaux_dispo, today=date.today())

@app.route("/transfert", methods=["GET", "POST"])
def transfert():
    if not session.get('logged_in'): return redirect(url_for('login'))
    conn = db.connect()
    
    if request.method == "POST":
        try:
            cur = curseur(conn)
            auth_user = verifier_securite_hash(cur)
            if not auth_user:
                flash("Identifiants incorrects.", "error")
                return redirect(url_for('transfert'))

            id_animal = request.form['id_animal']
            date_tr = request.form['date_transfert']
            cur.execute("UPDATE Heberge SET dateDepart = %s WHERE idAnimal = %s AND dateDepart IS NULL", (date_tr, id_animal))
            cur.execute("INSERT INTO Heberge (idAnimal, idRefuge, dateArrive, dateDepart) VALUES (%s, %s, %s, NULL)", 
                        (id_animal, request.form['id_destination'], date_tr))
            conn.commit()
            flash("Transfert validé !", "success")
            return redirect(url_for('pensionnaires'))
        except Exception as e:
            conn.rollback()
            flash(f"Erreur : {e}", "error")
            return redirect(url_for('transfert'))
        finally:
            cur.close()
            conn.close()

    animaux_locaux = []
    autres_refuges = []
    if conn:
        cur = curseur(conn)
        cur.execute("SELECT idRefuge FROM EstAffecte WHERE idEmploye = %s ORDER BY dateAffectation DESC LIMIT 1", (session['user_id'],))
        aff = cur.fetchone()
        if aff:
            mon_id = aff['idrefuge']
            cur.execute("""
                SELECT A.id, A.nom, A.espece, A.race FROM Animal A JOIN Heberge H ON A.id = H.idAnimal
                WHERE H.idRefuge = %s AND H.dateDepart IS NULL AND A.statut = 'Disponible' ORDER BY A.nom
            """, (mon_id,))
            animaux_locaux = cur.fetchall()
            cur.execute("SELECT idRefuge, nom, ville, codePostal FROM Refuge WHERE idRefuge != %s ORDER BY ville, nom", (mon_id,))
            autres_refuges = cur.fetchall()
        cur.close()
        conn.close()
    return render_template("transfert.html", user=session, animaux=animaux_locaux, refuges=autres_refuges, today=date.today())

if __name__ == '__main__':
    print("Serveur lancé sur http://127.0.0.1:5005")
    app.run(debug=True, port=5005)