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
        "outputs/PDFs/.download_complete"
    conda:
        selected_env
    script:
        "scripts/download_pdfs.py"

rule convert_pdfs_to_txt:
    input: