#!/bin/bash
#
# For sway, when I connect an external monitor, running this script will arrange the displays into monitors.
#  I usually keep monitor above laptop; or to the left of laptop (see below to change the script for this)
# When lid is closed, internal display is turned off
#
#default sleep for 0 second if arg is not passed
# I use this at times with a sleep of 5 seconds to issue
# the command and then close the laptop screen
sleep ${1:-0}

depencency_checks() {
  local missing=()
  for cmd in "$@"; do
    if command -v ${cmd} &>/dev/null; then
      :
    else
      missing+=("$cmd")
    fi
  done
  if ((${#missing[@]} > 0)); then
    echo "Please install following dependencies first:"
    for i in "${missing[@]}"; do
      echo "    $i"
    done
    exit 1
  fi
}

if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
  depencency_checks wlr-randr jq
  CMD_RANDR=wlr-randr
  SCALE_RANDR="1.35" #1.35
else
  depencency_checks xrandr jq jc
  CMD_RANDR=xrandr
  SCALE_RANDR="0.60x0.60"
fi

list_monitors() {
  #ASSumption: first one in sorted out is laptop builtin monitor
  if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    wlr-randr --json | jq -r ".[].name" | sort
  else
    xrandr -q | jc xrandr | jq -r ".screens[].devices[].device_name" | sort
  fi
}
get_external_monitor_shift() {
  local monitor_name="$1"
  local dimension="$2"
  if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    wlr-randr --json | jq ".[]|select(.name == \"${MONITORS[$i]}\")|.modes[]|select(.current)|.${dimension}"
  else
    xrandr -q | jc xrandr | jq ".screens[].devices[]|select(.device_name == \"${MONITORS[$i]}\")|.resolution_modes[]|select(.frequencies[].is_current)|.resolution_${dimension}"
  fi
}

readarray -t MONITORS < <(list_monitors)

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
  # find current monitor's resolution, push previous monitor down by that much height
  # for left side stacking, use width and $SHIFT,0
  SHIFT=$(get_external_monitor_shift "${MONITORS[$i]}" height)
  PREV_POSITION_FROM_CURRENT="--pos 0,$SHIFT"
  $CMD_RANDR --output "${MONITORS[$p]}" $PREV_POSITION_FROM_CURRENT "${MONITORS[$i]}"
done
