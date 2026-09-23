read_pure_data <- function(file_path) {
  utils::read.csv(file_path, stringsAsFactor = FALSE)
}
