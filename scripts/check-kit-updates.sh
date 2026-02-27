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
#   --project-dir DIR         Project root for project-level files (default: cwd)
#   --lang LANG               Language: python|nodejs|typescript|go|java|cpp
#   --profile core|full       Profile to install (default: core)
#   --platform auto|claude|cursor|both
#                             Platform target (default: auto)
#                             auto = detect from ~/.claude and ~/.cursor presence
#   --hooks                   Include security hook files in the plan (OPT-IN)
#   --force                   Re-check even if commit SHA hasn't changed
#
# Output (stdout): JSON action plan — pipe to install-kit.sh or save to file
#   {
#     "status":               "FIRST_INSTALL|NEEDS_UPDATE|UP_TO_DATE",
#     "kit_commit":           "<sha>",
#     "last_installed_commit":"<sha>",
#     "detected_lang":        "python",
#     "profile":              "core",
#     "platform":             "claude|cursor|both",
#     "needs_update":         true,
#     "summary":              { "new": N, "identical": N, "changed": N },
#     "files": [
#       { "action":     "NEW|IDENTICAL|CHANGED",
#         "source":     "skills/extend-agent",
#         "dest":       "~/.claude/skills/extend-agent",
#         "type":       "skill_dir|agent_file|command_file|rule_file|lang_file|hook_file|cursor_mdc|agents_md|gemini_md",
#         "scope":      "global|project",
#         "diff_stat":  "+5/-3 lines" }
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
PROFILE="core"
PLATFORM="auto"
FORCE=false
INSTALL_HOOKS=false
STATE_FILE="${HOME}/.claude/.agent-kit-state.json"
CLAUDE_DIR="${HOME}/.claude"
CURSOR_DIR="${HOME}/.cursor"

# ── Parse args ────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-dir) PROJECT_DIR="$2"; shift 2 ;;
    --lang)        LANG="$2";        shift 2 ;;
    --profile)     PROFILE="$2";     shift 2 ;;
    --platform)    PLATFORM="$2";    shift 2 ;;
    --hooks)       INSTALL_HOOKS=true; shift  ;;
    --force)       FORCE=true;       shift   ;;
    -h|--help)
      sed -n '3,35p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# Validate profile
case "${PROFILE}" in core|full) ;; *)
  echo "Unknown profile: ${PROFILE}. Use core or full." >&2; exit 1 ;;
esac

# ── Resolve platform ──────────────────────────────────────────────────────────
if [[ "${PLATFORM}" == "auto" ]]; then
  has_claude=false; has_cursor=false
  [[ -d "${CLAUDE_DIR}" ]] && has_claude=true
  [[ -d "${CURSOR_DIR}" || -d "${PROJECT_DIR}/.cursor" ]] && has_cursor=true
  if ${has_claude} && ${has_cursor}; then
    PLATFORM="both"
  elif ${has_cursor}; then
    PLATFORM="cursor"
  else
    PLATFORM="claude"
  fi
fi

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
REMOTE_COMMIT=$(git -C "${KIT_DIR}" ls-remote origin HEAD 2>/dev/null | cut -f1 || echo "")
LOCAL_COMMIT=$(git -C "${KIT_DIR}" rev-parse HEAD 2>/dev/null || echo "unknown")
KIT_COMMIT="${REMOTE_COMMIT:-${LOCAL_COMMIT}}"

LAST_INSTALLED=$(state_get "last_installed_commit" "none")

# ── Early exit if nothing changed ─────────────────────────────────────────────
if [[ "${FORCE}" == "false" && "${KIT_COMMIT}" == "${LAST_INSTALLED}" && "${LAST_INSTALLED}" != "none" ]]; then
  printf '{"status":"UP_TO_DATE","kit_commit":"%s","last_installed_commit":"%s","profile":"%s","platform":"%s","needs_update":false,"summary":{"new":0,"identical":0,"changed":0},"files":[]}\n' \
    "${KIT_COMMIT}" "${LAST_INSTALLED}" "${PROFILE}" "${PLATFORM}"
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

# ── Profile definitions ───────────────────────────────────────────────────────
CORE_SKILLS=(extend-agent git testing debugging security)
FULL_SKILLS=(planning tdd api-design spec-interview implement-jira-ticket)

CORE_AGENTS=(reviewer.md tester.md git-ops.md security.md)
FULL_AGENTS=(architect.md planner.md db-expert.md doc-writer.md refactorer.md)

CORE_COMMANDS=(commit.md push.md pr.md ship.md review.md test.md)
FULL_COMMANDS=(debug.md refactor.md spec-interview.md generate-prd.md implement-jira-ticket.md)

CORE_RULES=(base-conventions.md security.md testing.md)
FULL_RULES=(git-workflow.md performance.md infrastructure.md)

# Build selected lists
SELECTED_SKILLS=("${CORE_SKILLS[@]}")
SELECTED_AGENTS=("${CORE_AGENTS[@]}")
SELECTED_COMMANDS=("${CORE_COMMANDS[@]}")
SELECTED_RULES=("${CORE_RULES[@]}")

if [[ "${PROFILE}" == "full" ]]; then
  SELECTED_SKILLS+=("${FULL_SKILLS[@]}")
  SELECTED_AGENTS+=("${FULL_AGENTS[@]}")
  SELECTED_COMMANDS+=("${FULL_COMMANDS[@]}")
  SELECTED_RULES+=("${FULL_RULES[@]}")
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
  printf '%s' "$1" | python3 -c "import json,sys; print(json.dumps(sys.stdin.read())[1:-1])" 2>/dev/null || printf '%s' "$1"
}

# ── Build manifest and compare ────────────────────────────────────────────────
new_count=0; identical_count=0; changed_count=0
files_json=""

