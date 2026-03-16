#!/bin/bash
# SessionStart Hook - Load previous session context
#
# Runs when a new Claude session starts. Loads the most recent session
# summary into context via stdout.
#
# Install: Add to settings.json under hooks.SessionStart
# Requires: jq (optional, for JSON output)

SESSIONS_DIR="${HOME}/.claude/sessions"
LEARNED_DIR="${HOME}/.claude/learned-skills"

# Ensure directories exist
mkdir -p "$SESSIONS_DIR" "$LEARNED_DIR"

# Find recent session files (last 7 days)
RECENT_SESSIONS=$(find "$SESSIONS_DIR" -name "*-session.tmp" -mtime -7 -type f 2>/dev/null | sort -r)

SESSION_COUNT=$(echo "$RECENT_SESSIONS" | grep -c . 2>/dev/null || echo 0)

if [ "$SESSION_COUNT" -gt 0 ]; then
    LATEST=$(echo "$RECENT_SESSIONS" | head -1)
    >&2 echo "[SessionStart] Found $SESSION_COUNT recent session(s)"
    >&2 echo "[SessionStart] Latest: $LATEST"

    # Read and inject latest session content (only if it has real content, capped at 10KB)
    if [ -f "$LATEST" ]; then
        CONTENT=$(head -c 10000 "$LATEST")
        if ! echo "$CONTENT" | grep -q '\[Session context goes here\]'; then
            echo "Previous session summary:"
            echo "$CONTENT"
        fi
    fi
fi

# Check for learned skills
SKILL_COUNT=$(find "$LEARNED_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
if [ "$SKILL_COUNT" -gt 0 ]; then
    >&2 echo "[SessionStart] $SKILL_COUNT learned skill(s) available in $LEARNED_DIR"
fi

exit 0
