#!/usr/bin/env bash
# Claude PreToolUse hook: when Claude tries to `git push`, run flake8 + pytest
# in the repo first. Blocks the push if either fails so Claude doesn't ship
# broken CI again.
#
# Triggered ONLY when Claude invokes Bash with a command containing `git push`.
# User pushes from their own terminal are unaffected — this is a Claude-only
# safety net, not a git pre-push hook.
#
# stdin: tool_input JSON from Claude (see ~/.claude docs for shape).
# stdout: JSON with permissionDecision = "allow" | "deny" + reason.

set -euo pipefail

# Parse the tool_input.command from Claude's hook payload.
COMMAND=$(jq -r '.tool_input.command // ""')

# Only act on `git push`. Anything else: silent allow.
if [[ ! "$COMMAND" =~ (^|[^a-zA-Z_-])git[[:space:]]+push([[:space:]]|$) ]]; then
    echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
    exit 0
fi

# Resolve repo root. If we're not inside a git repo, let the command run
# (git will error informatively — not our job to second-guess).
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [ -z "$REPO_ROOT" ]; then
    echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
    exit 0
fi

cd "$REPO_ROOT"

# Skip non-Python repos: no sensi_redis/, no app/, no obvious package dir
# with a tests/ folder, and we silently allow. The CI for those repos has
# its own gates.
if [ ! -d tests ]; then
    echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
    exit 0
fi

# Prefer a Python 3.11 venv (matches Sensi CI). Fall back to other venvs,
# then to whatever python3 is on PATH. If none has the tools installed,
# we skip with a warning rather than blocking — don't punish repos that
# don't lint in CI.
PY=""
for candidate in ./venv311/bin/python ./venv/bin/python ./.venv/bin/python "$(command -v python3 || true)"; do
    [ -n "$candidate" ] && [ -x "$candidate" ] || continue
    # Require Python >= 3.11: repos here use 3.11+ syntax (e.g. `except*`), so an
    # older venv can't even import the suite. Skip it rather than false-block.
    if "$candidate" -c 'import sys; sys.exit(0 if sys.version_info[:2] >= (3, 11) else 1)' 2>/dev/null; then
        PY="$candidate"
        break
    fi
done

if [ -z "$PY" ]; then
    echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","permissionDecisionReason":"pre-push-checks: no python found, skipping"}}'
    exit 0
fi

OUTPUT_FILE=$(mktemp)
FAILED=""

# Files changed on this branch vs the default branch — the hook gates YOUR
# changes, not the repo's pre-existing lint/test debt (which CI owns).
BASE_REF=$(git merge-base HEAD origin/master 2>/dev/null || git merge-base HEAD origin/HEAD 2>/dev/null || true)
CHANGED_PY=""
if [ -n "$BASE_REF" ]; then
    CHANGED_PY=$(git diff --name-only --diff-filter=ACM "$BASE_REF" HEAD -- '*.py' 2>/dev/null || true)
fi

# flake8 — only if a .flake8 config exists (don't lint repos that didn't
# opt into a config; default max=79 would false-positive everything).
# Scoped to changed files so the repo's existing lint debt doesn't false-block.
if [ -f .flake8 ] && [ -n "$CHANGED_PY" ] && "$PY" -c "import flake8" 2>/dev/null; then
    if ! "$PY" -m flake8 $CHANGED_PY >"$OUTPUT_FILE" 2>&1; then
        FAILED="flake8"
    fi
fi

# pytest — only if pytest is importable in the venv we picked.
# Prefer unit tests: integration suites often regenerate SDKs / need Docker at
# collection time and can't run in this local hook env. Fall back to full
# tests/ for repos without a tests/unit layout. CI runs the full suite.
if [ -z "$FAILED" ] && "$PY" -c "import pytest" 2>/dev/null; then
    PYTEST_TARGET="tests/"
    [ -d tests/unit ] && PYTEST_TARGET="tests/unit"
    "$PY" -m pytest "$PYTEST_TARGET" -q >"$OUTPUT_FILE" 2>&1 && PYTEST_RC=0 || PYTEST_RC=$?
    # pytest exit 1 = real test failures -> block. Other nonzero codes are
    # collection/import/env errors (e.g. ungenerated code, missing services in
    # this local hook env) or "no tests"; don't false-block on those — CI runs
    # the full suite. See exit codes: 0 ok, 1 failed, 2 interrupted, 3 internal,
    # 4 usage, 5 no tests.
    if [ "${PYTEST_RC:-0}" -eq 1 ]; then
        FAILED="pytest"
    fi
fi

if [ -n "$FAILED" ]; then
    REASON=$(printf 'pre-push-checks blocked: %s failed\n\n%s' "$FAILED" "$(tail -50 "$OUTPUT_FILE")")
    # Emit as JSON so Claude sees the failure verbatim.
    jq -n --arg reason "$REASON" '{
        hookSpecificOutput: {
            hookEventName: "PreToolUse",
            permissionDecision: "deny",
            permissionDecisionReason: $reason
        }
    }'
    rm -f "$OUTPUT_FILE"
    exit 0
fi

rm -f "$OUTPUT_FILE"
echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'