emit() {
  local src_rel="$1" dest="$2" ftype="$3" scope="${4:-global}"
  # Expand ~ in dest
  dest="${dest/#\~/${HOME}}"
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
  entry="{\"action\":\"${action}\",\"source\":\"$(json_str "${src_rel}")\",\"dest\":\"$(json_str "${dest}")\",\"type\":\"${ftype}\",\"scope\":\"${scope}\",\"diff_stat\":\"$(json_str "${dstat}")\"}"

  if [[ -z "${files_json}" ]]; then
    files_json="${entry}"
  else
    files_json="${files_json},${entry}"
  fi
}

emit_cursor_mdc() {
  # Emit a cursor_mdc entry — source is a .md, dest is a .mdc
  local src_rel="$1" dest_dir="$2" dest_name="$3" scope="${4:-global}"
  local src_full="${KIT_DIR}/${src_rel}"
  [[ ! -e "${src_full}" ]] && return

  local dest="${dest_dir}/${dest_name}.mdc"

  # For NEW check: if .mdc doesn't exist, it's NEW
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
  entry="{\"action\":\"${action}\",\"source\":\"$(json_str "${src_rel}")\",\"dest\":\"$(json_str "${dest}")\",\"type\":\"cursor_mdc\",\"scope\":\"${scope}\",\"diff_stat\":\"$(json_str "${dstat}")\"}"

  if [[ -z "${files_json}" ]]; then
    files_json="${entry}"
  else
    files_json="${files_json},${entry}"
  fi
}

# ── Emit Claude files ─────────────────────────────────────────────────────────
if [[ "${PLATFORM}" == "claude" || "${PLATFORM}" == "both" ]]; then

  # Skills (global)
  for skill_name in "${SELECTED_SKILLS[@]}"; do
    emit "skills/${skill_name}" "${CLAUDE_DIR}/skills/${skill_name}" "skill_dir" "global"
  done

  # Subagents (global)
  for f in "${SELECTED_AGENTS[@]}"; do
    emit "subagents/${f}" "${CLAUDE_DIR}/agents/${f}" "agent_file" "global"
  done

  # Commands (global)
  for f in "${SELECTED_COMMANDS[@]}"; do
    emit "commands/${f}" "${CLAUDE_DIR}/commands/${f}" "command_file" "global"
  done

  # Base rules (project)
  for f in "${SELECTED_RULES[@]}"; do
    emit "rules/${f}" "${PROJECT_DIR}/.claude/rules/${f}" "rule_file" "project"
  done

  # Language conventions (project)
  if [[ -n "${LANG}" && -d "${KIT_DIR}/languages/${LANG}" ]]; then
    for f in "${KIT_DIR}/languages/${LANG}"/*.md; do
      [[ -f "${f}" ]] || continue
      name="$(basename "${f}" .md)"
      emit "languages/${LANG}/${name}.md" "${PROJECT_DIR}/.claude/rules/${LANG}-${name}.md" "lang_file" "project"
    done
  fi

  # Security hooks (global) — OPT-IN via --hooks flag
  if [[ "${INSTALL_HOOKS}" == "true" ]]; then
    for f in "${KIT_DIR}/hooks"/*.sh; do
      [[ -f "${f}" ]] || continue
      emit "hooks/$(basename "${f}")" "${CLAUDE_DIR}/hooks/$(basename "${f}")" "hook_file" "global"
    done
  fi

fi

# ── Emit Cursor files ─────────────────────────────────────────────────────────
if [[ "${PLATFORM}" == "cursor" || "${PLATFORM}" == "both" ]]; then
  CURSOR_RULES_DIR="${CURSOR_DIR}/rules"

  # Skills → .mdc (alwaysApply: false, user-invoked)
  for skill_name in "${SELECTED_SKILLS[@]}"; do
    emit_cursor_mdc "skills/${skill_name}/SKILL.md" "${CURSOR_RULES_DIR}" "skill-${skill_name}" "global"
  done

  # CORE rules → .mdc (alwaysApply: true)
  for f in "${CORE_RULES[@]}"; do
    name="${f%.md}"
    emit_cursor_mdc "rules/${f}" "${CURSOR_RULES_DIR}" "${name}" "global"
  done

  # FULL rules → .mdc (if full profile)
  if [[ "${PROFILE}" == "full" ]]; then
    for f in "${FULL_RULES[@]}"; do
      name="${f%.md}"
      emit_cursor_mdc "rules/${f}" "${CURSOR_RULES_DIR}" "${name}" "global"
    done
  fi

  # Language conventions → project .cursor/rules
  if [[ -n "${LANG}" && -d "${KIT_DIR}/languages/${LANG}" ]]; then
    for f in "${KIT_DIR}/languages/${LANG}"/*.md; do
      [[ -f "${f}" ]] || continue
      name="$(basename "${f}" .md)"
      emit_cursor_mdc "languages/${LANG}/${name}.md" "${PROJECT_DIR}/.cursor/rules" "${LANG}-${name}" "project"
    done
  fi

fi

# ── Emit project template files (AGENTS.md, GEMINI.md) ───────────────────────
if [[ -f "${KIT_DIR}/templates/AGENTS.md" ]]; then
  emit "templates/AGENTS.md" "${PROJECT_DIR}/AGENTS.md" "agents_md" "project"
fi
if [[ -f "${KIT_DIR}/templates/GEMINI.md" ]]; then
  emit "templates/GEMINI.md" "${PROJECT_DIR}/GEMINI.md" "gemini_md" "project"
fi

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
  "profile": "${PROFILE}",
  "platform": "${PLATFORM}",
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