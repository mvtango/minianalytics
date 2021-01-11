#! /bin/bash

set -Eeuo pipefail

if [ "${DEBUG:-}" != "" ] ; then
    set -x
fi


q -H --output-header --tab-delimited '
    select count(*) as c, referer from - 
    where 
      path not like "%static/%" and referer>"" 
    group by 
      referer ' \
| sed -r 's#(https?://([^/]+).*)#\2\t\1#' \
| q -H  --output-header --tab-delimited '
      select sum(c) as c, referer, max(c3) as ex from - group by referer order by c desc
  '
