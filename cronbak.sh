#!/bin/bash
# cron this to keep a backup of your cron! If cron hasn't changed, new versions won't be created
#
which rcsdiff > /dev/null 2>&1
WORKINGFILE=".crontab.txt"
if [ $? -ne 0 ]; then
   echo "ERROR: Install rcs package"
   exit 1
fi
# change this dir you want things to go to
cd ~
rm -f $WORKINGFILE
co -l $WORKINGFILE  > /dev/null 2>&1
if [ $? -ne 0 ]; then
   echo "No version info found; will create"
   crontab -l > $WORKINGFILE
   ci -u -m'Initial version' $WORKINGFILE
else
    crontab -l > $WORKINGFILE
    rcsdiff $WORKINGFILE  > /dev/null 2>&1
    res="$?"
    if [ $res -ne 0 ]; then
       #from cron, this will go to email :)
       rcsdiff $WORKINGFILE
       ci -u -m'Got a diff' $WORKINGFILE
    fi
fi
rm -f $WORKINGFILE
