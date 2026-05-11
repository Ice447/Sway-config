#!/usr/bin/env bash

set -u

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-media"
pause_hide_after=30

clear_media_cache() {
    rm -f "$cache_dir/cover.png" "$cache_dir/art-url" "$cache_dir/source" "$pause_state" 2>/dev/null || true
}

if ! mkdir -p "$cache_dir" 2>/dev/null; then
    cache_dir="/tmp/waybar-media-${USER:-user}"
    mkdir -p "$cache_dir"
fi

pause_state="$cache_dir/pause-since"
status="$(playerctl status 2>/dev/null || true)"

case "$status" in
    Playing)
        rm -f "$pause_state" 2>/dev/null || true
        exit 0
        ;;
    Paused)
        now="$(date +%s)"

        if [ ! -f "$pause_state" ]; then
            printf '%s\n' "$now" > "$pause_state"
            exit 0
        fi

        pause_started="$(cat "$pause_state" 2>/dev/null || printf '%s' "$now")"

        case "$pause_started" in
            *[!0-9]*|'')
                printf '%s\n' "$now" > "$pause_state"
                exit 0
                ;;
        esac

        if [ $((now - pause_started)) -ge "$pause_hide_after" ]; then
            exit 1
        fi

        exit 0
        ;;
    *)
        clear_media_cache
        exit 1
        ;;
esac
