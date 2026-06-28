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
for candidate in ./venv311/bin/python ./venv/bin/python ./.venv/bin/python; do
    if [ -x "$candidate" ]; then
        PY="$candidate"
        break
    fi
done
[ -z "$PY" ] && PY="$(command -v python3 || true)"

if [ -z "$PY" ]; then
    echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","permissionDecisionReason":"pre-push-checks: no python found, skipping"}}'
    exit 0
fi

OUTPUT_FILE=$(mktemp)
FAILED=""

# flake8 — only if a .flake8 config exists (don't lint repos that didn't
# opt into a config; default max=79 would false-positive everything).
if [ -f .flake8 ] && "$PY" -c "import flake8" 2>/dev/null; then
    if ! "$PY" -m flake8 >"$OUTPUT_FILE" 2>&1; then
        FAILED="flake8"
    fi
fi

# pytest — only if pytest is importable in the venv we picked.
if [ -z "$FAILED" ] && "$PY" -c "import pytest" 2>/dev/null; then
    if ! "$PY" -m pytest tests/ -q >"$OUTPUT_FILE" 2>&1; then
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