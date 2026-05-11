#!/usr/bin/env bash

set -u

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "$script_dir/common.sh"

slot="${1:-}"
entity_id="$(ha_slot_value "$slot" ENTITY)"
name="$(ha_slot_value "$slot" NAME)"
icon_on="$(ha_slot_value "$slot" ICON_ON)"
icon_off="$(ha_slot_value "$slot" ICON_OFF)"

if [ -z "$slot" ] || [ -z "$entity_id" ]; then
    ha_print_json "" "hidden" ""
    exit 0
fi

if [ -z "${HA_URL:-}" ] || [ -z "${HA_TOKEN:-}" ]; then
    ha_print_json "${icon_off:-?}" "unconfigured" "${name:-$entity_id}: Home Assistant not configured"
    exit 0
fi

startup_marker_dir="${XDG_RUNTIME_DIR:-/tmp}/waybar-homeassistant-startup"
startup_marker="${startup_marker_dir}/${PPID}-${slot}"
if [ ! -e "$startup_marker" ]; then
    mkdir -p "$startup_marker_dir" 2>/dev/null || true
    : > "$startup_marker" 2>/dev/null || true
    if [ -e "$startup_marker" ]; then
        ha_print_json "${icon_off:-○}" "off" "${name:-$entity_id}: off"
        exit 0
    fi
fi

ha_url="${HA_URL%/}"

states_json="$(curl -fsS --max-time 4 \
    -H "Authorization: Bearer ${HA_TOKEN}" \
    -H "Content-Type: application/json" \
    "${ha_url}/api/states" 2>/dev/null || true)"

if [ -z "$states_json" ]; then
    ha_print_json "${icon_off:-?}" "unavailable" "${name:-$entity_id}: unavailable"
    exit 0
fi

export HA_SLOT="$slot"
export HA_ENTITY_ID="$entity_id"
export HA_FALLBACK_NAME="${name:-$entity_id}"
export HA_ICON_ON="${icon_on:-●}"
export HA_ICON_OFF="${icon_off:-○}"
export HA_SLOTS="${HA_SLOTS:-desktop,tv,bed_led,ceiling_light}"

ha_slot_entities=""
IFS=',' read -ra ha_slot_names <<< "$HA_SLOTS"
for raw_slot_name in "${ha_slot_names[@]}"; do
    slot_name="${raw_slot_name//[[:space:]]/}"
    [ -n "$slot_name" ] || continue
    slot_entity="$(ha_slot_value "$slot_name" ENTITY)"
    ha_slot_entities="${ha_slot_entities}${slot_name}=${slot_entity}"$'\n'
done
export HA_SLOT_ENTITIES="$ha_slot_entities"

python3 -c '
import json
import os
import sys

try:
    states = json.load(sys.stdin)
except Exception:
    print(json.dumps({
        "text": os.environ["HA_ICON_OFF"],
        "class": "unavailable",
        "tooltip": f"{os.environ['HA_FALLBACK_NAME']}: invalid response",
    }))
    raise SystemExit

state_by_entity = {item.get("entity_id", ""): item for item in states}
entity_id = os.environ["HA_ENTITY_ID"]
data = state_by_entity.get(entity_id, {})
state = data.get("state", "unavailable")
attrs = data.get("attributes") or {}
name = attrs.get("friendly_name") or os.environ["HA_FALLBACK_NAME"]
is_on = state == "on"
is_off = state == "off"

slots = []
for line in os.environ.get("HA_SLOT_ENTITIES", "").splitlines():
    if "=" not in line:
        continue
    slot_name, slot_entity = line.split("=", 1)
    if slot_name:
        slots.append((slot_name, slot_entity))

visible_slots = [(slot, entity) for slot, entity in slots if entity]
index = next((i for i, pair in enumerate(visible_slots) if pair[0] == os.environ["HA_SLOT"]), None)

left_same = False
right_same = False
if index is not None:
    if index > 0:
        left_entity = visible_slots[index - 1][1]
        left_same = (state_by_entity.get(left_entity, {}).get("state") == state)
    if index < len(visible_slots) - 1:
        right_entity = visible_slots[index + 1][1]
        right_same = (state_by_entity.get(right_entity, {}).get("state") == state)

if is_on:
    if left_same and right_same:
        css_class = "on-connected-both"
    elif left_same:
        css_class = "on-connected-left"
    elif right_same:
        css_class = "on-connected-right"
    else:
        css_class = "on"
elif is_off:
    if left_same and right_same:
        css_class = "off-connected-both"
    elif left_same:
        css_class = "off-connected-left"
    elif right_same:
        css_class = "off-connected-right"
    else:
        css_class = "off"
else:
    css_class = "unavailable"

print(json.dumps({
    "text": os.environ["HA_ICON_ON"] if is_on else os.environ["HA_ICON_OFF"],
    "class": css_class,
    "tooltip": f"{name}: {state}",
}))
' <<< "$states_json"
