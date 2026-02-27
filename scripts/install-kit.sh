#!/usr/bin/env bash
# =============================================================================
# install-kit.sh — Agent Runtime Kit Atomic Installer
#
# Reads a JSON plan from check-kit-updates.sh and installs files atomically.
# Records every completed file in state so an interrupted install can be
# resumed exactly where it stopped — no half-applied updates.
#
# Usage:
#   # Pipe from check script (most common):
#   scripts/check-kit-updates.sh --profile core | scripts/install-kit.sh
#
#   # From a saved plan file:
#   scripts/install-kit.sh --plan /tmp/kit-plan.json
#
#   # Resume an interrupted install:
#   scripts/install-kit.sh --plan /tmp/kit-plan.json --resume
#
#   # Preview without writing anything:
#   scripts/install-kit.sh --plan /tmp/kit-plan.json --dry-run
#
# Options:
#   --plan FILE         JSON plan file (default: read from stdin)
#   --project-dir DIR   Project root for project-level files (default: cwd)
#   --resume            Resume an interrupted installation
#   --dry-run           Show what would happen without making changes
#
# Per-file actions in the plan:
#   NEW      — install (destination doesn't exist)
#   CHANGED  — replace (destination exists but differs)
#   IDENTICAL — skip (already up to date)
#   SKIP     — skip (user marked it to keep as-is)
#   MERGE    — skip (user will merge manually)
#
# File types handled:
#   skill_dir       — copy directory to ~/.claude/skills/
#   agent_file      — copy .md to ~/.claude/agents/
#   command_file    — copy .md to ~/.claude/commands/
#   rule_file       — copy .md to .claude/rules/ (project-level)
#   lang_file       — copy language convention .md to .claude/rules/
#   hook_file       — copy .sh to hooks dir, make executable
#   cursor_mdc      — generate .mdc from source .md via generate-cursor-mdc.sh
#   agents_md       — copy AGENTS.md template to project root
#   gemini_md       — copy GEMINI.md template to project root
#
# Exit codes:
#   0 = all done
#   1 = fatal error / aborted
#   2 = partial install (interrupted — run with --resume to continue)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROJECT_DIR="$(pwd)"
PLAN_FILE=""
RESUME=false
DRY_RUN=false
STATE_FILE="${HOME}/.claude/.agent-kit-state.json"
GENERATE_MDC="${SCRIPT_DIR}/generate-cursor-mdc.sh"

# ── Parse args ────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --plan)        PLAN_FILE="$2"; shift 2 ;;
    --project-dir) PROJECT_DIR="$2"; shift 2 ;;
    --resume)      RESUME=true;  shift ;;
    --dry-run)     DRY_RUN=true; shift ;;
    -h|--help)
      sed -n '3,50p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# ── Read plan ─────────────────────────────────────────────────────────────────
TMPPLAN="$(mktemp)"
trap 'rm -f "${TMPPLAN}"' EXIT

if [[ -n "${PLAN_FILE}" ]]; then
  cp "${PLAN_FILE}" "${TMPPLAN}"
else
  cat > "${TMPPLAN}"   # read from stdin
fi

# Validate JSON
if ! python3 -c "import json; json.load(open('${TMPPLAN}'))" 2>/dev/null; then
  echo "❌ Invalid JSON plan. Run check-kit-updates.sh first." >&2
  exit 1
fi

KIT_COMMIT=$(python3 -c "import json; print(json.load(open('${TMPPLAN}')).get('kit_commit','unknown'))" 2>/dev/null || echo "unknown")
PROFILE=$(python3 -c "import json; print(json.load(open('${TMPPLAN}')).get('profile','core'))" 2>/dev/null || echo "core")
PLATFORM=$(python3 -c "import json; print(json.load(open('${TMPPLAN}')).get('platform','claude'))" 2>/dev/null || echo "claude")
DETECTED_LANG=$(python3 -c "import json; print(json.load(open('${TMPPLAN}')).get('detected_lang',''))" 2>/dev/null || echo "")

# ── State helpers ─────────────────────────────────────────────────────────────
state_get() {
  local key="$1" default="${2:-}"
  python3 - <<PYEOF 2>/dev/null || echo "${default}"
import json, sys
try:
    d = json.load(open('${STATE_FILE}'))
    v = d.get('${key}')
    print(v if v is not None else '${default}')
except:
    print('${default}')
PYEOF
}

