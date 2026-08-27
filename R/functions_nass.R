# ============================================================
# functions_nass.R
#
# Reusable USDA NASS Quick Stats helper functions
# Jennifer Peebles / AJC
# ============================================================

clean_nass_value <- function(x) {
  if (is.numeric(x)) return(x)
  readr::parse_number(as.character(x))
}

authenticate_nass <- function() {
  api_key <- Sys.getenv("NASS_API_KEY")
  if (api_key == "") stop("NASS_API_KEY not found in .Renviron")
  rnassqs::nassqs_auth(key = api_key)
  message("Successfully authenticated with USDA NASS.")
}

get_nass_data <- function(
  commodity,
  statistic,
  agg_level = "STATE",
  start_year = 2000,
  end_year = lubridate::year(Sys.Date()),
  ...
) {
  query <- list(
    sector_desc = "CROPS",
    group_desc = "FRUIT & TREE NUTS",
    commodity_desc = commodity,
    statisticcat_desc = statistic,
    agg_level_desc = agg_level,
    year__GE = start_year,
    year__LE = end_year,
    format = "json",
    ...
  )

  results <- do.call(rnassqs::nassqs, query) |>
    janitor::clean_names()

  message(glue::glue("{commodity}: pulled {nrow(results)} rows."))
  results
}

get_crop_production <- function(
  commodity,
  start_year = 2000,
  end_year = lubridate::year(Sys.Date())
) {
  get_nass_data(
    commodity = commodity,
    statistic = "PRODUCTION",
    agg_level = "STATE",
    start_year = start_year,
    end_year = end_year
  ) |>
    dplyr::mutate(
      value_num = clean_nass_value(value),
      commodity = commodity
    )
}

get_crop_acreage <- function(
  commodity,
  state_alpha = "GA",
  start_year = 2000,
  end_year = lubridate::year(Sys.Date())
) {
  get_nass_data(
    commodity = commodity,
    statistic = "AREA BEARING",
    agg_level = "STATE",
    state_alpha = state_alpha,
    start_year = start_year,
    end_year = end_year,
    unit_desc = "ACRES"
  ) |>
    dplyr::mutate(
      value_num = clean_nass_value(value),
      commodity = commodity
    )
}

get_county_acreage <- function(
  commodity,
  state_alpha = "GA",
  year = 2022,
  class_desc = NULL
) {
  extra_args <- list()
  if (!is.null(class_desc)) extra_args$class_desc <- class_desc

  query_args <- c(
    list(
      commodity = commodity,
      statistic = "AREA BEARING",
      agg_level = "COUNTY",
      state_alpha = state_alpha,
      start_year = year,
      end_year = year,
      unit_desc = "ACRES"
    ),
    extra_args
  )

  do.call(get_nass_data, query_args) |>
    dplyr::mutate(
      value_num = clean_nass_value(value),
      commodity = commodity
    )
}

rank_states <- function(df) {
  df |>
    dplyr::group_by(year) |>
    dplyr::mutate(
      national_total = sum(production, na.rm = TRUE),
      rank = dplyr::min_rank(dplyr::desc(production)),
      percent_of_us = dplyr::if_else(
        national_total > 0,
        production / national_total * 100,
        NA_real_
      )
    ) |>
    dplyr::ungroup()
}
