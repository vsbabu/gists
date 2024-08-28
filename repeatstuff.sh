# there are times when you can't run stuff in cron, because full environment won't be available.
#   eg: automating tasks within Gnome or Cinnamon
# then, one easy way is to add your script to the startup application lists of your desktop environment
# it runs once, and then schedules itself to be repeated later using atq
# The following snippet can be used as is regardless of the name of the script.

#if you want to add some env variables into the mix
export DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS

# define a specific queue name for this script (a-z or A-Z)
QNAME="w"

#this clears up any already scheduled jobs in the queue. Useful if you want to manually run it and test
#and each run won't keep adding to existing queue
atrm $(atq -q $QNAME | cut -f1)
#just schedule yourself to run after a minute. Change 1 to whatever you want.
echo "`realpath $0`"|at -q $QNAME now + 1 min 