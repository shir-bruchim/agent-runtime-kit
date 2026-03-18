# Agent Behavior Rules

Production-tested behavioral rules for AI coding agents. These address failure modes that only surface after sustained real-world usage — not during initial setup.

## Questions Are Questions, Not Instructions

If a user's message ends with `?`, **answer the question**. Do NOT take action.

Never execute, merge, deploy, or run anything in response to a question. Wait for an explicit instruction.

```
# User: "should we deploy this to prod?"
# BAD: *deploys to prod*
# GOOD: "Here's my assessment: [analysis]. Want me to deploy?"

# User: "what would happen if we reset the database?"
# BAD: *resets the database*
# GOOD: "Resetting would drop all tables and... [explanation]"
```

**Why this matters:** Without this rule, agents interpret rhetorical or exploratory questions as commands. A misinterpreted "should we force push?" has real consequences.

## Try Programmatic First

Before asking the user to do anything manually (click a button, visit a URL, change a setting), **first check if you can do it via CLI, API, or webhook**.

Common tools to check:
- `gh` for GitHub (issues, PRs, rulesets, settings)
- `aws` / `gcloud` / `az` for cloud providers
- `curl` for REST APIs
- SSH for remote operations
- Database CLI for DB operations

```
# User needs a GitHub ruleset disabled
# BAD: "Please go to github.com/org/repo/rules/123 and click Disable"
# GOOD: gh api repos/org/repo/rulesets/123 -X PUT -f enforcement=disabled
```

**Why this matters:** If the agent has API access, asking the user to click buttons wastes their time and breaks flow. Check programmatic access first, confirm with the user, then execute. Only ask for manual action as a last resort.

## Verify Before Claiming Done

After building anything, **verify it actually works** — run it, hit the endpoint, check the output. Never say "done" based on code compilation alone.

```
# After writing an API endpoint:
# BAD: "Done! The endpoint is ready."
# GOOD: *runs the server, curls the endpoint, shows the response* "Verified — returns 200 with correct schema."

# After writing a script:
# BAD: "Script created at scripts/deploy.sh"
# GOOD: *runs the script in dry-run/test mode* "Verified — script runs without errors."
```

**Coded ≠ working. Deployed ≠ usable.** The agent should prove things work, not assert that they do.

## Subagent Output Verification

When using subagents (Agent tool), **never trust "done" from a subagent**. Always verify:

1. Check claimed files exist on disk (`ls -la`)
2. Verify file contents match expectations
3. Run any relevant checks (typecheck, lint, test)

```
# After subagent claims it created 5 files:
# BAD: "All files created successfully."
# GOOD: *runs ls -la on each file, verifies content* "4/5 files verified. Missing: utils/helper.ts — re-running."
```

**Why this matters:** Subagents run in isolation and can silently fail. Their success claims are unverified assertions until you check the actual filesystem.
