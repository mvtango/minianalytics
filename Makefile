SHELL := /bin/bash


.ONESHELL:
.SHELLFLAGS=-ec

.DEFAULT_GOAL := help


full: $(subst source/, data/full/, $(patsubst %.log.gz, %.tsv.gz, $(wildcard source/*.log.gz)))

data/full/%.tsv.gz: source/%.log.gz
	export TMPFILE=$$(mktemp ) \
	&& (zcat $< | python ./scripts/commonlog2tsv.py --header | gzip -c >$$TMPFILE) \
	&& mv $$TMPFILE $@ 

data/combined/full.tsv.gz: data/full/*.tsv.gz
	export TMPFILE=$$(mktemp )
	(zcat $< | head -1 
	for A in $?; do
	  zcat $$A | sed 1d
	done
	) | gzip -c >$$TMPFILE 
	[[ "$$?" == "0" ]] && mv $$TMPFILE $@


define REPORT_template =
data/$(1)/%-$(1).tsv.gz: data/full/%.tsv.gz reports/$(1).sh
	export TMPFILE=$$$$(mktemp ) \
	&& (zcat $$< | reports/$(1).sh | gzip -c >$$$$TMPFILE ) \
	&& mv $$$$TMPFILE $$@
endef

reportnames:= $(patsubst reports/%.sh,%,$(wildcard reports/*.sh))

$(foreach pipeline,$(reportnames),$(eval $(call REPORT_template,$(pipeline))))

dirs: $(patsubst %,data/%,$(reportnames))

data/%:
	mkdir -p $@

reports:= $(foreach reportname,$(reportnames), $(foreach datafile,$(wildcard data/full/*.tsv.gz), data/$(reportname)/$(patsubst data/full/%.tsv.gz,%,$(datafile))-$(reportname).tsv.gz))

reports: full dirs $(reports)

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

