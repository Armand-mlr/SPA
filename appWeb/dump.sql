--
-- PostgreSQL database dump
--

\restrict qOu172L3Fegny1n6nSPJfUhGgk0mFN94DMd8cYazyXJqcfNTdfNH2rWqy4zAvoX

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: adoption; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adoption (
    idadoption integer NOT NULL,
    idanimal integer NOT NULL,
    idparticulier integer,
    dateadoption date NOT NULL,
    CONSTRAINT adoption_dateadoption_check CHECK ((dateadoption <= CURRENT_DATE))
);


ALTER TABLE public.adoption OWNER TO postgres;

--
-- Name: adoption_idadoption_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adoption_idadoption_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.adoption_idadoption_seq OWNER TO postgres;

--
-- Name: adoption_idadoption_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adoption_idadoption_seq OWNED BY public.adoption.idadoption;


--
-- Name: animal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.animal (
    id integer NOT NULL,
    nom character varying(100) NOT NULL,
    espece character varying(50) NOT NULL,
    race character varying(50),
    age integer,
    sexe character(1) NOT NULL,
    signedistinctif text,
    statut character varying(50) NOT NULL,
    daterecueil date NOT NULL,
    idfourriere integer,
    CONSTRAINT animal_age_check CHECK (((age >= 0) AND (age <= 100))),
    CONSTRAINT animal_daterecueil_check CHECK ((daterecueil <= CURRENT_DATE)),
    CONSTRAINT animal_sexe_check CHECK ((sexe = ANY (ARRAY['M'::bpchar, 'F'::bpchar, 'I'::bpchar]))),
    CONSTRAINT animal_statut_check CHECK (((statut)::text = ANY ((ARRAY['Disponible'::character varying, 'Adopté'::character varying, 'En Soins'::character varying, 'Décédé'::character varying])::text[])))
);


ALTER TABLE public.animal OWNER TO postgres;

--
-- Name: animal_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.animal_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.animal_id_seq OWNER TO postgres;

--
-- Name: animal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.animal_id_seq OWNED BY public.animal.id;


--
-- Name: donnesoin; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.donnesoin (
    idsoin integer NOT NULL,
    idemploye integer NOT NULL,
    idanimal integer NOT NULL,
    datesoin date NOT NULL,
    dateprochainrappel date,
    CONSTRAINT donnesoin_check CHECK (((dateprochainrappel IS NULL) OR (dateprochainrappel > datesoin))),
    CONSTRAINT donnesoin_datesoin_check CHECK ((datesoin <= CURRENT_DATE))
);


ALTER TABLE public.donnesoin OWNER TO postgres;

--
-- Name: employe; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employe (
    idemploye integer NOT NULL,
    matricule character varying(50) NOT NULL,
    nom character varying(100) NOT NULL,
    prenom character varying(100) NOT NULL,
    adresse text,
    telephoneemploye character varying(15),
    datenaissance date NOT NULL,
    numerosecu character varying(20),
    dateembauche date NOT NULL,
    login character varying(50) NOT NULL,
    motdepasse character varying(255) NOT NULL,
    CONSTRAINT employe_dateembauche_check CHECK ((dateembauche <= CURRENT_DATE)),
    CONSTRAINT employe_datenaissance_check CHECK ((datenaissance < CURRENT_DATE)),
    CONSTRAINT employe_telephoneemploye_check CHECK (((telephoneemploye)::text ~ '^[0-9]{10,15}$'::text))
);


ALTER TABLE public.employe OWNER TO postgres;

--
-- Name: employe_idemploye_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employe_idemploye_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employe_idemploye_seq OWNER TO postgres;

--
-- Name: employe_idemploye_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employe_idemploye_seq OWNED BY public.employe.idemploye;


--
-- Name: estaffecte; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estaffecte (
    idemploye integer NOT NULL,
    idrefuge integer NOT NULL,
    dateaffectation date NOT NULL,
    fonction character varying(100) NOT NULL,
    CONSTRAINT estaffecte_dateaffectation_check CHECK ((dateaffectation <= CURRENT_DATE))
);


ALTER TABLE public.estaffecte OWNER TO postgres;

--
-- Name: fourriere; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fourriere (
    idfourriere integer NOT NULL,
    nomfourriere character varying(100) NOT NULL,
    adresse text NOT NULL,
    telephonefourriere character varying(15),
    CONSTRAINT fourriere_telephonefourriere_check CHECK (((telephonefourriere)::text ~ '^[0-9]{10,15}$'::text))
);


ALTER TABLE public.fourriere OWNER TO postgres;

--
-- Name: fourriere_idfourriere_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fourriere_idfourriere_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fourriere_idfourriere_seq OWNER TO postgres;

--
-- Name: fourriere_idfourriere_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fourriere_idfourriere_seq OWNED BY public.fourriere.idfourriere;


--
-- Name: heberge; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.heberge (
    idanimal integer NOT NULL,
    idrefuge integer NOT NULL,
    datearrive date NOT NULL,
    datedepart date,
    CONSTRAINT heberge_check CHECK (((datedepart IS NULL) OR (datedepart > datearrive)))
);


ALTER TABLE public.heberge OWNER TO postgres;

--
-- Name: particulier; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.particulier (
    idparticulier integer NOT NULL,
    nom character varying(100) NOT NULL,
    prenom character varying(100) NOT NULL,
    adresse text,
    telephoneparticulier character varying(15),
    CONSTRAINT particulier_telephoneparticulier_check CHECK (((telephoneparticulier)::text ~ '^[0-9]{10,15}$'::text))
);


ALTER TABLE public.particulier OWNER TO postgres;

--
-- Name: particulier_idparticulier_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.particulier_idparticulier_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.particulier_idparticulier_seq OWNER TO postgres;

--
-- Name: particulier_idparticulier_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.particulier_idparticulier_seq OWNED BY public.particulier.idparticulier;


--
-- Name: refuge; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.refuge (
    idrefuge integer NOT NULL,
    nom character varying(50) NOT NULL,
    ville character varying(100) NOT NULL,
    codepostal character varying(5) NOT NULL,
    telephonerefuge character varying(15),
    capaciteaccueil integer NOT NULL,
    idemploye integer,
    lat numeric(10,7),
    lon numeric(10,7),
    CONSTRAINT refuge_capaciteaccueil_check CHECK ((capaciteaccueil > 0)),
    CONSTRAINT refuge_codepostal_check CHECK (((codepostal)::text ~ '^[0-9]{5}$'::text)),
    CONSTRAINT refuge_telephonerefuge_check CHECK (((telephonerefuge)::text ~ '^[0-9]{10,15}$'::text))
);


ALTER TABLE public.refuge OWNER TO postgres;

--
-- Name: refuge_idrefuge_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.refuge_idrefuge_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.refuge_idrefuge_seq OWNER TO postgres;

