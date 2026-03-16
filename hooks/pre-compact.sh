#!/bin/bash
# PreCompact Hook - Save state before context compaction
#
# Runs before Claude compacts context. Logs the event and annotates
# the active session file so you can track when summarization occurred.
#
# Install: Add to settings.json under hooks.PreCompact

SESSIONS_DIR="${HOME}/.claude/sessions"
mkdir -p "$SESSIONS_DIR"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
COMPACTION_LOG="${SESSIONS_DIR}/compaction-log.txt"

# Log compaction event
echo "[$TIMESTAMP] Context compaction triggered" >> "$COMPACTION_LOG"

# Annotate the most recent active session file
LATEST_SESSION=$(find "$SESSIONS_DIR" -name "*-session.tmp" -type f 2>/dev/null | sort -r | head -1)

if [ -n "$LATEST_SESSION" ] && [ -f "$LATEST_SESSION" ]; then
    TIME_NOW=$(date +%H:%M:%S)
    echo "" >> "$LATEST_SESSION"
    echo "---" >> "$LATEST_SESSION"
    echo "**[Compaction occurred at ${TIME_NOW}]** - Context was summarized" >> "$LATEST_SESSION"
fi

>&2 echo "[PreCompact] State saved before compaction"
exit 0
