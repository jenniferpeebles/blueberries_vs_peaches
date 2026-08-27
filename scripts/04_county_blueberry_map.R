# ============================================================
# 04_county_blueberry_map.R
#
# Georgia blueberry county acreage map
# Blueberries vs. Peaches project
#
# Jennifer Peebles / AJC
# ============================================================

source("config.R")

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

county_blueberry_exclusions <- ga_blueberry_counties_raw %>%
  mutate(county_name = clean_county_name(county_name)) %>%
  filter(is.na(value_num)) %>%
  distinct(county_name, value, .keep_all = TRUE) %>%
  transmute(
    county_name,
    reported_value = value,
    exclusion_reason = "USDA value missing or suppressed"
  )

write_csv(
  ga_blueberry_counties,
  file.path(DATA_CLEAN_DIR, "ga_blueberry_counties_clean.csv")
)

# ------------------------------------------------------------
# Georgia counties geometry
# ------------------------------------------------------------

options(tigris_use_cache = TRUE)

ga_counties <- peeblestoolbox::get_ga_counties(
  year = COUNTY_BOUNDARY_YEAR,
  cb = TRUE,
  class = "sf"
)

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
  ) %>%
  left_join(
    county_blueberry_exclusions %>% select(county_name, exclusion_reason),
    by = "county_name"
  ) %>%
  mutate(
    data_status = case_when(
      !is.na(blueberry_acres) ~ "Published value",
      !is.na(exclusion_reason) ~ "Missing or suppressed by USDA",
      TRUE ~ "No USDA county record"
    )
  )

join_qa <- validate_map_join(
  ga_counties %>% mutate(county_name = clean_county_name(NAME)),
  ga_blueberry_counties_raw %>%
    mutate(county_name = clean_county_name(county_name)) %>%
    distinct(county_name),
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

write_csv(
  county_blueberry_exclusions,
  file.path(DOCS_DIR, "county_blueberry_suppressed_or_missing.csv")
)

county_data_status <- county_blueberry_map %>%
  st_drop_geometry() %>%
  count(data_status, name = "counties")

write_csv(
  county_data_status,
  file.path(DOCS_DIR, "county_blueberry_data_status.csv")
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
  sf_object = sf::st_transform(county_blueberry_map, 5070),
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

crs_notes <- c(
  paste0("Static map drawn in ", sf::st_crs(5070)$Name, " (EPSG:5070)."),
  "Datawrapper GeoJSON exported in WGS 84 longitude/latitude (EPSG:4326).",
  paste0("County boundaries: Census cartographic boundaries, ", COUNTY_BOUNDARY_YEAR, " vintage.")
)
writeLines(crs_notes, file.path(DOCS_DIR, "county_map_crs_notes.txt"))

# ------------------------------------------------------------
# Completion
# ------------------------------------------------------------

cat("\n====================================\n")
cat("COUNTY MAP COMPLETE\n")
cat("====================================\n")
cat("\nCounties with acreage records: ", nrow(ga_blueberry_counties), "\n")
cat("County rows missing or suppressed by USDA: ", nrow(county_blueberry_exclusions), "\n")
print(county_data_status)

sessionInfo()

if (interactive()) beepr::beep(2)