--
-- Name: refuge_idrefuge_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.refuge_idrefuge_seq OWNED BY public.refuge.idrefuge;


--
-- Name: soin; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.soin (
    idsoin integer NOT NULL,
    typesoin character varying(100) NOT NULL,
    description text
);


ALTER TABLE public.soin OWNER TO postgres;

--
-- Name: soin_idsoin_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.soin_idsoin_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.soin_idsoin_seq OWNER TO postgres;

--
-- Name: soin_idsoin_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.soin_idsoin_seq OWNED BY public.soin.idsoin;


--
-- Name: v_animaux_a_vacciner; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_animaux_a_vacciner AS
 SELECT a.id AS idanimal,
    a.nom AS nomanimal,
    a.espece,
    a.race,
    a.sexe,
    s.typesoin,
    s.description AS descriptionsoin,
    ds.dateprochainrappel
   FROM ((public.animal a
     JOIN public.donnesoin ds ON ((a.id = ds.idanimal)))
     JOIN public.soin s ON ((ds.idsoin = s.idsoin)))
  WHERE (((s.typesoin)::text = 'Vaccination'::text) AND (ds.dateprochainrappel IS NOT NULL))
  ORDER BY ds.dateprochainrappel;


ALTER VIEW public.v_animaux_a_vacciner OWNER TO postgres;

--
-- Name: v_top5_refuges_transferts_sortants; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_top5_refuges_transferts_sortants AS
 SELECT r.idrefuge,
    r.nom AS nomrefuge,
    count(h.idanimal) AS nombretransfertssortants
   FROM (public.refuge r
     JOIN public.heberge h USING (idrefuge))
  WHERE ((h.datedepart IS NOT NULL) AND (h.datedepart >= (CURRENT_DATE - '2 years'::interval)))
  GROUP BY r.idrefuge, r.nom
  ORDER BY (count(h.idanimal)) DESC
 LIMIT 5;


ALTER VIEW public.v_top5_refuges_transferts_sortants OWNER TO postgres;

--
-- Name: adoption idadoption; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adoption ALTER COLUMN idadoption SET DEFAULT nextval('public.adoption_idadoption_seq'::regclass);


--
-- Name: animal id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.animal ALTER COLUMN id SET DEFAULT nextval('public.animal_id_seq'::regclass);


--
-- Name: employe idemploye; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employe ALTER COLUMN idemploye SET DEFAULT nextval('public.employe_idemploye_seq'::regclass);


--
-- Name: fourriere idfourriere; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fourriere ALTER COLUMN idfourriere SET DEFAULT nextval('public.fourriere_idfourriere_seq'::regclass);


--
-- Name: particulier idparticulier; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.particulier ALTER COLUMN idparticulier SET DEFAULT nextval('public.particulier_idparticulier_seq'::regclass);


--
-- Name: refuge idrefuge; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refuge ALTER COLUMN idrefuge SET DEFAULT nextval('public.refuge_idrefuge_seq'::regclass);


--
-- Name: soin idsoin; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.soin ALTER COLUMN idsoin SET DEFAULT nextval('public.soin_idsoin_seq'::regclass);


--
-- Data for Name: adoption; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.adoption (idadoption, idanimal, idparticulier, dateadoption) FROM stdin;
1	2	1	2023-04-01
2	6	2	2023-07-15
3	10	3	2023-11-01
4	13	4	2024-02-01
5	17	5	2023-03-01
6	21	6	2023-08-01
7	25	7	2023-12-01
8	28	8	2024-03-01
9	33	9	2023-06-15
10	36	10	2023-08-01
11	40	11	2023-10-01
12	43	12	2023-11-15
13	47	13	2024-01-20
\.


