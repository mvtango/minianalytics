SHELL := /bin/bash


.ONESHELL:
.SHELLFLAGS=-ec

.DEFAULT_GOAL := help

full: ## convert log to tsv
full: $(subst source/, data/full/, $(patsubst %.log.gz, %.tsv.gz, $(wildcard source/*.log.gz))) 

data/full/%.tsv.gz: source/%.log.gz
	export TMPFILE=$$(mktemp ) \
	&& (zcat $< | python ./scripts/commonlog2tsv.py --header | gzip -c >$$TMPFILE) \
	&& mv $$TMPFILE $@ 


define REPORT_template =
data/$(1)/%-$(1).tsv.gz: data/full/%.tsv.gz reports/$(1).sh 
	@mkdir -p data/$(1) 
	printf "$$@ ----------- Start\n" >&2
	export TMPFILE=$$$$(mktemp ) \
	&& (zcat $$< | reports/$(1).sh | gzip -c >$$$$TMPFILE ) \
	&& mv $$$$TMPFILE $$@
	printf "$$@ ----------- End\n\n" >&2
endef

reportnames:= $(patsubst reports/%.sh,%,$(wildcard reports/*.sh))

partition_reports:= $(foreach reportname,$(reportnames), $(foreach datafile,$(wildcard data/full/*.tsv.gz), data/$(reportname)/$(patsubst data/full/%.tsv.gz,%,$(datafile))-$(reportname).tsv.gz))



$(foreach name,$(reportnames),$(eval $(call REPORT_template,$(name))))

dirs: $(patsubst %,data/%,$(reportnames))

# make data/(report) directories
data/%:
	mkdir -p $@



# join data/(report)/(partition)-(report).tsv.gz to data/(report).tsv.gz
data/%.tsv.gz: data/%
	q -H --tab-delimited -O "select * from $</*.gz" | gzip -c >$@
reports:= $(foreach reportname,$(reportnames),data/$(reportname).tsv.gz)

partition_reports: $(partition_reports)

reports: ## generate reports 
reports: full dirs $(reports)


all: partition_reports reports

test:
	echo REPORT NAMES: $(reportnames)
	echo PARTITIONED_REPORTS: $(partition_reports)
	echo REPORTS: $(reports)


EXAMPLES:=./data/ua/example-ua.tsv.gz ./data/searches/example-searches.tsv.gz ./data/full/example.tsv.gz ./data/head1/example-head1.tsv.gz ./data/tail/example-tail.tsv.gz ./data/sessiontest/example-sessiontest.tsv.gz ./data/hits/example-hits.tsv.gz ./data/sessions/example-sessions.tsv.gz ./data/referrer/example-referrer.tsv.gz ./source/example.log.gz
.PHONY: remove-examples
remove-examples:
	rm $(EXAMPLES)

restore-examples:
	git checkout -- $(EXAMPLES)
# queries: full $(subst sql/, data/, $(patsubst %.sql, %.tsv.gz, $(wildcard sql/*.sql)))
#
#data/%.tsv.gz: sql/%.sql data/combined/full.tsv.gz
#	echo combine $? to $@


	












# help prints out lines with double # 
# for .PHONY targets with double #: print everything up to the first double 
# so that target-specific variables get listed as well
.PHONY: help
help: ## Show help
	@printf "make targets:\n\n" \
	&& cat $(MAKEFILE_LIST) \
		| sed -rn '/^\.PHONY: .*\s##\s.*/,/\s##\s?/{;
	                 s/^[^\.][^ ]+:(\s##\s?)?/ /;
					 s/^\.PHONY: ([^ ]+)\s+##\s/\n\1:/;
				     p;
				   };
	               s/^(\S+)\s+##\s/\n\1 /p'

