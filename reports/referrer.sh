#! /bin/bash

set -Eeuo pipefail

if [ "${DEBUG:-}" != "" ] ; then
    set -x
fi


q -H --output-header --tab-delimited '
  select substr(time,0,11) as day, count(*) as c, referer from - 
    where 
      path not like "%static/%" and path not like "%favicon.ico" and referer>"" 
    group by 
      referer, day ' \
| python scripts/extract.py \
         "referer=://(?P<host>[^/]+)" \
         "host=(?P<source>[wm]\.google|baidu|yandex|wikipedia|duckduckgo|bing|facebook|t\.co|ihr\.world)" \
| q -H  --output-header --tab-delimited '
      select day, sum(c) as c, host, max(source) as source, max(referer) as example 
      from - group by host, day order by c desc
  '
