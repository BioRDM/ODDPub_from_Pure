check_data <- function(data, config) {
  links_col <- data[[config$main$article_links]]
  if (is.null(links_col)) {
    cli::cli_abort(c(
      "x" = "Could not find article links column: {links_col}",
      "i" = "Check the `article_links` parameter in your config file"
    ))
  }

  if (is.null(data$Title)) {
    cli::cli_abort(c(
      "x" = "Could not find `Title` column"
    ))
  }
}
