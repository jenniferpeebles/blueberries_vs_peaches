# ============================================================
# config.R
#
# Purpose: User-editable settings and shared setup for this pipeline.
# Inputs: None. Script 01 alone reads NASS_API_KEY from .Renviron.
# Outputs: Project settings, directories and shared helper functions.
# Assumptions: Run from the project root (the folder with the .Rproj).
# Workflow: Sourced first by every numbered script and 00_run_all.R.
# ============================================================

options(scipen = 999, digits = 4, stringsAsFactors = FALSE, tigris_use_cache = TRUE)

REQUIRED_PACKAGES <- c(
  "beepr", "glue", "janitor", "lubridate", "peeblestoolbox",
  "rnassqs", "scales", "sf", "tidyverse", "tigris", "viridis"
)

missing_packages <- REQUIRED_PACKAGES[
  !vapply(REQUIRED_PACKAGES, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  stop(
    "Install these required packages before running the pipeline: ",
    paste(missing_packages, collapse = ", "),
    call. = FALSE
  )
}

suppressPackageStartupMessages({
  library(tidyverse)
  library(sf)
  library(glue)
})

# User-editable analysis settings
START_YEAR <- 2000L
END_YEAR <- lubridate::year(Sys.Date())
COUNTY_ACREAGE_YEAR <- 2022L
COUNTY_BOUNDARY_YEAR <- 2024L

SELECTED_PEACH_STATES <- c("GA", "CA", "SC", "NJ", "PA", "MI")
SELECTED_BLUEBERRY_STATES <- c("GA", "WA", "OR", "MI", "NJ", "CA")

DEFAULT_PLOT_WIDTH <- 10
DEFAULT_PLOT_HEIGHT <- 6
DEFAULT_DPI <- 300
CAPTION_WRAP_WIDTH <- 105
WATERMARK_TEXT <- "NOT FOR PUBLICATION"

# Project directories
DATA_RAW_DIR <- "data_raw"
DATA_CLEAN_DIR <- "data_clean"
EXPORT_DIR <- "exports"
OUTPUT_DIR <- "outputs"
DOCS_DIR <- "docs"
LOG_DIR <- "logs"

PROJECT_DIRS <- c(
  DATA_RAW_DIR, DATA_CLEAN_DIR, EXPORT_DIR, OUTPUT_DIR, DOCS_DIR, LOG_DIR,
  file.path(DOCS_DIR, "data_dictionaries")
)
invisible(lapply(PROJECT_DIRS, dir.create, recursive = TRUE, showWarnings = FALSE))

# Attribution
SOURCE_NASS <- paste(
  "Source: U.S. Department of Agriculture National Agricultural",
  "Statistics Service (USDA NASS) Quick Stats."
)
AJC_CREDIT <- "Analysis & chart: Jennifer Peebles & Pete Corson/AJC"

# Project helpers
source(file.path("R", "functions_charts.R"))
source(file.path("R", "functions_maps.R"))
source(file.path("R", "functions_nass.R"))
source(file.path("R", "functions_qa.R"))
