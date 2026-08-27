# ============================================================
# functions_charts.R
#
# Reusable chart helpers
# Jennifer Peebles / AJC
#
# Peebles Pipeline principles:
# - Consistent newsroom styling
# - Timestamped exports
# - Watermarked work products
# - Reusable chart components
# ============================================================

# ------------------------------------------------------------
# Add newsroom watermark
# ------------------------------------------------------------
add_watermark_plot <- function(
  p,
  watermark_text = "NOT FOR PUBLICATION"
) {

  cowplot::ggdraw(p) +
    cowplot::draw_label(
      watermark_text,
      x = 0.5,
      y = 0.5,
      angle = 30,
      size = 32,
      alpha = 0.18,
      fontface = "bold"
    )
}

# ------------------------------------------------------------
# Standard source/caption helper
# ------------------------------------------------------------
build_ajc_caption <- function(
  source_text,
  credit_text = "Analysis & chart: Jennifer Peebles/AJC"
) {

  paste(
    source_text,
    credit_text,
    sep = "\n"
  )
}

# ------------------------------------------------------------
# Save plot with timestamp
# ------------------------------------------------------------
save_plot_with_timestamp <- function(
  plot,
  filename_stub,
  output_dir = "outputs",
  width = 10,
  height = 6,
  dpi = 300
) {

  dir.create(
    output_dir,
    showWarnings = FALSE,
    recursive = TRUE
  )

  timestamp <- format(
    Sys.time(),
    "%Y%m%d_%H%M%S"
  )

  output_file <- file.path(
    output_dir,
    paste0(
      filename_stub,
      "_",
      timestamp,
      ".jpg"
    )
  )

  ggplot2::ggsave(
    filename = output_file,
    plot = plot,
    width = width,
    height = height,
    dpi = dpi
  )

  message(paste("Saved:", output_file))

  return(output_file)
}

# ------------------------------------------------------------
# Standard bump chart
# ------------------------------------------------------------
make_bump_chart <- function(
  df,
  selected_states,
  chart_title,
  chart_subtitle,
  caption_text
) {

  df |>
    dplyr::filter(
      state_alpha %in% selected_states
    ) |>
    ggplot2::ggplot(
      ggplot2::aes(
        x = year,
        y = rank,
        color = state_name,
        group = state_name
      )
    ) +
    ggplot2::geom_line(linewidth = 1.2) +
    ggplot2::geom_point(size = 2) +
    ggplot2::scale_y_reverse(
      breaks = 1:10,
      limits = c(10, 1)
    ) +
    ggplot2::labs(
      title = chart_title,
      subtitle = chart_subtitle,
      x = NULL,
      y = "National rank",
      color = NULL,
      caption = caption_text
    ) +
    ggplot2::theme_minimal()
}

# ------------------------------------------------------------
# Standard line chart theme tweaks
# ------------------------------------------------------------
apply_ajc_theme <- function(p) {

  p +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold"),
      legend.position = "bottom",
      panel.grid.minor = ggplot2::element_blank()
    )
}

# ------------------------------------------------------------
# QA helper for chart exports
# ------------------------------------------------------------
export_watermarked_plot <- function(
  plot,
  filename_stub,
  output_dir = "outputs",
  width = 10,
  height = 6,
  dpi = 300,
  watermark_text = "NOT FOR PUBLICATION"
) {

  plot_watermarked <- add_watermark_plot(
    plot,
    watermark_text = watermark_text
  )

  save_plot_with_timestamp(
    plot = plot_watermarked,
    filename_stub = filename_stub,
    output_dir = output_dir,
    width = width,
    height = height,
    dpi = dpi
  )

  invisible(plot_watermarked)
}
