# ============================================================
# functions_qa.R
#
# Reusable QA functions
# Jennifer Peebles / AJC
# ============================================================

# ------------------------------------------------------------
# Basic dataset overview
# ------------------------------------------------------------
qa_dataset <- function(
  df,
  dataset_name = deparse(substitute(df))
) {

  cat("\n")
  cat(rep("=", 60), sep = "")
  cat("\nDATASET QA:", dataset_name)
  cat("\n")
  cat(rep("=", 60), sep = "")
  cat("\n")

  cat("\nRows:", format(nrow(df), big.mark = ","))
  cat("\nColumns:", ncol(df))

  invisible(df)
}

# ------------------------------------------------------------
# Missing values audit
# ------------------------------------------------------------
qa_missing_values <- function(df) {

  df |>
    dplyr::summarise(
      dplyr::across(
        everything(),
        ~ sum(is.na(.))
      )
    ) |>
    tidyr::pivot_longer(
      everything(),
      names_to = "field",
      values_to = "missing_values"
    ) |>
    dplyr::arrange(
      dplyr::desc(missing_values)
    )
}

# ------------------------------------------------------------
# Duplicate record finder
# ------------------------------------------------------------
qa_duplicates <- function(df, ...) {

  df |>
    dplyr::count(...) |>
    dplyr::filter(n > 1) |>
    dplyr::arrange(dplyr::desc(n))
}

# ------------------------------------------------------------
# Join QA
# ------------------------------------------------------------
qa_join <- function(
  left_df,
  right_df,
  by
) {

  unmatched_left <- dplyr::anti_join(
    left_df,
    right_df,
    by = by
  )

  unmatched_right <- dplyr::anti_join(
    right_df,
    left_df,
    by = by
  )

  list(
    unmatched_left = unmatched_left,
    unmatched_right = unmatched_right
  )
}

# ------------------------------------------------------------
# Category review
# ------------------------------------------------------------
qa_categories <- function(df, variable) {

  df |>
    dplyr::count(
      {{ variable }},
      sort = TRUE
    )
}

# ------------------------------------------------------------
# Numeric range review
# ------------------------------------------------------------
qa_numeric_range <- function(df, variable) {

  x <- dplyr::pull(df, {{ variable }})

  tibble::tibble(
    minimum = min(x, na.rm = TRUE),
    maximum = max(x, na.rm = TRUE),
    mean = mean(x, na.rm = TRUE),
    median = median(x, na.rm = TRUE),
    missing = sum(is.na(x))
  )
}

# ------------------------------------------------------------
# Negative value checker
# ------------------------------------------------------------
qa_negative_values <- function(df, variable) {

  df |>
    dplyr::filter(
      {{ variable }} < 0
    )
}

# ------------------------------------------------------------
# Year coverage review
# ------------------------------------------------------------
qa_years <- function(df) {

  if (!"year" %in% names(df)) {
    stop("No year field found.")
  }

  tibble::tibble(
    min_year = min(df$year, na.rm = TRUE),
    max_year = max(df$year, na.rm = TRUE),
    distinct_years = dplyr::n_distinct(df$year)
  )
}

# ------------------------------------------------------------
# Geography comparison
# ------------------------------------------------------------
qa_geography_match <- function(
  spatial_df,
  data_df,
  by
) {

  qa_join(
    spatial_df,
    data_df,
    by = by
  )
}

# ------------------------------------------------------------
# Percentage bounds checker
# ------------------------------------------------------------
qa_pct_bounds <- function(df, variable) {

  df |>
    dplyr::filter(
      {{ variable }} < 0 |
      {{ variable }} > 1
    )
}

# ------------------------------------------------------------
# Quick QA report
# ------------------------------------------------------------
qa_report <- function(
  df,
  dataset_name = deparse(substitute(df))
) {

  cat("\n")
  cat(rep("=", 60), sep = "")
  cat("\nQA REPORT:", dataset_name)
  cat("\n")
  cat(rep("=", 60), sep = "")
  cat("\n")

  cat("\nRows:")
  print(nrow(df))

  cat("\nColumns:")
  print(ncol(df))

  cat("\nMissing values:\n")
  print(qa_missing_values(df))

  invisible(df)
}
