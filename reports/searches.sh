#! /bin/bash

set -Eeuo pipefail

if [ "${DEBUG:-}" != "" ] ; then
    set -x
fi


q -H --output-header --tab-delimited '
  select 
       substr(time,0,11) as day, 
       count(*) as c, 
       case 
             when ua like "%bot%" or ua like "%crawl%" then "bot"
             else "user"
       end as category,
       query from - 
    where 
      query > ""
    group by 
      query, day, category ' \
|  python scripts/extract.py \
   'query=p=(?P<page>\d+)' \
   'query=name=(?P<name>[^&]+)' \
| q -H  --output-header --tab-delimited '
      select day, count(*) as c, max(page) as maxpage, name, category 
          from - 
          group by name, day, category
          order by day desc
  '\
| python scripts/unquote.py
