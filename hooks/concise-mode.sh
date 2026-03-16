#!/bin/bash
# Concise Mode Hook (UserPromptSubmit)
#
# When concise mode is enabled, prepends a style instruction to keep
# responses brief (1-3 sentences, no code blocks unless essential).
# Automatically skips if the user asks for elaboration.
#
# Install: Add to settings.json under hooks.UserPromptSubmit
# Toggle: Use /concise command or run concise-toggle.sh
# State file: ~/.claude/.concise-mode ("on" or "off")

STATE_FILE="${HOME}/.claude/.concise-mode"

# Check if concise mode is disabled
if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "off" ]; then
    exit 0
fi

# Check if state file exists at all (default: off unless explicitly enabled)
if [ ! -f "$STATE_FILE" ]; then
    exit 0
fi

# Read user prompt from stdin
INPUT=$(cat)
USER_PROMPT=$(echo "$INPUT" | jq -r '.user_prompt // empty' 2>/dev/null)

# Skip concise mode if user asks for elaboration
if echo "$USER_PROMPT" | grep -qiE '(elaborate|explain|detail|show code|example)'; then
    exit 0
fi

# Inject concise style prefix
echo '{"userPromptPrefix": "[STYLE: Be extremely brief. No code blocks, no tables, no bullet lists unless essential. 1-3 sentences max.]"}'
