install_python_deps <- function() {
  reticulate::py_require("selenium")
  reticulate::py_require("docx2pdf")
  reticulate::py_require("tqdm")
  reticulate::py_require("pdfminer")
}
