# Concurrent Session Safety

Rules for teams running multiple AI agent sessions on the same codebase. Without these, concurrent sessions will eventually destroy each other's work.

## The Problem

When multiple Claude Code sessions (or any AI agents) work on the same repository simultaneously, they share the same git working tree. One session's `git checkout` or `git stash` silently wipes uncommitted changes from all other sessions.

**Real-world incident:** A 3-hour, 100-file security audit across 7 parallel agents was completely wiped when a separate session ran `git checkout` on the same working tree. All uncommitted changes — gone instantly, unrecoverable.

## Rules

### 1. Detect Before Working

Before any repo work, check for concurrent sessions:

```bash
ps aux | grep claude | grep -v grep | wc -l
```

If more than one session exists, apply rules 2-5.

### 2. Always Use Your Own Branch

Never work directly on `main` or shared branches when other sessions are active. Create a feature branch immediately:

```bash
git checkout -b feat/my-task-description
```

### 3. Commit Incrementally

Never accumulate large uncommitted changes. Commit early and often — uncommitted work is indefensible against concurrent git operations.

```bash
# After every meaningful change, not just at the end
git add specific-file.ts
git commit -m "wip: partial progress on feature X"
```

### 4. Never Checkout Shared Branches

When other sessions might be active, **never run `git checkout main`** or any command that modifies the shared working tree. Use worktrees instead:

```bash
# Instead of: git checkout main (DANGEROUS)
# Use: git worktree (SAFE)
git worktree add /tmp/my-task main
```

### 5. Isolate Subagents

Agent subprocesses (spawned via the Agent tool) must use worktree isolation so they get their own copy of the repo:

```
Agent tool → isolation: "worktree"
```

After a subagent completes, verify its changes actually landed — don't trust the success message.

### 6. Cap Parallel Agents

Limit concurrent agents to 7-8 maximum. Beyond this, git contention and resource pressure cause silent failures. If a task needs more parallelism, run in waves.

## Quick Reference

| Situation | Action |
|-----------|--------|
| Solo session | Work normally on any branch |
| 2+ sessions, same repo | Own branch + incremental commits |
| Spawning subagents | Use `isolation: "worktree"` |
| Need to touch main | Use `git worktree`, never `git checkout` |
| 8+ parallel agents needed | Run in waves of 5-7 |
