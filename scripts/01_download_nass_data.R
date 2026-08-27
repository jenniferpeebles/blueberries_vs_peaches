# ============================================================
# 01_download_nass_data.R
#
# Download USDA NASS data for
# Blueberries vs Peaches project
#
# Jennifer Peebles / AJC
# ============================================================


cat("\n=========================================\n")
cat("Blueberries vs Peaches\n")
cat("NASS Download Script\n")
cat("=========================================\n")
cat("\nRun started:", as.character(Sys.time()), "\n")

# ------------------------------------------------------------
# Authenticate
# ------------------------------------------------------------

authenticate_nass()

# ------------------------------------------------------------
# Production data
# ------------------------------------------------------------

message("Downloading peach production...")

peaches_raw <- get_crop_production(
  commodity = "PEACHES",
  start_year = START_YEAR,
  end_year = END_YEAR
)

qa_report(peaches_raw, "PEACH_PRODUCTION_RAW")

message("Downloading blueberry production...")

blueberries_raw <- get_crop_production(
  commodity = "BLUEBERRIES",
  start_year = START_YEAR,
  end_year = END_YEAR
)

qa_report(blueberries_raw, "BLUEBERRY_PRODUCTION_RAW")

# ------------------------------------------------------------
# Georgia acreage
# ------------------------------------------------------------

message("Downloading peach acreage...")

ga_peach_acres_raw <- get_crop_acreage(
  commodity = "PEACHES",
  state_alpha = "GA",
  start_year = START_YEAR,
  end_year = END_YEAR
)

qa_report(ga_peach_acres_raw, "GA_PEACH_ACREAGE_RAW")

message("Downloading blueberry acreage...")

ga_blueberry_acres_raw <- get_crop_acreage(
  commodity = "BLUEBERRIES",
  state_alpha = "GA",
  start_year = START_YEAR,
  end_year = END_YEAR
)

qa_report(ga_blueberry_acres_raw, "GA_BLUEBERRY_ACREAGE_RAW")

# ------------------------------------------------------------
# County blueberry acreage
# ------------------------------------------------------------

message("Downloading Georgia blueberry county acreage...")

ga_blueberry_counties_raw <- get_county_acreage(
  commodity = "BLUEBERRIES",
  state_alpha = "GA",
  year = COUNTY_ACREAGE_YEAR,
  class_desc = "TAME"
)

qa_report(
  ga_blueberry_counties_raw,
  "GA_BLUEBERRY_COUNTIES_RAW"
)

# ------------------------------------------------------------
# Export raw files
# ------------------------------------------------------------

readr::write_csv(
  peaches_raw,
  file.path(DATA_RAW_DIR, "peaches_production_raw.csv")
)

readr::write_csv(
  blueberries_raw,
  file.path(DATA_RAW_DIR, "blueberries_production_raw.csv")
)

readr::write_csv(
  ga_peach_acres_raw,
  file.path(DATA_RAW_DIR, "ga_peaches_acreage_raw.csv")
)

readr::write_csv(
  ga_blueberry_acres_raw,
  file.path(DATA_RAW_DIR, "ga_blueberries_acreage_raw.csv")
)

readr::write_csv(
  ga_blueberry_counties_raw,
  file.path(DATA_RAW_DIR, "ga_blueberry_counties_raw.csv")
)

# ------------------------------------------------------------
# Run summary
# ------------------------------------------------------------

cat("\n=========================================\n")
cat("DOWNLOAD SUMMARY\n")
cat("=========================================\n")

cat("\nPeach production rows:", nrow(peaches_raw))
cat("\nBlueberry production rows:", nrow(blueberries_raw))
cat("\nGA peach acreage rows:", nrow(ga_peach_acres_raw))
cat("\nGA blueberry acreage rows:", nrow(ga_blueberry_acres_raw))
cat("\nGA county acreage rows:", nrow(ga_blueberry_counties_raw))
cat("\n\nRun completed:", as.character(Sys.time()), "\n")

sink()

beepr::beep(2)

message("01_download_nass_data.R completed successfully.")
