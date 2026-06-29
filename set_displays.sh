#!/bin/bash
#
# For sway, when I connect an external monitor, running this script will arrange the displays into monitors.
#  I usually keep monitor above laptop; or to the left of laptop (see below to change the script for this)
# When lid is closed, internal display is turned off
# Initial version used to be for i3/xrandr. To get this to work with xrandr, some work is needed.
#
#default sleep for 0 second if arg is not passed
# I use this at times with a sleep of 5 seconds to issue
# the command and then close the laptop screen
sleep ${1:-0}

# NOT really maintaining xrandr version
CMD_RANDR=xrandr
QRY_RANDR="xrandr -q"
SCALE_RANDR="0.60x0.60"
if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
  CMD_RANDR=wlr-randr
  QRY_RANDR=wlr-randr
  SCALE_RANDR="1.35" #1.35
fi

#TODO: xrandr based monitor listing
readarray -t MONITORS < <($QRY_RANDR | egrep "^\w+-" | cut -f1 -d' ' | sort)
#ASSumption: first one in sorted out is laptop builtin monitor

# turn off internal display when lid is closed; on otherwise
grep -ic open /proc/acpi/button/lid/LID0/state >/dev/null
LID_CLOSED=$?

for i in "${!MONITORS[@]}"; do
  #echo "Index: $i, Value: ${MONITORS[$i]}"
  if [ $i -eq 0 ]; then
    if [ $LID_CLOSED -eq 1 ]; then
      $CMD_RANDR --output "${MONITORS[$i]}" --off
    else
      $CMD_RANDR --output "${MONITORS[$i]}" --on --scale $SCALE_RANDR
    fi
    continue
  else
    $CMD_RANDR --output "${MONITORS[$i]}" --on
  fi
  p=$((i - 1))
  #TODO: xrandr based monitor resolution fetch
  # find current monitor's resolution, push previous monitor down by that much height
  # for left side stacking, use width and $SHIFT,0
  SHIFT=$(wlr-randr --json | jq ".[]|select(.name == \"${MONITORS[$i]}\")|.modes[]|select(.current)|.height")
  PREV_POSITION_FROM_CURRENT="--pos 0,$SHIFT"
  $CMD_RANDR --output "${MONITORS[$p]}" $PREV_POSITION_FROM_CURRENT "${MONITORS[$i]}"
done
