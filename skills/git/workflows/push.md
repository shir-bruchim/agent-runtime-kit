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
</safety_rules>

<success_criteria>
Push succeeded. Remote branch updated or created with upstream tracking.
</success_criteria>
