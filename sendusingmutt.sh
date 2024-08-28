#
# mutt works very well for sending mails without interaction as well. Quick one for my reference that has 
# a subject, to, from, body and attachment.
# 
EMTO="recipient@one.com,recipient@two.com"
EMFROM="Sender Name <name@sender.com>"
EMSUBJECT="Subject Line"
ATTACHF="/some/path/to/file.attachment.zip"
cat <<EOBODY | EMAIL="$EMFROM" mutt -s "$EMSUBJECT" -a "$ATTACHF" -- $EMTO

Please find the attachment file $ATTACHF.

EOBODY