--
-- Data for Name: animal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.animal (id, nom, espece, race, age, sexe, signedistinctif, statut, daterecueil, idfourriere) FROM stdin;
1	Rex	Chien	Berger Allemand	5	M	Oreille gauche tombante	Disponible	2023-01-10	1
2	Bella	Chien	Labrador	3	F	Tache blanche poitrail	Adopté	2023-02-15	2
3	Rocky	Chien	Boxer	4	M	Queue écourtée	Disponible	2023-03-20	3
4	Luna	Chien	Husky	2	F	Yeux vairons	En Soins	2023-04-25	4
5	Max	Chien	Golden Retriever	6	M	Cicatrice patte avant	Disponible	2023-05-30	5
6	Daisy	Chien	Beagle	1	F	Très vocale	Adopté	2023-06-05	6
7	Charlie	Chien	Cocker	7	M	Poils longs dorés	Décédé	2022-12-01	7
8	Lola	Chien	Chihuahua	8	F	Manque une dent	Disponible	2023-08-10	8
9	Buddy	Chien	Border Collie	2	M	Hyperactif	Disponible	2023-09-15	9
10	Sadie	Chien	Rottweiler	5	F	Queue longue	Adopté	2023-10-20	10
11	Zeus	Chien	Doberman	3	M	Oreilles droites	En Soins	2023-11-25	1
12	Ruby	Chien	Caniche	9	F	Pelage gris	Disponible	2023-12-30	2
13	Duke	Chien	Dogue Allemand	4	M	Très grand	Adopté	2024-01-05	3
14	Molly	Chien	Shih Tzu	6	F	Borgne	Disponible	2024-02-10	4
15	Bear	Chien	Terre-Neuve	2	M	Aime l'eau	Disponible	2024-03-15	5
16	Tyson	Chien	Staffordshire	4	M	Musclé	Disponible	2023-06-12	1
17	Princesse	Chien	Yorkshire	7	F	Petit noeud rose	Disponible	2023-07-01	2
18	Volt	Chien	Berger Blanc Suisse	2	M	Poil très blanc	Disponible	2023-08-15	3
19	Hatchi	Chien	Akita Inu	5	M	Fidèle	En Soins	2023-09-10	4
20	Lady	Chien	Cavalier King Charles	3	F	Oreilles longues	Disponible	2023-10-05	5
21	Marley	Chien	Labrador Chocolat	6	M	Très joueur	Disponible	2023-11-20	6
22	Snoopy	Chien	Beagle	4	M	Dort sur le toit	Adopté	2023-01-20	7
23	Lassie	Chien	Colley	3	F	Poils longs	Disponible	2023-02-14	8
24	Scooby	Chien	Dogue Allemand	2	M	Peureux	Disponible	2023-03-30	9
25	Beethoven	Chien	Saint-Bernard	5	M	Bave un peu	Disponible	2023-04-12	10
26	Pongo	Chien	Dalmatien	3	M	101 taches	Disponible	2023-05-18	1
27	Perdita	Chien	Dalmatien	3	F	Collier bleu	Disponible	2023-05-18	1
28	Idéfix	Chien	Westie	8	M	Tout petit	Adopté	2023-06-25	2
29	Milou	Chien	Fox Terrier	4	M	Très intelligent	Disponible	2023-07-14	3
30	Bill	Chien	Cocker Anglais	2	M	Oreilles tombantes	Disponible	2023-08-05	4
31	Rantaplan	Chien	Chien de berger	6	M	Un peu bête	Disponible	2023-09-01	5
32	Pluto	Chien	Saint-Hubert	5	M	Flair exceptionnel	Disponible	2023-10-10	6
33	Goofy	Chien	Bruno du Jura	7	M	Maladroit	En Soins	2023-11-15	7
34	Balto	Chien	Husky	3	M	Aime la neige	Disponible	2023-12-01	8
35	Croc-Blanc	Chien	Loup Tchécoslovaque	4	M	Regard perçant	Disponible	2024-01-05	9
36	Belle	Chien	Montagne des Pyrénées	3	F	Très protectrice	Disponible	2024-01-20	10
37	Sebastien	Chien	Berger des Pyrénées	2	M	Vif	Adopté	2024-02-01	1
38	Froufrou	Chien	Caniche Royal	5	F	Pompons aux pattes	Disponible	2024-02-15	2
39	Brutus	Chien	Bulldog Anglais	4	M	Ronfle	Disponible	2024-03-01	3
40	César	Chien	West Highland	6	M	Blanc immaculé	Disponible	2024-03-10	4
41	Pollux	Chien	Bobtail	7	M	Poils devant les yeux	Disponible	2024-03-20	5
42	Cubitus	Chien	Bobtail	5	M	Gros nounours	Disponible	2024-03-25	6
43	Pif	Chien	Epagneul Breton	3	M	Tache marron	Disponible	2024-04-01	7
44	Hercule	Chien	Basset Hound	4	M	Pattes courtes	Disponible	2024-04-05	8
45	Gromit	Chien	Beagle	5	M	Intelligent	Disponible	2024-04-10	9
46	Odie	Chien	Jack Russell	2	M	Langue pendante	Disponible	2024-04-15	10
47	Satanas	Chien	Levrier Afghan	4	M	Très rapide	Disponible	2024-04-20	1
48	Diabolo	Chien	Bâtard	3	M	Rire étrange	Disponible	2024-04-25	2
49	Scoubidou	Chien	Dogue Allemand	5	M	Gourmand	Disponible	2024-04-30	3
50	Volt	Chien	Berger Allemand	2	M	Éclair sur le flanc	Disponible	2024-05-01	4
51	Patch	Chien	Dalmatien	1	M	Tache sur l'oeil	Disponible	2024-05-05	5
52	Lucky	Chien	Dalmatien	1	M	Chanceux	Disponible	2024-05-05	6
53	Rolly	Chien	Dalmatien	1	M	Rondouillard	Disponible	2024-05-05	7
54	Penny	Chien	Dalmatien	1	F	Timide	Disponible	2024-05-05	8
55	Freckles	Chien	Dalmatien	1	M	Taches de rousseur	Disponible	2024-05-05	9
56	Pepper	Chien	Dalmatien	1	F	Épicée	Disponible	2024-05-05	10
57	Jewel	Chien	Dalmatien	1	F	Précieuse	Disponible	2024-05-05	1
58	Dipstick	Chien	Dalmatien	1	M	Queue noire	Disponible	2024-05-05	2
59	Wizzer	Chien	Dalmatien	1	M	Inquiet	Disponible	2024-05-05	3
60	Fidget	Chien	Dalmatien	1	M	Agité	Disponible	2024-05-05	4
61	Simba	Chat	Européen	3	M	Roux tigré	Disponible	2023-01-12	6
62	Nala	Chat	Siamois	2	F	Yeux bleus intenses	Adopté	2023-02-18	7
63	Leo	Chat	Maine Coon	5	M	Poids 10kg	Disponible	2023-03-22	8
64	Mimi	Chat	Persan	4	F	Face plate	En Soins	2023-04-28	9
65	Tigrou	Chat	Bengal	1	M	Taches léopard	Disponible	2023-06-02	10
66	Kitty	Chat	Sphynx	6	F	Sans poils	Adopté	2023-07-08	1
67	Felix	Chat	Gouttière	8	M	Noir et blanc	Décédé	2022-11-15	2
68	Lily	Chat	Sacré de Birmanie	3	F	Gants blancs	Disponible	2023-09-12	3
69	Garfield	Chat	Exotic Shorthair	7	M	Dort tout le temps	Disponible	2023-10-18	4
70	Zoe	Chat	Chartreux	2	F	Yeux or	Adopté	2023-11-22	5
71	Oreo	Chat	Ragdoll	4	M	Mou comme une poupée	En Soins	2023-12-28	6
72	Cleo	Chat	Abyssin	5	F	Pelage lièvre	Disponible	2024-01-08	7
73	Shadow	Chat	Bombay	2	M	Tout noir	Adopté	2024-02-12	8
74	Mia	Chat	Norvégien	3	F	Fourrure épaisse	Disponible	2024-03-18	9
75	Gribouille	Chat	Angora Turc	6	M	Yeux vairons	Disponible	2024-04-22	10
76	Minette	Chat	Européen	2	F	Tricolore	Disponible	2023-05-10	5
77	Grisou	Chat	Chartreux	4	M	Gris uniforme	Disponible	2023-06-15	6
78	Salem	Chat	Noir	100	M	Parle (parfois)	Disponible	2023-07-20	7
79	Chipie	Chat	Ecaille de tortue	3	F	Caractère fort	En Soins	2023-08-25	8
80	Caline	Chat	Sacré de Birmanie	5	F	Très douce	Disponible	2023-09-30	9
81	Mimi	Chat	Gouttière	1	F	Tigrée	Disponible	2023-10-15	10
82	Berlioz	Chat	Angora	2	M	Joueur de piano	Disponible	2023-11-05	1
83	Toulouse	Chat	Gouttière	2	M	Peintre	Disponible	2023-11-05	1
84	Marie	Chat	Angora	2	F	Nœud rose	Disponible	2023-11-05	1
85	Duchesse	Chat	Angora	5	F	Distinguée	Adopté	2023-11-05	1
86	O'Malley	Chat	Gouttière	6	M	Charmeur	Disponible	2023-11-10	2
87	Lucifer	Chat	Noir	4	M	Sournois	Disponible	2023-12-01	3
88	Figaro	Chat	Noir et Blanc	3	M	Danseur	Disponible	2023-12-15	4
89	Gédéon	Chat	Roux	5	M	Associé à un renard	Disponible	2024-01-01	5
90	Cheshire	Chat	Tigré Violet	10	M	Sourire effrayant	En Soins	2024-01-10	6
91	Azrael	Chat	Roux	4	M	Oreille abîmée	Disponible	2024-01-20	7
92	Tom	Chat	Gris et Blanc	6	M	Malchanceux	Disponible	2024-02-01	8
93	Sylvestre	Chat	Noir et Blanc	7	M	Zézaye	Disponible	2024-02-15	9
94	Garfield	Chat	Exotic Shorthair	8	M	Aime les lasagnes	Disponible	2024-03-01	10
95	Hello Kitty	Chat	Bobtail Japonais	2	F	Nœud rouge	Adopté	2024-03-10	1
96	Choupette	Chat	Sacré de Birmanie	3	F	Héritière	Disponible	2024-03-20	2
97	Grumpy	Chat	Snowshoe	4	F	Air grincheux	Disponible	2024-04-01	3
98	Nyan	Chat	Arc-en-ciel	1	M	Volant	Disponible	2024-04-05	4
99	Keyboard	Chat	Roux	5	M	Joue du synthé	Disponible	2024-04-10	5
100	Lil Bub	Chat	Perma-Kitten	3	F	Langue sortie	En Soins	2024-04-15	6
101	Maru	Chat	Scottish Fold	6	M	Aime les boîtes	Disponible	2024-04-20	7
102	Venus	Chat	Chimère	4	F	Visage bicolore	Disponible	2024-04-25	8
103	Snoopybabe	Chat	Exotic Shorthair	2	M	Yeux ronds	Disponible	2024-04-30	9
104	Hamilton	Chat	Hipster	3	M	Moustache blanche	Disponible	2024-05-01	10
105	Colonel Meow	Chat	Himalayen	5	M	Poils très longs	Décédé	2024-01-15	1
106	Puss	Chat	Roux	4	M	Bottes	Disponible	2024-05-05	2
107	Kitty Softpaws	Chat	Noir et Blanc	3	F	Pattes de velours	Disponible	2024-05-05	3
108	Snowbell	Chat	Persan Blanc	6	M	Prétentieux	Disponible	2024-05-05	4
109	Mr. Tinkles	Chat	Persan	5	M	Méchant	Disponible	2024-05-05	5
110	Sassy	Chat	Himalayen	4	F	Bavarde	Disponible	2024-05-05	6
111	D.C.	Chat	Siamois	3	M	Agent secret	Disponible	2024-05-05	7
112	Binx	Chat	Noir	22	M	Immortel	Disponible	2024-05-05	8
113	Salem	Chat	Noir	5	M	Sorcière	Disponible	2024-05-05	9
114	Luna	Chat	Noir	2	F	Lune sur le front	Disponible	2024-05-05	10
115	Artemis	Chat	Blanc	2	M	Lune sur le front	Disponible	2024-05-05	1
116	Diana	Chat	Gris	1	F	Lune sur le front	Disponible	2024-05-05	2
117	Meowth	Chat	Pokémon	5	M	Pièce sur la tête	Disponible	2024-05-05	3
118	Persian	Chat	Pokémon	6	M	Bijou rouge	Disponible	2024-05-05	4
119	Skitty	Chat	Pokémon	2	F	Queue en fleur	Disponible	2024-05-05	5
120	Delcatty	Chat	Pokémon	4	F	Collier violet	Disponible	2024-05-05	6
121	Panpan	Lapin	Nain	1	M	Grandes oreilles	Disponible	2023-05-01	1
122	Coco	Perroquet	Gris du Gabon	25	M	Parle beaucoup	Disponible	2023-05-15	2
123	Speedy	Tortue	Hermann	50	F	Carapace abîmée	Adopté	2023-06-01	3
124	Slinky	Furet	Putoisé	2	M	Très joueur	Disponible	2023-06-15	4
125	Pepito	Cochon d'Inde	Rosette	1	M	Poils en épi	Disponible	2023-07-01	5
126	Riri	Hamster	Doré	1	F	Joue gonflées	Adopté	2023-07-15	6
127	Kaa	Serpent	Python Royal	5	I	Mange des souris	En Soins	2023-08-01	7
128	Iggy	Iguane	Vert	3	M	Aime la chaleur	Disponible	2023-08-15	8
129	Babe	Cochon	Nain Vietnamien	2	F	Très propre	Disponible	2023-09-01	9
130	Biquette	Chèvre	Alpine	4	F	Cornes courbes	Adopté	2023-09-15	10
131	Jojo	Pigeon	Voyageur	2	M	Bague rouge	Disponible	2023-10-01	1
132	Flash	Escargot	Géant d'Afrique	1	I	Très lent	Disponible	2023-10-15	2
133	Spike	Hérisson	Africain	2	M	Piques blancs	Adopté	2023-11-01	3
134	Bernard	Rat	Husky	1	M	Intelligent	Disponible	2023-11-15	4
135	Bianca	Souris	Blanche	1	F	Yeux rouges	Disponible	2023-12-01	5
136	Choco	Octodon	Chilien	3	M	Queue pinceau	Disponible	2023-12-15	6
137	Pompom	Chinchilla	Gris standard	4	F	Douceur extrême	Adopté	2024-01-01	7
138	Zaza	Gerbille	Mongolie	1	F	Creuse tout le temps	Disponible	2024-01-15	8
139	Fifi	Canari	Jaune	2	M	Chanteur	Disponible	2024-02-01	9
140	Glouglou	Dindon	Noir	1	M	Fait la roue	Disponible	2024-02-15	10
141	Bugs	Lapin	Garenne	3	M	Mange des carottes	Disponible	2023-04-01	7
142	Lola	Lapin	Bélier	2	F	Joueuse de basket	Disponible	2023-04-15	8
143	Roger	Lapin	Blanc	4	M	Salopette rouge	Disponible	2023-05-01	9
144	Panpan	Lapin	Gris	1	M	Tape du pied	Disponible	2023-05-15	10
145	Judy	Lapin	Garenne	3	F	Policière	Disponible	2023-06-01	1
146	Snowball	Lapin	Blanc	2	M	Mignon mais dangereux	Disponible	2023-06-15	2
147	Pierre	Lapin	Veste bleue	2	M	Voleur de légumes	Disponible	2023-07-01	3
148	Jeannot	Lapin	Veste rouge	2	M	Suiveur	Disponible	2023-07-01	3
149	Coton	Lapin	Angora	1	F	Boule de poils	Disponible	2023-07-15	4
150	Noisette	Ecureuil	Roux	2	M	Rapide	Disponible	2023-08-01	5
151	Alvin	Tamias	Rayé	3	M	Chanteur	Disponible	2023-08-15	6
152	Simon	Tamias	Rayé	3	M	Intello	Disponible	2023-08-15	6
153	Theodore	Tamias	Rayé	3	M	Gourmand	Disponible	2023-08-15	6
154	Tic	Ecureuil	Marron	5	M	Nez noir	Disponible	2023-09-01	7
155	Tac	Ecureuil	Marron	5	M	Nez rouge	Disponible	2023-09-01	7
156	Denver	Iguane	Vert	10	M	Guitare	Disponible	2023-09-15	8
157	Pascal	Caméléon	Vert	2	M	Change de couleur	Disponible	2023-10-01	9
158	Kermit	Grenouille	Verte	5	M	Journaliste	Disponible	2023-10-15	10
159	Miss Piggy	Cochon	Rose	4	F	Star	Disponible	2023-11-01	1
160	Babe	Cochon	Rose	1	M	Berger	Adopté	2023-11-15	2
161	Wilbur	Cochon	Rose	1	M	Araignée amie	Disponible	2023-12-01	3
162	Pua	Cochon	Tacheté	1	M	Compagnon de voyage	Disponible	2023-12-15	4
163	Heihei	Coq	Bicolore	2	M	Stupide	Disponible	2024-01-01	5
164	Zazu	Oiseau	Calao	10	M	Majordome	Disponible	2024-01-15	6
165	Iago	Perroquet	Rouge	8	M	Bruyant	Disponible	2024-02-01	7
166	Blu	Perroquet	Ara Bleu	3	M	Ne sait pas voler	Disponible	2024-02-15	8
167	Jewel	Perroquet	Ara Bleu	3	F	Libre	Disponible	2024-02-15	8
168	Nigel	Cacatoès	Blanc	15	M	Méchant	En Soins	2024-03-01	9
169	Hedwig	Chouette	Harfang	4	F	Courrier	Disponible	2024-03-15	10
170	Errol	Hibou	Gris	12	M	Fatigué	Disponible	2024-04-01	1
\.


