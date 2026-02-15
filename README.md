# 🚗 Analyse des Risques Automobiles - ENSAssuRances

**Projet de Data Science Actuarielle (R)**
*Auteur : Maxendre Bauthamy*

## 📋 Contexte
Ce projet vise à analyser le portefeuille automobile d'ENSAssuRances (300 000 contrats) pour identifier les facteurs de risque et proposer une nouvelle segmentation tarifaire pour l'exercice à venir.

## 🛠️ Méthodologie
1. **Ingénierie des Données :**
   - Nettoyage des doublons de gestion dans la base Sinistres.
   - Consolidation des bases (Jointure Contrats/Sinistres).
   - Recodage des variables (Dates, Segments, Options).
2. **Analyse Exploratoire :**
   - Étude de la sinistralité par âge, genre et segment de véhicule.
   - Cartographie des zones à risque.

## 📊 Résultats Clés
- **Jeunes Conducteurs (18-25 ans) :** Sur-sinistralité confirmée (+40% de fréquence).
- **Segment "Familiale" :** Coût total des sinistres le plus élevé du portefeuille.
- **Option "Petit Rouleur" :** Permet de capter des profils à risque faible (rentabilité positive).

## 📂 Structure du Dépôt
- `data/` : Contient les jeux de données bruts (Contrats & Sinistres).
- `Projet_Final.Rmd` : Le code source complet (R Markdown).
- `Projet_Final.html` : Le rapport d'analyse généré et interactif.

## 🚀 Comment exécuter le projet ?
1. Cloner le dépôt.
2. Ouvrir `Projet_Final.Rmd` dans RStudio.
3. Installer les dépendances (`tidyverse`, `readxl`, `janitor`).
4. Cliquer sur le bouton **Knit**.
