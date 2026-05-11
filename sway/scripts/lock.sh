#!/bin/bash

BAT_CAP=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1)
BAT_CAP=${BAT_CAP:-"--"}

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
    --ring-color "E4D4A3" \
    --inside-color "282828cc" \
    --line-color "3c3836" \
    --separator-color "00000000" \
    --text-color "ebdbb2" \
    --text-caps-lock-color "fabd2f" \
    --key-hl-color "8ec07c" \
    --caps-lock-bs-hl-color "fb4934" \
    --caps-lock-key-hl-color "fabd2f" \
    --ring-ver-color "FDFD96" \
    --text-ver-color "ebdbb2" \
    --inside-ver-color "282828cc" \
    --ring-wrong-color "fb4934" \
    --inside-wrong-color "282828cc" \
    --text-wrong-color "ebdbb2" \
    --ring-clear-color "ebdbb2" \
    --inside-clear-color "282828cc" \
    --timestr "%H:%M" \
    --datestr "%a, %d %b | $BAT_CAP%"
