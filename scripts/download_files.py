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


pure_table = pd.read_csv(snakemake.input.clean_table)
file_urls = pure_table[snakemake.params.article_links]
file_names = pure_table['filename'].astype(str)
download_folder = Path(snakemake.params.download_folder)
url_separator = snakemake.params.url_separator
sentinel_file = Path(snakemake.output[0])

if file_names is None:
    file_names = [url.split("/")[-1] for url in file_urls]

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
        zip(file_urls, file_names),
        total=len(file_urls),
        desc="Downloading article files..."):

    url_list = urls.split(url_separator)
    dst = download_folder / (file_name + Path(url_list[0]).suffix)
    while not dst.exists() and len(url_list) > 0:
        url = url_list.pop(0)
        if not url or url == 'null':
            break
        dst = download_folder / (file_name + Path(url).suffix)
        dl_file = url.split("/")[-1]
        src = download_folder / dl_file
        driver.get(url)
        wait_for_download(download_folder, dl_file)
        if src.exists():
            src.rename(dst)

driver.quit()

sentinel_file.touch()
