# --- CONFIGURATION GRAPHIQUE ---
library(scales) # Pour le formatage des axes (pourcentages, euros...)

# Définition d'un thème pro pour ENSAssuRances
theme_set(theme_minimal() +
            theme(
              plot.title = element_text(face = "bold", size = 14, color = "#2C3E50"),
              axis.title = element_text(face = "bold", size = 10),
              legend.position = "bottom"
            ))

# --- 1. DISTRIBUTION DES CONTRATS PAR ANNÉE ---
p1 <- ggplot(df_final, aes(x = factor(idx_year))) +
  geom_bar(fill = "steelblue") +
  labs(title = "Évolution du Portefeuille",
       subtitle = "Nombre de contrats par année d'exercice",
       x = "Année d'exercice",
       y = "Nombre de contrats") +
  geom_text(stat='count', aes(label=..count..), vjust=-0.5)

print(p1)

# --- 2. HISTOGRAMME DU TOTAL SINISTRES PAR ANNÉE ---
# On agrège d'abord les sinistres par année
sinistres_par_annee <- df_final %>%
  group_by(idx_year) %>%
  summarise(total_sinistres = sum(nb_sinistres_total))

p2 <- ggplot(sinistres_par_annee, aes(x = factor(idx_year), y = total_sinistres)) +
  geom_col(fill = "firebrick") +
  labs(title = "Sinistralité Globale",
       subtitle = "Nombre total de sinistres par année",
       x = "Année",
       y = "Nombre de sinistres") +
  geom_text(aes(label=total_sinistres), vjust=-0.5)

print(p2)


# --- 3. RÉPARTITION PAR SEGMENT (Bar Plot) ---
p3 <- ggplot(df_final, aes(x = fct_infreq(vh_segment))) + # fct_infreq trie par fréquence
  geom_bar(fill = "#2E86C1") +
  labs(title = "Composition du Parc : Segments Commerciaux",
       x = "Segment",
       y = "Nombre de véhicules") +
  coord_flip() # On met les barres à l'horizontale pour lire les noms

print(p3)

# --- 4. RÉPARTITION PAR ÉNERGIE ---
p4 <- ggplot(df_final, aes(x = vh_energy, fill = vh_energy)) +
  geom_bar() +
  labs(title = "Répartition par Motorisation",
       x = "Énergie",
       y = "Nombre de véhicules") +
  theme(legend.position = "none") # Pas besoin de légende si l'axe X est clair

print(p4)

# --- 5. DISTRIBUTION SELON LE GROUPE (SRA) ---
# Le groupe SRA détermine souvent la prime.
p5 <- ggplot(df_final, aes(x = factor(vh_group))) +
  geom_bar(fill = "darkcyan") +
  labs(title = "Distribution des Groupes de Véhicules",
       x = "Groupe SRA",
       y = "Effectif")

print(p5)


# --- 6. OPTION PETIT ROULEUR (Comparaison) ---
p6 <- ggplot(df_final, aes(x = ct_km, fill = ct_km)) +
  geom_bar() +
  labs(title = "Souscription à l'option Petit Rouleur",
       x = "Option Petit Rouleur (O/N)",
       y = "Nombre de contrats") +
  scale_fill_manual(values = c("gray", "orange"))

print(p6)

# --- 7. SINISTRES SELON L'ÂGE DU CONDUCTEUR ---
# Ici, on veut voir la distribution des âges de CEUX QUI ONT EU UN SINISTRE
# On filtre d'abord pour ne garder que les sinistrés
df_sinistres_seuls <- df_final %>% filter(nb_sinistres_total > 0)

p7 <- ggplot(df_sinistres_seuls, aes(x = drv1age)) +
  geom_histogram(binwidth = 2, fill = "purple", color = "white", alpha = 0.7) +
  labs(title = "Distribution de l'âge des conducteurs accidentés",
       subtitle = "Pic de sinistralité chez les jeunes ?",
       x = "Âge du conducteur",
       y = "Nombre de sinistres") +
  scale_x_continuous(breaks = seq(18, 90, 10))

print(p7)

# --- 8. IMPACT DES ANTÉCÉDENTS (BONUS/MALUS) ---
# Relation entre historique passé (claims_ant) et sinistres actuels
p8 <- ggplot(df_final, aes(x = factor(claims_ant), y = nb_sinistres_total)) +
  stat_summary(fun = "mean", geom = "bar", fill = "darkred") +
  labs(title = "Fréquence moyenne de sinistre selon les antécédents",
       subtitle = "Un conducteur ayant déjà eu des sinistres est-il plus à risque ?",
       x = "Nombre de sinistres antérieurs (Années précédentes)",
       y = "Fréquence moyenne (Sinistres/Contrat)")

print(p8)


# --- 9. SINISTRES PAR SEGMENT COMMERCIAL ---
# On regarde le volume total de sinistres par type de voiture
p9 <- df_final %>%
  group_by(vh_segment) %>%
  summarise(nb_sinistres = sum(nb_sinistres_total)) %>%
  ggplot(aes(x = reorder(vh_segment, nb_sinistres), y = nb_sinistres)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Sinistralité par Segment de Véhicule",
       x = "Segment",
       y = "Volume total de sinistres")

print(p9)

# --- 10. RISQUE SELON LE SEXE (Nombre et Pourcentage) ---
# On prépare les données : total sinistres par sexe / total contrats par sexe
analyse_sexe <- df_final %>%
  group_by(drv1sex) %>%
  summarise(
    Total_Contrats = n(),
    Total_Sinistres = sum(nb_sinistres_total),
    Frequence = Total_Sinistres / Total_Contrats
  )

# Visualisation de la Fréquence (plus pertinent que le nombre absolu)
p10 <- ggplot(analyse_sexe, aes(x = drv1sex, y = Frequence, fill = drv1sex)) +
  geom_col() +
  geom_text(aes(label = percent(Frequence, accuracy = 0.01)), vjust = -0.5) +
  labs(title = "Fréquence de sinistre par Genre",
       subtitle = "Ratio : Nombre de sinistres / Nombre de contrats",
       x = "Genre",
       y = "Fréquence") +
  scale_y_continuous(labels = scales::percent)

print(p10)


# --- 11. ZONES GÉOGRAPHIQUES À RISQUE ---
# On extrait les 2 premiers chiffres du code INSEE pour avoir le département
df_geo <- df_final %>%
  mutate(departement = str_sub(ct_insee, 1, 2)) %>%
  group_by(departement) %>%
  summarise(
    nb_contrats = n(),
    nb_sinistres = sum(nb_sinistres_total),
    frequence = nb_sinistres / nb_contrats
  ) %>%
  filter(nb_contrats > 100) %>% # On ne garde que les départements avec assez de volume
  arrange(desc(frequence)) %>%
  slice(1:15) # Top 15

p11 <- ggplot(df_geo, aes(x = reorder(departement, frequence), y = frequence)) +
  geom_col(fill = "darkorange") +
  coord_flip() +
  labs(title = "Top 15 Départements à plus forte fréquence de sinistre",
       subtitle = "Zones à surveiller pour la tarification",
       x = "Département (Code)",
       y = "Fréquence de sinistre") +
  scale_y_continuous(labels = scales::percent)

print(p11)