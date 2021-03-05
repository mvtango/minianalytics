#! /bin/bash

set -Eeuo pipefail

if [ "${DEBUG:-}" != "" ] ; then
    set -x
fi


q -H --output-header --tab-delimited '
   select count(*), ua from - 
    group by 
     ua '
