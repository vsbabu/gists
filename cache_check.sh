#!/bin/bash

# Prevent frequent runs for expensive processes.
# Checked only in bash and in gnu/linux. Needs GNU Stat command to be present.
#
# ****************************** Usage *********************************************
# in calling script, do this first:
#    source ~/thisfile.sh <optional argument for time duration for cache_check> <optional for time unit of measure>
#         if no argument is given, it is taken as 1 days. You can give 8 hours, 10 minutes etc.
#         See "man touch" and read DATE STRING section.
#         if argument is given as 0, it will assume script should be forced to run
#
# before you run rest of the commands in the calling script, do:
#   if cacheCanProceed; then
#      .... all your tasks
#
#      cacheMarkComplete
#   else
#      echo -n "Skipping run - last run at: "
#      cacheDate
#      echo -n "Next run can be after: "
#      nextAllowedDate
#   fi
#
#   The last cacheMarkComplete is necessary, preferably after all the
#   other tasks in that script are completed successfully

CACHE_DIR=~/.local/share/cache_check/
CACHE_TIME=${1:-1}
CACHE_TIME_UNIT=${2:-"days"}

if [[ ! -d $CACHE_DIR ]]; then
  mkdir -p $CACHE_DIR
fi

CALLING_SCRIPT=$0
EXECUTE=false

#make a key file name by replacing directory separators.
CACHE_KEY=$(echo $CALLING_SCRIPT | sed 's/\//_/g')
CACHE_FILE="${CACHE_DIR}/${CACHE_KEY}"
CACHE_TIME_AGO=/tmp/cache_check.$$
touch -d "$CACHE_TIME $CACHE_TIME_UNIT ago" $CACHE_TIME_AGO

# if cache_file is older than ago timestamp, go ahead
# if cache_file doesn't exist, this test command will be true
if [ "$CACHE_FILE" -ot "$CACHE_TIME_AGO" ]; then
  EXECUTE=true
fi
if [ $CACHE_TIME -eq 0 ]; then
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

function nextAllowedDate() {
  touch -r "$CACHE_FILE" -d "+$CACHE_TIME $CACHE_TIME_UNIT" $CACHE_TIME_AGO
  echo "$(stat -c '%y' $CACHE_TIME_AGO)"
}
