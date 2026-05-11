#!/usr/bin/env bash

set -u

config_file="${HOME}/.config/waybar/secrets/homeassistant.env"

if [ -f "$config_file" ]; then
    # shellcheck disable=SC1090
    . "$config_file"
fi

xdg-open "${HA_URL:-http://homeassistant.local:8123}" >/dev/null 2>&1
