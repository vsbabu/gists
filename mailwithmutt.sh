#!/bin/bash
# thiscommand toemailaddress subject -r replyto -a attachment -m "mailbox to # copy to" -c cclist_csv_nospace
# body is in the standard input 
# FIXME: html mail mode doesn't go as html
#
#
ATTACHF="NONE"
MUTTRC="`dirname $0`/.gmail.muttrc"
# Contents of this .gmail.muttrc are as below.
# You must configure gmail to accept application password
# http://support.google.com/accounts/bin/answer.py?answer=185833
#  set from = "email@domain"
#  set realname = "fill it up"
#  set smtp_url = "smtp://me@domain:password@smtp.gmail.com:587/"
#  set record="$SEND_MBOX"
MBOX=".sent.default"
REPLYTO=""
EMTO="$1"; shift
EMSUBJECT="$1"; shift
#placeholder bogus command
MAILTYPE="set content_type=text/plain"
CCLIST=""
while getopts ":a:m:r:c:h" opt; do
  case $opt in
    a)
      ATTACHF=${OPTARG}
      ;;
    m)
      MBOX=".sent.${OPTARG}"
      ;;
    r)
      REPLYTO=${OPTARG}
      ;;
    c)
      CCLIST=${OPTARG}
      ;;
    h)
      MAILTYPE="set content_type=text/html"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done
if [ ! $CCLIST == "" ]; then
	#FIXME: looks like cclist has a bug if not given
	CCLIST=`echo "$CCLIST"|sed 's/,/ -c /g'`
	CCLIST="-c $CCLIST"
fi
if [ "NONE" == "$ATTACHF" ]; then
	cat - | REPLYTO="$REPLYTO" SEND_MBOX="$MBOX" mutt -F $MUTTRC -e "$MAILTYPE" $CCLIST -s "$EMSUBJECT" --  $EMTO
else
	if [ !  -f $ATTACHF ]; then
		echo "File not found $ATTACHF" >&2  
		exit 2
	fi
	cat - | REPLYTO="$REPLYTO" SEND_MBOX="$MBOX" mutt -F $MUTTRC -e "$MAILTYPE" $CCLIST -s "$EMSUBJECT" -a $ATTACHF   --  $EMTO
fi