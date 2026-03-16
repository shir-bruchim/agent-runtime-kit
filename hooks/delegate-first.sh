#!/bin/bash
# Delegate-First Hook (UserPromptSubmit)
#
# Appends a delegation reminder to every user prompt, encouraging the agent
# to use specialized subagents and skills before doing work directly.
#
# Install: Add to settings.json under hooks.UserPromptSubmit

echo '{"userPromptSuffix": "\n\n[DELEGATION CHECK: Before starting this task, check if there is a subagent or skill that fits. Use Explore agent for codebase exploration, planner for design decisions, git-ops for commits/PRs, tester for tests, perplexity-research for ANY web research. Delegate when appropriate to keep context clean.]"}'
