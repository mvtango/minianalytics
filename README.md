
Layout

source/[dslug].*gz -> Source Files
sql/[qslug]*.sql -> Queries
data/raw/[dslug]*.gz -> TSV files
data/[qslug]*.gz -> Results


For each source/*.gz produce a data/raw/*.gz

For each sql/qslug*.sql produce a data/qslug.tsv.gz from all data/full/*tsv
