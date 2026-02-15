# --- CHARGEMENT ET PRÉPARATION DES DONNÉES (VOLET 1) ---
# Option 1 : Charger les données prétraitées
# load("df_final.RData")

# Option 2 : Exécuter tout le traitement du Volet 1
# Chargement des données brutes
df_contrats <- read_excel("data/Contrat.xlsx") %>% clean_names()
df_sinistres <- read_excel("data/Sinistre.xlsx") %>% clean_names()

# Nettoyage des noms
df_contrats <- df_contrats %>% clean_names()
df_sinistres <- df_sinistres %>% clean_names()

# Traitement des contrats
df_contrats_clean <- df_contrats %>%
  mutate(
    sit_start_date = ymd(sit_start_date), 
    sit_end_date   = ymd(sit_end_date),
    sit_expo              = as.numeric(sit_expo),
    drv1age               = as.numeric(drv1age),
    drv1drive_licence_age = as.numeric(drv1drive_licence_age),
    vh_age                = as.numeric(vh_age),
    vh_value              = as.numeric(vh_value),
    cot_ass_base          = as.numeric(cot_ass_base),
    cot_ass0km            = as.numeric(cot_ass0km),
    cot_ass_vhr           = as.numeric(cot_ass_vhr),
    drv1sex      = as.factor(drv1sex),
    vh_energy    = as.factor(vh_energy),
    vh_segment   = as.factor(vh_segment),
    ct_usage     = as.factor(ct_usage)
  )

# Traitement des sinistres
df_sinistres_clean <- df_sinistres %>%
  mutate(
    surv_sin = ymd(surv_sin),
    decl_sin = ymd(decl_sin),
    clo_sin  = ymd(clo_sin),
    gest_sin = ymd(gest_sin),
    mt_eval = as.numeric(mt_eval),
    mt_regl = as.numeric(mt_regl),
    gar_sin = as.factor(gar_sin)
  )

# Sinistres uniques
df_sinistres_unique <- df_sinistres_clean %>%
  group_by(idx_sin) %>%
  arrange(desc(gest_sin)) %>%
  slice(1) %>%
  ungroup()

# Pivot et jointure
df_joined <- df_contrats_clean %>%
  mutate(across(matches("^id[0-9]"), as.character)) %>%
  pivot_longer(
    cols = matches("^id[0-9]"),    
    names_to = "position_sinistre", 
    values_to = "idx_sin",          
    values_drop_na = TRUE
  )

df_consolide <- df_joined %>%
  left_join(df_sinistres_unique, by = "idx_sin")

# Base finale
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