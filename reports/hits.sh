#! /bin/bash

set -Eeuo pipefail

if [ "${DEBUG:-}" != "" ] ; then
    set -x
fi


q -H --output-header --tab-delimited '
  select substr(time,0,11) as day, count(*) as c, path from - 
    where 
      path not like "%static/%" and path not like "%favicon.ico" and status="200"
    group by 
      path, day ' \
| python scripts/extract.py \
         "path=/(?P<lang>[^/]+)/(?P<type>[^/]+)" \
| q -H  --output-header --tab-delimited '
      select day, sum(c) as c, lang, type  
          from - 
          group by day, lang, type
          order by c desc
  '
