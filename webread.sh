#!/bin/bash
# Collect all text in clipboard and add arguments given and open each in
# a browser. Needs `xsel` command to be available
# Useful to read articles, for which you get links in mail with bunch of utm trackers
#
_BROWSER="google-chrome --incognito"

function remove_query_string {
    echo "`echo "$1"|sed 's/?.*$//g'`"
}

function open_in_browser {
  txt_in="$1"
  if [[ $txt_in =~ ^(http|https)://* ]] ; then
    url="$txt_in"
    if [[ "$txt_in" = *source\=email-* ]]; then
      url=`remove_query_string $txt_in`
    #change this below to actual domain
    elif [[ "$txt_in" = https://site_using_too_much_utm_source.com* ]]; then
      url=`remove_query_string $txt_in`
    fi
    $_BROWSER "$url"
  fi
}

read -r -a array <<< "`xsel -o` $@"
for var in "${array[@]}"; do
  open_in_browser "$var"
done
