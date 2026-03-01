#!/usr/bin/env bash
# =============================================================================
# block-dangerous-commands.sh — Hard-block destructive shell commands
#
# OPT-IN security hook. Install to ~/.claude/hooks/ and register in
# ~/.claude/settings.json under PreToolUse for the Bash tool.
#
# Blocked patterns:
#   - rm -rf / or rm -rf ~      (filesystem wipe)
#   - dd if=... of=/dev/...      (disk overwrite)
#   - :(){:|:&};:                (fork bomb)
#   - mkfs.*                     (disk format)
#   - git push --force / --force-with-lease (force push — block by default)
#
# Exit codes:
#   0 = allow
#   2 = HARD BLOCK (Claude stops the operation immediately)
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

block() {
  local reason="$1"
  printf '{"decision":"block","reason":"%s"}\n' "${reason}" >&2
  echo "${reason}" >&2
  exit 2
}

# Block: rm -rf targeting root or home directory
if echo "${command}" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*r)\s+(/\s*$|~\s*$|/\s|~\s)'; then
  block "Blocked: rm -rf on root or home directory."
fi

# Block: dd targeting a raw disk device
if echo "${command}" | grep -qE 'dd\s+.*\bof=/dev/(s|h|v|xv)d[a-z]\b'; then
  block "Blocked: dd to a raw disk device."
fi

# Block: fork bomb pattern
if echo "${command}" | grep -qE ':\s*\(\)\s*\{'; then
  block "Blocked: fork bomb pattern detected."
fi

# Block: disk formatting
if echo "${command}" | grep -qE '\bmkfs\b'; then
  block "Blocked: mkfs (disk formatting) is not allowed."
fi

# Block: git force push (--force or --force-with-lease)
if echo "${command}" | grep -qE 'git\s+push\s+.*--(force(-with-lease)?)\b|git\s+push\s+.*-f\b'; then
  block "Blocked: git push --force / --force-with-lease. Use a safe push workflow or override manually."
fi

exit 0