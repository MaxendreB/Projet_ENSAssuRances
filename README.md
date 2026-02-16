# 🚗 Analyse des Risques Automobiles - ENSAssuRances

**Projet de Data Science Actuarielle (R)**

*Auteur : Maxendre Bauthamy*

## 📋 Contexte
Le projet porte sur la base de données Sinistre et Contrat contenant des informations sur des contrats d’assurance automobile et les sinistres associés, pour une compagnie fictive ENSAssuRances. Cette base contient 320 000 lignes et permet d’étudier la fréquence, la répartition et les facteurs de risque liés aux sinistres automobiles.

Mené au sein de la Direction Technique Automobile d'ENSAssurances, ce projet individuel placé sous l'égide de son directeur, Prof. Dr. Solym Manou-Abi, vise à : 
- structurer, nettoyer et transformer la base de données sinistres et contrats,
- produire des analyses exploratoires et statistiques détaillées,
- visualiser les données afin de faciliter la prise de décision en assurance,
- identifier les caractéristiques des contrats et véhicules à risque.

## 🛠️ Méthodologie
1. **Ingénierie des Données :**
   - Nettoyage des doublons de gestion dans la base Sinistres.
   - Consolidation des bases (Jointure Contrats/Sinistres).
   - Recodage des variables (Dates, Segments, Options).
2. **Analyse Exploratoire :**
   - Étude de la sinistralité par âge, genre et segment de véhicule.
   - Analyses temporelles
   - Facteurs de risque

## 📂 Structure du Dépôt
- `data/` : Contient les jeux de données bruts (Contrats & Sinistres) et le DataFrame après l'étape d'Ingénierie des Données.
- `scripts/` : Contient les scripts R des parties Ingénierie des Données et Data Visualisation.
- `Projet_Final.Rmd` : Le code source complet (R Markdown).
- `Projet_Final.html` : Le rapport d'analyse généré et interactif.

## 🎯 Livrables
- `Dépôt RPubs` : Le lien RPubs : 
- `Rapport final synthétique orienté aide à la décision` : Le fichier nommé "Projet_Final.Rmd".
- `Documents pour chaque étape d’analyse` : Codes R présent le dossier "scripts".
