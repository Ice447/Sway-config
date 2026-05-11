#!/usr/bin/env bash

set -u

status="$(playerctl status 2>/dev/null || true)"
title="$(playerctl metadata title 2>/dev/null || true)"
player="$(playerctl metadata --format '{{playerName}}' 2>/dev/null || true)"

if [ -n "$title" ]; then
    text="$title"
else
    text="$player"
fi

case "$status" in
    Playing)
        class="playing"
        ;;
    Paused)
        class="paused"
        ;;
    *)
        text=""
        class="hidden"
        ;;
esac

python3 -c 'import json, sys; print(json.dumps({"text": sys.argv[1], "tooltip": sys.argv[2], "class": sys.argv[3]}))' \
    "$text" "${player}: ${title}" "$class"
