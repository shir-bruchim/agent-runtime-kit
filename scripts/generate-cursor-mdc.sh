#!/usr/bin/env bash
# =============================================================================
# generate-cursor-mdc.sh — Generate Cursor .mdc rules from kit sources
#
# Converts kit Markdown files to Cursor .mdc format with deterministic
# frontmatter. Idempotent: re-running produces identical output.
#
# Usage:
#   scripts/generate-cursor-mdc.sh [OPTIONS]
#
# Options:
#   --kit-dir DIR         Root of the kit repo (default: script's parent)
#   --dest-dir DIR        Destination directory for .mdc files (required)
#   --profile core|full  Which files to generate (default: core)
#   --lang LANG           Language pack to include: python|nodejs|typescript|go|java|cpp
#   --dry-run             Print what would be generated without writing
#
# Output: .mdc files in --dest-dir
#
# Rules for alwaysApply:
#   - CORE rules (base-conventions, security, testing): alwaysApply: true
#   - Skills: alwaysApply: false (user-invoked)
#   - FULL rules: alwaysApply: false (opinionated, not forced)
#   - Language packs: alwaysApply: false (only when globs match)
#
# Exit codes: 0 = success, 1 = error
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEST_DIR=""
PROFILE="core"
LANG=""
DRY_RUN=false

# ── Parse args ────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --kit-dir)   KIT_DIR="$2";  shift 2 ;;
    --dest-dir)  DEST_DIR="$2"; shift 2 ;;
    --profile)   PROFILE="$2";  shift 2 ;;
    --lang)      LANG="$2";     shift 2 ;;
    --dry-run)   DRY_RUN=true;  shift   ;;
    -h|--help)
      sed -n '3,30p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "${DEST_DIR}" ]]; then
  echo "Error: --dest-dir is required" >&2
  exit 1
fi

case "${PROFILE}" in core|full) ;; *)
  echo "Unknown profile: ${PROFILE}. Use core or full." >&2; exit 1 ;;
esac

# ── Profile definitions ───────────────────────────────────────────────────────
CORE_SKILLS=(extend-agent git testing debugging security)
FULL_SKILLS=(planning tdd api-design spec-interview implement-jira-ticket)
CORE_RULES=(base-conventions security testing)
FULL_RULES=(git-workflow performance infrastructure)

SELECTED_SKILLS=("${CORE_SKILLS[@]}")
SELECTED_RULES=("${CORE_RULES[@]}")
if [[ "${PROFILE}" == "full" ]]; then
  SELECTED_SKILLS+=("${FULL_SKILLS[@]}")
  SELECTED_RULES+=("${FULL_RULES[@]}")
fi

# ── Helper: extract description from SKILL.md/rules frontmatter ──────────────
extract_description() {
  local file="$1"
  # Look for description: in YAML frontmatter (between --- markers)
  python3 - "$file" <<'PYEOF' 2>/dev/null || echo ""
import sys, re
content = open(sys.argv[1]).read()
m = re.match(r'^---\s*\n(.*?)\n---', content, re.DOTALL)
if m:
    for line in m.group(1).splitlines():
        if line.strip().startswith('description:'):
            print(line.split(':', 1)[1].strip())
            break
PYEOF
}

# ── Helper: strip frontmatter from source ─────────────────────────────────────
strip_frontmatter() {
  local file="$1"
  python3 - "$file" <<'PYEOF' 2>/dev/null || cat "$file"
import sys, re
content = open(sys.argv[1]).read()
# Remove the first ---...--- block if present
stripped = re.sub(r'^---\s*\n.*?\n---\s*\n', '', content, count=1, flags=re.DOTALL)
print(stripped, end='')
PYEOF
}

# ── Helper: write a .mdc file ─────────────────────────────────────────────────
write_mdc() {
  local src="$1" dest="$2" description="$3" always_apply="$4" globs="${5:-}"

  if [[ "${DRY_RUN}" == "true" ]]; then
    echo "  [dry-run] → ${dest}"
    return 0
  fi

  mkdir -p "$(dirname "${dest}")"

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
    strip_frontmatter "${src}"
  } > "${dest}"

  echo "  ✓ ${dest}"
}

