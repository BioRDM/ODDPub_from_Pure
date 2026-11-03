import pandas as pd


article_id = snakemake.params.article_id

pure_table = pd.read_csv(snakemake.input.pure_table)
oddpub_results = (
    pd.read_csv(snakemake.input.oddpub_results)
    .assign(Article_ID=lambda x: x.article.str.replace('.txt', '').astype('int'))
)

data_sharing = (
    pure_table
    .merge(oddpub_results, how='left', left_on=article_id, right_on='Article_ID')
)

data_sharing.to_csv(snakemake.output.data_sharing, index=False)

sharing_scores = (
    data_sharing
    .dropna(subset='is_open_data')
    .groupby(snakemake.params.author_id)
    .agg(sharing_score=('is_open_data', 'mean'))
    .reset_index()
    .assign(
        sharing_category=lambda df: pd.cut(
            df['sharing_score'],
            bins=[-0.001, 0, 0.2, 0.4, 0.6, 0.8, 0.99, 1],
            labels=['0', '1-20', '21-40', '41-60', '61-80', '81-99', '100'],
            right=True
        )
    )
)

sharing_scores.to_csv(snakemake.output.sharing_scores, index=False)
