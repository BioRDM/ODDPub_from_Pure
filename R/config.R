#' @export
read_config <- function(config_path) {

  config <- yaml::read_yaml(config_path)

  default_config <- list(
    .meta = list(
      input_name = tools::file_path_sans_ext(basename(config$main$input_file)),
      package_version = as.character(utils::packageVersion("ODDPubFromPure"))
    ),
    metadata = list(
      Author = "Not provided",
      Email = "Not provided",
      "Data description" = "Not provided",
      "Data access date" = "Not provided",
      "Data source" = "Not provided",
      "Data source url" = ""
    ),
    main = list(
      output_path = "output",
      article_links = "Files",
      title_column = "Title",
      url_separator = " // "
    )
  )

  # Merge the provided config with the default config
  config <- utils::modifyList(default_config, config, keep.null = TRUE)

  config$metadata[["Data source"]] <- paste0("\\href{", config$metadata[["Data source url"]], "}", "{", config$metadata[["Data source"]], "}")
  config$metadata[["Data source url"]] <- NULL
  config
}
