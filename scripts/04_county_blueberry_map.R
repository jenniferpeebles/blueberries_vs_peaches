# ============================================================
# 04_county_blueberry_map.R
#
# Georgia blueberry county acreage map
# Blueberries vs. Peaches project
#
# Jennifer Peebles / AJC
# ============================================================

# ------------------------------------------------------------
# Read raw county acreage data
# ------------------------------------------------------------

ga_blueberry_counties_raw <- readr::read_csv(
  file.path(DATA_RAW_DIR, "ga_blueberry_counties_raw.csv"),
  show_col_types = FALSE
)

qa_report(
  ga_blueberry_counties_raw,
  "GA_BLUEBERRY_COUNTIES_RAW"
)

# ------------------------------------------------------------
# Clean county acreage data
# ------------------------------------------------------------

ga_blueberry_counties <- ga_blueberry_counties_raw %>%
  mutate(
    county_name = clean_county_name(county_name)
  ) %>%
  filter(!is.na(value_num)) %>%
  group_by(county_name) %>%
  summarise(
    blueberry_acres = sum(value_num, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(
  ga_blueberry_counties,
  file.path(DATA_CLEAN_DIR, "ga_blueberry_counties_clean.csv")
)

# ------------------------------------------------------------
# Georgia counties geometry
# ------------------------------------------------------------

options(tigris_use_cache = TRUE)

ga_counties <- tigris::counties(
  state = "GA",
  year = 2024,
  class = "sf"
) %>%
  ensure_wgs84()

qa_geometry(ga_counties)

# ------------------------------------------------------------
# Join spatial and acreage data
# ------------------------------------------------------------

county_blueberry_map <- ga_counties %>%
  mutate(
    county_name = clean_county_name(NAME)
  ) %>%
  left_join(
    ga_blueberry_counties,
    by = "county_name"
  )

join_qa <- validate_map_join(
  ga_counties %>% mutate(county_name = clean_county_name(NAME)),
  ga_blueberry_counties,
  by = "county_name"
)

write_csv(
  st_drop_geometry(join_qa$unmatched_spatial),
  file.path(DOCS_DIR, "county_join_unmatched_spatial.csv")
)

write_csv(
  join_qa$unmatched_data,
  file.path(DOCS_DIR, "county_join_unmatched_data.csv")
)

# ------------------------------------------------------------
# Export GeoJSON
# ------------------------------------------------------------

export_geojson_wgs84(
  county_blueberry_map,
  file.path(
    EXPORT_DIR,
    "ga_blueberry_county_choropleth.geojson"
  )
)

# ------------------------------------------------------------
# Build map
# ------------------------------------------------------------

p_blueberry_map <- build_county_choropleth(
  sf_object = county_blueberry_map,
  fill_variable = blueberry_acres,
  title = "South Georgia is blueberry country",
  subtitle = "County acreage of bearing blueberry plants reported by USDA.",
  caption = build_ajc_caption(
    SOURCE_NASS,
    AJC_CREDIT
  ),
  fill_label = "Bearing acres"
)

export_watermarked_plot(
  p_blueberry_map,
  filename_stub = "ga_blueberry_county_choropleth",
  output_dir = OUTPUT_DIR,
  width = 10,
  height = 7
)

# ------------------------------------------------------------
# Reporter export
# ------------------------------------------------------------

top_counties <- ga_blueberry_counties %>%
  arrange(desc(blueberry_acres)) %>%
  slice_head(n = 20)

write_csv(
  top_counties,
  file.path(EXPORT_DIR, "top_blueberry_counties.csv")
)

# ------------------------------------------------------------
# Completion
# ------------------------------------------------------------

cat("\n====================================\n")
cat("COUNTY MAP COMPLETE\n")
cat("====================================\n")
cat("\nCounties with acreage records: ", nrow(ga_blueberry_counties), "\n")

sessionInfo()

beepr::beep(2)
