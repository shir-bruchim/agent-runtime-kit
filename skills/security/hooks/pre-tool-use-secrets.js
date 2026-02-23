#!/usr/bin/env node
// Pre-tool-use hook: Block commits containing potential secrets
// Configure in .claude/hooks.json as a PreToolUse hook for Bash tool

const fs = require('fs');

// Read hook input from stdin
let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  let parsed;
  try {
    parsed = JSON.parse(input);
  } catch {
    process.exit(0); // invalid input, allow
  }

  const command = (parsed?.tool_input?.command || '').toLowerCase();

  // Only intercept git commit commands
  if (!command.includes('git commit')) {
    process.exit(0);
  }

  // Check staged changes for secrets
  const { execSync } = require('child_process');
  let staged;
  try {
    staged = execSync('git diff --cached --unified=0 2>/dev/null', { encoding: 'utf8' });
  } catch {
    process.exit(0); // can't check, allow
  }

  const secretPatterns = [
    /api[_-]?key\s*[=:]\s*["'][^"']{8,}/i,
    /secret[_-]?key\s*[=:]\s*["'][^"']{8,}/i,
    /password\s*[=:]\s*["'][^"']{6,}/i,
    /AKIA[0-9A-Z]{16}/,
    /ghp_[a-zA-Z0-9]{36}/,
    /sk-[a-zA-Z0-9]{48}/,
    /-----BEGIN (RSA |EC |)?PRIVATE KEY-----/,
  ];

  for (const pattern of secretPatterns) {
    if (pattern.test(staged)) {
      const result = {
        decision: 'block',
        reason: `Potential secret detected in staged changes (matched pattern: ${pattern.source}). Remove secrets before committing.`
      };
      process.stdout.write(JSON.stringify(result));
      process.exit(2);
    }
  }

  process.exit(0); // allow
});
