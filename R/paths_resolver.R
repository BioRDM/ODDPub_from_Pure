Paths <- function(config) {

  base_path <- config$main$output_path

  create_output_paths(base_path)

  list(
    input_file = config$main$input_file,
    output = base_path,
    pdf = get_pdf_path(base_path),
    txt = get_txt_path(base_path),
    src = get_src_path(),
    batch_pdf_download = get_batch_pdf_download(),
    batch_pdf_to_txt = get_batch_pdf_to_txt()
  )
}

create_output_paths <- function(base_path) {
  if (!dir.exists(base_path)) {
    dir.create(base_path, recursive = TRUE)
  }

  pdf_path <- get_pdf_path(base_path)
  if (!dir.exists(pdf_path)) {
    dir.create(pdf_path, recursive = TRUE)
  }
}

get_pdf_path <- function(base_path) {
  file.path(base_path, "pdf")
}

get_txt_path <- function(base_path) {
  file.path(base_path, "txt")
}

get_src_path <- function() {
  system.file("src", package = "ODDPubFromPure")
}

get_batch_pdf_download <- function() {
  file.path(get_src_path(), "Batch_pdf_download.py")
}

get_batch_pdf_to_txt <- function() {
  file.path(get_src_path(), "Batch_pdf_to_txt.py")
}
