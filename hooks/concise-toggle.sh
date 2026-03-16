#!/bin/bash
# Concise Mode Toggle
#
# Usage: concise-toggle.sh [on|off|status]
# State stored in: ~/.claude/.concise-mode

STATE_FILE="${HOME}/.claude/.concise-mode"
ACTION="${1:-status}"

case "$ACTION" in
    on)
        echo "on" > "$STATE_FILE"
        echo "Concise mode: ON (brief responses, 1-3 sentences)"
        ;;
    off)
        echo "off" > "$STATE_FILE"
        echo "Concise mode: OFF (normal responses)"
        ;;
    status|*)
        if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "on" ]; then
            echo "Concise mode: ON"
        else
            echo "Concise mode: OFF"
        fi
        ;;
esac
