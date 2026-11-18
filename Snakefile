import os
from scripts.util import get_expected_files


configfile: "config.yaml"

rule clean_table:
    input:
        data_file = config["main"]["input_file"]
    output:
        "outputs/prelim_data/clean_table.csv"
    params:
        article_id = config["main"]["article_id"],
        article_links = config["main"]["article_links"]
    conda:
        "envs/selenium.yaml"
    script:
        "scripts/clean_table.py"

rule download_files:
    input:
        clean_table = "outputs/prelim_data/clean_table.csv"
    params:
        download_folder = os.path.join(workflow.basedir, "outputs/Files"),
        article_links = config["main"]["article_links"],
        url_separator = config["main"].get("url_separator", " // ")
    output:
        touch("outputs/Files/.download_complete")
    conda:
        "envs/selenium.yaml"
    script:
        "scripts/download_files.py"

rule convert_to_txt:
    input:
        sentinel = "outputs/Files/.download_complete",
    output:
        txt = "outputs/txt/{sample}.txt"
    params:
        pdf = "outputs/Files/{sample}.pdf",
        docx = "outputs/Files/{sample}.docx"
    conda:
        "envs/selenium.yaml"
    script:
        "scripts/convert_to_txt.py"

rule run_oddpub:
    input:
        txt_files = expand(
            'outputs/txt/{sample}.txt',
            sample=get_expected_files(
                input_file_path=config['main']['input_file'],
                id_col_name=config['main'].get('article_id', 'Pure ID')
            )
        )
    output:
        "outputs/oddpub/oddpub_results.csv"
    params:
        input_dir = "outputs/txt",
        output_file = "outputs/oddpub/oddpub_results.csv"
    conda:
        "envs/r-oddpub.yaml"
    script:
        "scripts/run_oddpub.R"

rule sharing_score:
    input:
        oddpub_results = "outputs/oddpub/oddpub_results.csv",
        pure_table = config["main"]["input_file"]
    output:
        data_sharing = "outputs/articles_data_sharing.csv",
        sharing_scores = "outputs/author_sharing_scores.csv"
    params:
        article_id = config["main"]["article_id"],
        author_id = config["main"]["author_id"]
    conda:
        "envs/selenium.yaml"
    script:
        "scripts/sharing_score.py"
