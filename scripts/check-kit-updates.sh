#!/usr/bin/env bash
# =============================================================================
# check-kit-updates.sh — Agent Runtime Kit Update Checker
#
# Compares the kit repo against locally installed files and outputs a JSON
# action plan. Caches the last-checked commit so repeated runs are free when
# nothing has changed.
#
# Usage:
#   scripts/check-kit-updates.sh [OPTIONS]
#
# Options:
#   --project-dir DIR   Project root for project-level files (default: cwd)
#   --lang LANG         Language: python|nodejs|typescript|go|java|cpp
#   --force             Re-check even if commit SHA hasn't changed
#
# Output (stdout): JSON action plan — pipe to install-kit.sh or save to file
#   {
#     "status":               "FIRST_INSTALL|NEEDS_UPDATE|UP_TO_DATE",
#     "kit_commit":           "<sha>",
#     "last_installed_commit":"<sha>",
#     "detected_lang":        "python",
#     "needs_update":         true,
#     "summary":              { "new": N, "identical": N, "changed": N },
#     "files": [
#       { "action": "NEW|IDENTICAL|CHANGED",
#         "source": "skills/extend-agent",
#         "dest":   "~/.claude/skills/extend-agent",
#         "type":   "skill_dir|agent_file|command_file|rule_file|lang_file|hook_file",
#         "diff_stat": "+5/-3 lines" }
#     ]
#   }
#
# State file: ~/.claude/.agent-kit-state.json
# Exit codes: 0 = success, 1 = error
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROJECT_DIR="$(pwd)"
LANG=""
FORCE=false
STATE_FILE="${HOME}/.claude/.agent-kit-state.json"
CLAUDE_DIR="${HOME}/.claude"

# ── Parse args ────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-dir) PROJECT_DIR="$2"; shift 2 ;;
    --lang)        LANG="$2";        shift 2 ;;
    --force)       FORCE=true;       shift   ;;
    -h|--help)
      sed -n '3,30p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

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

state_set() {
  local key="$1" val="$2"
  mkdir -p "$(dirname "${STATE_FILE}")"
  python3 - <<PYEOF 2>/dev/null || true
import json, os
f = '${STATE_FILE}'
d = {}
if os.path.exists(f):
    try: d = json.load(open(f))
    except: pass
d['${key}'] = '${val}'
json.dump(d, open(f, 'w'), indent=2)
PYEOF
}

# ── Get commits ───────────────────────────────────────────────────────────────
# Try remote first (checks if kit has been updated on GitHub)
REMOTE_COMMIT=$(git -C "${KIT_DIR}" ls-remote origin HEAD 2>/dev/null | cut -f1 || echo "")
# Fall back to local HEAD if no network or not a git repo
LOCAL_COMMIT=$(git -C "${KIT_DIR}" rev-parse HEAD 2>/dev/null || echo "unknown")
KIT_COMMIT="${REMOTE_COMMIT:-${LOCAL_COMMIT}}"

LAST_INSTALLED=$(state_get "last_installed_commit" "none")

# ── Early exit if nothing changed ─────────────────────────────────────────────
if [[ "${FORCE}" == "false" && "${KIT_COMMIT}" == "${LAST_INSTALLED}" && "${LAST_INSTALLED}" != "none" ]]; then
  printf '{"status":"UP_TO_DATE","kit_commit":"%s","last_installed_commit":"%s","needs_update":false,"summary":{"new":0,"identical":0,"changed":0},"files":[]}\n' \
    "${KIT_COMMIT}" "${LAST_INSTALLED}"
  exit 0
fi

