#!/bin/bash

selection=$(printf '%s\n' \
    "󰓅 performance" \
    "󰾅 balanced" \
    "󰌪 power-saver" \
    "󰜉 reboot" \
    "󰐥 shutdown" \
    "󰍃 logout" |
    wofi --dmenu \
        --prompt "Power profile" \
        --width 260 \
        --height 270 \
        --style "$HOME/.config/wofi/style.css")

case "$selection" in
    *performance*) profile="performance" ;;
    *balanced*) profile="balanced" ;;
    *power-saver*) profile="power-saver" ;;
    *reboot*)
        systemctl reboot
        exit 0
        ;;
    *shutdown*)
        systemctl poweroff
        exit 0
        ;;
    *logout*)
        swaymsg exit
        exit 0
        ;;
    *) exit 0 ;;
esac

if powerprofilesctl set "$profile"; then
    pkill -RTMIN+8 waybar 2>/dev/null
    notify-send "Power profile" "$profile"
else
    notify-send "Power profile" "Could not set $profile"
    exit 1
fi
