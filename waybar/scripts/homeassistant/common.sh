#!/usr/bin/env bash

config_file="${HOME}/.config/waybar/secrets/homeassistant.env"

if [ -f "$config_file" ]; then
    # shellcheck disable=SC1090
    . "$config_file"
fi

ha_slot_key() {
    printf '%s' "$1" | tr '[:lower:]-' '[:upper:]_'
}

ha_slot_value() {
    slot_key="$(ha_slot_key "$1")"
    var_name="HA_${slot_key}_${2}"
    printf '%s' "${!var_name:-}"
}

ha_json_escape() {
    python3 -c 'import json, sys; print(json.dumps(sys.argv[1]))' "$1"
}

ha_print_json() {
    text="$(ha_json_escape "$1")"
    class="$(ha_json_escape "$2")"
    tooltip="$(ha_json_escape "$3")"
    printf '{"text":%s,"class":%s,"tooltip":%s}\n' "$text" "$class" "$tooltip"
}

ha_entity_urlencode() {
    python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "$1"
}
