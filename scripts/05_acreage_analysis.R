# ============================================================
# 05_acreage_analysis.R
#
# Georgia peach vs. blueberry acreage analysis
# Blueberries vs. Peaches project
#
# Jennifer Peebles / AJC
# ============================================================

# ------------------------------------------------------------
# Read raw acreage data
# ------------------------------------------------------------

ga_peach_acres_raw <- readr::read_csv(
  file.path(DATA_RAW_DIR, "ga_peaches_acreage_raw.csv"),
  show_col_types = FALSE
)

ga_blueberry_acres_raw <- readr::read_csv(
  file.path(DATA_RAW_DIR, "ga_blueberries_acreage_raw.csv"),
  show_col_types = FALSE
)

# Defensive cleanup in case value_num was not exported
if (!"value_num" %in% names(ga_peach_acres_raw)) {
  ga_peach_acres_raw <- ga_peach_acres_raw %>%
    mutate(value_num = clean_nass_value(value))
}

if (!"value_num" %in% names(ga_blueberry_acres_raw)) {
  ga_blueberry_acres_raw <- ga_blueberry_acres_raw %>%
    mutate(value_num = clean_nass_value(value))
}

# ------------------------------------------------------------
# QA
# ------------------------------------------------------------

qa_report(ga_peach_acres_raw, "GA_PEACH_ACRES_RAW")
qa_report(ga_blueberry_acres_raw, "GA_BLUEBERRY_ACRES_RAW")

# ------------------------------------------------------------
# Document available acreage series
# ------------------------------------------------------------

acreage_series_review <- bind_rows(
  ga_peach_acres_raw %>% mutate(crop = "PEACHES"),
  ga_blueberry_acres_raw %>% mutate(crop = "BLUEBERRIES")
) %>%
  count(
    crop,
    short_desc,
    class_desc,
    statisticcat_desc,
    unit_desc,
    sort = TRUE
  )

write_csv(
  acreage_series_review,
  file.path(DOCS_DIR, "acreage_series_review.csv")
)

# ------------------------------------------------------------
# Build clean acreage dataset
# ------------------------------------------------------------

ga_acres <- bind_rows(
  ga_peach_acres_raw,
  ga_blueberry_acres_raw
) %>%
  filter(
    short_desc %in% c(
      "PEACHES - ACRES BEARING",
      "BLUEBERRIES, TAME - ACRES BEARING"
    )
  ) %>%
  group_by(year, commodity) %>%
  summarise(
    acres = max(value_num, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    commodity_label = case_when(
      commodity == "PEACHES" ~ "Peaches",
      commodity == "BLUEBERRIES" ~ "Blueberries",
      TRUE ~ commodity
    )
  ) %>%
  arrange(commodity_label, year)

write_csv(
  ga_acres,
  file.path(DATA_CLEAN_DIR, "ga_acres.csv")
)

# ------------------------------------------------------------
# Comparable years only
# ------------------------------------------------------------

common_acre_years <- ga_acres %>%
  count(year) %>%
  filter(n == 2) %>%
  pull(year)

ga_acres_common_years <- ga_acres %>%
  filter(year %in% common_acre_years)

write_csv(
  ga_acres_common_years,
  file.path(EXPORT_DIR, "ga_crop_acreage.csv")
)

# ------------------------------------------------------------
# QA duplicate check
# ------------------------------------------------------------

acre_dupes <- qa_duplicates(
  ga_acres,
  year,
  commodity
)

stopifnot(nrow(acre_dupes) == 0)

# ------------------------------------------------------------
# Acreage chart
# ------------------------------------------------------------

p_acres <- ggplot2::ggplot(
  ga_acres_common_years,
  ggplot2::aes(
    x = factor(year),
    y = acres,
    fill = commodity_label
  )
) +
  ggplot2::geom_col(position = "dodge") +
  ggplot2::scale_y_continuous(labels = scales::comma) +
  ggplot2::labs(
    title = "Georgia farmers plant more blueberry acreage than peach acreage",
    subtitle = "Years where USDA reports bearing acreage for both crops.",
    x = NULL,
    y = "Bearing acres",
    fill = NULL,
    caption = build_ajc_caption(
      SOURCE_NASS,
      AJC_CREDIT
    )
  )

p_acres <- apply_ajc_theme(p_acres)

export_watermarked_plot(
  p_acres,
  filename_stub = "ga_peach_blueberry_bearing_acres",
  output_dir = OUTPUT_DIR
)

# ------------------------------------------------------------
# Datawrapper export
# ------------------------------------------------------------

acres_datawrapper <- ga_acres_common_years %>%
  select(
    year,
    commodity = commodity_label,
    bearing_acres = acres
  ) %>%
  arrange(commodity, year)

write_csv(
  acres_datawrapper,
  file.path(
    EXPORT_DIR,
    "datawrapper_ga_peach_blueberry_acres.csv"
  )
)

# ------------------------------------------------------------
# Reporter findings
# ------------------------------------------------------------

latest_common_year <- max(common_acre_years, na.rm = TRUE)

reporter_acreage_findings <- ga_acres_common_years %>%
  filter(year == latest_common_year) %>%
  select(
    year,
    commodity_label,
    acres
  ) %>%
  arrange(desc(acres))

write_csv(
  reporter_acreage_findings,
  file.path(EXPORT_DIR, "reporter_acreage_findings.csv")
)

# ------------------------------------------------------------
# Completion
# ------------------------------------------------------------

cat("\n====================================\n")
cat("ACREAGE ANALYSIS COMPLETE\n")
cat("====================================\n")
cat("\nComparable acreage years: ", length(common_acre_years), "\n")

sessionInfo()

beepr::beep(2)
