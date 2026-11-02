conda_prefix <- Sys.getenv("CONDA_PREFIX")
conda_lib <- file.path(conda_prefix, "lib", "R", "library")

if (dir.exists(conda_lib)) {
  .libPaths(c(conda_lib, .libPaths()))
  # Tell renv to treat this as an external library it can trust,
  # instead of trying to reinstall these packages into renv's project library
  options(renv.config.external.libraries = conda_lib)
}

if (file.exists("renv/activate.R")) {
  source("renv/activate.R")
  renv::restore(prompt = FALSE)
}

input_dir <- snakemake@params$input_dir
output_file <- snakemake@params$output_file

all_files <- list.files(input_dir, pattern = "\\.txt$", full.names = TRUE)

file_sizes <- file.info(all_files)$size
valid_files <- all_files[file_sizes > 0]

message(sprintf("Running ODDPub on %d files.", length(valid_files)))

if (length(valid_files) == 0) {
  warning("No valid text files found. Creating empty results CSV.")
  empty_df <- data.frame(
    filename = character(),
    open_data = logical(),
    statement = character(),
    stringsAsFactors = FALSE
  )
  write.csv(empty_df, output_file, row.names = FALSE)
  quit(save = "no", status = 0)
}

staging_dir <- file.path(input_dir, ".staging_valid_files")
if (!dir.exists(staging_dir)) {
  dir.create(staging_dir, recursive = TRUE)
}

copy_success <- file.copy(valid_files, staging_dir, overwrite = TRUE)

tryCatch({
  
  result <- progressr::with_progress({
    
    future::plan(future::multisession)
    
    pdf_text_sentences <- oddpub::pdf_load(staging_dir)
    
    oddpub::open_data_search(pdf_text_sentences, screen_das = "priority")
  })
  
  write.csv(result, output_file, row.names = FALSE)
  message("ODDPub analysis complete.")
  
}, error = function(e) {
  future::plan("sequential") 
  stop(sprintf("ODDPub failed: %s", e$message))
})

unlink(staging_dir, recursive = TRUE)
message("Staging directory cleaned up.")
