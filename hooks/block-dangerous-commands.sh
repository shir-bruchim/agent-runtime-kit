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

# Extract command from tool_input (try jq first, then python3; fail-closed if both missing)
extract_command() {
  local json="$1"
  if command -v jq &>/dev/null; then
    echo "${json}" | jq -r '.tool_input.command // empty' 2>/dev/null && return
  fi
  if command -v python3 &>/dev/null; then
    echo "${json}" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except:
    pass
" 2>/dev/null && return
  fi
  # Fail-closed: if neither jq nor python3 is available, block
  echo "__PARSE_FAILED__"
}

command=$(extract_command "${input}")

if [[ "${command}" == "__PARSE_FAILED__" ]]; then
  printf '{"decision":"block","reason":"Security hook cannot parse input (jq and python3 unavailable)."}\n' >&2
  exit 2
fi

[[ -z "${command}" ]] && exit 0

block() {
  local reason="$1"
  printf '{"decision":"block","reason":"%s"}\n' "${reason}" >&2
  echo "${reason}" >&2
  exit 2
}

# Block: rm -rf targeting root or home directory
# Catches: rm -rf /, rm -r -f /, rm --recursive --force /, rm -rf ~, rm -rf $HOME
if echo "${command}" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*r)\s+(/\s*$|~\s*$|/\s|~\s)'; then
  block "Blocked: rm -rf on root or home directory."
fi
if echo "${command}" | grep -qE 'rm\s+(-r\s+-f|-f\s+-r)\s+(/\s*$|~\s*$|/\s|~\s)'; then
  block "Blocked: rm -r -f on root or home directory."
fi
if echo "${command}" | grep -qE 'rm\s+--recursive\s+--force\s+(/|~)|rm\s+--force\s+--recursive\s+(/|~)'; then
  block "Blocked: rm --recursive --force on root or home directory."
fi

# Block: dd targeting a raw disk device (includes NVMe, mapper, disk-by-id)
if echo "${command}" | grep -qE 'dd\s+.*\bof=/dev/(s|h|v|xv)d[a-z]|dd\s+.*\bof=/dev/nvme|dd\s+.*\bof=/dev/mapper/|dd\s+.*\bof=/dev/disk/'; then
  block "Blocked: dd to a raw disk device."
fi

# Block: fork bomb patterns (multiple syntaxes)
if echo "${command}" | grep -qE ':\s*\(\)\s*\{'; then
  block "Blocked: fork bomb pattern detected."
fi

# Block: disk formatting
if echo "${command}" | grep -qE '\bmkfs\b'; then
  block "Blocked: mkfs (disk formatting) is not allowed."
fi

# Block: curl/wget pipe to shell (remote code execution)
if echo "${command}" | grep -qE 'curl\s.*\|\s*(ba)?sh|wget\s.*\|\s*(ba)?sh|curl\s.*\|\s*zsh|wget\s.*\|\s*zsh'; then
  block "Blocked: piping remote content to shell is not allowed."
fi

# Block: recursive chmod 777 (world-writable)
if echo "${command}" | grep -qE 'chmod\s+(-[a-zA-Z]*R[a-zA-Z]*\s+)?777\s+/'; then
  block "Blocked: chmod 777 on root paths is not allowed."
fi

# Block: git force push (--force, --force-with-lease, -f, or +ref syntax)
if echo "${command}" | grep -qE 'git\s+push\s+.*--(force(-with-lease)?)\b|git\s+push\s+.*-[a-zA-Z]*f[a-zA-Z]*\b'; then
  block "Blocked: git push --force / --force-with-lease. Use a safe push workflow or override manually."
fi
if echo "${command}" | grep -qE 'git\s+push\s+\S+\s+\+'; then
  block "Blocked: git push +ref (force push via + syntax)."
fi

exit 0