# ============================================================
# 03_georgia_production_analysis.R
#
# Georgia peaches vs. blueberries analysis
# Blueberries vs. Peaches project
#
# Jennifer Peebles / AJC
# ============================================================

source("config.R")

# ------------------------------------------------------------
# Read cleaned data
# ------------------------------------------------------------

peach_ranked <- readr::read_csv(
  file.path(DATA_CLEAN_DIR, "peach_ranked.csv"),
  show_col_types = FALSE
)

blueberry_ranked <- readr::read_csv(
  file.path(DATA_CLEAN_DIR, "blueberry_ranked.csv"),
  show_col_types = FALSE
)

ga_summary <- readr::read_csv(
  file.path(DATA_CLEAN_DIR, "ga_summary.csv"),
  show_col_types = FALSE
)

# ------------------------------------------------------------
# QA
# ------------------------------------------------------------

qa_report(ga_summary, "GA_SUMMARY")

# ------------------------------------------------------------
# Latest rankings table
# ------------------------------------------------------------

latest_peaches <- peach_ranked |>
  filter(year == max(year, na.rm = TRUE)) |>
  arrange(rank)

latest_blueberries <- blueberry_ranked |>
  filter(year == max(year, na.rm = TRUE)) |>
  arrange(rank)

write_csv(
  latest_peaches,
  file.path(EXPORT_DIR, "latest_peach_rankings.csv")
)

write_csv(
  latest_blueberries,
  file.path(EXPORT_DIR, "latest_blueberry_rankings.csv")
)

# ------------------------------------------------------------
# Georgia rank chart
# ------------------------------------------------------------

p_rank <- ga_summary |>
  ggplot2::ggplot(
    ggplot2::aes(
      x = year,
      y = rank,
      color = commodity_label
    )
  ) +
  ggplot2::geom_line(linewidth = 1.2) +
  ggplot2::geom_point(size = 2) +
  ggplot2::scale_y_reverse(breaks = 1:10) +
  ggplot2::labs(
    title = "Georgia's changing crop rankings",
    subtitle = "Georgia's standing among states differs sharply between peaches and blueberries.",
    x = NULL,
    y = "National rank",
    color = NULL,
    caption = build_ajc_caption(
      SOURCE_NASS,
      AJC_CREDIT
    )
  )

p_rank <- apply_ajc_theme(p_rank)

export_watermarked_plot(
  p_rank,
  filename_stub = "ga_rank_chart",
  output_dir = OUTPUT_DIR
)

# ------------------------------------------------------------
# Production comparison in pounds
# ------------------------------------------------------------

ga_production_lbs <- ga_summary |>
  mutate(
    production_lbs = case_when(
      commodity == "PEACHES" ~ production * 2000,
      commodity == "BLUEBERRIES" ~ production,
      TRUE ~ NA_real_
    )
  )

write_csv(
  ga_production_lbs,
  file.path(EXPORT_DIR, "ga_production_comparison.csv")
)

# ------------------------------------------------------------
# Datawrapper export
# ------------------------------------------------------------

ga_production_datawrapper <- ga_production_lbs |>
  select(
    year,
    commodity = commodity_label,
    production_original_units = production,
    original_unit = unit_desc,
    production_lbs,
    national_rank = rank,
    percent_of_us
  ) |>
  arrange(commodity, year)

write_csv(
  ga_production_datawrapper,
  file.path(
    EXPORT_DIR,
    "datawrapper_georgia_peach_blueberry_production_lbs.csv"
  )
)

# ------------------------------------------------------------
# Production chart
# ------------------------------------------------------------

p_production <- ga_production_lbs |>
  ggplot2::ggplot(
    ggplot2::aes(
      x = year,
      y = production_lbs,
      color = commodity_label
    )
  ) +
  ggplot2::geom_line(linewidth = 1.2) +
  ggplot2::geom_point(size = 2) +
  ggplot2::scale_y_continuous(
    labels = scales::label_number(
      scale_cut = scales::cut_short_scale()
    )
  ) +
  ggplot2::labs(
    title = "Blueberries surpass peaches",
    subtitle = "Peach production converted from tons to pounds for comparison.",
    x = NULL,
    y = "Production (pounds)",
    color = NULL,
    caption = build_ajc_caption(
      SOURCE_NASS,
      AJC_CREDIT
    )
  )

p_production <- apply_ajc_theme(p_production)

export_watermarked_plot(
  p_production,
  filename_stub = "ga_production_chart",
  output_dir = OUTPUT_DIR
)

# ------------------------------------------------------------
# Reporter-friendly findings
# ------------------------------------------------------------

reporter_brief <- tibble::tibble(
  commodity_label = c("Peaches", "Blueberries"),
  finding = c(
    "Latest Georgia peach rank",
    "Latest Georgia blueberry rank"
  )
) %>%
  left_join(
    ga_summary %>%
      group_by(commodity_label) %>%
      filter(year == max(year, na.rm = TRUE)) %>%
      ungroup() %>%
      select(commodity_label, year, value = rank),
    by = "commodity_label"
  )

write_csv(
  reporter_brief,
  file.path(EXPORT_DIR, "reporter_brief_key_findings.csv")
)

# ------------------------------------------------------------
# Completion
# ------------------------------------------------------------

cat("\n====================================\n")
cat("GEORGIA ANALYSIS COMPLETE\n")
cat("====================================\n")
cat("Latest peach year: ", max(peach_ranked$year, na.rm = TRUE), "\n")
cat("Latest blueberry year: ", max(blueberry_ranked$year, na.rm = TRUE), "\n")

sessionInfo()

if (interactive()) beepr::beep(2)
