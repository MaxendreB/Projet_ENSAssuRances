# ===================================================
# PROJET ENSAssuRances - Volet 2 : Data Visualisation
# Auteur : Maxendre Bauthamy
# ===================================================

# Chargement des librairies
library(tidyverse)
library(scales)

# Chargement des données préparées au Volet 1
df_final <- readRDS("data/df_final.rds")

# Définition du thème commun
theme_set(theme_minimal() +
            theme(
              plot.title = element_text(face = "bold", size = 14, color = "#2C3E50"),
              axis.title = element_text(face = "bold"),
              legend.position = "bottom"
            ))


# ANALYSES TEMPORELLES

# Histogramme du total de sinistres par année
df_sinistres_annee <- df_final %>%
  group_by(idx_year) %>%
  summarise(total_sinistres = sum(nb_sinistres_total))

ggplot(df_sinistres_annee, aes(x = factor(idx_year), y = total_sinistres)) +
  geom_col(fill = "#C0392B") +
  geom_text(aes(label = total_sinistres), vjust = -0.5) +
  labs(title = "Total de sinistres par année",
       x = "Année", y = "Nombre de sinistres")


# Distribution des contrats par année d’exercice
ggplot(df_final, aes(x = factor(idx_year))) +
  geom_bar(fill = "#2980B9") +
  geom_text(stat = 'count', aes(label = ..count..), vjust = -0.5) +
  labs(title = "Distribution des contrats par année",
       subtitle = "Évolution de la taille du portefeuille",
       x = "Année", y = "Nombre de contrats actifs")


# ANALYSE VÉHICULE

# Bar plot de répartition des types de véhicules
ggplot(df_final, aes(x = fct_infreq(vh_segment))) +
  geom_bar(fill = "#16A085") +
  coord_flip() +
  labs(title = "Répartition des types de véhicules",
       x = "Types de véhicules", y = "Nombre de véhicules")


# Répartition des véhicules selon l’alimentation (essence, diesel, électrique…)
ggplot(df_final, aes(x = vh_energy, fill = vh_energy)) +
  geom_bar() +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Répartition des véhicules selon l’alimentation",
       x = "Énergie", y = "Volume") +
  theme(legend.position = "none")

### ======================================================================================================================================================
# Distribution des véhicules selon leur groupe
ggplot(df_final, aes(x = factor(vh_group))) +
  geom_bar(fill = "#8E44AD") +
  labs(title = "Distribution des véhicules selon leur groupe",
       subtitle = "Classification technique des véhicules",
       x = "Groupe", y = "Effectif")
### ======================================================================================================================================================


# FACTEURS DE RISQUE

# Histogramme des contrats avec ou sans option petit rouleur
ggplot(df_final, aes(x = ct_km, fill = ct_km)) +
  geom_bar() +
  scale_fill_manual(values = c("gray", "orange")) +
  labs(title = "Répartition Option Petit Rouleur",
       x = "Option souscrite ?", y = "Nombre de contrats")


# Nombre de sinistres en fonction de l’âge du sociétaire
sinistres_seuls <- df_final %>% filter(nb_sinistres_total > 0)

ggplot(sinistres_seuls, aes(x = drv1age)) +
  geom_histogram(binwidth = 2, fill = "#E74C3C", color = "white", alpha = 0.8) +
  labs(title = "Sinistres selon l'âge",
       subtitle = "Distribution de l'âge des conducteurs accidentés",
       x = "Âge du sociétaire", y = "Nombre de sinistres")


# Nombre de sinistres selon le nombre de sinistres antécédents
sinistres_par_ant <- df_final %>%
  group_by(claims_ant) %>%
  summarise(nb_sinistres = sum(nb_sinistres_total))

ggplot(sinistres_par_ant, aes(x = factor(claims_ant), y = nb_sinistres)) +
  geom_col(fill = "#34495E") +
  labs(title = "Sinistres selon les antécédents",
       x = "Nombre de sinistres passés (Historique)",
       y = "Nombre de sinistres actuels (Total)")


# Nombre de sinistres par segment commercial du véhicule
vol_sinistre_segment <- df_final %>%
  group_by(vh_segment) %>%
  summarise(nb = sum(nb_sinistres_total))

ggplot(vol_sinistre_segment, aes(x = reorder(vh_segment, nb), y = nb)) +
  geom_col(fill = "#D35400") +
  coord_flip() +
  labs(title = "Nombre de sinistres par Segment (Type de véhicule)",
       x = "", y = "Volume de sinistres")


# ANALYSES AVANCÉES

# Identification des véhicules à risque élevé
# On définit le risque par la fréquence (Nb sinistres / Nb contrats)
risque_vehicule <- df_final %>%
  group_by(vh_segment) %>%
  summarise(
    nb_contrats = n(),
    nb_sinistres = sum(nb_sinistres_total),
    frequence = nb_sinistres / nb_contrats
  ) %>%
  arrange(desc(frequence))

ggplot(risque_vehicule, aes(x = reorder(vh_segment, frequence), y = frequence)) +
  geom_col(fill = "#27AE60") +
  coord_flip() +
  geom_text(aes(label = percent(frequence, 0.01)), hjust = -0.1) +
  labs(title = "Véhicules à risque élevé",
       subtitle = "Classement par fréquence de sinistre",
       x = "", y = "Fréquence (Sinistres / Contrats)") +
  scale_y_continuous(labels = percent)


# Nombre et pourcentage de sinistres selon le sexe
analyse_sexe <- df_final %>%
  group_by(drv1sex) %>%
  summarise(nb_sinistres = sum(nb_sinistres_total)) %>%
  mutate(pourcentage = nb_sinistres / sum(nb_sinistres))

ggplot(analyse_sexe, aes(x = drv1sex, y = nb_sinistres, fill = drv1sex)) +
  geom_col() +
  geom_text(aes(label = paste0(nb_sinistres, "\n(", percent(pourcentage, 0.1), ")")), 
            vjust = -0.5) +
  labs(title = "Répartition des sinistres par Sexe",
       x = "Genre", y = "Nombre de sinistres") +
  theme(legend.position = "none")


# Carte des zones géographiques à risque
geo_risk <- df_final %>%
  group_by(departement) %>%
  summarise(
    nb_sinistres = sum(nb_sinistres_total),
    nb_contrats = n(),
    frequence = nb_sinistres / nb_contrats
  ) %>%
  filter(nb_contrats > 100) %>%
  arrange(desc(frequence)) %>%
  slice(1:15)

ggplot(geo_risk, aes(x = reorder(departement, frequence), y = frequence)) +
  geom_col(fill = "firebrick") +
  coord_flip() +
  labs(title = "Zones Géographiques à Risque (Top 15)",
       subtitle = "Départements avec la plus forte fréquence de sinistre",
       x = "Code Département", y = "Fréquence") +
  scale_y_continuous(labels = percent)