state_update() {
  local updates="$1"    # Python dict literal string
  mkdir -p "$(dirname "${STATE_FILE}")"
  python3 - <<PYEOF 2>/dev/null || true
import json, os
f = '${STATE_FILE}'
d = {}
if os.path.exists(f):
    try: d = json.load(open(f))
    except: pass
d.update(${updates})
json.dump(d, open(f, 'w'), indent=2)
PYEOF
}

mark_done() {
  local dest="$1"
  python3 - <<PYEOF 2>/dev/null || true
import json, os
f = '${STATE_FILE}'
d = {}
if os.path.exists(f):
    try: d = json.load(open(f))
    except: pass
done = d.get('install_completed_files', [])
if '${dest}' not in done:
    done.append('${dest}')
d['install_completed_files'] = done
json.dump(d, open(f, 'w'), indent=2)
PYEOF
}

is_done() {
  local dest="$1"
  python3 - <<PYEOF 2>/dev/null || echo "no"
import json
try:
    d = json.load(open('${STATE_FILE}'))
    print('yes' if '${dest}' in d.get('install_completed_files', []) else 'no')
except:
    print('no')
PYEOF
}

# ── Guard against unresolved interrupted install ──────────────────────────────
INSTALL_STATUS=$(state_get "install_status" "idle")
if [[ "${INSTALL_STATUS}" == "in_progress" && "${RESUME}" == "false" && "${DRY_RUN}" == "false" ]]; then
  prev_commit=$(state_get "install_kit_commit" "unknown")
  echo "⚠  A previous installation was interrupted (commit: ${prev_commit:0:8})" >&2
  echo "   Run with --resume to continue from where it stopped." >&2
  echo "   Or delete ${STATE_FILE} to start fresh." >&2
  exit 1
fi

# ── Initialise state for a fresh install ─────────────────────────────────────
if [[ "${RESUME}" == "false" && "${DRY_RUN}" == "false" ]]; then
  state_update "{'install_status':'in_progress','install_kit_commit':'${KIT_COMMIT}','install_project_dir':'${PROJECT_DIR}','install_completed_files':[],'install_started_at':'$(date -u +%Y-%m-%dT%H:%M:%SZ)'}"
fi

echo "Installing Agent Runtime Kit"
echo "  commit:   ${KIT_COMMIT:0:8}..."
echo "  profile:  ${PROFILE}"
echo "  platform: ${PLATFORM}"
[[ "${RESUME}"   == "true" ]] && echo "  (resuming interrupted install)"
[[ "${DRY_RUN}"  == "true" ]] && echo "  (dry-run — no files will be written)"
echo ""

# ── Install helper ────────────────────────────────────────────────────────────
installed=0; skipped=0; failed=0

