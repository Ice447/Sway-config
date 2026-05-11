#!/bin/bash

state_dir="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-system"
state_file="${state_dir}/bluetooth-state"

save_state() {
    mkdir -p "$state_dir"
    printf '%s\n' "$1" > "$state_file"
}

bluetooth_status=$(bluetoothctl show | awk '/Powered:/ { print $2; exit }')

if [ "$bluetooth_status" = "yes" ]; then
    bluetoothctl power off && save_state off
else
    bluetoothctl power on && save_state on
fi