--
-- Data for Name: donnesoin; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.donnesoin (idsoin, idemploye, idanimal, datesoin, dateprochainrappel) FROM stdin;
1	11	1	2023-01-12	2024-01-12
1	13	2	2023-02-17	2024-02-17
1	11	3	2023-03-22	2024-03-22
1	16	4	2023-04-27	2024-04-27
1	11	16	2023-01-14	2024-01-14
1	13	17	2023-02-20	2024-02-20
3	11	1	2023-01-20	\N
3	13	16	2023-01-25	\N
3	16	4	2023-05-01	\N
2	12	1	2023-01-15	2023-04-15
2	14	2	2023-02-18	2023-05-18
4	11	1	2023-01-11	\N
5	11	4	2023-05-10	\N
6	13	19	2023-05-01	2024-05-01
8	12	5	2023-06-15	\N
9	16	26	2024-01-02	\N
10	19	7	2022-11-05	\N
\.


--
-- Data for Name: employe; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employe (idemploye, matricule, nom, prenom, adresse, telephoneemploye, datenaissance, numerosecu, dateembauche, login, motdepasse) FROM stdin;
1	M001	Dupont	Jean	Paris	0601010101	1980-05-15	1800575001001	2010-01-01	jdupont	pbkdf2:sha256:1000000$anNw17IMZTfr1No9$6e95d72026bed39b69915cddcd9bcb733a297fa1445af8e7f718709e4008df0e
2	M002	Martin	Claire	Lyon	0602020202	1985-06-20	2850669001002	2012-02-01	cmartin	pbkdf2:sha256:1000000$tHVXtgEb1T6Yp0P6$17f6fc1bda30311f38491c63b80eaae8a936de4554a7a7a74518b0732061783a
3	M003	Bernard	Luc	Marseille	0603030303	1978-03-10	1780313001003	2008-05-15	lbernard	pbkdf2:sha256:1000000$O1JTIczNnrJfWEa3$f1d140e5eb4467e6dd6d4ccdf70c33ca6dda524d16540e150c3771b4b43a5bf7
4	M004	Petit	Emma	Bordeaux	0604040404	1990-11-25	2901133001004	2015-09-01	epetit	pbkdf2:sha256:1000000$Mra3biOyRWM6HVyP$6f4750988db54bbaa69d8c7c4ed8c8c91702ea23d58f587e79ff84599ea2f243
5	M005	Robert	Hugo	Toulouse	0605050505	1982-08-30	1820831001005	2011-03-20	hrobert	pbkdf2:sha256:1000000$nSCueIYJSfW4jS2Y$5c0ecce23a17b535717dcab88ca52e77071a7844420aec09b207a4d23b811c6d
6	M006	Richard	Ines	Nantes	0606060606	1995-02-14	2950244001006	2018-07-01	irichard	pbkdf2:sha256:1000000$sxqeUs9kK5UFz3Ny$ec8ea0684f351a2aab0634f6a2af79c3783b9839cd8e8456e29b935667adfbfb
7	M007	Durand	Tom	Strasbourg	0607070707	1988-12-05	1881267001007	2014-10-10	tdurand	pbkdf2:sha256:1000000$4ik7TSXpcq2oMXsJ$2a7c79e29cf00d44a9abf6d74ac77e942bf8f327464667c2e746b105bf1868e6
8	M008	Lefebvre	Lea	Lille	0608080808	1992-04-18	2920459001008	2016-01-05	llefebvre	pbkdf2:sha256:1000000$knlCzWxHAWrIlDuE$79fa289c13567998eab1494680c245ff4acd62ecde700c80669d54554f14ec9a
9	M009	Moreau	Louis	Montpellier	0609090909	1975-09-22	1750934001009	2005-06-30	lmoreau	pbkdf2:sha256:1000000$JRVtP730pWpADCa1$5502e8b7b900cd9d71fe4e1dd07a22a719cd0a8a6b978c694331164e203e5fd2
10	M010	Simon	Jade	Rennes	0610101010	1993-07-08	2930735001010	2017-11-15	jsimon	pbkdf2:sha256:1000000$LJu3UzpizDSIe5j1$bdee1713424da606d70d5f7fc3ce8bc8e0c87a9f62890b657cb7fd0de15c4d4f
11	V001	Laurent	Pierre	Paris	0701010101	1984-01-15	1840175001111	2015-05-20	plaurent	pbkdf2:sha256:1000000$MvOSLOrJfkIlJWKJ$6f3fa4877916d7327198a0b065190243be1348f2d46bf6e21fb8cbeb894a893d
12	S001	Michel	Sarah	Paris	0702020202	1998-03-12	2980375001222	2020-09-01	smichel	pbkdf2:sha256:1000000$bNbBUA4OtAY9t9w7$312db924cbc9dd8ad93985cde20c918e74dd14c60e015ced86e3c5455b5c9b44
13	V002	Garcia	David	Lyon	0703030303	1986-07-30	1860769001333	2016-02-15	dgarcia	pbkdf2:sha256:1000000$yPKfFgxmwUvBb91A$7ea059fab493a47b5c33e4f82c12cff0404989f39302647753bad7ce01b25b8f
14	S002	David	Julie	Lyon	0704040404	1999-12-05	2991269001444	2021-01-10	jdavid	pbkdf2:sha256:1000000$xV5OiLWN99q9uC55$e0695bc11a1dc0a40b9aa34898eb2ce585090d53bc6ee9e77dc27e51bb34fd5e
15	S003	Bertrand	Paul	Marseille	0705050505	1997-05-25	1970513001555	2019-11-20	pbertrand	pbkdf2:sha256:1000000$nsmQdgtvOXLtc3Ww$95d33bd45635fc5095ea33703fcbe868e0c3831084a8a02f2cbea03af8e763fb
16	V003	Rousseau	Anna	Bordeaux	0706060606	1989-09-14	2890933001666	2017-04-05	arousseau	pbkdf2:sha256:1000000$mbDqfIgTQXYqiqKS$cc8e988a5c3ecbf669ed69263bc3cb753223d0fd37b4ca6efb35da7cb27a1e41
17	S004	Vincent	Leo	Toulouse	0707070707	2000-02-28	1000231001777	2022-06-15	lvincent	pbkdf2:sha256:1000000$087nQhjyu3N5kDtn$4a09e63045640b043e3a51fcd21347b1fac3ca2f25683a134adf2bbd32e198f5
18	S005	Muller	Eva	Nantes	0708080808	1996-08-10	2960844001888	2019-03-01	emuller	pbkdf2:sha256:1000000$Uh8ZHiX4TxxqPyzV$638c10ad0133828f887b5a43a8394f8588302eae7cd0786d5515a86b2591e144
19	V004	Lambert	Nathan	Strasbourg	0709090909	1983-11-03	1831167001999	2014-08-20	nlambert	pbkdf2:sha256:1000000$9PxiNc8YzckGpAFi$a88df28b6fea3f49be26358de2641212b2ed1b18ed69b271133c3235cdf91f1c
20	S006	Faure	Zoe	Lille	0710101010	2001-04-12	2010459002000	2023-01-05	zfaure	pbkdf2:sha256:1000000$C7iIzVby6Hx22PtY$0f05f7a521d3ba5176ec6732e538d53909ec40525b1e9b6527775f1c3aba4649
21	S007	Andre	Gabin	Montpellier	0711111111	1995-10-22	1951034002111	2018-12-10	gandre	pbkdf2:sha256:1000000$jtXslLPVIUZQM1sE$c43c45b81fb3bea1f45796fd9f093cb4440a2bdce88bbc361f6b16cf2d7ae0da
22	V005	Mercier	Lola	Rennes	0712121212	1991-06-18	2910635002222	2016-09-25	lmercier	pbkdf2:sha256:1000000$d9buHKVx2eAuZp7p$a85bc2dba89ae78b3e454074c151e100446011ec1727485471cb2e752e246b0e
23	S008	Blanc	Arthur	Paris	0713131313	1994-03-08	1940375002333	2017-05-15	ablanc	pbkdf2:sha256:1000000$RWu7GPFjaBa99wMz$6fd615e47533f5637acc8cf38492094ba14e264ac9bb92497f78f8e1093e0682
24	S009	Guerin	Romane	Lyon	0714141414	1999-01-30	2990169002444	2020-11-01	rguerin	pbkdf2:sha256:1000000$JbWXV4ESnlIOjpDN$a1f5465fe0c528560b6ad7ba06dcacdda15d7dc67b435fc9ceccada5e5ba1463
25	S010	Boyer	Jules	Marseille	0715151515	2002-07-15	1020713002555	2023-08-20	jboyer	pbkdf2:sha256:1000000$RdiasQAjRgI783rl$ec4fee69401720860742057b560062647aa8d2dc2969f282261178a9e39afeaf
\.