do_install() {
  local action="$1" src_rel="$2" dest="$3" ftype="$4"

  # Skip non-install actions
  case "${action}" in IDENTICAL|SKIP|MERGE)
    (( skipped++ )) || true
    return 0
  esac

  # Resume: skip already-completed files
  if [[ "${RESUME}" == "true" ]] && [[ "$(is_done "${dest}")" == "yes" ]]; then
    echo "  ⏭  already done: ${dest}"
    (( skipped++ )) || true
    return 0
  fi

  if [[ "${DRY_RUN}" == "true" ]]; then
    echo "  [dry-run] ${action}: ${src_rel} → ${dest}"
    (( installed++ )) || true
    return 0
  fi

  local src_full="${KIT_DIR}/${src_rel}"

  # Handle cursor_mdc: generate .mdc from source .md
  if [[ "${ftype}" == "cursor_mdc" ]]; then
    local dest_dir dest_name
    dest_dir="$(dirname "${dest}")"
    dest_name="$(basename "${dest}" .mdc)"

    mkdir -p "${dest_dir}"

    # Determine if this is a CORE rule (alwaysApply: true)
    local always_apply="false"
    case "${dest_name}" in base-conventions|security|testing)
      always_apply="true" ;;
    esac

    # Determine globs based on dest_name
    local globs=""
    case "${dest_name}" in
      python-conventions) globs="**/*.py" ;;
      python-testing)     globs="**/test_*.py,**/*_test.py" ;;
      python-database)    globs="**/models/*.py,**/db/*.py" ;;
      typescript-conventions) globs="**/*.ts,**/*.tsx" ;;
      typescript-testing) globs="**/*.test.ts,**/*.spec.ts" ;;
      nodejs-conventions) globs="**/*.js,**/*.mjs" ;;
      nodejs-testing)     globs="**/*.test.js,**/*.spec.js" ;;
      go-conventions)     globs="**/*.go" ;;
      go-testing)         globs="**/*_test.go" ;;
      java-conventions)   globs="**/*.java" ;;
      cpp-conventions)    globs="**/*.cpp,**/*.hpp,**/*.h" ;;
      cpp-testing)        globs="**/*_test.cpp,**/test_*.cpp" ;;
    esac

    # Extract description and strip frontmatter via generate-cursor-mdc helper
    # Use generate-cursor-mdc.sh single-file mode if available; otherwise inline python -c
    local description
    description=$(python3 -c "
import sys, re
content = open(sys.argv[1]).read()
m = re.match(r'^---\s*\n(.*?)\n---', content, re.DOTALL)
if m:
    for line in m.group(1).splitlines():
        if line.strip().startswith('description:'):
            print(line.split(':',1)[1].strip()); sys.exit(0)
m2 = re.search(r'^# (.+)$', content, re.MULTILINE)
if m2: print(m2.group(1))
" "${src_full}" 2>/dev/null || echo "")
    [[ -z "${description}" ]] && description="${dest_name}"

    # Generate .mdc: frontmatter + body (frontmatter stripped)
    {
      echo "---"
      echo "description: ${description}"
      if [[ -n "${globs}" ]]; then
        echo "globs: [\"${globs}\"]"
      else
        echo "globs: []"
      fi
      echo "alwaysApply: ${always_apply}"
      echo "---"
      echo ""
      python3 -c "
import sys, re
content = open(sys.argv[1]).read()
stripped = re.sub(r'^---\s*\n.*?\n---\s*\n', '', content, count=1, flags=re.DOTALL)
print(stripped, end='')
" "${src_full}" 2>/dev/null || cat "${src_full}"
    } > "${dest}"

    mark_done "${dest}"
    echo "  ✓  ${action} (mdc): ${dest}"
    (( installed++ )) || true
    return 0
  fi

  # Standard file/dir copy
  mkdir -p "$(dirname "${dest}")"

  if [[ -d "${src_full}" ]]; then
    rm -rf "${dest}"
    cp -r "${src_full}" "${dest}"
  else
    cp "${src_full}" "${dest}"
  fi

  # Hooks need to be executable
  [[ "${ftype}" == "hook_file" ]] && chmod +x "${dest}"

  mark_done "${dest}"
  echo "  ✓  ${action}: ${dest}"
  (( installed++ )) || true
}

# ── Process every file in the plan ───────────────────────────────────────────
TMPENTRIES="$(mktemp)"
trap 'rm -f "${TMPPLAN}" "${TMPENTRIES}"' EXIT

python3 - <<PYEOF > "${TMPENTRIES}" 2>/dev/null
import json
data = json.load(open('${TMPPLAN}'))
for f in data.get('files', []):
    print('\t'.join([
        f.get('action', ''),
        f.get('source', ''),
        f.get('dest', ''),
        f.get('type', 'file'),
    ]))
PYEOF

while IFS=$'\t' read -r action source dest ftype; do
  [[ -z "${action}" ]] && continue
  do_install "${action}" "${source}" "${dest}" "${ftype}" || {
    echo "  ✗  FAILED: ${dest}" >&2
    (( failed++ )) || true
  }
done < "${TMPENTRIES}"

# ── Create project hooks.json if missing (Claude installs only) ───────────────
if [[ "${PLATFORM}" == "claude" || "${PLATFORM}" == "both" ]]; then
  HOOKS_JSON="${PROJECT_DIR}/.claude/hooks.json"
  if [[ ! -f "${HOOKS_JSON}" && "${DRY_RUN}" == "false" ]]; then
    mkdir -p "${PROJECT_DIR}/.claude"
    cat > "${HOOKS_JSON}" <<'HOOKEOF'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/block-dangerous-bash.sh",
            "timeout": 10000
          }
        ]
      },
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/protect-files.sh",
            "timeout": 10000
          }
        ]
      }
    ]
  }
}
HOOKEOF
    mark_done "${HOOKS_JSON}"
    echo "  ✓  created: ${HOOKS_JSON}"
  fi
fi

# ── Finalise ──────────────────────────────────────────────────────────────────
echo ""
if (( failed == 0 )); then
  if [[ "${DRY_RUN}" == "false" ]]; then
    state_update "{'install_status':'complete','last_installed_commit':'${KIT_COMMIT}','last_checked_commit':'${KIT_COMMIT}','install_profile':'${PROFILE}','install_platform':'${PLATFORM}'}"
  fi
  echo "✅ Done: ${installed} installed, ${skipped} skipped"
  exit 0
else
  echo "⚠  Partial: ${installed} installed, ${failed} failed — run with --resume to retry" >&2
  exit 2
fi