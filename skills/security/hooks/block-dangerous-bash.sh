#!/bin/bash
# Blocks dangerous bash commands (rm -rf, force push to main, etc.)
# Install: configure as PreToolUse hook for Bash tool
# Input: JSON via stdin with tool_input.command

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null)

if [ -z "$COMMAND" ]; then
    exit 0
fi

# Patterns to BLOCK completely
BLOCK_PATTERNS=(
    "rm\s+(-[^\s]*)*-[rRf]"
    "rm\s+--recursive"
    "rm\s+--force"
    "sudo\s+rm\b"
    "git\s+reset\s+--hard\b"
    "git\s+push\s+.*--force(?!-with-lease)"
    "git\s+push\s+(-[^\s]*)*-f\b"
    "git\s+push\b.*(origin|upstream)\s+(main|master)\b"
    "git\s+push\s*$"
    "git\s+clean\s+(-[^\s]*)*-[fd]"
    "git\s+filter-branch\b"
    "chmod\s+(-[^\s]+\s+)*777\b"
    "mkfs\."
    "dd\s+.*of=/dev/"
    "kill\s+-9\s+-1\b"
    "killall\s+-9\b"
    "history\s+-c\b"
    "DELETE\s+FROM\s+\w+\s*;"
    "TRUNCATE\s+TABLE\b"
    "DROP\s+TABLE\b"
    "DROP\s+DATABASE\b"
    "terraform\s+destroy\b"
    "pulumi\s+destroy\b"
)

for pattern in "${BLOCK_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qP "$pattern" 2>/dev/null || echo "$COMMAND" | grep -qE "$pattern"; then
        echo '{"decision":"block","reason":"Command matches dangerous operation pattern. Command: '"$(echo $COMMAND | head -c 100)"'"}'
        exit 2
    fi
done

exit 0  # Allow
