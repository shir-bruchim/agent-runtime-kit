#!/usr/bin/env bash
# =============================================================================
# suggest-compact.sh — Suggest manual /compact at strategic intervals
#
# OPT-IN hook. Tracks tool call count per session and suggests compaction
# at configurable thresholds. Install alongside the strategic-compact skill.
#
# Hook config (in ~/.claude/settings.json):
# {
#   "hooks": {
#     "PreToolUse": [{
#       "matcher": "Edit|Write",
#       "hooks": [{
#         "type": "command",
#         "command": "~/.claude/skills/strategic-compact/suggest-compact.sh"
#       }]
#     }]
#   }
# }
#
# Environment:
#   COMPACT_THRESHOLD — Tool calls before first suggestion (default: 50)
#   CLAUDE_SESSION_ID — Session identifier (auto-set by Claude Code)
# =============================================================================

# Session-specific counter file
SESSION_ID="${CLAUDE_SESSION_ID:-${PPID:-default}}"
COUNTER_FILE="/tmp/claude-tool-count-${SESSION_ID}"
THRESHOLD=${COMPACT_THRESHOLD:-50}

# Initialize or increment counter
if [[ -f "${COUNTER_FILE}" ]]; then
  count=$(cat "${COUNTER_FILE}")
  count=$((count + 1))
  echo "${count}" > "${COUNTER_FILE}"
else
  echo "1" > "${COUNTER_FILE}"
  count=1
fi

# Suggest compact at threshold
if [[ "${count}" -eq "${THRESHOLD}" ]]; then
  echo "[StrategicCompact] ${THRESHOLD} tool calls reached — consider /compact if transitioning phases" >&2
fi

# Periodic reminders after threshold (every 25 calls)
if [[ "${count}" -gt "${THRESHOLD}" ]] && [[ $((count % 25)) -eq 0 ]]; then
  echo "[StrategicCompact] ${count} tool calls — good checkpoint for /compact if context is stale" >&2
fi

exit 0
