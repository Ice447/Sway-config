#!/usr/bin/env bash

set -u

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "$script_dir/common.sh"

slot="${1:-}"
entity_id="$(ha_slot_value "$slot" ENTITY)"

if [ -z "$slot" ] || [ -z "$entity_id" ] || [ -z "${HA_URL:-}" ] || [ -z "${HA_TOKEN:-}" ]; then
    exit 1
fi

domain="${entity_id%%.*}"
ha_url="${HA_URL%/}"
payload="$(python3 -c 'import json, sys; print(json.dumps({"entity_id": sys.argv[1]}))' "$entity_id")"

curl -fsS --max-time 5 \
    -H "Authorization: Bearer ${HA_TOKEN}" \
    -H "Content-Type: application/json" \
    -X POST \
    -d "$payload" \
    "${ha_url}/api/services/${domain}/toggle" >/dev/null 2>&1 || exit 1

pkill -RTMIN+9 waybar 2>/dev/null || true
