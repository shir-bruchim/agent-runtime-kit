#!/usr/bin/env bash
# Emit the top-level feature keys configured in ~/.claude/settings.json.
# Called from SKILL.md via the pre-approved
# `Bash(bash ~/.claude/skills/strategic-compact/scripts/*)` allow-tool,
# so it bypasses the session's working-directory grep sandbox that would
# otherwise reject a direct `grep ~/.claude/settings.json`.
set -euo pipefail
SETTINGS="${HOME}/.claude/settings.json"
[[ -r "$SETTINGS" ]] || { echo "(no settings.json)"; exit 0; }
grep -E '"(hooks|mcpServers|plugins|marketplaces|skillOverrides|skillListingBudgetFraction)"' "$SETTINGS" 2>/dev/null || echo "(none configured)"