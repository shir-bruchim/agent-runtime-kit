#!/usr/bin/env bash
# =============================================================================
# block-dangerous-commands.sh — Block destructive shell commands
#
# OPT-IN security hook. Install to ~/.claude/hooks/ and register in
# ~/.claude/settings.json under PreToolUse for the Bash tool.
#
# Blocked patterns:
#   - rm -rf / or rm -rf ~      (filesystem wipe)
#   - dd if=... of=/dev/...      (disk overwrite)
#   - :(){:|:&};:                (fork bomb)
#   - mkfs.*                     (disk format)
#
# Exit codes:
#   0 = allow (also outputs nothing or empty JSON)
#   0 = block (outputs JSON {"decision":"block","reason":"..."})
# =============================================================================

# Read JSON input from Claude
read -r input 2>/dev/null || input=""

# Extract command from tool_input
command=$(echo "${input}" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except:
    pass
" 2>/dev/null || echo "")

[[ -z "${command}" ]] && exit 0

# Block: rm -rf targeting root or home directory
if echo "${command}" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*r)\s+(/\s*$|~\s*$|/\s|~\s)'; then
  printf '{"decision":"block","reason":"Blocked: rm -rf on root or home directory."}\n'
  exit 0
fi

# Block: dd targeting a raw disk device
if echo "${command}" | grep -qE 'dd\s+.*\bof=/dev/(s|h|v|xv)d[a-z]\b'; then
  printf '{"decision":"block","reason":"Blocked: dd to a raw disk device."}\n'
  exit 0
fi

# Block: fork bomb pattern
if echo "${command}" | grep -qE ':\s*\(\)\s*\{'; then
  printf '{"decision":"block","reason":"Blocked: fork bomb pattern detected."}\n'
  exit 0
fi

# Block: disk formatting
if echo "${command}" | grep -qE '\bmkfs\b'; then
  printf '{"decision":"block","reason":"Blocked: mkfs (disk formatting) is not allowed."}\n'
  exit 0
fi

exit 0