--
-- Data for Name: estaffecte; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.estaffecte (idemploye, idrefuge, dateaffectation, fonction) FROM stdin;
1	1	2010-01-01	Directeur
2	2	2012-02-01	Directeur
3	3	2008-05-15	Directeur
4	4	2015-09-01	Directeur
5	5	2011-03-20	Directeur
6	6	2018-07-01	Directeur
7	7	2014-10-10	Directeur
8	8	2016-01-05	Directeur
9	9	2005-06-30	Directeur
10	10	2017-11-15	Directeur
11	1	2015-05-20	Vétérinaire
12	1	2020-09-01	Soigneur
13	2	2016-02-15	Vétérinaire
14	2	2021-01-10	Soigneur
15	3	2019-11-20	Soigneur
16	4	2017-04-05	Vétérinaire
17	5	2022-06-15	Soigneur
18	6	2019-03-01	Soigneur
19	7	2014-08-20	Vétérinaire
20	8	2023-01-05	Soigneur
21	9	2018-12-10	Soigneur
22	10	2016-09-25	Vétérinaire
23	1	2017-05-15	Soigneur
24	2	2020-11-01	Soigneur
25	3	2023-08-20	Soigneur
\.


--
-- Data for Name: fourriere; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fourriere (idfourriere, nomfourriere, adresse, telephonefourriere) FROM stdin;
1	Fourriere Paris Centre	12 Rue du Chenil, Paris	0144556677
2	Fourriere Lyon Sud	45 Avenue Berthelot, Lyon	0478990011
3	Fourriere Marseille Nord	8 Impasse des Oliviers, Marseille	0491223344
4	Fourriere Bordeaux Lac	Zone Industrielle Nord, Bordeaux	0556112233
5	Fourriere Toulouse Purpan	Route de Bayonne, Toulouse	0561445566
6	Fourriere Nantes Est	Chemin des Vignes, Nantes	0240112233
7	Fourriere Strasbourg Robertsau	Quai Jacoutot, Strasbourg	0388112233
8	Fourriere Lille Moulins	Boulevard de Belfort, Lille	0320112233
9	Fourriere Montpellier Prés	Avenue de la Mer, Montpellier	0467112233
10	Fourriere Rennes Cleunay	Rue de la Vilaine, Rennes	0299112233
\.


