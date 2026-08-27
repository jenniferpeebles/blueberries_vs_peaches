# ============================================================
# 07_reporter_brief.R
#
# Generate newsroom reporter brief
# Blueberries vs. Peaches project
#
# Jennifer Peebles / AJC
# ============================================================

# ------------------------------------------------------------
# Read inputs
# ------------------------------------------------------------

ga_summary <- readr::read_csv(
  file.path(DATA_CLEAN_DIR, "ga_summary.csv"),
  show_col_types = FALSE
)

acres_findings <- readr::read_csv(
  file.path(EXPORT_DIR, "reporter_acreage_findings.csv"),
  show_col_types = FALSE
)

bump_findings <- readr::read_csv(
  file.path(EXPORT_DIR, "reporter_bump_chart_findings.csv"),
  show_col_types = FALSE
)

# Optional files

top_counties <- tryCatch({
  readr::read_csv(
    file.path(EXPORT_DIR, "top_blueberry_counties.csv"),
    show_col_types = FALSE
  )
}, error = function(e) NULL)

# ------------------------------------------------------------
# Key statistics
# ------------------------------------------------------------

latest_year <- max(ga_summary$year, na.rm = TRUE)

latest_peach <- ga_summary |>
  filter(
    year == latest_year,
    commodity_label == "Peaches"
  )

latest_blueberry <- ga_summary |>
  filter(
    year == latest_year,
    commodity_label == "Blueberries"
  )

# ------------------------------------------------------------
# Build markdown brief
# ------------------------------------------------------------

brief_lines <- c(
  "# Reporter brief",
  "",
  glue("Generated: {Sys.Date()}"),
  "",
  "## Top findings",
  "",
  glue("* In {latest_year}, Georgia ranked No. {latest_peach$rank} nationally in peach production."),
  glue("* In {latest_year}, Georgia ranked No. {latest_blueberry$rank} nationally in blueberry production."),
  glue("* Georgia's share of U.S. peach production was {scales::percent(latest_peach$pct_of_us, accuracy = 0.1)}."),
  glue("* Georgia's share of U.S. blueberry production was {scales::percent(latest_blueberry$pct_of_us, accuracy = 0.1)}."),
  "",
  "## Acreage findings",
  ""
)

for(i in seq_len(nrow(acres_findings))) {
  brief_lines <- c(
    brief_lines,
    glue("* {acres_findings$commodity_label[i]}: {scales::comma(acres_findings$acres[i])} bearing acres ({acres_findings$year[i]}).")
  )
}

brief_lines <- c(
  brief_lines,
  "",
  "## Selected-state rankings",
  ""
)

for(i in seq_len(min(10, nrow(bump_findings)))) {
  brief_lines <- c(
    brief_lines,
    glue("* {bump_findings$crop[i]}: {bump_findings$state_name[i]} ranked No. {bump_findings$rank[i]} in {bump_findings$year[i]}.")
  )
}

if (!is.null(top_counties)) {
  brief_lines <- c(
    brief_lines,
    "",
    "## Leading blueberry counties",
    ""
  )

  top_n <- min(10, nrow(top_counties))

  for(i in seq_len(top_n)) {
    brief_lines <- c(
      brief_lines,
      glue("* {top_counties$county_name[i]} County: {scales::comma(top_counties$blueberry_acres[i])} bearing acres.")
    )
  }
}

brief_lines <- c(
  brief_lines,
  "",
  "## Caveats",
  "",
  "* Blueberry analysis uses tame (non-wild) blueberry production.",
  "* Wild blueberry production was excluded to avoid distortion from Maine's wild blueberry industry.",
  "* Peach production is reported by USDA in tons and converted to pounds only when making direct crop comparisons.",
  "* Acreage comparisons rely on years where USDA reported both crops.",
  "",
  "## Don't overstate",
  "",
  "* A high rank does not necessarily mean production is increasing.",
  "* Production changes may reflect weather, disease, market conditions, acreage changes, or reporting differences.",
  "",
  "## Suggested story angles",
  "",
  "* Georgia's identity as the Peach State versus its growing role in blueberry production.",
  "* Geographic concentration of blueberry acreage in South Georgia.",
  "* Long-term changes in fruit acreage and production.",
  "",
  "## Data sources",
  "",
  "* USDA National Agricultural Statistics Service (NASS) Quick Stats.",
  "* USDA Census of Agriculture acreage data."
)

output_file <- file.path(DOCS_DIR, "reporter_brief.md")
writeLines(brief_lines, output_file)

cat("Reporter brief written to:\n")
cat(output_file)
cat("\n")

sessionInfo()
beepr::beep(2)
