#!/usr/bin/env bash
# =============================================================================
# block-dangerous-bash.sh — Compatibility alias for block-dangerous-commands.sh
#
# Kept so that existing hooks.json configs referencing the "bash" filename
# continue to work. Delegates to block-dangerous-commands.sh in the same dir.
#
# OPT-IN security hook. Install to ~/.claude/hooks/ alongside
# block-dangerous-commands.sh and register in ~/.claude/settings.json under
# PreToolUse for the Bash tool.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/block-dangerous-commands.sh"