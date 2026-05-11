#!/bin/bash

state_file="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-system/bluetooth-state"

[ -r "$state_file" ] || exit 0

state=$(tr -d '[:space:]' < "$state_file")

case "$state" in
    on)
        power_state=on
        ;;
    off)
        power_state=off
        ;;
    *)
        exit 0
        ;;
esac

for _ in 1 2 3 4 5 6 7 8 9 10; do
    if bluetoothctl show >/dev/null 2>&1; then
        bluetoothctl power "$power_state"
        exit $?
    fi

    sleep 1
done

exit 1
