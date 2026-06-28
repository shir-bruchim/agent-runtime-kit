#!/usr/bin/env bash
# =============================================================================
# protect-files.sh — Prevent writes to protected file paths and sensitive files
#
# OPT-IN security hook. Install to ~/.claude/hooks/ and register in
# ~/.claude/settings.json under PreToolUse for Write|Edit tools.
#
# Two layers of protection:
#   Layer 1 — Path prefixes (configurable):
#     1. PROTECTED_PATHS env var: colon-separated list of path prefixes
#     2. ~/.claude/protected-paths.txt: one path prefix per line (# = comment)
#     3. Built-in defaults: ~/.ssh, ~/.gnupg, ~/.aws/credentials
#
#   Layer 2 — Filename patterns (built-in, always active):
#     .env files, private keys (*.pem, *.key), credential files, tfstate,
#     kubeconfig. Allows .env.example/.env.sample/.env.template.
#
# Example ~/.claude/protected-paths.txt:
#   ~/.ssh
#   ~/.gnupg
#   /etc/passwd
#   ~/my-project/.env
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

# Build list of protected path prefixes
protected_paths=()

# From environment variable (colon-separated)
if [[ -n "${PROTECTED_PATHS:-}" ]]; then
  IFS=':' read -ra env_paths <<< "${PROTECTED_PATHS}"
  for p in "${env_paths[@]}"; do
    protected_paths+=("${p/#\~/${HOME}}")
  done
fi

# From config file
config_file="${HOME}/.claude/protected-paths.txt"
if [[ -f "${config_file}" ]]; then
  while IFS= read -r line || [[ -n "${line}" ]]; do
    [[ -z "${line}" || "${line}" =~ ^# ]] && continue
    protected_paths+=("${line/#\~/${HOME}}")
  done < "${config_file}"
fi

# Built-in defaults (always protected)
protected_paths+=(
  "${HOME}/.ssh"
  "${HOME}/.gnupg"
  "${HOME}/.aws/credentials"
)

# Check if file_path is under any protected prefix
for pattern in "${protected_paths[@]}"; do
  [[ -z "${pattern}" ]] && continue
  if [[ "${file_path}" == "${pattern}"* ]]; then
    reason="Blocked: ${file_path} is under protected path ${pattern}. Set PROTECTED_PATHS to reconfigure."
    printf '{"decision":"block","reason":"%s"}\n' "${reason}" >&2
    echo "${reason}" >&2
    exit 2
  fi
done

# --- Built-in zero-access filename patterns (secrets, credentials, keys) ---
block() {
  local reason="$1"
  printf '{"decision":"block","reason":"%s"}\n' "${reason}" >&2
  echo "${reason}" >&2
  exit 2
}

basename=$(basename "${file_path}")
basename_lower=$(echo "${basename}" | tr '[:upper:]' '[:lower:]')

# .env files (allow .env.example, .env.sample, .env.template)
if [[ "${basename_lower}" == ".env" || "${basename_lower}" == .env.* ]]; then
  case "${basename_lower}" in
    .env.example|.env.sample|.env.template) ;;
    *) block "Blocked write: ${file_path} — .env files are protected." ;;
  esac
fi

# Private key files
case "${basename_lower}" in
  *.pem|*.key|*.p12|*.pfx)
    block "Blocked write: ${file_path} — private key files are protected."
    ;;
esac

# Credential/secret files
if echo "${basename_lower}" | grep -qE '(^secrets\.|^credentials\.|serviceaccount|firebase-adminsdk)'; then
  block "Blocked write: ${file_path} — credential files are protected."
fi

# Terraform state
if echo "${basename_lower}" | grep -qE '\.tfstate(\.backup)?$'; then
  block "Blocked write: ${file_path} — Terraform state files are protected."
fi

# Kubeconfig
if [[ "${basename_lower}" == "kubeconfig" || "${basename_lower}" == ".kubeconfig" ]]; then
  block "Blocked write: ${file_path} — kubeconfig files are protected."
fi

exit 0