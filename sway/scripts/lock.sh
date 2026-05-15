#!/usr/bin/env bash

set -u

BAT_CAP="$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1)"
BAT_CAP="${BAT_CAP:-"--"}"

theme_file="$HOME/.config/sway/scripts/lock-colors.sh"
if [[ -r "$theme_file" ]]; then
    # shellcheck source=/dev/null
    source "$theme_file"
fi

color_value() {
    local name="$1"
    local fallback="${2:-#000000}"
    printf '%s' "${!name:-$fallback}"
}

hex_color() {
    local color
    color="$(color_value "$1" "${2:-#000000}")"
    color="${color#\#}"
    printf '%s' "${color:0:6}"
}

hex_alpha() {
    printf '%s%s' "$(hex_color "$1" "${3:-#000000}")" "$2"
}

swaylock \
    --screenshots \
    --clock \
    --indicator \
    --indicator-radius 120 \
    --indicator-thickness 15 \
    --effect-blur 10x10 \
    --effect-vignette 0.5:0.5 \
    --font "JetBrains Mono" \
    --font "Symbols Nerd Font" \
    --color "$(hex_color LOCK_SCREEN_COLOR)" \
    --bs-hl-color "$(hex_color LOCK_BS_HL_COLOR '#fb4934')" \
    --caps-lock-bs-hl-color "$(hex_color LOCK_CAPS_LOCK_BS_HL_COLOR '#fb4934')" \
    --caps-lock-key-hl-color "$(hex_color LOCK_CAPS_LOCK_KEY_HL_COLOR '#fabd2f')" \
    --inside-color "$(hex_alpha LOCK_INSIDE_COLOR aa)" \
    --inside-clear-color "$(hex_alpha LOCK_INSIDE_CLEAR_COLOR aa)" \
    --inside-caps-lock-color "$(hex_alpha LOCK_INSIDE_CAPS_LOCK_COLOR aa)" \
    --inside-ver-color "$(hex_alpha LOCK_INSIDE_VERIFY_COLOR aa)" \
    --inside-wrong-color "$(hex_alpha LOCK_INSIDE_WRONG_COLOR aa)" \
    --key-hl-color "$(hex_color LOCK_KEY_HL_COLOR '#8ec07c')" \
    --layout-bg-color "$(hex_alpha LOCK_LAYOUT_BG_COLOR aa)" \
    --layout-border-color "$(hex_color LOCK_LAYOUT_BORDER_COLOR '#3c3836')" \
    --layout-text-color "$(hex_color LOCK_LAYOUT_TEXT_COLOR '#ebdbb2')" \
    --line-color "$(hex_color LOCK_LINE_COLOR '#3c3836')" \
    --line-clear-color "$(hex_color LOCK_LINE_CLEAR_COLOR '#3c3836')" \
    --line-caps-lock-color "$(hex_color LOCK_LINE_CAPS_LOCK_COLOR '#fabd2f')" \
    --line-ver-color "$(hex_color LOCK_LINE_VERIFY_COLOR '#FDFD96')" \
    --line-wrong-color "$(hex_color LOCK_LINE_WRONG_COLOR '#fb4934')" \
    --ring-color "$(hex_color LOCK_RING_COLOR '#E4D4A3')" \
    --ring-clear-color "$(hex_color LOCK_RING_CLEAR_COLOR '#ebdbb2')" \
    --ring-caps-lock-color "$(hex_color LOCK_RING_CAPS_LOCK_COLOR '#fabd2f')" \
    --ring-ver-color "$(hex_color LOCK_RING_VERIFY_COLOR '#FDFD96')" \
    --ring-wrong-color "$(hex_color LOCK_RING_WRONG_COLOR '#fb4934')" \
    --separator-color "$(hex_alpha LOCK_SEPARATOR_COLOR 00)" \
    --text-color "$(hex_color LOCK_TEXT_COLOR '#ebdbb2')" \
    --text-clear-color "$(hex_color LOCK_TEXT_CLEAR_COLOR '#ebdbb2')" \
    --text-caps-lock-color "$(hex_color LOCK_TEXT_CAPS_LOCK_COLOR '#fabd2f')" \
    --text-ver-color "$(hex_color LOCK_TEXT_VERIFY_COLOR '#ebdbb2')" \
    --text-wrong-color "$(hex_color LOCK_TEXT_WRONG_COLOR '#ebdbb2')" \
    --timestr "%H:%M" \
    --datestr "%a, %d %b | $BAT_CAP%"