# ── Auto-detect language ──────────────────────────────────────────────────────
if [[ -z "${LANG}" ]]; then
  if   [[ -f "${PROJECT_DIR}/tsconfig.json" ]];                                         then LANG="typescript"
  elif [[ -f "${PROJECT_DIR}/package.json" ]];                                          then LANG="nodejs"
  elif [[ -f "${PROJECT_DIR}/pyproject.toml" || -f "${PROJECT_DIR}/requirements.txt" || -f "${PROJECT_DIR}/setup.py" ]]; then LANG="python"
  elif [[ -f "${PROJECT_DIR}/go.mod" ]];                                                then LANG="go"
  elif [[ -f "${PROJECT_DIR}/pom.xml" || -f "${PROJECT_DIR}/build.gradle" ]];          then LANG="java"
  elif ls "${PROJECT_DIR}"/*.cpp &>/dev/null 2>&1 || [[ -f "${PROJECT_DIR}/CMakeLists.txt" ]]; then LANG="cpp"
  fi
fi

# ── Comparison helpers ────────────────────────────────────────────────────────
compare() {
  local src="$1" dest="$2"
  if [[ ! -e "${dest}" ]]; then
    echo "NEW"
  elif diff -rq "${src}" "${dest}" &>/dev/null 2>&1; then
    echo "IDENTICAL"
  else
    echo "CHANGED"
  fi
}

diffstat() {
  local src="$1" dest="$2"
  [[ ! -e "${dest}" ]] && echo "" && return
  if [[ -d "${src}" ]]; then
    local n
    n=$(diff -rq "${src}" "${dest}" 2>/dev/null | wc -l | tr -d ' ')
    echo "${n} file(s) differ"
  else
    local added removed
    added=$(diff   "${src}" "${dest}" 2>/dev/null | grep '^>' | wc -l | tr -d ' ')
    removed=$(diff "${src}" "${dest}" 2>/dev/null | grep '^<' | wc -l | tr -d ' ')
    echo "+${added}/-${removed} lines"
  fi
}

json_str() {
  # Minimal JSON string escape
  printf '%s' "$1" | python3 -c "import json,sys; print(json.dumps(sys.stdin.read())[1:-1])" 2>/dev/null || printf '%s' "$1"
}

# ── Build manifest and compare ────────────────────────────────────────────────
new_count=0; identical_count=0; changed_count=0
files_json=""

emit() {
  local src_rel="$1" dest="$2" ftype="$3"
  local src_full="${KIT_DIR}/${src_rel}"
  [[ ! -e "${src_full}" ]] && return   # skip if source missing

  local action dstat
  action=$(compare "${src_full}" "${dest}")
  dstat=""
  [[ "${action}" == "CHANGED" ]] && dstat=$(diffstat "${src_full}" "${dest}")

  case "${action}" in
    NEW)       (( new_count++       )) || true ;;
    IDENTICAL) (( identical_count++ )) || true ;;
    CHANGED)   (( changed_count++   )) || true ;;
  esac

  local entry
  entry="{\"action\":\"${action}\",\"source\":\"$(json_str "${src_rel}")\",\"dest\":\"$(json_str "${dest}")\",\"type\":\"${ftype}\",\"diff_stat\":\"$(json_str "${dstat}")\"}"

  if [[ -z "${files_json}" ]]; then
    files_json="${entry}"
  else
    files_json="${files_json},${entry}"
  fi
}

# Skills (directories)
for skill_dir in "${KIT_DIR}/skills"/*/; do
  [[ -d "${skill_dir}" ]] || continue
  skill_name="$(basename "${skill_dir}")"
  emit "skills/${skill_name}" "${CLAUDE_DIR}/skills/${skill_name}" "skill_dir"
done

# Subagents
for f in "${KIT_DIR}/subagents"/*.md; do
  [[ -f "${f}" ]] || continue
  emit "subagents/$(basename "${f}")" "${CLAUDE_DIR}/agents/$(basename "${f}")" "agent_file"
done

# Commands
for f in "${KIT_DIR}/commands"/*.md; do
  [[ -f "${f}" ]] || continue
  emit "commands/$(basename "${f}")" "${CLAUDE_DIR}/commands/$(basename "${f}")" "command_file"
done

# Base rules (project-level)
for f in "${KIT_DIR}/rules"/*.md; do
  [[ -f "${f}" ]] || continue
  emit "rules/$(basename "${f}")" "${PROJECT_DIR}/.claude/rules/$(basename "${f}")" "rule_file"
done

# Language conventions (project-level)
if [[ -n "${LANG}" && -d "${KIT_DIR}/languages/${LANG}" ]]; then
  for f in "${KIT_DIR}/languages/${LANG}"/*.md; do
    [[ -f "${f}" ]] || continue
    name="$(basename "${f}" .md)"
    emit "languages/${LANG}/${name}.md" "${PROJECT_DIR}/.claude/rules/${LANG}-${name}.md" "lang_file"
  done
fi

# Security hooks (project-level)
for f in "${KIT_DIR}/skills/security/hooks"/*.sh; do
  [[ -f "${f}" ]] || continue
  emit "skills/security/hooks/$(basename "${f}")" "${PROJECT_DIR}/.claude/hooks/$(basename "${f}")" "hook_file"
done

# ── Determine status ──────────────────────────────────────────────────────────
needs_update="false"
if [[ "${LAST_INSTALLED}" == "none" ]]; then
  status="FIRST_INSTALL"; needs_update="true"
elif (( new_count + changed_count > 0 )); then
  status="NEEDS_UPDATE"; needs_update="true"
else
  status="UP_TO_DATE"
fi

# ── Emit JSON ─────────────────────────────────────────────────────────────────
cat <<ENDJSON
{
  "status": "${status}",
  "kit_commit": "$(json_str "${KIT_COMMIT}")",
  "last_installed_commit": "$(json_str "${LAST_INSTALLED}")",
  "detected_lang": "$(json_str "${LANG}")",
  "needs_update": ${needs_update},
  "summary": {
    "new": ${new_count},
    "identical": ${identical_count},
    "changed": ${changed_count}
  },
  "files": [${files_json}]
}
ENDJSON

# ── Cache checked commit ──────────────────────────────────────────────────────
state_set "last_checked_commit" "${KIT_COMMIT}"
