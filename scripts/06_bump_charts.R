# ============================================================
# 06_bump_charts.R
#
# National ranking bump charts
# Blueberries vs. Peaches project
#
# Jennifer Peebles / AJC
# ============================================================

# ------------------------------------------------------------
# Read ranked datasets
# ------------------------------------------------------------

peach_ranked <- readr::read_csv(
  file.path(DATA_CLEAN_DIR, "peach_ranked.csv"),
  show_col_types = FALSE
)

blueberry_ranked <- readr::read_csv(
  file.path(DATA_CLEAN_DIR, "blueberry_ranked.csv"),
  show_col_types = FALSE
)

qa_report(peach_ranked, "PEACH_RANKED")
qa_report(blueberry_ranked, "BLUEBERRY_RANKED")

# ------------------------------------------------------------
# Datawrapper exports
# ------------------------------------------------------------

peach_bump_datawrapper <- peach_ranked %>%
  filter(state_alpha %in% SELECTED_PEACH_STATES) %>%
  mutate(crop = "Peaches") %>%
  select(
    year,
    crop,
    state_name,
    state_alpha,
    national_rank = rank,
    production,
    unit_desc,
    national_total,
    pct_of_us
  ) %>%
  arrange(state_name, year)

blueberry_bump_datawrapper <- blueberry_ranked %>%
  filter(state_alpha %in% SELECTED_BLUEBERRY_STATES) %>%
  mutate(crop = "Blueberries") %>%
  select(
    year,
    crop,
    state_name,
    state_alpha,
    national_rank = rank,
    production,
    unit_desc,
    national_total,
    pct_of_us
  ) %>%
  arrange(state_name, year)

write_csv(
  peach_bump_datawrapper,
  file.path(EXPORT_DIR, "datawrapper_peach_bump_chart_selected_states.csv")
)

write_csv(
  blueberry_bump_datawrapper,
  file.path(EXPORT_DIR, "datawrapper_blueberry_bump_chart_selected_states.csv")
)

# ------------------------------------------------------------
# Peach bump chart
# ------------------------------------------------------------

p_peach_bump <- make_bump_chart(
  df = peach_ranked,
  selected_states = SELECTED_PEACH_STATES,
  chart_title = "Georgia bested in peach production",
  chart_subtitle = "Selected states' national rankings in peach production over time.",
  caption_text = build_ajc_caption(
    SOURCE_NASS,
    AJC_CREDIT
  )
)

p_peach_bump <- apply_ajc_theme(p_peach_bump)

export_watermarked_plot(
  p_peach_bump,
  filename_stub = "selected_states_peach_rank_bump",
  output_dir = OUTPUT_DIR
)

# ------------------------------------------------------------
# Blueberry bump chart
# ------------------------------------------------------------

p_blueberry_bump <- make_bump_chart(
  df = blueberry_ranked,
  selected_states = SELECTED_BLUEBERRY_STATES,
  chart_title = "Georgia ascends into top tier for blueberries",
  chart_subtitle = "Selected states' national rankings in tame blueberry production.",
  caption_text = build_ajc_caption(
    SOURCE_NASS,
    AJC_CREDIT
  )
)

p_blueberry_bump <- apply_ajc_theme(p_blueberry_bump)

export_watermarked_plot(
  p_blueberry_bump,
  filename_stub = "selected_states_blueberry_rank_bump",
  output_dir = OUTPUT_DIR
)

# ------------------------------------------------------------
# Reporter exports
# ------------------------------------------------------------

latest_peach_year <- max(peach_ranked$year, na.rm = TRUE)
latest_blueberry_year <- max(blueberry_ranked$year, na.rm = TRUE)

reporter_bump_findings <- bind_rows(
  peach_ranked %>%
    filter(
      year == latest_peach_year,
      state_alpha %in% SELECTED_PEACH_STATES
    ) %>%
    mutate(crop = "Peaches"),

  blueberry_ranked %>%
    filter(
      year == latest_blueberry_year,
      state_alpha %in% SELECTED_BLUEBERRY_STATES
    ) %>%
    mutate(crop = "Blueberries")
) %>%
  select(
    crop,
    state_name,
    state_alpha,
    year,
    rank,
    production,
    pct_of_us
  ) %>%
  arrange(crop, rank)

write_csv(
  reporter_bump_findings,
  file.path(EXPORT_DIR, "reporter_bump_chart_findings.csv")
)

# ------------------------------------------------------------
# QA artifact
# ------------------------------------------------------------

selected_states_review <- tibble::tibble(
  crop = c(
    rep("Peaches", length(SELECTED_PEACH_STATES)),
    rep("Blueberries", length(SELECTED_BLUEBERRY_STATES))
  ),
  state_alpha = c(
    SELECTED_PEACH_STATES,
    SELECTED_BLUEBERRY_STATES
  )
)

write_csv(
  selected_states_review,
  file.path(DOCS_DIR, "selected_states_review.csv")
)

# ------------------------------------------------------------
# Completion
# ------------------------------------------------------------

cat("\n====================================\n")
cat("BUMP CHART ANALYSIS COMPLETE\n")
cat("====================================\n")

cat("\nPeach states: ", length(SELECTED_PEACH_STATES))
cat("\nBlueberry states: ", length(SELECTED_BLUEBERRY_STATES))
cat("\n")

sessionInfo()

beepr::beep(2)
