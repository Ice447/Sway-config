#!/usr/bin/env bash
set -euo pipefail

config="$HOME/.config/matugen/config.toml"
wallpaper="${1:-}"

if [[ -z "$wallpaper" ]]; then
    wallpaper="$HOME/.wallpaper/background.png"
fi

if ! command -v matugen >/dev/null 2>&1; then
    echo "matugen is not installed" >&2
    exit 1
fi

if [[ ! -f "$wallpaper" ]]; then
    echo "wallpaper not found: ${wallpaper:-$HOME/.wallpaper/background.png}" >&2
    exit 1
fi

case "${wallpaper,,}" in
    *.png) ;;
    *)
        echo "unsupported wallpaper format: $wallpaper" >&2
        echo "expected a .png file" >&2
        exit 1
        ;;
esac

if [[ ! -f "$config" ]]; then
    echo "matugen config not found: $config" >&2
    exit 1
fi

matugen image "$wallpaper" \
    --config "$config" \
    --mode dark \
    --type scheme-tonal-spot \
    --prefer saturation \
    --quiet

if command -v swaymsg >/dev/null 2>&1; then
    swaymsg reload >/dev/null 2>&1 || true
fi

if command -v waybar >/dev/null 2>&1; then
    pkill waybar >/dev/null 2>&1 || true
    setsid waybar >/dev/null 2>&1 &
fi
