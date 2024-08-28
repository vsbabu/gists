#!/bin/bash
#
# changes wallpaper according to battery levels in Cinnamon DE
#
cd `dirname $0`
CMD="/usr/bin/gsettings set org.cinnamon.desktop.background picture-uri"
WALLP="file://${HOME}/Dropbox/Apps/Desktoppr/battery_cup"
CUR=`/usr/bin/gsettings get org.cinnamon.desktop.background picture-uri|sed "s/'//g"`
PCT=`cat /sys/class/power_supply/CMB0/capacity`
TYP=`cat /sys/class/power_supply/CMB0/status| tr '[:upper:]' '[:lower:]'`
WALLP="${WALLP}_${TYP}"
#set -e
if [ $PCT -ge 90 ]; then
  WALLP="${WALLP}_99.png"
elif [ $PCT -ge 70 ]; then
  WALLP="${WALLP}_75.png"
elif [ $PCT -ge 40 ]; then
  WALLP="${WALLP}_50.png"
elif [ $PCT -ge 20 ]; then
  WALLP="${WALLP}_25.png"
else
  WALLP="${CMD}_00.png"
fi
date > /tmp/wallpaper.sh.log
echo "$CUR ~ $WALLP" >> /tmp/wallpaper.sh.log
if [ "$CUR" != "$WALLP" ]; then
  echo "$CMD $WALLP" >> /tmp/wallpaper.sh.log
  $CMD $WALLP
fi
echo "$TYP type $PCT %" >> /tmp/wallpaper.sh.log
if [ "$TYP" == "charging" ]; then
  if [ $PCT -ge 95 ]; then
    #FIXME: This can get annoying if I am not around
    #       to unplug
    notify-send -u critical -i ac-adapter-symbolic "Disconnect charger" 
  fi
fi
export DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS
QNAME="w"
atrm $(atq -q $QNAME | cut -f1)
echo "`realpath $0`"|at -q $QNAME now + 1 min  >> /tmp/wallpaper.sh.log