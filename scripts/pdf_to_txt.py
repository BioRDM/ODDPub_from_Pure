from pathlib import Path
from pdfminer.high_level import extract_text
from pdfminer.layout import LAParams
import re
import multiprocessing
import sys


def extract_text_with_timeout(pdf_path, laparams, timeout_seconds):
    def _target(pdf_path_str, laparams_dict, conn):
        try:
            from pdfminer.layout import LAParams
            lp = LAParams(
                line_margin=laparams_dict['line_margin'],
                char_margin=laparams_dict['char_margin'],
                word_margin=laparams_dict['word_margin'],
                boxes_flow=laparams_dict['boxes_flow']
            )
            text = extract_text(pdf_path_str, laparams=lp)
            conn.send({'success': True, 'text': text})
        except Exception as e:
            conn.send({'success': False, 'error': str(e)})
        finally:
            conn.close()

    laparams_dict = {
        'line_margin': laparams.line_margin,
        'char_margin': laparams.char_margin,
        'word_margin': laparams.word_margin,
        'boxes_flow': laparams.boxes_flow
    }

    parent_conn, child_conn = multiprocessing.Pipe()

    try:
        multiprocessing.set_start_method('spawn', force=False)
    except RuntimeError:
        pass

    p = multiprocessing.Process(target=_target, args=(str(pdf_path), laparams_dict, child_conn))
    p.start()
    p.join(timeout_seconds)

    if p.is_alive():
        p.terminate()
        p.join()
        raise TimeoutError(f"Extraction timed out after {timeout_seconds} seconds")

    result = parent_conn.recv()
    if not result['success']:
        raise Exception(result['error'])
    
    return result['text']

if __name__ == '__main__':
    input_pdf = Path(snakemake.params.pdf_path)
    output_txt = Path(snakemake.output.txt)

    output_txt.parent.mkdir(parents=True, exist_ok=True)

    if not input_pdf.exists():
        with open(output_txt, 'w', encoding='utf-8') as f:
            f.write("")
        sys.exit(0)

    laparams = LAParams(line_margin=0.5,
                        char_margin=4.0,
                        word_margin=0.1,
                        boxes_flow=None)

    TIMEOUT_SECONDS = 120

    try:
        text = extract_text_with_timeout(input_pdf, laparams, TIMEOUT_SECONDS)

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
            
    except TimeoutError as e:
        print(f'TIMEOUT while converting {input_pdf.name}: {e}')
        with open(output_txt, 'w', encoding='utf-8') as f:
            f.write("")
        sys.exit(0)
        
    except Exception as e:
        print(f'ERROR converting {input_pdf.name}: {e}')
        with open(output_txt, 'w', encoding='utf-8') as f:
            f.write("")
        sys.exit(0)
