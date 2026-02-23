#!/bin/bash
# Blocks writes to sensitive files (.env, private keys, credentials)
# Install: configure as PreToolUse hook for Write|Edit tools
# Input: JSON via stdin with tool_input.file_path

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path','') or d.get('tool_input',{}).get('path',''))" 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
    exit 0  # No file path found, allow
fi

# Zero-access patterns (block completely)
ZERO_ACCESS_PATTERNS=(
    "\.env$"
    "\.env\."
    "\.env\*"
    "secrets\."
    "credentials\."
    "\.pem$"
    "\.key$"
    "\.p12$"
    "\.pfx$"
    "\.aws/"
    "\.ssh/"
    "serviceAccount"
    "firebase-adminsdk"
    "\.tfstate"
    "kubeconfig"
)

for pattern in "${ZERO_ACCESS_PATTERNS[@]}"; do
    if echo "$FILE_PATH" | grep -qE "$pattern"; then
        echo '{"decision":"block","reason":"'"$FILE_PATH"' matches protected file pattern. Secrets and credentials must not be modified by AI agents."}'
        exit 2
    fi
done

exit 0  # Allow
