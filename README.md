# Blueberries vs. Peaches

USDA NASS analysis of Georgia blueberry and peach production, acreage, rankings, and county geography.

README generated: 2026-08-27

## Reporting question

How does Georgia's modern blueberry industry compare with its traditional peach industry?

## Data sources

* USDA National Agricultural Statistics Service (NASS) Quick Stats
* USDA Census of Agriculture
* U.S. Census Bureau TIGER/Line county boundaries via tigris

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

## Authorship

Jennifer Peebles / Atlanta Journal-Constitution

Disclosure: Codex helped Jennifer refactor the pipeline and write this README. Jennifer remains responsible for the reporting, analysis, and publication decisions.
