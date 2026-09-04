# Blueberries vs. Peaches

USDA NASS analysis of Georgia blueberry and peach production, acreage, rankings, and county geography.

README generated: 2026-09-04

## Reporting question

Is Georgia really the Peach State? Or is it now the Blueberry State? How does Georgia's modern blueberry industry compare with its traditional peach industry? Those are questions I wanted to answer for my *Atlanta Journal-Constitution* colleague Olivia Wakim for her [May 2026 story on Georgia blueberries](https://www.ajc.com/food-and-dining/2026/05/blueberries-taking-bigger-bite-of-business-in-peach-state/).

## Key requirement

Users will need an API key from the U.S. Department of Agriculture's National Agricultural Statistics Service (NASS) to use this code. The code assumes the key is saved as `NASS_API_KEY` in the user's .Renviron file. Getting a key is free -- [sign up for one at this link](https://quickstats.nass.usda.gov/api).

## Data sources

* USDA [National Agricultural Statistics Service (NASS)](https://www.nass.usda.gov/) Quick Stats
* USDA Census of Agriculture
* U.S. Census Bureau TIGER/Line county boundaries via [tigris](https://cran.r-project.org/web/packages/tigris/index.html)

## Project structure

```text
config.R
R/
scripts/
data_raw/
data_clean/
exports/
outputs/
docs/
logs/
```

## Pipeline scripts

* 00_run_all.R
* 01_download_nass_data.R
* 02_clean_production_data.R
* 03_georgia_production_analysis.R
* 04_county_blueberry_map.R
* 05_acreage_analysis.R
* 06_bump_charts.R
* 07_reporter_brief.R
* 08_data_dictionary.R
* 09_build_readme.R

## Reusable functions

* functions_charts.R
* functions_maps.R
* functions_nass.R
* functions_qa.R

## Key outputs

* Georgia production comparison charts
* State ranking charts
* Bump charts
* County blueberry acreage map
* GeoJSON exports
* Reporter brief
* Data dictionaries

## QA standards

* Duplicate detection
* Missing value audits
* Map join validation
* Production-series review
* Reproducible exports and logs

## Running the project

Open the `.Rproj`, add `NASS_API_KEY` to `.Renviron`, then run `scripts/00_run_all.R` from the project root. The runner stops on the first failed stage and writes a log and CSV summary to `logs/`.

If the raw downloads already exist, scripts 02 through 09 can be rerun without making another API request.

## Peebles Pipeline pieces

* `peeblestoolbox` supplies the chart and map themes, review watermark, plot saver, Georgia county boundaries, and WGS84 GeoJSON export.
* `docs/production_exclusions.csv` accounts for selected production records excluded because USDA values were missing or suppressed.
* County map QA distinguishes published values, missing or suppressed values, and counties with no USDA record. Gray does not mean zero.
* `docs/reporter_brief.md` is generated as a deterministic Mad-Lib from current outputs.

## Caveats

* Wild blueberries are excluded from production analysis.
* Peach production is commonly reported in tons while blueberry production is reported in pounds.
* Acreage comparisons depend on USDA reporting availability.

## Special thanks
This project uses a number of R packages, including the [tidyverse family of packages](https://tidyverse.tidyverse.org/index.html) created by [Hadley Wickham](https://hadley.nz/) et al and the [tigris package](https://cran.r-project.org/web/packages/tigris/index.html) created by [Kyle Walker](https://walker-data.com/) that downloads and works with U.S. Census Bureau TIGER/Line geographic files. I am also very grateful for packages including [janitor](https://cran.r-project.org/web/packages/janitor/index.html) and [sf](https://cran.r-project.org/web/packages/sf/index.html), among others. Thank you to the brilliant people behind these packages who wrote all the code and keep it maintained.

## Authorship

[Jennifer Peebles](https://www.ajc.com/staff/jennifer-peebles/) / [Atlanta Journal-Constitution](https://www.ajc.com/)

A note from JP: I built this project with help from ChatGPT/Codex, which drafted this README from the project's code, outputs and my instructions. I want to be transparent about the help I received.
