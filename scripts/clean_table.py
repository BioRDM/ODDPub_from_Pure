import pandas as pd


input_file = snakemake.input.data_file

(
    pd.read_csv(input_file)
    .groupby(snakemake.params.article_id)
    .agg({'Files': 'first'})
    .reset_index()
    .query("Files != 'null'")
    .dropna(subset=['Files'])
    .assign(filename=lambda x: x['Pure ID'].astype(str))
    .to_csv(snakemake.output[0])
)
