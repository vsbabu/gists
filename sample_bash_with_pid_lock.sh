#!/bin/bash
SCRIPTDIR=`dirname $0`
PIDFILE="${SCRIPTDIR}/`basename $0`.pid"
if [[ -f $PIDFILE ]]; then
   echo "*** Last process hasn't completed successfully"
   curpid=$(<"$PIDFILE")
   echo "PID $curpid started at: `stat -c %y $PIDFILE`"
   if ps -p $curpid > /dev/null
   then 
      echo "$curpid is still running"
   else 
      echo "$curpid is NOT running; delete $PIDFILE before rerun"
   fi
   exit 1
fi
echo $$ > $PIDFILE
echo "doing work"
# exit on error
set -e 
sleep 5
echo "done work"
rm -f $PIDFILE