#! /bin/bash

set -Eeuo pipefail

if [ "${DEBUG:-}" != "" ] ; then
    set -x
fi


q -H --output-header --tab-delimited '
  select substr(time,0,11) as day, count(*) as c, query from - 
    where 
      query > ""
    group by 
      query, day ' \
|  python scripts/extract.py \
   'query=p=(?P<page>\d+)' \
   'query=name=(?P<name>[^&]+)' \
| q -H  --output-header --tab-delimited '
      select day, count(*) as c, max(page) as maxpage, name 
          from - 
          group by name, day
          order by day desc
  '\
| python scripts/unquote.py
