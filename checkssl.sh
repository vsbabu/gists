#!/bin/bash

DEFSSLPORT=443
read -r -d '' __DOC__ <<- EOH
USAGE: $0 domain1 domain2 domain3
Depends: openssl, gnu date
Assumes: SSL port is ${DEFSSLPORT} for all the domains
Output: Domain, Expiry Date, Days till expiry
EOH
if [[ $# -eq 0 ]];then
    echo "$__DOC__"
    exit 1
fi
for h in $*
do
    hf="${h}:${DEFSSLPORT}"
    hf_endssl=`echo | openssl s_client -connect $hf 2>/dev/null | openssl x509 -noout -dates|grep notAfter|cut -f2 -d'='`
    hf_endssl=`date --date="${hf_endssl}" --iso-8601`
    hf_daystill=`echo $(( ( $(date -ud ${hf_endssl} +'%s') - $(date -u +'%s') )/60/60/24 ))`
    printf "%30s %8s %4s\n" $hf $hf_endssl $hf_daystill
done
