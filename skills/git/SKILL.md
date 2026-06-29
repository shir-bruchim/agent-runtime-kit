---
name: git
description: Git operations for committing, pushing, and opening PRs. Includes safety rules to prevent destructive operations. Use when performing any version control tasks — commit, push, PR, or full ship workflow.
---

<essential_principles>

<git_safety>
**Never run without explicit user request:**
- `git push --force` to main/master
- `git reset --hard`
- `--no-verify` flag (skip hooks)
- `git commit --amend` on pushed commits
- Direct push to main/master (create feature branch first)

**Always verify before acting:**
- `git status` before staging
- `git log --oneline -5` for commit style
- Check remote tracking before push

**`git worktree remove` is destructive — sweep first.** Before removing ANY worktree, in EACH worktree run:
- `git status --short` — surface uncommitted edits (modified, untracked, staged)
- `git log --oneline <upstream>..HEAD` — surface unpushed commits
- If either is non-empty, STOP. Ask the user explicitly: (a) commit + push it now, (b) save as a patch (`git diff > /tmp/<name>.patch`) for later, or (c) discard. Don't assume "the work is mirrored elsewhere" — the whole reason worktrees exist is to hold work that isn't yet on the canonical branch. Surfacing the diff one-line-per-file BEFORE the user makes the call is the right move; running `git worktree remove --force` to bypass a "worktree contains modified files" warning is the wrong one. Also delete stale local branch labels (`git branch -D <name>`) AFTER worktree removal if the label points at a commit the user has confirmed they're done with.

**Branch naming:**
- Features: `feat/description`
- Fixes: `fix/description`
- Chores: `chore/description`
</git_safety>

<commit_format>
Commit message structure:
```
type(scope): short description

- What changed (if not obvious from description)
- Why it changed (motivation)

Co-Authored-By: Claude <noreply@anthropic.com>
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`

Use HEREDOC for multi-line messages:
```bash
git commit -m "$(cat <<'EOF'
feat(auth): add JWT refresh token rotation

- Rotates refresh tokens on every use
- Prevents replay attacks on stolen tokens

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```
</commit_format>

<pr_format>
PR body:
```markdown
## Summary
- [What this PR does in 1-3 bullets]

## Test plan
- [ ] [Test 1]
- [ ] [Test 2]

## Changes
- [File 1]: [What changed]
- [File 2]: [What changed]
```
</pr_format>

</essential_principles>

<intake>
What would you like to do?

1. **Commit** — Stage and commit changes
2. **Push** — Push commits to remote
3. **PR** — Open a pull request
4. **Ship** — Full workflow: commit + push + PR

**Wait for response.**
</intake>

<routing>
| Response | Workflow |
|----------|----------|
| 1, "commit" | `workflows/commit.md` |
| 2, "push" | `workflows/push.md` |
| 3, "pr", "pull request" | `workflows/pr.md` |
| 4, "ship", "all" | commit → push → pr (sequential) |
</routing>

<workflows_index>
| Workflow | Purpose |
|----------|---------|
| commit.md | Stage changes and create commit |
| push.md | Push to remote, create branch if needed |
| pr.md | Create pull request with gh CLI |
</workflows_index>
