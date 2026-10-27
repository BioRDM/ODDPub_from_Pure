from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import time
from pathlib import Path
import subprocess
import platform
from tqdm import tqdm
import pandas as pd


def wait_for_download(download_folder: str | Path,
                      filename: str,
                      timeout: int = 10):
    """Wait until the file is downloaded (no .crdownload extension)."""
    download_folder = Path(download_folder)
    file_path = download_folder / filename
    crdownload_path = file_path.with_suffix(".crdownload")
    elapsed = 0
    while elapsed < timeout:
        if crdownload_path.exists():
            time.sleep(1)
            elapsed += 1
        elif file_path.exists():
            return True
        else:
            time.sleep(1)
            elapsed += 1
    return False


def tidy_docx_files(download_folder: str | Path):
    download_folder = Path(download_folder)
    for docx_file in download_folder.glob("*.doc*"):
        if (download_folder / (docx_file.stem + ".pdf")).exists():
            docx_file.unlink()
        else:
            pdf_file = download_folder / (docx_file.stem + ".pdf")
            convert_docx_to_pdf(docx_file, pdf_file)
            docx_file.unlink()


def convert_docx_to_pdf(docx_path: str | Path, pdf_path: str | Path = None):
    """
    Convert a .docx file to PDF using LibreOffice on Linux,
    or docx2pdf on Windows/Mac.
    """
    docx_path = Path(docx_path)
    if pdf_path is not None:
        pdf_path = Path(pdf_path)

    if platform.system() == "Linux":
        output_dir = docx_path.parent
        cmd = [
            "libreoffice",
            "--headless",
            "--convert-to", "pdf",
            "--outdir", output_dir,
            docx_path
        ]
        subprocess.run(cmd, check=True)
        if pdf_path is not None:
            generated_pdf = output_dir / (docx_path.stem + ".pdf")
            if generated_pdf.exists():
                generated_pdf.rename(pdf_path)
    else:
        from docx2pdf import convert
        if pdf_path is not None:
            convert(docx_path, pdf_path)
        else:
            convert(docx_path)


pure_table = pd.read_csv(snakemake.input.clean_table)
pdf_urls = pure_table['Files']
file_names = pure_table['filename'].astype(str)
download_folder = Path(snakemake.params.download_folder)
url_separator = snakemake.params.url_separator
sentinel_file = Path(snakemake.output[0])

if file_names is None:
    file_names = [url.split("/")[-1] for url in pdf_urls]

options = Options()
options.add_experimental_option("prefs", {
    "download.default_directory": str(download_folder),
    "download.prompt_for_download": False,
    "plugins.always_open_pdf_externally": True
})
options.add_argument("--disable-gpu")

driver = webdriver.Chrome(options=options)
driver.get("https://www.pure.ed.ac.uk/admin/files")
input("Log in manually, then press Enter...")

for urls, file_name in tqdm(
        zip(pdf_urls, file_names),
        total=len(pdf_urls),
        desc="Downloading PDFs"):

    url_list = urls.split(url_separator)
    dst = download_folder / (file_name + ".pdf")
    while not dst.exists() and len(url_list) > 0:
        url = url_list.pop(0)
        if not url or url == 'null':
            break
        dl_file = url.split("/")[-1]
        src = download_folder / dl_file
        driver.get(url)
        wait_for_download(download_folder, dl_file)
        if src.exists():
            src.rename(dst)

driver.quit()

tidy_docx_files(download_folder)

sentinel_file.touch()
