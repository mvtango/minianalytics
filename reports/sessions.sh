#! /bin/bash

set -Eeuo pipefail

if [ "${DEBUG:-}" != "" ] ; then
    set -x
fi

q -H --output-header --tab-delimited '
 select time, ua, host, path, status from - 
' \
| python scripts/eval.py 'day=lambda r:r["time"][:10]' \
                       'session=lambda r: md5([r["ua"],r["host"],r["day"]])'  \
| q -H --output-header --tab-delimited '
  select day, count(*) as c, path, session, ua from - 
    where 
      path 
        not like "%well-known%" 
        and path not like "%static/%" 
        and path not like "%favicon.ico" 
        and path not like "%.env%" 
        and status="200"
    group by 
      path, day, session, ua ' \
| python scripts/extract.py \
         "path=/(?P<lang>[^/]+)(?P<type>/[^/]*)" \
| q -H  --output-header --tab-delimited '
      select day, session, sum(c) as c, lang, type, max(path) as example_path, max(ua) as example_ua  
          from - 
          group by day, session, lang, type
          order by c desc
  '
