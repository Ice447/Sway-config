#!/usr/bin/env bash

set -euo pipefail

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
bluetooth_state="$cache_dir/bluetooth-state"
waybar_config="${WAYBAR_CONFIG:-$HOME/.config/waybar/config}"
wofi_style="$HOME/.config/wofi/style.css"

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$@" || true
    fi
}

restart_waybar() {
    [[ "${WAYBAR_RESTART:-1}" == "1" ]] || return 0
    pkill -x waybar >/dev/null 2>&1 || true
    setsid waybar >/dev/null 2>&1 &
}

power_status() {
    local class profile text tooltip

    profile="$(powerprofilesctl get 2>/dev/null || true)"
    case "$profile" in
        performance) text="<span size='large' weight='bold'>󰓅</span>"; class="performance" ;;
        balanced) text="<span size='large' weight='bold'>󰾅</span>"; class="balanced" ;;
        power-saver) text="<span size='large' weight='bold'>󰌪</span>"; class="power-saver" ;;
        *) text="<span size='large' weight='bold'>󰤆</span> ppd"; class="error"; profile="unavailable" ;;
    esac

    tooltip="Power profile: $profile"
    printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$text" "$class" "$tooltip"
}

current_position() {
    python3 - "$waybar_config" <<'PY'
import json
import sys
from pathlib import Path

try:
    print(json.loads(Path(sys.argv[1]).read_text()).get("position", "top"))
except Exception:
    print("top")
PY
}

set_position() {
    local position="${1:-}"

    case "$position" in
        top|bottom) ;;
        toggle) [[ "$(current_position)" == "bottom" ]] && position="top" || position="bottom" ;;
        *) printf 'usage: %s position top|bottom|toggle\n' "$0" >&2; exit 2 ;;
    esac

    python3 - "$waybar_config" "$position" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
position = sys.argv[2]
config = json.loads(path.read_text())
modules = [m for m in config.get("modules-right", []) if m != "pulseaudio"]
modules.insert(modules.index("network") if "network" in modules else 0, "pulseaudio")

config["position"] = position
config["height"] = 27
config["modules-center"] = ["sway/window"]
config["modules-right"] = modules
config.pop("width", None)
path.write_text(json.dumps(config, ensure_ascii=False, indent=4) + "\n")
PY

    restart_waybar
    if [[ "${WAYBAR_NOTIFY:-1}" == "1" ]]; then
        notify "Waybar" "Position: $position"
    fi
}

power_menu() {
    local profile selection

    selection="$(
        printf '%s\n' \
            "󰓅 performance" \
            "󰾅 balanced" \
            "󰌪 power-saver" \
            "󰓡 waybar position" \
            "󰜉 reboot" \
            "󰐥 shutdown" \
            "󰍃 logout" |
            wofi --dmenu --prompt "Power" --width 260 --height 320 --style "$wofi_style"
    )" || exit 0

    case "$selection" in
        *performance*) profile="performance" ;;
        *balanced*) profile="balanced" ;;
        *power-saver*) profile="power-saver" ;;
        *"waybar position"*) set_position toggle; exit 0 ;;
        *reboot*) systemctl reboot; exit 0 ;;
        *shutdown*) systemctl poweroff; exit 0 ;;
        *logout*) swaymsg exit; exit 0 ;;
        *) exit 0 ;;
    esac

    if powerprofilesctl set "$profile"; then
        pkill -RTMIN+8 waybar 2>/dev/null || true
        notify "Power profile" "$profile"
    else
        notify "Power profile" "Could not set $profile"
        exit 1
    fi
}

toggle_audio() {
    pactl set-sink-mute @DEFAULT_SINK@ toggle
}

toggle_wifi() {
    if [[ "$(nmcli radio wifi)" == "enabled" ]]; then
        nmcli radio wifi off
    else
        nmcli radio wifi on
    fi
}

toggle_bluetooth() {
    local powered

    mkdir -p "$cache_dir"
    powered="$(bluetoothctl show | awk '/Powered:/ { print $2; exit }')"
    if [[ "$powered" == "yes" ]]; then
        bluetoothctl power off && printf 'off\n' > "$bluetooth_state"
    else
        bluetoothctl power on && printf 'on\n' > "$bluetooth_state"
    fi
}

restore_bluetooth() {
    local state

    [[ -r "$bluetooth_state" ]] || exit 0
    state="$(tr -d '[:space:]' < "$bluetooth_state")"
    [[ "$state" == "on" || "$state" == "off" ]] || exit 0

    for _ in 1 2 3 4 5 6 7 8 9 10; do
        if bluetoothctl show >/dev/null 2>&1; then
            bluetoothctl power "$state"
            exit $?
        fi
        sleep 1
    done

    exit 1
}

case "${1:-}" in
    power-status) power_status ;;
    power-menu) power_menu ;;
    position) set_position "${2:-}" ;;
    audio-toggle) toggle_audio ;;
    wifi-toggle) toggle_wifi ;;
    bluetooth-toggle) toggle_bluetooth ;;
    bluetooth-restore) restore_bluetooth ;;
    *) printf 'usage: %s {power-status|power-menu|position|audio-toggle|wifi-toggle|bluetooth-toggle|bluetooth-restore}\n' "$0" >&2; exit 2 ;;
esac
