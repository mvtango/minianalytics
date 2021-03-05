#! /bin/bash

set -Eeuo pipefail

if [ "${DEBUG:-}" != "" ] ; then
    set -x
fi


q -H --output-header --tab-delimited ' select count(*) as c, ua from - group by ua ' \
| q -H --output-header --tab-delimited '
   select 
       ua,
       c,
       case 
             when ua like "%Android%" then "mobile.android"
             when ua like "%iPhone%" or ua like "%iPad%" then "mobile.ios"
             when ua like "%OS X%" then "desktop.mac"
             when ua like "%Linux%" then "desktop.linux"
             when ua like "%Windows %" then "desktop.windows"
             else "unknown"
       end as system,
       case 
             when ua like "%bot%" or ua like "%crawl%" then "bot"
             else "user"
       end as category
       from - 
    '
