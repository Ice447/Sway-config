#!/usr/bin/env bash

set -u

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "$script_dir/common.sh"

slot="${1:-}"
entity_id="$(ha_slot_value "$slot" ENTITY)"

[ -n "$slot" ] && [ -n "$entity_id" ]
