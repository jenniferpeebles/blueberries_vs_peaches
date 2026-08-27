# ============================================================
# functions_maps.R
#
# Reusable mapping functions
# Jennifer Peebles / AJC
#
# Peebles Pipeline principles:
# - QA before choropleths
# - WGS84 for newsroom exports
# - Preserve geography IDs
# - Make joins auditable
# ============================================================

# ------------------------------------------------------------
# Standard county-name cleanup
# ------------------------------------------------------------
clean_county_name <- function(x) {

  x |>
    stringr::str_remove(" County") |>
    stringr::str_trim() |>
    stringr::str_to_upper()
}

# ------------------------------------------------------------
# Validate map join
# ------------------------------------------------------------
validate_map_join <- function(
  spatial_df,
  data_df,
  by
) {

  unmatched_spatial <- dplyr::anti_join(
    spatial_df,
    data_df,
    by = by
  )

  unmatched_data <- dplyr::anti_join(
    data_df,
    spatial_df,
    by = by
  )

  list(
    unmatched_spatial = unmatched_spatial,
    unmatched_data = unmatched_data
  )
}

# ------------------------------------------------------------
# Force WGS84 for newsroom exports
# ------------------------------------------------------------
ensure_wgs84 <- function(sf_object) {

  sf::st_transform(
    sf_object,
    4326
  )
}

# ------------------------------------------------------------
# Export GeoJSON in WGS84
# ------------------------------------------------------------
export_geojson_wgs84 <- function(
  sf_object,
  output_file
) {

  peeblestoolbox::export_geojson(
    layer = sf_object,
    filename = basename(output_file),
    folder = dirname(output_file),
    overwrite = TRUE
  )
}

# ------------------------------------------------------------
# Build basic county choropleth
# ------------------------------------------------------------
build_county_choropleth <- function(
  sf_object,
  fill_variable,
  title,
  subtitle,
  caption,
  fill_label = "Value"
) {

  ggplot2::ggplot(sf_object) +
    ggplot2::geom_sf(
      ggplot2::aes(fill = {{ fill_variable }}),
      color = "white",
      linewidth = 0.15
    ) +
    viridis::scale_fill_viridis(
      discrete = FALSE,
      na.value = "grey90"
    ) +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      fill = fill_label,
      caption = caption
    ) +
    peeblestoolbox::theme_peebles_map()
}

# ------------------------------------------------------------
# Quick geometry QA
# ------------------------------------------------------------
qa_geometry <- function(sf_object) {

  tibble::tibble(
    rows = nrow(sf_object),
    valid_geometries = sum(sf::st_is_valid(sf_object)),
    invalid_geometries = sum(!sf::st_is_valid(sf_object)),
    crs = as.character(sf::st_crs(sf_object)$input)
  )
}
