clean_data <- function(data, config) {
  data |>
    dplyr::group_by(.data[[config$main$title_column]]) |>
    dplyr::summarise(
      files = dplyr::first(.data[[config$main$article_links]])
    ) |>
    dplyr::filter(!is.null(.data$files)) |>
    dplyr::mutate(file_names = dplyr::row_number())
}
