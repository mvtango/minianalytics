#! /bin/bash

set -Eeuo pipefail

if [ "${DEBUG:-}" != "" ] ; then
    set -x
fi


q -H --output-header --tab-delimited '
  select substr(time,0,11) as day, 
         count(*) as c, 
         path,
         case 
             when ua like "%bot%" or ua like "%crawl%" then "bot"
             else "user"
         end as category
         from - 
    where 
      path 
        not like "%well-known%" 
        and path not like "%static/%" 
        and path not like "%favicon.ico" 
        and path not like "%.env%" 
        and status="200"
    group by 
      path, day, category ' \
| python scripts/extract.py \
         "path=/(?P<lang>[^/]+)(?P<type>/[^/]*)" \
| q -H  --output-header --tab-delimited '
      select day, sum(c) as c, lang, type, max(path) as example, category 
          from - 
          group by day, lang, type, category
          order by c desc
  '
