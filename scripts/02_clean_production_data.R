# ============================================================
# 02_clean_production_data.R
#
# Clean USDA NASS production data
# Blueberries vs. Peaches project
#
# Jennifer Peebles / AJC
# ============================================================

source("config.R")

# ------------------------------------------------------------
# Read raw data
# ------------------------------------------------------------

peaches_raw <- readr::read_csv(
  file.path(DATA_RAW_DIR, "peaches_production_raw.csv"),
  show_col_types = FALSE
)

blueberries_raw <- readr::read_csv(
  file.path(DATA_RAW_DIR, "blueberries_production_raw.csv"),
  show_col_types = FALSE
)

# ------------------------------------------------------------
# Document available USDA series
# ------------------------------------------------------------

peach_series_review <- peaches_raw %>%
  count(
    short_desc,
    unit_desc,
    class_desc,
    prodn_practice_desc,
    sort = TRUE
  )

blueberry_series_review <- blueberries_raw %>%
  count(
    short_desc,
    unit_desc,
    class_desc,
    prodn_practice_desc,
    sort = TRUE
  )

series_review <- bind_rows(
  peach_series_review %>% mutate(crop = "PEACHES"),
  blueberry_series_review %>% mutate(crop = "BLUEBERRIES")
)

write_csv(
  series_review,
  file.path(DOCS_DIR, "production_series_review.csv")
)

# ------------------------------------------------------------
# Clean peaches
# ------------------------------------------------------------

peaches_selected <- peaches_raw %>%
  filter(
    short_desc == "PEACHES, UTILIZED - PRODUCTION, MEASURED IN TONS",
    unit_desc == "TONS",
    prodn_practice_desc == "ALL PRODUCTION PRACTICES",
    domain_desc == "TOTAL"
  )

peach_production_exclusions <- peaches_selected %>%
  filter(is.na(value_num)) %>%
  select(any_of(c("year", "state_name", "state_alpha", "value", "cv_percent", "short_desc"))) %>%
  mutate(exclusion_reason = "USDA value missing or suppressed")

peaches_clean <- peaches_selected %>%
  transmute(
    year,
    state_name,
    state_alpha,
    commodity,
    short_desc,
    production = value_num,
    unit_desc
  ) %>%
  filter(!is.na(production))

# ------------------------------------------------------------
# Clean blueberries
# ------------------------------------------------------------

blueberries_selected <- blueberries_raw %>%
  filter(
    stringr::str_detect(short_desc, "BLUEBERRIES"),
    stringr::str_detect(short_desc, "TAME"),
    stringr::str_detect(short_desc, "UTILIZED"),
    unit_desc == "LB"
  )

blueberry_production_exclusions <- blueberries_selected %>%
  filter(is.na(value_num)) %>%
  select(any_of(c("year", "state_name", "state_alpha", "value", "cv_percent", "short_desc"))) %>%
  mutate(exclusion_reason = "USDA value missing or suppressed")

blueberries_clean <- blueberries_selected %>%
  transmute(
    year,
    state_name,
    state_alpha,
    commodity,
    short_desc,
    production = value_num,
    unit_desc
  ) %>%
  filter(!is.na(production))

# ------------------------------------------------------------
# QA
# ------------------------------------------------------------

qa_report(peaches_clean, "PEACHES_CLEAN")
qa_report(blueberries_clean, "BLUEBERRIES_CLEAN")

peach_dupes <- qa_duplicates(
  peaches_clean,
  year,
  state_alpha
)

blueberry_dupes <- qa_duplicates(
  blueberries_clean,
  year,
  state_alpha
)

stopifnot(nrow(peach_dupes) == 0)
stopifnot(nrow(blueberry_dupes) == 0)

# ------------------------------------------------------------
# Rankings
# ------------------------------------------------------------

peach_ranked <- rank_states(peaches_clean)
blueberry_ranked <- rank_states(blueberries_clean)

# ------------------------------------------------------------
# Georgia summary
# ------------------------------------------------------------

ga_summary <- bind_rows(
  peach_ranked,
  blueberry_ranked
) %>%
  filter(state_alpha == "GA") %>%
  mutate(
    commodity_label = case_when(
      commodity == "PEACHES" ~ "Peaches",
      commodity == "BLUEBERRIES" ~ "Blueberries",
      TRUE ~ commodity
    )
  ) %>%
  arrange(commodity_label, year)

# ------------------------------------------------------------
# Export cleaned datasets
# ------------------------------------------------------------

write_csv(
  peaches_clean,
  file.path(DATA_CLEAN_DIR, "peaches_clean.csv")
)

write_csv(
  blueberries_clean,
  file.path(DATA_CLEAN_DIR, "blueberries_clean.csv")
)

write_csv(
  peach_ranked,
  file.path(DATA_CLEAN_DIR, "peach_ranked.csv")
)

write_csv(
  blueberry_ranked,
  file.path(DATA_CLEAN_DIR, "blueberry_ranked.csv")
)

write_csv(
  ga_summary,
  file.path(DATA_CLEAN_DIR, "ga_summary.csv")
)

write_csv(
  bind_rows(
    peach_production_exclusions %>% mutate(crop = "Peaches"),
    blueberry_production_exclusions %>% mutate(crop = "Blueberries")
  ),
  file.path(DOCS_DIR, "production_exclusions.csv")
)

# ------------------------------------------------------------
# Completion summary
# ------------------------------------------------------------

cat("\n====================================")
cat("\nCLEANING COMPLETE")
cat("\n====================================")

cat("\nPeach rows:", nrow(peaches_clean))
cat("\nBlueberry rows:", nrow(blueberries_clean))
cat("\nGeorgia summary rows:", nrow(ga_summary))
cat("\nSelected production rows excluded as missing/suppressed:",
    nrow(peach_production_exclusions) + nrow(blueberry_production_exclusions))
cat("\n")

sessionInfo()

if (interactive()) beepr::beep(2)
