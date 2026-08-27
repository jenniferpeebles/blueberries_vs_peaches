# ============================================================
# 09_build_readme.R
#
# Generate project README.md automatically
# Blueberries vs. Peaches project
#
# Jennifer Peebles / AJC
# ============================================================


# ------------------------------------------------------------
# Gather project metadata
# ------------------------------------------------------------

script_files <- if (dir.exists("scripts")) {
  list.files("scripts", pattern = "\\.R$", full.names = FALSE)
} else {
  character(0)
}

function_files <- if (dir.exists("R")) {
  list.files("R", pattern = "\\.R$", full.names = FALSE)
} else {
  character(0)
}

# ------------------------------------------------------------
# Build README
# ------------------------------------------------------------

readme_lines <- c(
  "# Blueberries vs. Peaches",
  "",
  "USDA NASS analysis of Georgia blueberry and peach production, acreage, rankings, and county geography.",
  "",
  paste("README generated:", Sys.Date()),
  "",
  "## Reporting question",
  "",
  "How does Georgia's modern blueberry industry compare with its traditional peach industry?",
  "",
  "## Data sources",
  "",
  "* USDA National Agricultural Statistics Service (NASS) Quick Stats",
  "* USDA Census of Agriculture",
  "* U.S. Census Bureau TIGER/Line county boundaries via tigris",
  "",
  "## Project structure",
  "",
  "```text",
  "config.R",
  "R/",
  "scripts/",
  "data_raw/",
  "data_clean/",
  "exports/",
  "outputs/",
  "docs/",
  "logs/",
  "```",
  "",
  "## Pipeline scripts",
  ""
)

if (length(script_files) > 0) {
  readme_lines <- c(
    readme_lines,
    paste("*", script_files)
  )
}

readme_lines <- c(
  readme_lines,
  "",
  "## Reusable functions",
  ""
)

if (length(function_files) > 0) {
  readme_lines <- c(
    readme_lines,
    paste("*", function_files)
  )
}

readme_lines <- c(
  readme_lines,
  "",
  "## Key outputs",
  "",
  "* Georgia production comparison charts",
  "* State ranking charts",
  "* Bump charts",
  "* County blueberry acreage map",
  "* GeoJSON exports",
  "* Reporter brief",
  "* Data dictionaries",
  "",
  "## QA standards",
  "",
  "* Duplicate detection",
  "* Missing value audits",
  "* Map join validation",
  "* Production-series review",
  "* Reproducible exports and logs",
  "",
  "## Running the project",
  "",
  "Run scripts in numerical order or use a future run_all.R orchestrator.",
  "",
  "## Caveats",
  "",
  "* Wild blueberries are excluded from production analysis.",
  "* Peach production is commonly reported in tons while blueberry production is reported in pounds.",
  "* Acreage comparisons depend on USDA reporting availability.",
  "",
  "## Authorship",
  "",
  "Jennifer Peebles / Atlanta Journal-Constitution"
)

writeLines(readme_lines, "README.md")

cat("README.md generated successfully\n")

sessionInfo()
beepr::beep(2)