--
-- Data for Name: heberge; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.heberge (idanimal, idrefuge, datearrive, datedepart) FROM stdin;
1	1	2023-01-11	\N
11	1	2023-11-26	\N
21	1	2023-07-09	2023-08-01
31	1	2023-05-02	\N
41	1	2023-10-02	\N
51	1	2023-06-12	\N
61	1	2023-05-18	\N
71	1	2024-04-20	\N
81	1	2024-05-05	\N
91	1	2023-11-05	\N
101	1	2023-11-05	2023-12-01
111	1	2024-03-10	\N
121	1	2024-05-05	\N
131	1	2024-01-15	\N
141	1	2023-06-01	\N
151	1	2023-11-01	\N
161	1	2024-04-01	\N
2	2	2023-02-16	2023-04-01
12	2	2023-12-31	\N
22	2	2022-11-16	2022-11-20
32	2	2023-05-16	\N
42	2	2023-10-16	\N
52	2	2023-07-01	\N
62	2	2023-05-18	\N
72	2	2024-04-25	\N
82	2	2024-05-05	\N
92	2	2023-05-10	\N
102	2	2023-11-10	\N
112	2	2024-03-20	\N
122	2	2024-05-05	\N
132	2	2024-05-05	\N
142	2	2023-06-15	\N
152	2	2023-11-15	2023-12-01
162	2	2024-01-01	\N
3	3	2023-03-21	\N
13	3	2024-01-06	2024-02-01
23	3	2023-09-13	\N
33	3	2023-06-02	2023-06-15
43	3	2023-11-02	2023-11-15
53	3	2023-08-15	\N
63	3	2023-06-25	2023-07-01
73	3	2024-04-30	\N
83	3	2024-05-05	\N
93	3	2023-06-15	\N
103	3	2023-12-01	\N
113	3	2024-04-01	\N
123	3	2024-05-05	\N
133	3	2024-05-05	\N
143	3	2023-07-01	\N
153	3	2023-12-01	\N
163	3	2024-02-01	\N
4	4	2023-04-26	\N
14	4	2024-02-11	\N
24	4	2023-10-19	\N
34	4	2023-06-16	\N
44	4	2023-11-16	\N
54	4	2023-09-10	\N
64	4	2023-07-14	\N
74	4	2024-05-01	\N
84	4	2024-05-05	\N
94	4	2023-07-20	\N
104	4	2023-12-15	\N
114	4	2024-04-05	\N
124	4	2024-05-05	\N
134	4	2024-05-05	\N
144	4	2023-07-01	\N
154	4	2023-12-15	\N
164	4	2024-02-15	\N
5	5	2023-05-31	\N
15	5	2024-03-16	\N
25	5	2023-11-23	2023-12-01
35	5	2023-07-02	\N
45	5	2023-12-02	\N
55	5	2023-10-05	\N
65	5	2023-08-05	\N
75	5	2024-05-05	\N
85	5	2024-05-05	\N
95	5	2023-08-25	\N
105	5	2024-01-01	\N
115	5	2024-04-10	\N
125	5	2024-05-05	\N
135	5	2024-05-05	\N
145	5	2023-07-15	\N
155	5	2024-01-01	\N
165	5	2024-02-15	\N
6	6	2023-06-06	2023-07-15
16	6	2023-01-13	\N
26	6	2023-12-29	\N
36	6	2023-07-16	2023-08-01
46	6	2023-12-16	\N
56	6	2023-11-20	\N
66	6	2023-09-01	\N
76	6	2024-05-05	\N
86	6	2024-05-05	\N
96	6	2023-09-30	\N
106	6	2024-01-10	\N
116	6	2024-04-15	\N
126	6	2024-05-05	\N
136	6	2024-05-05	\N
146	6	2023-08-01	\N
156	6	2024-01-15	\N
166	6	2024-03-01	\N
7	7	2022-11-01	2022-12-01
17	7	2023-02-19	2023-03-01
27	7	2024-01-09	\N
37	7	2023-08-02	\N
47	7	2024-01-02	2024-01-20
57	7	2023-01-20	2023-02-01
67	7	2023-10-10	\N
77	7	2024-05-05	\N
87	7	2024-05-05	\N
97	7	2023-10-15	\N
107	7	2024-01-20	\N
117	7	2024-04-20	\N
127	7	2024-05-05	\N
137	7	2024-05-05	\N
147	7	2023-08-15	\N
157	7	2024-02-01	\N
167	7	2024-03-15	\N
8	8	2023-08-11	\N
18	8	2023-03-23	\N
28	8	2024-02-13	2024-03-01
38	8	2023-08-16	\N
48	8	2024-01-16	\N
58	8	2023-02-14	\N
68	8	2023-11-15	\N
78	8	2024-05-05	\N
88	8	2024-05-05	\N
98	8	2023-11-05	\N
108	8	2024-02-01	\N
118	8	2024-04-25	\N
128	8	2024-05-05	\N
138	8	2024-05-05	\N
148	8	2023-08-15	\N
158	8	2024-02-15	\N
168	8	2024-04-01	\N
9	9	2023-09-16	\N
19	9	2023-04-29	\N
29	9	2024-03-19	\N
39	9	2023-09-02	\N
49	9	2024-02-02	\N
59	9	2023-03-30	\N
69	9	2023-12-01	\N
79	9	2024-05-05	\N
89	9	2024-05-05	\N
99	9	2023-11-05	\N
109	9	2024-02-15	\N
119	9	2024-04-30	\N
129	9	2024-05-05	\N
139	9	2024-05-05	\N
149	9	2023-08-15	\N
159	9	2024-03-01	\N
169	9	2023-04-01	\N
10	10	2023-10-21	2023-11-01
20	10	2023-06-03	\N
30	10	2024-04-23	\N
40	10	2023-09-16	2023-10-01
50	10	2024-02-16	\N
60	10	2023-04-12	\N
70	10	2024-01-05	\N
80	10	2024-05-05	\N
90	10	2024-05-05	\N
100	10	2023-11-05	2023-12-01
110	10	2024-03-01	\N
120	10	2024-05-01	\N
130	10	2024-01-15	\N
140	10	2024-05-05	\N
150	10	2023-09-01	\N
160	10	2023-11-01	\N
170	10	2024-04-15	\N
\.


