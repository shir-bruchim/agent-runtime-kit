#!/usr/bin/env bash
# =============================================================================
# block-dangerous-read.sh — Prevent reads of secrets, credentials, and keys
#
# OPT-IN security hook. Install to ~/.claude/hooks/ and register in
# ~/.claude/settings.json under PreToolUse for the Read tool.
#
# Blocked by default (zero-access — no reading allowed):
#   - .env files (.env, .env.local, .env.production, etc.)
#   - Private keys (*.pem, *.key, *.p12, *.pfx)
#   - SSH keys (~/.ssh/*)
#   - GPG keys (~/.gnupg/*)
#   - Cloud credentials (~/.aws/credentials, serviceAccount*.json, etc.)
#   - Terraform state (*.tfstate)
#   - Kubernetes configs (kubeconfig)
#
# Configuration (checked in order):
#   1. BLOCKED_READ_PATHS env var: colon-separated list of path patterns
#   2. ~/.claude/blocked-read-paths.txt: one pattern per line (# = comment)
#   3. Built-in defaults below
#
# Exit codes:
#   0 = allow
#   2 = HARD BLOCK (Claude stops the operation immediately)
# =============================================================================

read -r input 2>/dev/null || input=""

# Extract file_path from tool_input
file_path=$(echo "${input}" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    inp = d.get('tool_input', {})
    print(inp.get('file_path', inp.get('path', '')))
except:
    pass
" 2>/dev/null || echo "")

[[ -z "${file_path}" ]] && exit 0

# Expand ~ in file_path
file_path="${file_path/#\~/${HOME}}"

block() {
  local reason="$1"
  printf '{"decision":"block","reason":"%s"}\n' "${reason}" >&2
  echo "${reason}" >&2
  exit 2
}

# --- Custom blocked paths (from env or config file) ---
custom_paths=()

if [[ -n "${BLOCKED_READ_PATHS:-}" ]]; then
  IFS=':' read -ra env_paths <<< "${BLOCKED_READ_PATHS}"
  for p in "${env_paths[@]}"; do
    custom_paths+=("${p/#\~/${HOME}}")
  done
fi

config_file="${HOME}/.claude/blocked-read-paths.txt"
if [[ -f "${config_file}" ]]; then
  while IFS= read -r line || [[ -n "${line}" ]]; do
    [[ -z "${line}" || "${line}" =~ ^# ]] && continue
    custom_paths+=("${line/#\~/${HOME}}")
  done < "${config_file}"
fi

# Check custom path prefixes
for pattern in "${custom_paths[@]}"; do
  [[ -z "${pattern}" ]] && continue
  if [[ "${file_path}" == "${pattern}"* ]]; then
    block "Blocked read: ${file_path} is under protected path ${pattern}."
  fi
done

# --- Built-in zero-access path prefixes ---
if [[ "${file_path}" == "${HOME}/.ssh"* ]]; then
  block "Blocked read: ${file_path} — SSH keys are zero-access."
fi

if [[ "${file_path}" == "${HOME}/.gnupg"* ]]; then
  block "Blocked read: ${file_path} — GPG keys are zero-access."
fi

if [[ "${file_path}" == "${HOME}/.aws/credentials"* ]]; then
  block "Blocked read: ${file_path} — AWS credentials are zero-access."
fi

# --- Built-in zero-access filename patterns ---
basename=$(basename "${file_path}")
basename_lower=$(echo "${basename}" | tr '[:upper:]' '[:lower:]')

# .env files (exact and prefixed: .env, .env.local, .env.production, etc.)
# Allow template files: .env.example, .env.sample, .env.template
if [[ "${basename_lower}" == ".env" || "${basename_lower}" == .env.* ]]; then
  case "${basename_lower}" in
    .env.example|.env.sample|.env.template) ;;  # Allow templates
    *) block "Blocked read: ${file_path} — .env files are zero-access." ;;
  esac
fi

# Private key files
case "${basename_lower}" in
  *.pem|*.key|*.p12|*.pfx)
    block "Blocked read: ${file_path} — private key files are zero-access."
    ;;
esac

# Credential/secret files
if echo "${basename_lower}" | grep -qE '(^secrets\.|^credentials\.|serviceaccount|firebase-adminsdk)'; then
  block "Blocked read: ${file_path} — credential files are zero-access."
fi

# Terraform state
if echo "${basename_lower}" | grep -qE '\.tfstate(\.backup)?$'; then
  block "Blocked read: ${file_path} — Terraform state files are zero-access."
fi

# Kubeconfig
if [[ "${basename_lower}" == "kubeconfig" || "${basename_lower}" == ".kubeconfig" ]]; then
  block "Blocked read: ${file_path} — kubeconfig files are zero-access."
fi

exit 0
