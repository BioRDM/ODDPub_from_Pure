#' @export
assemble_report <- function(config_file) {

  install_python_deps()

  # Load Config file
  config <- read_config(config_file)
  print(paste0("Running ODDPubFromPure package version ", config$.meta$package_version))

  # Get paths (and create directories)
  paths <- Paths(config)

  # Load Pure data table
  data <- read_pure_data(paths$input_file)

  # Check that the table contains what we need
  # (links to full-text PDFs)
  check_data(data, config)

  # Clean up data
  data <- clean_data(data, config)

  # Download PDFs from Pure
  ## reticulate::source_python(paths$batch_pdf_download)
  ## download_pdfs(pdf_urls = data[[paths$input_file]],
  ##               download_folder = paths$pdf,
  ##               file_names = data$file_names,
  ##               url_separator = config$main$url_separator)
  library(wdman)
  library(RSelenium)

  eCaps <- list(
    chromeOptions = list(
      prefs = list(
        "download.default_directory" = "/home/dthedie",
        "download.prompt_for_download" = FALSE,
        "plugins.always_open_pdf_externally" = TRUE
      ),
      args = list("--disable-gpu")
    )
  )

  chrome_driver <- wdman::chrome(port = 4545L, version = "latest")

  remDr <- remoteDriver(
    remoteServerAddr = "localhost",
    port = 4545L,
    browserName = "chrome",
    extraCapabilities = eCaps
  )

  remDr$open()
  remDr$navigate("https://www.pure.ed.ac.uk/admin/files")

  readline(prompt = "Log in manually, then press [Enter] in R to continue...")

  # --- download loop here ---

  remDr$close()
  chrome_driver$stop()



  # Convert PDFs to text
  reticulate::source_python(paths$batch_pdf_to_txt)
  batch_pdf_to_txt(pdf_folder = paths$pdf,
                   txt_folder = paths$txt)

  # Run ODDPub on text files

  # Create PDF report
}
