import pandas as pd
import os
from pathlib import Path


def get_expected_files(input_file_path, id_col_name):
    if not os.path.exists(input_file_path):
        return []

    try:
        df = pd.read_csv(input_file_path)

        samples = df[id_col_name].dropna().astype('str').unique()
        samples = [s for s in samples if s.lower() not in ['nan', 'null', '']]
        return samples

    except Exception as e:
        print(f'Could not read {input_file_path} to determine PDFs to download: {e}')
        return []


def get_pdf_samples(wildcards):
    pdf_dir = "outputs/PDFs"
    if not os.path.exists(pdf_dir):
        return []
    files = [f.stem for f in Path(pdf_dir).glob("*.pdf")]
    return files
