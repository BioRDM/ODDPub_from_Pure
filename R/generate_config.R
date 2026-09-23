.default_config <- "metadata:
  Author: Name of the report author
  Email: Email address for the report author
  Data description: Main data file description
  Data access_date: 01-01-2020
  Data source:
  Data source_url:

main:
  input_file: /path/to/Pure_data.csv
  output_path: /path/to/Outputs
  article_links: Files
  title_column: Title
  url_separator: //
"

#' Generate a config file for the Pure to ODDPub pipeline
#'
#' @param path The path where the config file will be created
#' @returns None (writes a .yaml config file to the specified path)
#' @export
generate_config <- function(path = ".") {
  # Add check that provided path exists
  if (dir.exists(path)) {
    out_file <- file.path(path, "Pure_to_ODDPub_config.yaml")
  } else {
    parent_dir <- dirname(path)

    if (!dir.exists(parent_dir)) {
      cli::cli_abort(c("x" = "Input path does not exist: {parent_dir}"))
    }

    out_file <- path
  }

  writeLines(.default_config, out_file)
}
