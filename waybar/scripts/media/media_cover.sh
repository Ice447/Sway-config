#!/usr/bin/env bash

set -u

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-media"
cover_path="$cache_dir/cover.png"
state_path="$cache_dir/art-url"
tmp_path="$cache_dir/source"

if ! mkdir -p "$cache_dir" 2>/dev/null; then
    cache_dir="/tmp/waybar-media-${USER:-user}"
    cover_path="$cache_dir/cover.png"
    state_path="$cache_dir/art-url"
    tmp_path="$cache_dir/source"
    mkdir -p "$cache_dir"
fi

art_url="$(playerctl metadata mpris:artUrl 2>/dev/null || true)"
tooltip="$(playerctl metadata --format '{{artist}} - {{title}}' 2>/dev/null || true)"

if [ -z "$art_url" ]; then
    rm -f "$cover_path" "$state_path" "$tmp_path" 2>/dev/null || true
    printf '\n'
    exit 0
fi

if [ -f "$cover_path" ] && [ -f "$state_path" ] && [ "$(cat "$state_path")" = "$art_url" ]; then
    printf '%s\n%s\n' "$cover_path" "$tooltip"
    exit 0
fi

case "$art_url" in
    file://*)
        source_path="$(python3 -c 'import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))' "${art_url#file://}")"
        ;;
    http://*|https://*)
        if ! curl -fsSL --max-time 5 -o "$tmp_path" "$art_url"; then
            printf '\n'
            exit 0
        fi
        source_path="$tmp_path"
        ;;
    *)
        source_path="$art_url"
        ;;
esac

if [ ! -f "$source_path" ]; then
    rm -f "$cover_path" "$state_path" "$tmp_path" 2>/dev/null || true
    printf '\n'
    exit 0
fi

if command -v magick >/dev/null 2>&1; then
    magick "$source_path" \
        -resize 48x48^ -gravity center -extent 48x48 \
        \( -size 48x48 xc:none -fill white -draw "roundrectangle 0,0 47,47 8,8" \) \
        -alpha set -compose DstIn -composite \
        "$cover_path" >/dev/null 2>&1
else
    cp "$source_path" "$cover_path"
fi

if [ -f "$cover_path" ]; then
    printf '%s' "$art_url" > "$state_path"
    printf '%s\n%s\n' "$cover_path" "$tooltip"
else
    printf '\n'
fi
