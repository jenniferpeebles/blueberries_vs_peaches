# ============================================================
# 00_run_all.R
#
# Purpose: Run the complete Blueberries vs. Peaches pipeline in order.
# Inputs: NASS_API_KEY in .Renviron and internet access for script 01.
# Outputs: Data, QA tables, graphics, handoff files and documentation.
# Assumptions: Run from the project root; the run stops on the first failure.
# Workflow: Main entry point. Individual scripts may also be rerun.
# ============================================================

source("config.R")

pipeline_scripts <- file.path("scripts", c(
  "01_download_nass_data.R", "02_clean_production_data.R",
  "03_georgia_production_analysis.R", "04_county_blueberry_map.R",
  "05_acreage_analysis.R", "06_bump_charts.R",
  "07_reporter_brief.R", "08_data_dictionary.R", "09_build_readme.R"
))

run_started <- Sys.time()
run_id <- format(run_started, "%Y%m%d_%H%M%S")
log_file <- file.path(LOG_DIR, paste0("pipeline_run_", run_id, ".log"))
summary_file <- file.path(LOG_DIR, paste0("pipeline_summary_", run_id, ".csv"))
log_connection <- file(log_file, open = "wt")

sink(log_connection, split = TRUE)
sink(log_connection, type = "message")
on.exit({
  if (sink.number(type = "message") > 2) sink(type = "message")
  if (sink.number() > 0) sink()
  close(log_connection)
}, add = TRUE)

cat("BLUEBERRIES VS. PEACHES PIPELINE\nStarted:", format(run_started), "\n")
results <- tibble::tibble(script = character(), status = character(), seconds = numeric())

for (script_file in pipeline_scripts) {
  cat("\nRUNNING:", script_file, "\n")
  step_started <- Sys.time()
  error_message <- tryCatch({
    source(script_file, local = new.env(parent = globalenv()))
    NA_character_
  }, error = function(e) conditionMessage(e))

  step_status <- if (is.na(error_message)) "SUCCESS" else "FAILED"
  results <- dplyr::bind_rows(results, tibble::tibble(
    script = script_file,
    status = step_status,
    seconds = round(as.numeric(difftime(Sys.time(), step_started, units = "secs")), 1)
  ))
  readr::write_csv(results, summary_file)

  if (step_status == "FAILED") {
    if (interactive()) beepr::beep(3)
    stop("Pipeline stopped in ", script_file, ": ", error_message, call. = FALSE)
  }
}

cat("\nPIPELINE COMPLETE\n")
print(results)
cat("Runtime (minutes):", round(as.numeric(difftime(Sys.time(), run_started, units = "mins")), 2), "\n")
print(sessionInfo())
if (interactive()) beepr::beep(2)
