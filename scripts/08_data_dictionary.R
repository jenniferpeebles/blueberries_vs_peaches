# ============================================================
# 08_data_dictionary.R
#
# Generate data dictionaries for project datasets
# Blueberries vs. Peaches project
#
# Jennifer Peebles / AJC
# ============================================================

source("config.R")

# ------------------------------------------------------------
# Helper function
# ------------------------------------------------------------

create_data_dictionary <- function(df, dataset_name) {

  tibble::tibble(
    dataset = dataset_name,
    field_name = names(df),
    field_type = purrr::map_chr(df, ~ class(.x)[1]),
    missing_values = purrr::map_int(df, ~ sum(is.na(.x))),
    distinct_values = purrr::map_int(df, dplyr::n_distinct)
  )
}

# ------------------------------------------------------------
# Files to document
# ------------------------------------------------------------

candidate_dirs <- c(
  DATA_RAW_DIR,
  DATA_CLEAN_DIR,
  EXPORT_DIR
)

csv_files <- unlist(
  lapply(
    candidate_dirs,
    function(x) {
      if (dir.exists(x)) {
        list.files(
          x,
          pattern = "\\.csv$",
          full.names = TRUE
        )
      } else {
        character(0)
      }
    }
  )
)

# ------------------------------------------------------------
# Build dictionaries
# ------------------------------------------------------------

master_dictionary <- tibble::tibble()

for (file_path in csv_files) {

  dataset_name <- tools::file_path_sans_ext(
    basename(file_path)
  )

  message(paste("Documenting:", dataset_name))

  df <- readr::read_csv(
    file_path,
    show_col_types = FALSE
  )

  dictionary <- create_data_dictionary(
    df,
    dataset_name
  )

  readr::write_csv(
    dictionary,
    file.path(
      DOCS_DIR,
      "data_dictionaries",
      paste0(dataset_name, "_dictionary.csv")
    )
  )

  master_dictionary <- dplyr::bind_rows(
    master_dictionary,
    dictionary
  )
}

# ------------------------------------------------------------
# Master dictionary
# ------------------------------------------------------------

readr::write_csv(
  master_dictionary,
  file.path(
    DOCS_DIR,
    "master_data_dictionary.csv"
  )
)

# ------------------------------------------------------------
# Markdown summary
# ------------------------------------------------------------

summary_lines <- c(
  "# Data dictionary summary",
  "",
  paste("Generated:", Sys.Date()),
  "",
  paste("Datasets documented:", length(unique(master_dictionary$dataset))),
  paste("Fields documented:", nrow(master_dictionary))
)

writeLines(
  summary_lines,
  file.path(DOCS_DIR, "data_dictionary_summary.md")
)

cat("\n====================================\n")
cat("DATA DICTIONARY COMPLETE\n")
cat("====================================\n")
cat("\nDatasets documented: ", length(unique(master_dictionary$dataset)), "\n")
cat("Fields documented: ", nrow(master_dictionary), "\n")

sessionInfo()

if (interactive()) beepr::beep(2)
