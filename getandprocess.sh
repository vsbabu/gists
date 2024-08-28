#!/bin/bash
######################################################################
#
# Sample bash pattern to show efficiently downloading and
# processing downloaded files in a date order. Very useful
# when you are processing daily batch files. Downloads can
# happen parallely, but processing has to be sequential,
# in the order of date, even if some later files got downloaded
# first.
#
######################################################################

#this limits how many downloads in parallel; 
#set it to zero at your own peril :) 1 doesn't
#exactly limit it to 1.
MAX_PARALLEL_DOWNLOADS=1

download_tracker=`mktemp -d`
getfile() {
  local dt=$1
  local fl="${dt}.txt"
  local current_downloads=`find $download_tracker -name '*.txt'|wc -l`
  until [[ $current_downloads -lt $MAX_PARALLEL_DOWNLOADS ]]; do
    current_downloads=`find $download_tracker -name '*.txt'|wc -l`
    sleep $[ ( $RANDOM % 3 )  + 1 ]s
  done
  echo  "$fl : download started"
  #file based counters work better than global variables
  touch $download_tracker/$fl
  #TODO: change this line below to actually plugin download code
  #      currently it just sleeps random 1-10 seconds
  sleep $[ ( $RANDOM % 10 )  + 1 ]s && date > $fl
  echo "$fl : downloaded"
  rm -f $download_tracker/$fl
}

processfile() {
  local fl=$1
  echo "$fl : process started"
  #TODO: change this below to plugin process code
  sleep $[ ( $RANDOM % 5 )  + 1 ]s
  echo "$fl : processed"
}


#yymmdd
sincedb="160905"
fromdt=`date -d "$sincedb 1 days" +%Y%m%d`
yesterday=`date -d 'yesterday' +%Y%m%d`
processqueue=""

until [[ "$fromdt" > "$yesterday" ]]; do
  fromdt=`date -d "$fromdt 1 days" +%Y%m%d`
  getfile $fromdt &
  processqueue="$processqueue ${fromdt}.txt"
done
IFS=' ' read -r -a processqueue <<< "$processqueue"

for qf in "${processqueue[@]}"; do
  #wait for the file till it is present
  until [ -f $qf ]; do
    sleep 2
  done
  processfile $qf
  #cleanup
  rm -f $qf
  #you could update a file with date handled so fr
  #then you can read from that file into sincedb above
  #to pick up from where you left off.
done
