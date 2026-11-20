# Vidéo de présentation de Refu'Gest

Vidéo d'environ 1 minute (1920×1080, 30 i/s) qui présente l'application, réalisée en code avec [Remotion](https://www.remotion.dev/).
Les écrans sont reconstruits à partir des vrais templates, du CSS et des données de démonstration (`appWeb/dump.sql`) : aucune base de données n'est nécessaire.

## Commandes

À lancer depuis ce dossier `animation/` :

```bash
npm install          # une seule fois
npm run studio       # aperçu interactif dans le navigateur
npm run render       # génère out/refugest.mp4
npm run music        # régénère la musique (public/music.wav)
```

## Organisation

| Fichier | Rôle |
|---|---|
| `src/Video.tsx` | Enchaînement des scènes, transitions et musique |
| `src/scenes/` | Une scène par fichier : intro, accueil, recherche, fiche refuge, connexion, tableau de bord, adoption, schéma de la base, crédits |
| `src/components/` | Éléments réutilisés : fenêtre de navigateur, curseur, légendes, carte, barre latérale… |
| `src/data.ts` | Données affichées (extraites du dump SQL) |
| `scripts/music.mjs` | Musique synthétisée par le script (aucun échantillon externe, donc pas de droits) |

Pour utiliser une autre musique, remplacer `public/music.wav` (même nom) puis relancer `npm run render`.
