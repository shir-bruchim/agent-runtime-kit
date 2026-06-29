#!/usr/bin/env bash
# =============================================================================
# self-healing-sweep.sh — Run the mechanical self-healing checks in one call
#
# Replaces the inline bash blocks in references/self-healing-checks.md for the
# four checks that ARE mechanical (no LLM reasoning needed): Check 1
# (cross-reference rot), Check 2 (stale promotion stubs), Check 4 (description
# length), Check 7 (hook-script existence + builtin-detection).
#
# The remaining checks (3 — duplication drift, 5 — repeat-use signal, 6 —
# subagent freshness, 8 — rule duplication, 9 — MCP health, 10 — plugin
# cohesion) still need LLM reasoning and stay in the workflow doc.
#
# Why a script: these four checks run on EVERY SCAN. Each one is multi-line
# bash/python. Promoting them removes ~80 lines of inline bash from the
# workflow that the SCAN agent would otherwise consume + reproduce as tool
# calls.
#
# Output sections (parseable by "===" prefix):
#   === XREF_ROT ===            Broken ~/.claude/<x>/<y> links across skills/agents/rules/commands
#   === STALE_PROMOTIONS ===    feedback-*.md stubs with "Promoted" marker
#   === DESC_LENGTH ===         SKILL.md descriptions over the 120-char target
#   === HOOK_EXISTENCE ===      Missing hook scripts (skips shell builtins)
#
# Project memory dir is auto-detected from $PWD. Override with $MEMORY_DIR.
#
# Usage:
#   bash ~/.claude/skills/strategic-compact/scripts/self-healing-sweep.sh
# =============================================================================

set -u

