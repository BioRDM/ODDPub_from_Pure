from scripts.util import get_expected_files


configfile: "config.yaml"

env_map = {
    "linux": "envs/selenium-linux.yaml",
    "windows": "envs/selenium-windows.yaml",
    "macos": "envs/selenium-windows.yaml"
}

selected_env = env_map.get(config["os_type"], "envs/selenium-linux.yaml")

rule clean_table:
    input:
        data_file = config["main"]["input_file"]
    output:
        "outputs/clean_table.csv"
    params:
        article_id = config["main"]["article_id"]
    conda:
        selected_env
    script:
        "scripts/clean_table.py"

rule download_pdfs:
    input:
        clean_table = "outputs/clean_table.csv"
    params:
        download_folder = config["main"]["pdf_output"],
        url_separator = config["main"].get("url_separator", " // ")
    output:
        touch("outputs/PDFs/.download_complete")
    conda:
        selected_env
    script:
        "scripts/download_pdfs.py"

rule convert_pdf_to_txt:
    input:
        sentinel = "outputs/PDFs/.download_complete"
    output:
        txt = "outputs/txt/{sample}.txt"
    params:
        pdf_path = "outputs/PDFs/{sample}.pdf"
    conda:
        selected_env
    script:
        "scripts/pdf_to_txt.py"

rule run_oddpub:
    input:
        txt_files = expand('outputs/txt/{sample}.txt',
                           sample=get_expected_files(
                               input_file_path=config['main']['input_file'],
                               id_col_name=config['main'].get('article_id', 'Pure ID')
                           ))
    output:
        "outputs/oddpub_results.csv"
    params:
        input_dir = "outputs/txt",
        output_file = "outputs/oddpub_results.csv"
    conda:
        "envs/r-oddpub.yaml"
    script:
        "scripts/run_oddpub.R"

rule all:
    input:
        txt_files = expand(
            "outputs/txt/{sample}.txt",
            sample=get_expected_files(
                input_file_path=config['main']['input_file'],
                id_col_name=config['main'].get('article_id', 'Pure ID')
            )
        ),
        oddpub_results = "outputs/oddpub_results.csv"
