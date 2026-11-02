from pathlib import Path
from pdfminer.high_level import extract_text
from pdfminer.layout import LAParams
import re


input_pdf = Path(snakemake.params.pdf_path)
output_txt = Path(snakemake.output.txt)

output_txt.parent.mkdir(parents=True, exist_ok=True)

if not input_pdf.exists():
    with open(output_txt, 'w') as f:
        f.write("")
    exit(0)

laparams = LAParams(line_margin=0.5,
                    char_margin=4.0,
                    word_margin=0.1,
                    boxes_flow=None)

try:
    text = extract_text(str(input_pdf), laparams=laparams)

    if text:
        # Remove dashes followed by a linebreak (hyphenated line breaks)
        text = re.sub(r'-\n', '\n', text)
        # Replace single linebreaks with space, keep double linebreaks
        text = re.sub(r'(?<!\n)\n(?!\n)', ' ', text)
        with open(output_txt, "w", encoding="utf-8") as f:
            f.write(text)
    else:
        print(f'No text extracted from {input_pdf.name}')
        output_txt.touch()
except Exception as e:
    print(f'ERROR converting {input_pdf.name}: {e}')
    raise e
