# Minianalytics

Motivation: The logfile is there, yet we install Google Analytics because it has more options. After that, we use Google Analytics to derive the number of page views. That's a shame.

Built with: Makefile, Unix Pipes, Python, Q.

## How does it work

Common logfiles arrive in 

`source/`

they get converted to .tsv.gz in 

`full/`

then queried for reports using scripts in `reports/` that do Unix-Pipe-TSV transformations.  

The result is stored in 

`data/`

Common python helpers (generate session ID out of User Agent + IP + day, decode URL-encoded values) are stored in scripts/

Next step: make .sqlite file out of data and publish with datasette.




# Layout

### Step 1: produce one .tsv.gz from every logfile.gz
source/[dslug].*gz -> Source Files
data/full/[dslug]*.gz -> TSV files

### Step 2: produce one report for every tsv.gz and every reports/*.sh
reports/[rslug]*.sh -> reports
for each (rslug, dslug):
data/[rslug]/[dslug]-[rslug].tsv.gz -> results

### Step 3: join sub-reports

reports/[rslug]/*.tsv.gz -> reports/[rslug].tsv.gz



# Requirements

  - q http://harelba.github.io/q/
  - python