--
-- Data for Name: particulier; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.particulier (idparticulier, nom, prenom, adresse, telephoneparticulier) FROM stdin;
1	Lemoine	Paul	10 Rue de la Paix, Paris	0611223344
2	Dubois	Julie	5 Avenue Foch, Lyon	0622334455
3	Vasseur	Marc	12 Boulevard Michelet, Marseille	0633445566
4	Leroy	Sophie	8 Rue Sainte-Catherine, Bordeaux	0644556677
5	Morel	Antoine	3 Place du Capitole, Toulouse	0655667788
6	Fournier	Emma	20 Rue Crébillon, Nantes	0666778899
7	Girard	Lucas	7 Place Kléber, Strasbourg	0677889900
8	Bonnet	Chloé	15 Grand Place, Lille	0688990011
9	Roux	Thomas	9 Place de la Comédie, Montpellier	0699001122
10	Vincent	Lea	4 Place des Lices, Rennes	0600112233
11	Guerin	Nicolas	11 Rue Royale, Versailles	0612121212
12	Boyer	Camille	66 Route 66, Melun	0613131313
13	Garnier	Hugo	77 Allée des Cygnes, Annecy	0614141414
14	Chevalier	Manon	88 Impasse des Lilas, Tours	0615151515
15	Blanc	Alexandre	99 Boulevard Gambetta, Nice	0616161616
16	Gauthier	Sarah	22 Rue de la République, Avignon	0617171717
17	Perrin	Mathieu	33 Cours Mirabeau, Aix	0618181818
18	Morin	Elodie	44 Quai Perdonnet, Vevey	0619191919
19	Mathieu	Clement	55 Rue de Siam, Brest	0620202020
20	Clement	Charlotte	101 Champs Elysées, Paris	0621212121
\.


