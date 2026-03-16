#!/bin/bash
# SessionEnd Hook - Persist session summary when session ends
#
# Reads the session transcript (provided via stdin JSON with transcript_path),
# extracts key information, and saves a session summary file.
#
# Install: Add to settings.json under hooks.Stop
# Requires: jq

SESSIONS_DIR="${HOME}/.claude/sessions"
mkdir -p "$SESSIONS_DIR"

TODAY=$(date +%Y-%m-%d)
TIME_NOW=$(date +%H:%M:%S)
SHORT_ID=$(echo $RANDOM | md5sum 2>/dev/null | head -c 6 || echo $RANDOM | md5 2>/dev/null | head -c 6 || echo "$$")
SESSION_FILE="${SESSIONS_DIR}/${TODAY}-${SHORT_ID}-session.tmp"

# Read stdin to get transcript_path
STDIN_DATA=$(cat)
TRANSCRIPT_PATH=""

if command -v jq &>/dev/null && [ -n "$STDIN_DATA" ]; then
    TRANSCRIPT_PATH=$(echo "$STDIN_DATA" | jq -r '.transcript_path // empty' 2>/dev/null)
fi

# Fallback to env var
[ -z "$TRANSCRIPT_PATH" ] && TRANSCRIPT_PATH="${CLAUDE_TRANSCRIPT_PATH:-}"

# Extract summary from transcript
USER_MESSAGES=""
FILES_MODIFIED=""
TOOLS_USED=""
MSG_COUNT=0

if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ] && command -v jq &>/dev/null; then
    # Extract user messages (last 10)
    USER_MESSAGES=$(grep '"type":"user"\|"role":"user"' "$TRANSCRIPT_PATH" 2>/dev/null | \
        jq -r '
            (.message.content // .content) |
            if type == "string" then .
            elif type == "array" then map(.text // "") | join(" ")
            else ""
            end
        ' 2>/dev/null | \
        grep -v '^$' | tail -10 | while read -r line; do
            echo "- ${line:0:200}"
        done)

    MSG_COUNT=$(grep -c '"type":"user"\|"role":"user"' "$TRANSCRIPT_PATH" 2>/dev/null || echo 0)

    # Extract files modified (Edit/Write tools)
    FILES_MODIFIED=$(grep '"type":"assistant"' "$TRANSCRIPT_PATH" 2>/dev/null | \
        jq -r '
            .message.content[]? |
            select(.type == "tool_use") |
            select(.name == "Edit" or .name == "Write") |
            .input.file_path // empty
        ' 2>/dev/null | sort -u | head -30 | while read -r f; do
            [ -n "$f" ] && echo "- $f"
        done)

    # Extract tools used
    TOOLS_USED=$(grep '"type":"assistant"' "$TRANSCRIPT_PATH" 2>/dev/null | \
        jq -r '.message.content[]? | select(.type == "tool_use") | .name // empty' 2>/dev/null | \
        sort -u | head -20 | tr '\n' ', ' | sed 's/,$//')
fi

# Build session file
cat > "$SESSION_FILE" << EOF
# Session: ${TODAY}
**Date:** ${TODAY}
**Started:** ${TIME_NOW}
**Last Updated:** ${TIME_NOW}

---

## Session Summary

### Tasks
${USER_MESSAGES:-"- (no tasks recorded)"}

### Files Modified
${FILES_MODIFIED:-"- (none)"}

### Tools Used
${TOOLS_USED:-"(none)"}

### Stats
- Total user messages: ${MSG_COUNT}
EOF

>&2 echo "[SessionEnd] Created session file: $SESSION_FILE"
exit 0
