#!/bin/bash
# Pre-commit hook: Block commits containing potential secrets
# Install: cp pre-commit-secrets.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
# Or use as a Claude Code PreToolUse hook for git commit commands

# Patterns that indicate secrets in staged changes
SECRET_PATTERNS=(
    'api[_-]?key\s*[=:]\s*["\047][^"\047]{8,}'
    'secret[_-]?key\s*[=:]\s*["\047][^"\047]{8,}'
    'password\s*[=:]\s*["\047][^"\047]{6,}'
    'token\s*[=:]\s*["\047][^"\047]{10,}'
    'private[_-]?key\s*[=:]\s*["\047]'
    'aws[_-]?access[_-]?key[_-]?id\s*[=:]\s*AKIA'
    'AKIA[0-9A-Z]{16}'
    'ghp_[a-zA-Z0-9]{36}'
    'sk-[a-zA-Z0-9]{48}'
    '-----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----'
)

# Only check staged changes
STAGED=$(git diff --cached --unified=0 2>/dev/null)
if [ -z "$STAGED" ]; then
    exit 0
fi

for pattern in "${SECRET_PATTERNS[@]}"; do
    if echo "$STAGED" | grep -qiE "$pattern" 2>/dev/null; then
        echo "❌ BLOCKED: Potential secret detected in staged changes"
        echo "   Pattern matched: $pattern"
        echo ""
        echo "   Remove secrets before committing."
        echo "   Use environment variables or a secrets manager instead."
        echo ""
        echo "   To bypass (if this is a false positive):"
        echo "   git commit --no-verify"
        exit 1
    fi
done

exit 0
