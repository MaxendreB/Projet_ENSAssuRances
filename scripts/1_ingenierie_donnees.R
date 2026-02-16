# =======================================================
# PROJET ENSAssuRances - Volet 1 : Ingénierie des données
# Auteur : Maxendre Bauthamy
# =======================================================

# Chargement des librairies
library(tidyverse)
library(readxl)
library(janitor)
library(lubridate)
library(visdat)
library(here)


# MANIPULATION DE DONNÉES TABULAIRES

# Chargement des données brutes
df_contrats <- read_excel(here("data/Contrat.xlsx")) %>% clean_names()
df_sinistres <- read_excel(here("data/Sinistre.xlsx")) %>% clean_names()

# Gestion des doublons
nb_doublons_ct <- sum(duplicated(df_contrats))
if(nb_doublons_ct > 0) {
  df_contrats <- df_contrats %>% distinct()
  print(paste("Doublons supprimés dans Contrats :", nb_doublons_ct))
}

# Structuration et typage
df_contrats <- df_contrats %>%
  mutate(
    sit_start_date = ymd(sit_start_date),
    sit_end_date = ymd(sit_end_date),
    sit_expo = as.numeric(sit_expo),
    drv1age = as.numeric(drv1age),
    vh_age = as.numeric(vh_age),
    vh_value = as.numeric(vh_value),
    idx_ct = as.character(idx_ct)
  )

df_sinistres <- df_sinistres %>%
  mutate(
    surv_sin = ymd(surv_sin),
    mt_regl = as.numeric(mt_regl),
    gest_sin = ymd(gest_sin),
    idx_sin = as.character(idx_sin)
  )

# Indexation et extraction de sous-ensembles pertinents
df_sinistres <- df_sinistres %>%
  arrange(idx_sin, desc(gest_sin))

df_sinistres_unique <- df_sinistres %>%
  group_by(idx_sin) %>%
  slice(1) %>%
  ungroup()


# RECODAGE ET TRANSFORMATION

df_contrats_clean <- df_contrats %>%
  mutate(
    # Recodage des modalités des variables catégorielles
    option_petit_rouleur = case_when(
      ct_km == "N" ~ "Non Souscrit",
      ct_km == "O" ~ "Souscrit",
      TRUE ~ "Inconnu"
    ),
    
    # Transformation variable continue
    tranche_age = cut(drv1age, 
                      breaks = c(17, 25, 60, 100), 
                      labels = c("Jeune (18-25)", "Adulte (26-60)", "Senior (>60)")),
    
    # Conversion en facteurs
    vh_energy  = as.factor(vh_energy),
    vh_segment = as.factor(vh_segment)
  )

# Agrégation des données par année
synthese_annee <- df_contrats_clean %>%
  group_by(idx_year) %>%
  summarise(
    nb_contrats = n(),
    age_moyen = mean(drv1age, na.rm = TRUE)
  )
print(synthese_annee)


# JOINTURE DE DONNÉES

# Pivot des colonnes ID sinistre dans Contrats
df_pivot <- df_contrats_clean %>%
  mutate(across(matches("^id[0-9]"), as.character)) %>%
  pivot_longer(
    cols = matches("^id[0-9]"),
    names_to = "pos_sinistre",
    values_to = "idx_sin",
    values_drop_na = TRUE
  )

# Fusion des tables avec Left_Join
df_consolide <- df_pivot %>%
  left_join(df_sinistres_unique, by = "idx_sin")

# Analyse de l'impact de la jointure
nb_lignes_pivot <- nrow(df_pivot)
nb_lignes_apres_join <- nrow(df_consolide)
sinistres_non_trouves <- sum(is.na(df_consolide$mt_regl))

cat("Lignes avant jointure : ", nb_lignes_pivot, "\n")
cat("Lignes après jointure : ", nb_lignes_apres_join, "\n")
cat("Sinistres déclarés dans Contrats mais introuvables dans Sinistre : ", sinistres_non_trouves, "\n")


# CONTRÔLE ET FLUX DE DONNÉES

# Structures conditionnelles et boucles
echantillon <- df_contrats_clean[1:100, ] 
for(i in 1:nrow(echantillon)) {
  valeur <- echantillon$vh_value[i]
  
  if(!is.na(valeur) && valeur > 40000) {
    echantillon$statut_vh[i] <- "Luxe"
  } else {
    echantillon$statut_vh[i] <- "Standard"
  }
}

# Recherche et extraction de cas spécifiques
vehicules_electriques <- df_contrats_clean %>% 
  filter(vh_energy == "Electrique" | vh_energy == "Hybride")

jeunes_conducteurs <- df_contrats_clean %>% 
  filter(drv1age < 25)


# TRANSFORMATION ET EXPLORATION

# Gestion des dates
df_contrats_clean <- df_contrats_clean %>%
  mutate(annee_reelle = year(sit_start_date))

# Visualisation des proportions
prop_segments <- prop.table(table(df_contrats_clean$vh_segment)) * 100
print(round(prop_segments, 2))


# VALEURS MANQUANTES ET DATA PROCESSING

# Identification des valeurs manquantes
col_avec_na <- names(which(sapply(df_contrats_clean, anyNA)))
print(paste("Colonnes avec NA :", paste(col_avec_na, collapse = ", ")))

# Stratégie d'imputation
moyenne_vh_value <- mean(df_contrats_clean$vh_value, na.rm = TRUE)

df_contrats_clean <- df_contrats_clean %>%
  mutate(
    vh_value_impute = ifelse(is.na(vh_value), moyenne_vh_value, vh_value),
    flag_imputation = ifelse(is.na(vh_value), "Imputé", "Origine")
  )

# Visualisation avec des graphiques d’imputation pour vérification
vis_miss(dplyr::slice_sample(df_contrats_clean))


# DONNÉES SPÉCIFIQUES

# Analyse des données spatiales : Extraction du Département depuis le Code INSEE
df_contrats_clean <- df_contrats_clean %>%
  mutate(departement = substr(ct_insee, 1, 2))


# CRÉATION DE LA TABLE FINALE

resume_sinistres <- df_consolide %>%
  group_by(idx_ct, idx_year) %>%
  summarise(
    nb_sinistres_total = n(),
    cout_sinistres_total = sum(mt_regl, na.rm = TRUE),
    .groups = "drop"
  )

df_final <- df_contrats_clean %>%
  left_join(resume_sinistres, by = c("idx_ct", "idx_year")) %>%
  mutate(
    nb_sinistres_total = replace_na(nb_sinistres_total, 0),
    cout_sinistres_total = replace_na(cout_sinistres_total, 0),
    is_sinistre = ifelse(nb_sinistres_total > 0, 1, 0)
  )

# Sauvegarde du DataFrame final
saveRDS(df_final, here("data/df_final.rds"))