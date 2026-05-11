#!/bin/bash

profile=$(powerprofilesctl get 2>/dev/null)

case "$profile" in
    performance)
        text="<span size='large' weight='bold'>󰓅</span>"
        class="performance"
        tooltip="Power profile: performance"
        ;;
    balanced)
        text="<span size='large' weight='bold'>󰾅</span>"
        class="balanced"
        tooltip="Power profile: balanced"
        ;;
    power-saver)
        text="<span size='large' weight='bold'>󰌪</span>"
        class="power-saver"
        tooltip="Power profile: power-saver"
        ;;
    *)
        text="<span size='large' weight='bold'>󰤆</span> ppd"
        class="error"
        tooltip="power-profiles-daemon unavailable"
        ;;
esac

printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$text" "$class" "$tooltip"
