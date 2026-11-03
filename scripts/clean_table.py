import pandas as pd


input_file = snakemake.input.data_file
id_col = snakemake.params.article_id
links_col = snakemake.params.article_links

(
    pd.read_csv(input_file)
    .dropna(subset=[links_col])
    .loc[lambda x: x[links_col] != 'null']
    .groupby(id_col)
    .agg({links_col: 'first'})
    .reset_index()
    .assign(filename=lambda x: x[id_col].astype(str))
    .to_csv(snakemake.output[0], index=False)
)
