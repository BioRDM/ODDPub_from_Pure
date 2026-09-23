from pathlib import Path
from pdfminer.high_level import extract_text
from pdfminer.layout import LAParams
import re


def batch_pdf_to_txt(pdf_folder: str | Path,
                     txt_folder: str | Path):
    pdf_folder = Path(pdf_folder)
    txt_folder = Path(txt_folder)
    txt_folder.mkdir(parents=True, exist_ok=True)

    laparams = LAParams(line_margin=0.5,
                        char_margin=4.0,
                        word_margin=0.1,
                        boxes_flow=None)
    failed_files = 0
    for pdf_file in pdf_folder.glob("*.pdf"):
        txt_file = txt_folder / (pdf_file.stem + ".txt")
        try:
            text = extract_text(str(pdf_file), laparams=laparams)
            # Remove dashes followed by a linebreak (hyphenated line breaks)
            text = re.sub(r'-\n', '\n', text)
            # Replace single linebreaks with space, keep double linebreaks
            text = re.sub(r'(?<!\n)\n(?!\n)', ' ', text)
            with open(txt_file, "w", encoding="utf-8") as f:
                f.write(text)
        except Exception as e:
            failed_files += 1

    print(f"Batch PDF to txt conversion completed with {failed_files} failures.")
