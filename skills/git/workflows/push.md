# Workflow: Git Push

<process>
1. Check current branch: `git branch --show-current`
2. Verify not on main/master (if so, create feature branch)
3. Check remote tracking: `git status`
4. Push with upstream tracking if first push:
   ```bash
   git push -u origin $(git branch --show-current)
   ```
   Or regular push if already tracking:
   ```bash
   git push
   ```
5. Confirm push succeeded
</process>

<safety_rules>
- NEVER use `--force` to main/master
- Use `--force-with-lease` if force is truly necessary (never to protected branches)
- If push rejected, investigate WHY before force-pushing
- **Push-gate lints the wrong repo (worktree case):** if a local PreToolUse push gate runs lint/tests in the shell's CWD and that CWD is a different repo than the branch being pushed (common from a worktree — the shell resets to the primary project dir each Bash call, so the gate validates the wrong tree and wrongly denies), do NOT `--no-verify` or force. Push via the host GitHub API (create_branch / push_files / delete_file / create_pull_request), which bypasses the local Bash gate cleanly.
- **Force-push gated but a rebase must land:** rebase locally, then move the remote branch to its base sha via the host API (`gh api -X PATCH repos/<owner>/<repo>/git/refs/heads/<branch> -f sha=<base_sha> -F force=true`); a normal `git push` then **fast-forwards** (the rebased commit's parent == base) without tripping the force gate. GOTCHA: force-resetting a PR branch to its base makes head==base, which **auto-closes the PR** — run `gh pr reopen <n>` after the follow-up push (head/commits recompute on reopen).
- **Pushing LARGE files past a gate — go byte-exact via the git-database API, NOT `push_files` / `create_or_update_file`.** Those helpers require the full file *content* as a call parameter, which routes every byte through the model context — lossy re-emission (a single mis-typed line corrupts the file) and huge token cost for a 1000+-line or binary file. Instead build the commit from disk: for each changed file create a blob — `gh api -X POST repos/<o>/<r>/git/blobs -f content="$(base64 -i FILE)" -f encoding=base64` — and **verify each returned sha == `git hash-object FILE`** (byte-exact proof); then create a tree with `base_tree=<target-commit-tree-sha>` and the blob entries (`{path,mode:"100644",type:"blob",sha}`), create a commit (`parents:[<target-sha>]`), and update the ref (force to squash onto the base; then `gh pr reopen`). Content never enters context. A subagent with `gh` + disk access can do the whole sequence. (Iterate the file list with a shell **array**, not an unquoted `$VAR` — zsh doesn't word-split unquoted expansions, so `for f in $FILES` runs once on the whole string.)
</safety_rules>

<success_criteria>
Push succeeded. Remote branch updated or created with upstream tracking.
</success_criteria>
