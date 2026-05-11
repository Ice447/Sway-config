#!/usr/bin/env bash

status="$(playerctl status 2>/dev/null || true)"

case "$status" in
    Playing)
        printf '{"text":"󰏤","tooltip":"Pause"}\n'
        ;;
    Paused)
        printf '{"text":"󰐊","tooltip":"Wiedergabe"}\n'
        ;;
    *)
        printf '{"text":"","class":"hidden"}\n'
        ;;
esac
