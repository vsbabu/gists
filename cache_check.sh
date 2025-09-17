#!/bin/bash

# Prevent frequent runs for expensive processes.
# Note: Granularity level is only by days. To reduce it, see touch command
#       in the script and change the date modifier.
# Checked only in bash and in gnu/linux. Needs GNU Stat command to be present.
#
# ****************************** Usage *********************************************
# in calling script, do this first:
#    source ~/thisfile.sh <optional argument for number of days of cache_check>
#         if no argument is given, it is taken as 1 day
#         if argument is given as 0, it will assume script should be forced to run
#
# before you run rest of the commands in the calling script, do:
#   if cacheCanProceed; then
#      .... all your tasks
#
#      cacheMarkComplete
#   else
#      echo "Skipping run - last run at:"
#      cacheDate
#   fi
#
#   The last cacheMarkComplete is necessary, preferably after all the
#   other tasks in that script are completed successfully

CACHE_DIR=~/.local/share/cache_check/
CACHE_DAYS=${1:-1}

if [[ ! -d $CACHE_DIR ]]; then
  mkdir -p $CACHE_DIR
fi

CALLING_SCRIPT=$0
EXECUTE=false

#make a key file name by replacing directory separators.
CACHE_KEY=$(echo $CALLING_SCRIPT | sed 's/\//_/g')
CACHE_FILE="${CACHE_DIR}/${CACHE_KEY}"
CACHE_DAYS_AGO=/tmp/cache_check.$$
touch -d "$CACHE_DAYS days ago" $CACHE_DAYS_AGO

# if cache_file is older than ago timestamp, go ahead
# if cache_file doesn't exist, this test command will be true
if [ "$CACHE_FILE" -ot "$CACHE_DAYS_AGO" ]; then
  EXECUTE=true
fi
if [ $CACHE_DAYS -eq 0 ]; then
  EXECUTE=true
fi

# In calling script, call this function to check to proceed or not
function cacheCanProceed() {
  $EXECUTE
}

# In calling script, call this function when completed successfully
function cacheMarkComplete() {
  touch $CACHE_FILE
}

function cacheDate() {
  echo "$(stat -c '%y' $CACHE_FILE)"
}
