# ============================================================
# config.R
#
# Project configuration
# Blueberries vs Peaches
# Jennifer Peebles / AJC
# ============================================================

# ------------------------------------------------------------
# Setup
# ------------------------------------------------------------

# rm(list = ls())

options(
  scipen = 999,
  digits = 4,
  stringsAsFactors = FALSE
)

library(beepr)
library(glue)
library(janitor)
library(lubridate)
library(scales)
library(sf)
library(tidyverse)
library(tigris)

# ------------------------------------------------------------
# Source project files
# ------------------------------------------------------------

source("config.R")
source("R/functions_charts.R")
source("R/functions_maps.R")
source("R/functions_nass.R")
source("R/functions_qa.R")

# ------------------------------------------------------------
# Create directories
# ------------------------------------------------------------

dir.create(DATA_CLEAN_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(DATA_RAW_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(DOCS_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(EXPORT_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(LOG_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(DOCS_DIR, "data_dictionaries"), recursive = TRUE, showWarnings = FALSE)

# ------------------------------------------------------------
# Project folders
# ------------------------------------------------------------

project_dirs <- c(
  "data_raw",
  "data_clean",
  "exports",
  "outputs",
  "docs",
  "logs"
)

invisible(
  lapply(
    project_dirs,
    dir.create,
    recursive = TRUE,
    showWarnings = FALSE
  )
)

# ------------------------------------------------------------
# Logging
# ------------------------------------------------------------

timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")

log_file <- file.path(
  LOG_DIR,
  paste0("download_log_", timestamp, ".txt")
)

sink(log_file, split = TRUE)

# log_file <- file.path(
#   "logs",
#   paste0("pipeline_run_", timestamp, ".log")
# )

start_time <- Sys.time()

timestamp <- format(start_time, "%Y%m%d_%H%M%S")

# ------------------------------------------------------------
# Date parameters
# ------------------------------------------------------------

START_YEAR <- 2000

END_YEAR <- lubridate::year(Sys.Date())

COUNTY_ACREAGE_YEAR <- 2022

# ------------------------------------------------------------
# Directory structure
# ------------------------------------------------------------

DATA_RAW_DIR <- "data_raw"

DATA_CLEAN_DIR <- "data_clean"

EXPORT_DIR <- "exports"

OUTPUT_DIR <- "outputs"

DOCS_DIR <- "docs"

LOG_DIR <- "logs"

# ------------------------------------------------------------
# Selected states for bump charts
# ------------------------------------------------------------

SELECTED_PEACH_STATES <- c(
  "GA",
  "CA",
  "SC",
  "NJ",
  "PA",
  "MI"
)

SELECTED_BLUEBERRY_STATES <- c(
  "GA",
  "WA",
  "OR",
  "MI",
  "NJ",
  "CA"
)

# ------------------------------------------------------------
# Chart defaults
# ------------------------------------------------------------

DEFAULT_PLOT_WIDTH <- 10

DEFAULT_PLOT_HEIGHT <- 6

DEFAULT_DPI <- 300

WATERMARK_TEXT <- "NOT FOR PUBLICATION"

# ------------------------------------------------------------
# Attribution
# ------------------------------------------------------------

SOURCE_NASS <- paste(
  "Source: U.S. Department of Agriculture",
  "National Agricultural Statistics Service"
)

AJC_CREDIT <- paste(
  "Analysis & chart:",
  "Jennifer Peebles & Pete Corson/AJC"
)


cat("====================================================\n")
cat("BLUEBERRIES VS PEACHES PIPELINE\n")
cat("====================================================\n")
cat("Started: ", as.character(start_time), "\n\n")


# ------------------------------------------------------------
# Script registry
# ------------------------------------------------------------

pipeline_scripts <- c(
  "scripts/01_download_nass_data.R",
  "scripts/02_clean_production_data.R",
  "scripts/03_georgia_production_analysis.R",
  "scripts/04_county_blueberry_map.R",
  "scripts/05_acreage_analysis.R",
  "scripts/06_bump_charts.R",
  "scripts/07_reporter_brief.R",
  "scripts/08_data_dictionary.R",
  "scripts/09_build_readme.R"
)

results <- data.frame(
  script = character(),
  status = character(),
  stringsAsFactors = FALSE
)


# ------------------------------------------------------------
# Execute pipeline
# ------------------------------------------------------------

for (script_file in pipeline_scripts) {
  
  cat("\n----------------------------------------------------\n")
  cat("RUNNING:", script_file, "\n")
  cat("----------------------------------------------------\n")
  
  status <- tryCatch({
    
    source(script_file, local = new.env())
    
    "SUCCESS"
    
  }, error = function(e) {
    
    cat("\nERROR:\n")
    cat(conditionMessage(e), "\n")
    
    "FAILED"
  })
  
  results <- rbind(
    results,
    data.frame(
      script = script_file,
      status = status,
      stringsAsFactors = FALSE
    )
  )
  
  if (status == "FAILED") {
    
    cat("\nPIPELINE STOPPED DUE TO FAILURE\n")
    
    break
  }
}

# ------------------------------------------------------------
# Export run summary
# ------------------------------------------------------------

write.csv(
  results,
  file.path(
    "logs",
    paste0("pipeline_summary_", timestamp, ".csv")
  ),
  row.names = FALSE
)

end_time <- Sys.time()
runtime_minutes <- round(
  as.numeric(difftime(end_time, start_time, units = "mins")),
  2
)

cat("\n====================================================\n")
cat("PIPELINE SUMMARY\n")
cat("====================================================\n")
print(results)
cat("\nRuntime (minutes): ", runtime_minutes, "\n")
cat("Finished: ", as.character(end_time), "\n")

sessionInfo()

sink()

if (all(results$status == "SUCCESS")) {
  beepr::beep(2)
} else {
  beepr::beep(3)
}