# ── Main generation ───────────────────────────────────────────────────────────
echo "Generating Cursor .mdc files → ${DEST_DIR} (profile: ${PROFILE})"
echo ""

# Skills → alwaysApply: false
echo "Skills:"
for skill_name in "${SELECTED_SKILLS[@]}"; do
  src="${KIT_DIR}/skills/${skill_name}/SKILL.md"
  [[ -f "${src}" ]] || { echo "  ⚠ missing: ${src}"; continue; }
  desc=$(extract_description "${src}")
  [[ -z "${desc}" ]] && desc="Use the ${skill_name} skill"
  dest="${DEST_DIR}/skill-${skill_name}.mdc"
  write_mdc "${src}" "${dest}" "${desc}" "false" ""
done

echo ""
echo "Rules:"
# CORE rules → alwaysApply: true (baseline, always active)
for rule_name in "${CORE_RULES[@]}"; do
  src="${KIT_DIR}/rules/${rule_name}.md"
  [[ -f "${src}" ]] || { echo "  ⚠ missing: ${src}"; continue; }
  # Extract first heading as description
  desc=$(grep -m1 '^# ' "${src}" | sed 's/^# //' || echo "${rule_name}")
  dest="${DEST_DIR}/${rule_name}.mdc"
  write_mdc "${src}" "${dest}" "${desc}" "true" ""
done

# FULL rules → alwaysApply: false (opinionated, not forced)
if [[ "${PROFILE}" == "full" ]]; then
  for rule_name in "${FULL_RULES[@]}"; do
    src="${KIT_DIR}/rules/${rule_name}.md"
    [[ -f "${src}" ]] || { echo "  ⚠ missing: ${src}"; continue; }
    desc=$(grep -m1 '^# ' "${src}" | sed 's/^# //' || echo "${rule_name}")
    dest="${DEST_DIR}/${rule_name}.mdc"
    write_mdc "${src}" "${dest}" "${desc}" "false" ""
  done
fi

# Language conventions → alwaysApply: false, with globs
if [[ -n "${LANG}" && -d "${KIT_DIR}/languages/${LANG}" ]]; then
  echo ""
  echo "Language (${LANG}):"

  # Resolve glob pattern for a language-name combination
  lang_glob() {
    local k="$1"
    case "${k}" in
      python-conventions)     echo "**/*.py" ;;
      python-testing)         echo "**/test_*.py,**/*_test.py" ;;
      python-database)        echo "**/models/*.py,**/db/*.py" ;;
      typescript-conventions) echo "**/*.ts,**/*.tsx" ;;
      typescript-testing)     echo "**/*.test.ts,**/*.spec.ts" ;;
      nodejs-conventions)     echo "**/*.js,**/*.mjs" ;;
      nodejs-testing)         echo "**/*.test.js,**/*.spec.js" ;;
      go-conventions)         echo "**/*.go" ;;
      go-testing)             echo "**/*_test.go" ;;
      java-conventions)       echo "**/*.java" ;;
      cpp-conventions)        echo "**/*.cpp,**/*.hpp,**/*.h" ;;
      cpp-testing)            echo "**/*_test.cpp,**/test_*.cpp" ;;
      *)                      echo "" ;;
    esac
  }

  for f in "${KIT_DIR}/languages/${LANG}"/*.md; do
    [[ -f "${f}" ]] || continue
    name="$(basename "${f}" .md)"
    key="${LANG}-${name}"
    globs=$(lang_glob "${key}")
    desc=$(grep -m1 '^# ' "${f}" | sed 's/^# //' || echo "${LANG} ${name}")
    dest="${DEST_DIR}/${key}.mdc"
    write_mdc "${f}" "${dest}" "${desc}" "false" "${globs}"
  done
fi

echo ""
echo "Done."