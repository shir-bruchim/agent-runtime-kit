#!/usr/bin/env bash
# =============================================================================
# scan-inventory.sh — Dump the full Claude extension universe in one call
#
# Replaces the 6+ separate inventory bash blocks the self-improvement-pass
# workflow used to run inline (steps 1, 1d, 1e, 1f, 1g, 1h, 1i). One script,
# one tool call, one block of structured output the SCAN agent can parse.
#
# Why a script: the SCAN agent runs this EVERY invocation. Inline bash blocks
# burn tokens twice — once in the workflow doc that prescribes them, again in
# the tool-call payload. A single scripted call collapses both.
#
# Output sections, each prefixed with a "===" header for cheap awk-parsing:
#   === SKILLS ===          ls ~/.claude/skills/
#   === SUBAGENTS ===       ls ~/.claude/agents/
#   === COMMANDS ===        ls ~/.claude/commands/
#   === RULES ===           ls ~/.claude/rules/  + line counts
#   === CLAUDE_MD ===       wc -l on ~/.claude/CLAUDE.md (or absent marker)
#   === HOOK_SCRIPTS ===    ls ~/.claude/hooks/
#   === HOOKS_CONFIG ===    hooks section of settings.json (parsed JSON)
#   === MCP ===             mcpServers section of settings.json
#   === PLUGINS ===         plugins/marketplaces + ls ~/.claude/plugins/
#   === SKILL_LENGTHS ===   line count per SKILL.md (for token-budget review)
#
# Usage:
#   bash ~/.claude/skills/strategic-compact/scripts/scan-inventory.sh
# =============================================================================

set -u

SETTINGS="$HOME/.claude/settings.json"

section() { printf '\n=== %s ===\n' "$1"; }

section SKILLS
ls -1 ~/.claude/skills/ 2>/dev/null

section SUBAGENTS
ls -1 ~/.claude/agents/ 2>/dev/null

section COMMANDS
ls -1 ~/.claude/commands/ 2>/dev/null

section RULES
# Rules tree is folder-per-rule (`~/.claude/rules/<name>/RULE.md`) since the
# 2026-06-29 restructure, with optional `references/*.md` deep-dives. Old
# flat `*.md` glob returned EMPTY against the new layout.
if [ -d ~/.claude/rules ]; then
  for f in ~/.claude/rules/*/RULE.md; do
    [ -e "$f" ] || continue
    name="$(basename "$(dirname "$f")")"
    main_lines="$(wc -l < "$f" | tr -d ' ')"
    ref_lines=0
    ref_count=0
    if [ -d "$(dirname "$f")/references" ]; then
      for r in "$(dirname "$f")"/references/*.md; do
        [ -e "$r" ] || continue
        ref_count=$((ref_count + 1))
        ref_lines=$((ref_lines + $(wc -l < "$r" | tr -d ' ')))
      done
    fi
    if [ "$ref_count" -gt 0 ]; then
      printf '%s\t%s lines (+%s refs, %s lines)\n' "$name" "$main_lines" "$ref_count" "$ref_lines"
    else
      printf '%s\t%s lines\n' "$name" "$main_lines"
    fi
  done
fi

section CLAUDE_MD
if [ -f ~/.claude/CLAUDE.md ]; then
  printf '%s lines\n' "$(wc -l < ~/.claude/CLAUDE.md | tr -d ' ')"
else
  echo "ABSENT"
fi

section HOOK_SCRIPTS
ls -1 ~/.claude/hooks/ 2>/dev/null

section HOOKS_CONFIG
python3 - "$SETTINGS" <<'PY' 2>/dev/null
import json, os, sys
path = sys.argv[1]
if not os.path.exists(path):
    print("settings.json absent")
    sys.exit(0)
with open(path) as f:
    s = json.load(f)
hooks = s.get('hooks') or {}
if not hooks:
    print("(no hooks configured)")
for event, entries in hooks.items():
    for e in entries:
        matcher = e.get('matcher', '*')
        for h in (e.get('hooks') or []):
            kind = h.get('type', '?')
            target = h.get('command') or h.get('prompt') or ''
            cond = h.get('if', '')
            cond_str = f" if={cond}" if cond else ""
            print(f"{event}\tmatcher={matcher}\ttype={kind}{cond_str}\ttarget={target[:120]}")
PY

section MCP
python3 - "$SETTINGS" <<'PY' 2>/dev/null
import json, os, sys
path = sys.argv[1]
if not os.path.exists(path):
    sys.exit(0)
with open(path) as f:
    s = json.load(f)
servers = s.get('mcpServers') or {}
if not servers:
    print("(none in settings.json — may be configured at plugin/project scope)")
for name, cfg in servers.items():
    transport = cfg.get('type') or cfg.get('transport') or ('stdio' if cfg.get('command') else '?')
    print(f"{name}\ttransport={transport}")
PY

section PLUGINS
python3 - "$SETTINGS" <<'PY' 2>/dev/null
import json, os, sys
path = sys.argv[1]
if not os.path.exists(path):
    sys.exit(0)
with open(path) as f:
    s = json.load(f)
plugins = s.get('plugins') or {}
marketplaces = s.get('marketplaces') or {}
print(f"plugins_in_settings={list(plugins.keys()) if isinstance(plugins, dict) else plugins}")
print(f"marketplaces_in_settings={list(marketplaces.keys()) if isinstance(marketplaces, dict) else marketplaces}")
PY
ls -1 ~/.claude/plugins/ 2>/dev/null | sed 's/^/  plugins_dir: /'

section SKILL_LENGTHS
for f in ~/.claude/skills/*/SKILL.md; do
  [ -e "$f" ] || continue
  name=$(basename "$(dirname "$f")")
  lines=$(wc -l < "$f" | tr -d ' ')
  printf '%s\t%s\n' "$name" "$lines"
done | sort

section TIMESTAMP_UTC
date -u +%Y-%m-%dT%H:%M:%SZ