--
-- Data for Name: refuge; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.refuge (idrefuge, nom, ville, codepostal, telephonerefuge, capaciteaccueil, idemploye, lat, lon) FROM stdin;
1	Refuge de l'Espoir	Paris	75012	0144001122	100	1	48.8412000	2.4005000
2	SPA Lyon Centre	Lyon	69002	0478001122	80	2	45.7579000	4.8320000
3	Abri Marseillais	Marseille	13008	0491001122	90	3	43.2798000	5.3857000
4	Refuge Bordelais	Bordeaux	33000	0556001122	70	4	44.8378000	-0.5792000
5	Oasis Toulouse	Toulouse	31000	0561001122	85	5	43.6047000	1.4442000
6	Refuge Nantais	Nantes	44000	0240001122	60	6	47.2184000	-1.5536000
7	Arche de Strasbourg	Strasbourg	67000	0388001122	75	7	48.5734000	7.7521000
8	Refuge du Nord	Lille	59000	0320001122	65	8	50.6292000	3.0573000
9	Soleil Montpellier	Montpellier	34000	0467001122	95	9	43.6108000	3.8767000
10	Refuge Breton	Rennes	35000	0299001122	55	10	48.1173000	-1.6778000
\.


--
-- Data for Name: soin; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.soin (idsoin, typesoin, description) FROM stdin;
1	Vaccination	Vaccins essentiels (Carré, Leucose, Rage, etc.)
2	Vermifugation	Traitement antiparasitaire interne
3	Stérilisation	Ovariectomie ou castration
4	Identification	Pose de puce électronique ou tatouage
5	Chirurgie Orthopédique	Réparation de fractures ou ligaments
6	Soins Dentaires	Détartrage et extraction
7	Toilettage Sanitaire	Tonte pour animaux aux poils emmêlés/malades
8	Rééducation	Physiothérapie suite à un accident
9	Traitement Antibiotique	Pour infections bactériennes
10	Bilan Sanguin	Analyse complète pour animaux âgés
\.


--
-- Name: adoption_idadoption_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.adoption_idadoption_seq', 13, true);


--
-- Name: animal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.animal_id_seq', 170, true);


--
-- Name: employe_idemploye_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employe_idemploye_seq', 25, true);


--
-- Name: fourriere_idfourriere_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fourriere_idfourriere_seq', 10, true);


--
-- Name: particulier_idparticulier_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.particulier_idparticulier_seq', 20, true);


--
-- Name: refuge_idrefuge_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.refuge_idrefuge_seq', 10, true);


--
-- Name: soin_idsoin_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.soin_idsoin_seq', 10, true);


--
-- Name: adoption adoption_idanimal_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adoption
    ADD CONSTRAINT adoption_idanimal_key UNIQUE (idanimal);


--
-- Name: adoption adoption_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adoption
    ADD CONSTRAINT adoption_pkey PRIMARY KEY (idadoption);


--
-- Name: animal animal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT animal_pkey PRIMARY KEY (id);


--
-- Name: donnesoin donnesoin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donnesoin
    ADD CONSTRAINT donnesoin_pkey PRIMARY KEY (idsoin, idemploye, idanimal, datesoin);


--
-- Name: employe employe_login_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employe
    ADD CONSTRAINT employe_login_key UNIQUE (login);


--
-- Name: employe employe_matricule_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employe
    ADD CONSTRAINT employe_matricule_key UNIQUE (matricule);


--
-- Name: employe employe_numerosecu_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employe
    ADD CONSTRAINT employe_numerosecu_key UNIQUE (numerosecu);


--
-- Name: employe employe_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employe
    ADD CONSTRAINT employe_pkey PRIMARY KEY (idemploye);


--
-- Name: estaffecte estaffecte_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estaffecte
    ADD CONSTRAINT estaffecte_pkey PRIMARY KEY (idemploye, idrefuge, dateaffectation);


--
-- Name: fourriere fourriere_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fourriere
    ADD CONSTRAINT fourriere_pkey PRIMARY KEY (idfourriere);


--
-- Name: heberge heberge_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.heberge
    ADD CONSTRAINT heberge_pkey PRIMARY KEY (idanimal, idrefuge, datearrive);


--
-- Name: particulier particulier_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.particulier
    ADD CONSTRAINT particulier_pkey PRIMARY KEY (idparticulier);


--
-- Name: refuge refuge_nom_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refuge
    ADD CONSTRAINT refuge_nom_key UNIQUE (nom);


--
-- Name: refuge refuge_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refuge
    ADD CONSTRAINT refuge_pkey PRIMARY KEY (idrefuge);


--
-- Name: soin soin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.soin
    ADD CONSTRAINT soin_pkey PRIMARY KEY (idsoin);


--
-- Name: soin soin_typesoin_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.soin
    ADD CONSTRAINT soin_typesoin_key UNIQUE (typesoin);


--
-- Name: adoption adoption_idanimal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adoption
    ADD CONSTRAINT adoption_idanimal_fkey FOREIGN KEY (idanimal) REFERENCES public.animal(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: adoption adoption_idparticulier_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adoption
    ADD CONSTRAINT adoption_idparticulier_fkey FOREIGN KEY (idparticulier) REFERENCES public.particulier(idparticulier) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: animal animal_idfourriere_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT animal_idfourriere_fkey FOREIGN KEY (idfourriere) REFERENCES public.fourriere(idfourriere) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: donnesoin donnesoin_idanimal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donnesoin
    ADD CONSTRAINT donnesoin_idanimal_fkey FOREIGN KEY (idanimal) REFERENCES public.animal(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: donnesoin donnesoin_idemploye_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donnesoin
    ADD CONSTRAINT donnesoin_idemploye_fkey FOREIGN KEY (idemploye) REFERENCES public.employe(idemploye) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: donnesoin donnesoin_idsoin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donnesoin
    ADD CONSTRAINT donnesoin_idsoin_fkey FOREIGN KEY (idsoin) REFERENCES public.soin(idsoin) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: estaffecte estaffecte_idemploye_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estaffecte
    ADD CONSTRAINT estaffecte_idemploye_fkey FOREIGN KEY (idemploye) REFERENCES public.employe(idemploye) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: estaffecte estaffecte_idrefuge_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estaffecte
    ADD CONSTRAINT estaffecte_idrefuge_fkey FOREIGN KEY (idrefuge) REFERENCES public.refuge(idrefuge) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: heberge heberge_idanimal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.heberge
    ADD CONSTRAINT heberge_idanimal_fkey FOREIGN KEY (idanimal) REFERENCES public.animal(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: heberge heberge_idrefuge_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.heberge
    ADD CONSTRAINT heberge_idrefuge_fkey FOREIGN KEY (idrefuge) REFERENCES public.refuge(idrefuge) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: refuge refuge_idemploye_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refuge
    ADD CONSTRAINT refuge_idemploye_fkey FOREIGN KEY (idemploye) REFERENCES public.employe(idemploye) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict qOu172L3Fegny1n6nSPJfUhGgk0mFN94DMd8cYazyXJqcfNTdfNH2rWqy4zAvoX

