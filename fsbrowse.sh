#!/bin/bash

#Start vivaldi and wait for it to appear
#  then full screen it.
#  Vivaldi is already setup to always start with empty tab and startpage

log() {
  local lvl="$1"
  shift
  local msg="$*"
  local ts
  ts="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
  # Logs colored output to terminal and plain text to a file
  printf "[%s] [%s] %s\\n" "$ts" "$lvl" "$msg" | tee -a "${LOG_FILE:-/tmp/script.log}"
}
info() { log INFO "$@"; }
error() { log ERROR "$@"; }

MAXCOUNTER=5
DELAY=2
BROWSER_BIN=${1:-"vivaldi"}

#set window name
case $BROWSER_BIN in
microsoft-edge)
  browser_win="Edge"
  ;;
zen)
  browser_win="Zen Browser"
  ;;
*)
  #generally for other browsers, it is first letter uppercase
  browser_win="${BROWSER_BIN^}"
  ;;
esac
counter=1
browser_log="/tmp/$(basename $0)_${BROWSER_BIN}.log"

while true; do
  if [ $counter -gt $MAXCOUNTER ]; then
    error "Exiting - tries ($counter) exceeded max attempts ($MAXCOUNTER)"
    exit 1
  fi
  id=$(wmctrl -l | grep -oP "(?<=)(0x\w+)(?=.*$browser_win)")
  if [ $? -eq 0 ]; then
    log "got $BROWSER_BIN window $id in $COUNTER tries"
    break
  fi
  nohup $BROWSER_BIN &>$browser_log &
  log "started $BROWSER_BIN with pid $!"
  sleep $DELAY
  log "counter[$counter] - slept for $DELAY seconds"
  ((counter++))
done

#key seems to need a mini sleep to be active
log "sending F11 to maximize $BROWSER_BIN"
xdotool windowfocus $id key F11 sleep 0.5
