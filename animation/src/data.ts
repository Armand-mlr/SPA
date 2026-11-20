// Données extraites de appWeb/dump.sql (données de démonstration fictives)

export type Refuge = {
  id: number;
  nom: string;
  ville: string;
  cp: string;
  tel: string;
  capacite: number;
  lat: number;
  lon: number;
};

export const refuges: Refuge[] = [
  { id: 1, nom: "Refuge de l'Espoir", ville: "Paris", cp: "75012", tel: "0144001122", capacite: 100, lat: 48.8412, lon: 2.4005 },
  { id: 2, nom: "SPA Lyon Centre", ville: "Lyon", cp: "69002", tel: "0478001122", capacite: 80, lat: 45.7579, lon: 4.832 },
  { id: 3, nom: "Abri Marseillais", ville: "Marseille", cp: "13008", tel: "0491001122", capacite: 90, lat: 43.2798, lon: 5.3857 },
  { id: 4, nom: "Refuge Bordelais", ville: "Bordeaux", cp: "33000", tel: "0556001122", capacite: 70, lat: 44.8378, lon: -0.5792 },
  { id: 5, nom: "Oasis Toulouse", ville: "Toulouse", cp: "31000", tel: "0561001122", capacite: 85, lat: 43.6047, lon: 1.4442 },
  { id: 6, nom: "Refuge Nantais", ville: "Nantes", cp: "44000", tel: "0240001122", capacite: 60, lat: 47.2184, lon: -1.5536 },
  { id: 7, nom: "Arche de Strasbourg", ville: "Strasbourg", cp: "67000", tel: "0388001122", capacite: 75, lat: 48.5734, lon: 7.7521 },
  { id: 8, nom: "Refuge du Nord", ville: "Lille", cp: "59000", tel: "0320001122", capacite: 65, lat: 50.6292, lon: 3.0573 },
  { id: 9, nom: "Soleil Montpellier", ville: "Montpellier", cp: "34000", tel: "0467001122", capacite: 95, lat: 43.6108, lon: 3.8767 },
  { id: 10, nom: "Refuge Breton", ville: "Rennes", cp: "35000", tel: "0299001122", capacite: 55, lat: 48.1173, lon: -1.6778 },
];

export type Animal = {
  nom: string;
  espece: string;
  race: string;
  age: number;
  statut: string;
};

// Pensionnaires actuels de SPA Lyon Centre (triés par nom, comme la requête)
export const lyonAnimaux: Animal[] = [
  { nom: "Berlioz", espece: "Chat", race: "Angora", age: 2, statut: "Disponible" },
  { nom: "Binx", espece: "Chat", race: "Noir", age: 22, statut: "Disponible" },
  { nom: "Cleo", espece: "Chat", race: "Abyssin", age: 5, statut: "Disponible" },
  { nom: "Coco", espece: "Perroquet", race: "Gris du Gabon", age: 25, statut: "Disponible" },
  { nom: "Cubitus", espece: "Chien", race: "Bobtail", age: 5, statut: "Disponible" },
  { nom: "Flash", espece: "Escargot", race: "Géant d'Afrique", age: 1, statut: "Disponible" },
  { nom: "Lola", espece: "Lapin", race: "Bélier", age: 2, statut: "Disponible" },
  { nom: "Lucky", espece: "Chien", race: "Dalmatien", age: 1, statut: "Disponible" },
  { nom: "Nala", espece: "Chat", race: "Siamois", age: 2, statut: "Adopté" },
  { nom: "Tom", espece: "Chat", race: "Gris et Blanc", age: 6, statut: "Disponible" },
  { nom: "Venus", espece: "Chat", race: "Chimère", age: 4, statut: "Disponible" },
];

export const especesLyon = ["Chat", "Chien", "Cochon", "Escargot", "Lapin", "Perroquet"];

export const equipeParis = [
  { initiale: "P", nom: "Pierre Laurent", fonction: "Vétérinaire" },
  { initiale: "S", nom: "Sarah Michel", fonction: "Soigneur" },
  { initiale: "A", nom: "Arthur Blanc", fonction: "Soigneur" },
];

export const alertesLocal = [
  { animal: "Rex", espece: "Chien", soin: "Vaccination", refuge: "Refuge de l'Espoir", date: "12/01/2024" },
];

export const alertesReseau = [
  { animal: "Rex", espece: "Chien", soin: "Vaccination", refuge: "Refuge de l'Espoir", date: "12/01/2024" },
  { animal: "Tyson", espece: "Chien", soin: "Vaccination", refuge: "Refuge Nantais", date: "14/01/2024" },
  { animal: "Rocky", espece: "Chien", soin: "Vaccination", refuge: "Abri Marseillais", date: "22/03/2024" },
  { animal: "Luna", espece: "Chien", soin: "Vaccination", refuge: "Refuge Bordelais", date: "27/04/2024" },
];

// Vue V_Top5_Refuges_Transferts_Sortants (transferts sortants dans le dump)
export const top5 = [
  { nom: "Abri Marseillais", n: 4 },
  { nom: "Arche de Strasbourg", n: 4 },
  { nom: "SPA Lyon Centre", n: 3 },
  { nom: "Refuge Breton", n: 3 },
  { nom: "Refuge de l'Espoir", n: 2 },
];
