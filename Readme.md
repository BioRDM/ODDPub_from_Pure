# ODDPub from Pure

This repository contains a snakemake pipeline to download PDFs from the University of Edinburgh Pure, convert them to text, and run the [ODDPub data sharing detection algorithm](https://github.com/quest-bih/oddpub) on them.

The only required input is a table of publications exported from Pure, with the following columns:

- Article ID (e.g. Pure ID, but any unique ID is ok)
- Links to article full text on Pure ("Files"). Do not use DOIs or links to publisher websites, as many of those don't work for automatic download
- Author ID (e.g. author names or Pure ID, but any unique ID is ok)

## Authors

- Daniel Thedie (daniel.thedie@ed.ac.uk)

## Installation

### Pre-requisites

Check that Git is installed on your machine:

```sh
git --version
```

If not, [install Git](https://git-scm.com/install/windows).

If you cannot or do not want to install Git on your computer, that's fine - at the repository cloning step (see below), download the code from GitHub instead of cloning.

If you are using Windows or MacOS, MS Word will need to be installed on your machine (to convert docx files to pdf). If you are using Linux, Libreoffice should be installed.

### Snakemake

Open Powershell

Install pixi

```sh
powershell -ExecutionPolicy Bypass -c "irm -useb https://pixi.sh/install.ps1 | iex"
```

Create a new directory for snakemake. **Make sure the directory is on a local drive (C:\) and not a network drive (e.g. M:\ or U:\)**. To change directory, use `cd`.

```sh
mkdir snakemake
cd snakemake
```

Install and activate snakemake:

```sh
pixi init
pixi workspace channel add conda-forge
pixi workspace channel add bioconda
pixi add snakemake
pixi add conda
pixi shell
```

Clone the repository:

```sh
git clone https://github.com/BioRDM/ODDPub_from_Pure.git
```

Alternatively, if you don't have git installed, just download the code from GitHub and place it in the snakemake folder.

## Usage

Enter the "ODDPub_from_Pure" repository:

```sh
cd ODDPub_from_Pure
```

Edit the config file:

```sh
notepad config.yaml
```

The main things to edit are:

- OS type
- Path to input data table (the repository contains an example table in the test-data repository if you want to test the pipeline)

When working with your own data, make sure the following fields are also set correctly:

| Field         | Description                                                                                                                                                     |
|---------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| article_id    | Column name for the article unique identifier (e.g. Pure ID)                                                                                                    |
| article_links | Column name for the full text download links (usually called "Files" in Pure)                                                                                   |
| url_separator | String that separates multiple URLs in the "article_links" column. If the string is "//", make sure to include spaces (" // ") so it does not match https://... |
| author_id     | Column name for the author unique identifier (usually author name, or Pure ID)                                                                                  |

Run the full pipeline:

```sh
snakemake --cores all --use-conda sharing_score
```

You will be prompted to authenticate with your University of Edinburgh logins once. After authentication, the browser window will show a 500 error. This is normal. Ignore the error, leave the window open, and return to the console. Press Enter to resume the pipeline. After this, the pipeline will be fully automated.

Note that the full execution of the pipeline will take **some time**, especially for several hundred articles (could be several hours).

If the pipeline crashes at any point (or gets interrupted by the computer going to sleep, etc.), just restart it with the same command as above. It will recognise where it stopped, and resume from there. If PDF download had already completed, you won't be asked to enter your credentials again.

## Outputs

Pipeline outputs are saved in the "outputs" folder in the ODDPub_from_Pure repository. Here are the folders and files, in the order they are generated:

- prelim_data/
  - clean_table.csv
	- An intermediate table containing article IDs and download links
- PDFs/
  - The full text PDFs downloaded from Pure
- txt/
  - The article full text in .txt format, converted from the PDFs
- oddpub/
  - oddpub_results.csv
	- The results file output by ODDPub after running on the text files
- articles_data_sharing.csv
  - The input table, with ODDPub results merged at the end
- author_sharing_scores.csv
  - A table of all authors with their sharing score (0-1) and sharing category (in 20% bins, plus 0 and 100)

## Developer info

### Pipeline

The pipeline is defined in the "Snakefile" at the root of this repository. For details on snakemake and snakefiles, see the [snakemake docs](https://snakemake.readthedocs.io/en/stable/).

The scripts folder contains the code used for the pipeline. All of it is Python, except ODDPub which runs in R.

### Environments

Environments are defined in yaml files in the "envs/" folder.

There are two Python environments depending on OS (Linux or Windows, MacOS uses the Windows environment). The reason for this is that Windows/MacOS need the `docx2pdf` package to convert docx files to pdf at the download stage. This package is not available on Linux (which uses Libreoffice instead), so it's excluded from the environment.

The R environment installs R and the basic libraries that are necessary. Installing ODDPub and its dependencies is done via [renv](https://rstudio.github.io/renv/articles/renv.html), with packages to install listed in "renv.lock".