# Auto-detect project memory dir from $PWD (encoded path format).
# Override with MEMORY_DIR env var.
detect_memory_dir() {
  if [ -n "${MEMORY_DIR:-}" ]; then
    echo "$MEMORY_DIR"; return
  fi
  local encoded
  encoded=$(pwd | sed 's|/|-|g')
  local candidate="$HOME/.claude/projects/${encoded}/memory"
  if [ -d "$candidate" ]; then
    echo "$candidate"
  else
    # Fall back to most recently modified project memory dir.
    ls -dt "$HOME/.claude/projects"/*/memory 2>/dev/null | head -1
  fi
}

section() { printf '\n=== %s ===\n' "$1"; }

section XREF_ROT
# For every ~/.claude/<x>/<y> reference in skill/agent/rule/command bodies,
# verify the target path exists. Filters known false-positive patterns by
# default; set SCAN_STRICT_XREF=1 to see everything (useful for debugging the
# filter rules themselves).
python3 - <<'PY' 2>/dev/null
import os, re
home = os.path.expanduser("~")
strict = os.environ.get("SCAN_STRICT_XREF") == "1"
roots = [f"{home}/.claude/skills", f"{home}/.claude/agents",
         f"{home}/.claude/rules", f"{home}/.claude/commands"]
# Match ~/.claude/<dir>/<filename>[/...]  — capture the path up to first space, quote, or backtick.
pat = re.compile(r"~/\.claude/[A-Za-z0-9_./-]+")

# Known optional / placeholder paths — these are documentation, not broken links.
OPTIONAL_TARGETS = {
    "~/.claude/CLAUDE.md",            # canonically optional per /en/memory
    "~/.claude/protected-paths.txt",  # user-supplied, may not exist
    "~/.claude/memory/",              # documented optional dir
    "~/.claude/skills/expertise/",    # documented optional dir for domain skills
    "~/.claude/.concise-mode",        # state file, created on demand
    "~/.claude/tmp/",                 # state dir, created on demand
}
# Path fragments that are placeholders, not real paths (end with a separator/hyphen,
# contain a literal <X> placeholder, or end with `*` glob).
def is_placeholder(target: str) -> bool:
    if target.endswith(("-", "/", ".")):
        return True
    if "<" in target or ">" in target or "*" in target:
        return True
    return False

broken = []
suppressed = 0
for root in roots:
    if not os.path.isdir(root):
        continue
    for dirpath, _, files in os.walk(root):
        for fn in files:
            if not fn.endswith((".md", ".sh")):
                continue
            full = os.path.join(dirpath, fn)
            try:
                with open(full) as f:
                    for lineno, line in enumerate(f, 1):
                        for m in pat.findall(line):
                            target = m.rstrip(".,);:`'\"")
                            if not strict:
                                if target in OPTIONAL_TARGETS or is_placeholder(target):
                                    suppressed += 1
                                    continue
                            expanded = os.path.expanduser(target)
                            if not os.path.exists(expanded):
                                broken.append(f"{full}:{lineno} -> {target}")
            except (OSError, UnicodeDecodeError):
                pass
if broken:
    for b in broken:
        print(b)
else:
    print("(no broken links after filtering)")
if not strict and suppressed:
    print(f"  ({suppressed} suppressed — known-optional or placeholder; run with SCAN_STRICT_XREF=1 to see)")
PY

section STALE_PROMOTIONS
MEM_DIR=$(detect_memory_dir)
if [ -n "$MEM_DIR" ] && [ -d "$MEM_DIR" ]; then
  echo "memory_dir=$MEM_DIR"
  for f in "$MEM_DIR"/feedback-*.md; do
    [ -e "$f" ] || continue
    if grep -l -i "promoted" "$f" >/dev/null 2>&1; then
      # Extract the first ~/.claude/skills pointer (if any) and verify it exists
      pointer=$(grep -oE '~/\.claude/skills/[A-Za-z0-9_./-]+' "$f" | head -1)
      if [ -n "$pointer" ]; then
        expanded=$(eval echo "$pointer")
        if [ -e "$expanded" ]; then
          status="OK"
        else
          status="MISSING_TARGET"
        fi
        printf '%s\t%s\t%s\n' "$(basename "$f")" "$status" "$pointer"
      else
        printf '%s\tNO_POINTER\n' "$(basename "$f")"
      fi
    fi
  done
else
  echo "(memory dir not found — set MEMORY_DIR or run from a project working dir)"
fi

section DESC_LENGTH
# Per claude-code-best-practices.md, ~120 chars is the target for description.
# Hard cap on (description + when_to_use) is 1,536; flagging >200 chars here
# as a tightening candidate.
#
# Parse strategy: read YAML frontmatter only (between the first two `---`
# lines) and pull the `description:` value. Supports both single-line strings
# and YAML block scalars (`|` / `>`). Anything outside the frontmatter is
# ignored — that's what made an earlier regex include the whole body.
python3 - <<'PY' 2>/dev/null
import glob, os, re

TARGET = 120
WARN_AT = 200

def extract_description(text: str) -> str | None:
    """Return the description value from a SKILL.md's YAML frontmatter, or None."""
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None
    # Locate the closing `---` of the frontmatter.
    try:
        end = next(i for i in range(1, len(lines)) if lines[i].strip() == "---")
    except StopIteration:
        return None
    fm = lines[1:end]
    # Find the description: line.
    for i, line in enumerate(fm):
        m = re.match(r"^description:\s*(.*)$", line)
        if not m:
            continue
        rest = m.group(1)
        # Block scalar?
        if rest.strip() in ("|", ">", "|-", ">-"):
            block = []
            for follow in fm[i + 1 :]:
                if re.match(r"^\S", follow):  # next top-level key
                    break
                block.append(follow.strip())
            return " ".join(b for b in block if b)
        # Single-line (may be quoted).
        return rest.strip().strip('"\'')
    return None

any_flagged = False
for path in sorted(glob.glob(os.path.expanduser("~/.claude/skills/*/SKILL.md"))):
    try:
        with open(path) as f:
            text = f.read()
    except OSError:
        continue
    desc = extract_description(text)
    if desc is None:
        continue
    desc = re.sub(r"\s+", " ", desc).strip()
    if len(desc) > WARN_AT:
        any_flagged = True
        name = os.path.basename(os.path.dirname(path))
        print(f"{name}\t{len(desc)} chars (target <={TARGET})")
if not any_flagged:
    print("(all descriptions within target)")
PY

section HOOK_EXISTENCE
python3 - <<'PY' 2>/dev/null
import json, os, shutil
settings = os.path.expanduser("~/.claude/settings.json")
if not os.path.exists(settings):
    print("(settings.json absent)")
    raise SystemExit
with open(settings) as f:
    s = json.load(f)
# Shell builtins that look like missing scripts but aren't.
BUILTINS = {"echo", "true", "false", ":", "exit", "cd", "test", "[", "printf", "pwd"}
missing = []
for event, entries in (s.get('hooks') or {}).items():
    for e in entries:
        for h in (e.get('hooks') or []):
            if h.get('type') != 'command':
                continue
            cmd = (h.get('command') or '').strip()
            if not cmd:
                continue
            # Strip leading interpreter (bash / sh / python3) so we resolve the script.
            parts = cmd.split()
            first = parts[0]
            if first in {"bash", "sh", "zsh", "python3", "python"} and len(parts) > 1:
                target = parts[1]
            else:
                target = first
            # Skip builtins.
            if target in BUILTINS:
                continue
            # Expand $CLAUDE_PROJECT_DIR (project-scope) and tildes.
            target = target.replace("$CLAUDE_PROJECT_DIR", ".")
            expanded = os.path.expandvars(os.path.expanduser(target))
            # If PATH-resolvable (no slashes), use which.
            if "/" not in expanded:
                if shutil.which(expanded) is None and expanded not in BUILTINS:
                    missing.append(f"[{event}] PATH_NOT_FOUND: {target}")
            else:
                if not os.path.exists(expanded):
                    missing.append(f"[{event}] MISSING: {expanded}")
if missing:
    for m in missing:
        print(m)
else:
    print("(all hook scripts resolve)")
PY

section TIMESTAMP_UTC
date -u +%Y-%m-%dT%H:%M:%SZ