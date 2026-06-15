# Workflow: Execute Only

<objective>
Run Ralph on an existing prd.json file using skill-native subagents with parallel batch execution.
</objective>

<process>

<step name="1_verify_prd_json">
**Check prd.json exists and is valid**

```bash
# Verify file exists
ls -la tasks/prd.json

# Check structure and schema version
cat tasks/prd.json | jq '{
  project: .project,
  branch: .branchName,
  total_stories: (.userStories | length),
  has_new_schema: (any(.userStories[]; .status != null)),
  with_verification: ([.userStories[] | select(.verificationCommands != null and (.verificationCommands | length) > 0)] | length)
}'

# Show incomplete stories
cat tasks/prd.json | jq '.userStories[] | select(.status != "done" and .passes != true) | {id, title, status: (.status // "pending"), attempts: (.attempts // 0), storyType}'
```

If no tasks/prd.json exists, route to full-pipeline or from-prd workflow.

If using old schema (no `status` field), warn user:
"prd.json uses the old schema (boolean `passes` field). Ralph will auto-migrate stories to the new status-based schema during execution. Consider running ralph-convert-prd again for full verification commands."
</step>

<step name="2_review_stories">
**Show current status**

Display stories to user:
```bash
cat tasks/prd.json | jq '.userStories[] | {id, title, status: (.status // (if .passes then "done" else "pending" end)), priority, storyType, attempts: (.attempts // 0), blockedBy: (.blockedBy // [])}'
```

Ask: "These are the stories Ralph will work on. Incomplete stories will be implemented in priority/dependency order, with independent stories running in parallel. Ready to execute?"
</step>

<step name="3_detect_framework">
**Detect project framework and build agent routing table**

This runs once before execution begins. The orchestrator scans the project to understand its stack.

**Framework detection:**
- Read `package.json` → detect React/Next.js/Vue/Express/Nest, test runner (jest/vitest/playwright)
- Read `pyproject.toml` or `setup.py` → detect Python/FastAPI/Django, test runner (pytest)
- Read `go.mod` → detect Go
- Read `Cargo.toml` → detect Rust
- Read `tsconfig.json` → confirm TypeScript
- Read `playwright.config.ts` or `playwright.config.js` → Playwright available
- Detect ORM: Prisma (`prisma/schema.prisma`), Drizzle (`drizzle.config.ts`), SQLAlchemy, etc.

Build a `framework_profile` object:
```json
{
  "language": "typescript",
  "framework": "next.js (app router)",
  "test_runner": "vitest",
  "e2e_runner": "playwright",
  "orm": "prisma",
  "package_manager": "pnpm"
}
```

**Agent discovery and routing:**

Scan available agents:
- Read `.claude/agents/*.md` (project-level)
- Read `~/.claude/agents/*.md` (user-level)
- Parse each agent's name + description

Build routing table — for each storyType, find the best matching agent:

| storyType | Coder agent | Tester agent |
|-----------|-------------|--------------|
| frontend | Agent whose description matches "frontend" + "implement\|build\|create\|component" | Agent whose description matches "test\|verify\|qa\|debug" + "frontend\|UI\|e2e" |
| backend | Agent matching "backend" + "implement\|build\|service" | Agent matching "test\|pytest\|verify" |
| api | Agent matching "api" + "implement\|build\|endpoint" | Agent matching "test\|pytest\|verify" |
| database | Agent matching "database\|db\|migration\|schema" | Agent matching "test\|pytest\|verify" |
| infra | Agent matching "infra\|docker\|config\|deploy" | Agent matching "test\|verify\|qa" |
| test | N/A | Agent matching "test\|pytest\|verify" |

**Fallback:** If no matching agent found for a storyType, use `ralph-coder` (for coder role) or `ralph-tester` (for tester role).

**Key:** Even when using a project-specific agent (e.g., `db-expert`), the orchestrator wraps it with Ralph context — the story spec, return format, constraints, framework profile, and progress learnings.
</step>

<step name="4_execute_subagent_loop">
**Run autonomous implementation via parallel batch subagent loop**

**CRITICAL: ALL implementation MUST go through ralph-coder/ralph-tester subagents via the Agent tool. NEVER write code or modify project files directly.**

Ask user for max iterations:
"How many story iterations? (default: 10, remaining stories: [N])"

Initialize:
- `iterations = 0`
- `max_iterations` = user's answer
- Ensure `tasks/progress.txt` exists
- Ensure `tasks/test-log.md` exists
- Ensure `tasks/review-notes.md` exists
- Ensure `tasks/common_knowledge.md` exists (shared knowledge base across all stories)

**LOOP** (while eligible stories exist AND iterations < max_iterations):

**a. Read current state**
```bash
cat tasks/prd.json
cat tasks/common_knowledge.md
```

Read `tasks/common_knowledge.md` — this contains patterns, conventions, gotchas, and decisions discovered by previous stories. Use this to:
- Inform agent routing decisions
- Include relevant knowledge in subagent prompts
- Detect if previous stories surfaced issues the orchestrator should act on (e.g., "DB migrations require manual step" → warn user before spawning database stories)

**b. Find ALL eligible stories**
A story is eligible if:
- `status == "pending"` OR (`status == "failed"` AND `attempts < maxAttempts`)
- AND all story IDs in `blockedBy` array have `status == "done"`

**c. Check termination conditions**
- If no eligible stories AND all stories "done" → report **COMPLETE**, break loop
- If no eligible stories AND remaining are blocked/exhausted → report **BLOCKED**, show failed stories with `lastAttemptLog`, break loop

**d. Group eligible stories into a PARALLEL BATCH**
From eligible stories sorted by priority:
- Greedily select stories whose `blockedBy` sets don't include any other story in the current batch
- Stories with no dependency between them run concurrently

Display batch to user:
```
BATCH [N]: Running [X] stories in parallel
  - US-001: Add DB schema (coder: db-expert, tester: pytest-writer)
  - US-005: Add export feature (coder: ralph-coder, tester: ralph-tester)
```

**e. Update prd.json for all batch stories**
For each story in batch: set `status = "in_progress"`, increment `attempts`

--- **PHASE 1: CODE (parallel across batch)** ---

**f. Spawn coder Agents IN PARALLEL**
For each story in the batch, spawn an Agent call with:
- `subagent_type`: The matched coder agent name (e.g., `"ralph-coder"`) — use the name from the routing table built in step 3
- `isolation`: `"worktree"` — each coder gets an isolated git worktree automatically
- `prompt`: Include all context the coder needs (see template below)

**Agent call example (spawn ALL batch stories in a single message for parallelism):**
```
Agent({
  description: "Ralph coder: US-001 - Add DB schema",
  subagent_type: "ralph-coder",
  isolation: "worktree",
  prompt: "... (see template below)"
})
```

**Prompt template for coder Agent:**
```
You are executing Ralph story {story.id}: {story.title}

## Story Spec
{full story JSON object}

## Framework Profile
{framework_profile JSON}

## Progress Learnings
{relevant progress.txt content}

## Common Knowledge
{tasks/common_knowledge.md content — patterns, conventions, gotchas from previous stories}

## Instructions
{coder agent instructions — from ralph-coder.md or matched project agent}

## Constraints
- Do NOT commit any changes
- Do NOT write tests (the tester agent handles this)
- Do NOT modify tasks/prd.json
- Match existing project conventions
- Update docs/ folder with any new features, APIs, or concepts
- Append discoveries to tasks/common_knowledge.md

## Return Format
When done, output ONLY a JSON block:
{
  "story_id": "US-XXX",
  "status": "done" or "failed",
  "files_created": ["path/to/new/file.ts"],
  "files_modified": ["path/to/existing/file.ts"],
  "docs_updated": ["docs/api.md"],
  "implementation_notes": "Brief description",
  "needs_attention": "Anything the tester should know, or null"
}
```

**g. Wait for ALL coder Agents to complete**
Collect results from each Agent call. The Agent tool returns:
- The agent's text output (parse the JSON block from it)
- If `isolation: "worktree"` was used and the agent made changes: the **worktree path** and **branch name** are returned in the result metadata

**IMPORTANT:** Save the worktree path and branch name from each coder's result — you need these for the tester phase and for merging.

**h. Handle coder failures**
If a coder returns `status: "failed"` or the Agent call itself fails:
- Update prd.json: set story `status = "failed"`, write `lastAttemptLog` with the failure details
- Skip the tester phase for this story
- Log to progress.txt
- The worktree is automatically cleaned up if the agent made no changes

--- **PHASE 2: TEST (parallel across batch)** ---

**i. Spawn tester Agents IN PARALLEL**
For each story where coder succeeded, spawn an Agent call. The tester must work in the **same worktree** as the coder so it can see the implementation files.

- `subagent_type`: The matched tester agent name (e.g., `"ralph-tester"`)
- `isolation`: **DO NOT set** — the tester must NOT get its own worktree
- `prompt`: **MUST start with `cd [worktree_path]`** — include the worktree path from the coder's result so the tester works on the coder's files

**Agent call example:**
```
Agent({
  description: "Ralph tester: US-001 - Add DB schema",
  subagent_type: "ralph-tester",
  prompt: "IMPORTANT: First run `cd [worktree_path]` to enter the worktree where the coder implemented this story. ALL your work must happen in that directory.\n\n... (rest of prompt)"
})
```

**Prompt template for tester Agent:**
```
IMPORTANT: First run this command before doing anything else:
cd {worktree_path_from_coder_result}

ALL your work (reading files, writing tests, running commands) must happen in this directory.
This is the worktree where the coder implemented story {story.id}.

## Story Spec
{full story JSON object, including verificationCommands}

## Coder Result
{coder's JSON result: files_created, files_modified, implementation_notes, needs_attention}

## Framework Profile
{framework_profile JSON}

## Test Commands (project-level regression suite)
{testCommands from prd.json root}

## Progress Learnings
{relevant progress.txt content}

## Common Knowledge
{tasks/common_knowledge.md content}

## Instructions
{tester agent instructions — from ralph-tester.md or matched project agent}

## Constraints
- First cd into the worktree: {worktree_path}
- Do NOT commit any changes
- Do NOT modify production code (except minor bug fixes like typos, missing imports)
- Do NOT touch tasks/prd.json
- Update tasks/test-log.md, tasks/review-notes.md, tasks/common_knowledge.md, and docs/

## Return Format
When done, output ONLY a JSON block:
{
  "story_id": "US-XXX",
  "status": "done" or "failed",
  "tests_created": ["tests/unit/test_x.py"],
  "tests_modified": [],
  "docs_updated": [],
  "verification_results": [
    {"command": "...", "expect": "exit_code:0", "passed": true}
  ],
  "regression_passed": true,
  "failure_details": null,
  "review_notes": "observations"
}
```

**j. Wait for ALL tester Agents to complete**
Collect results from each Agent call. Parse the JSON block from the output.

--- **MERGE & UPDATE** ---

**k. Process results for each story**

The Agent tool with `isolation: "worktree"` returns the worktree path and branch name when the agent made changes. Use these values below.

**If tester returns `status: "done"`:**
1. Commit in the worktree (use the worktree path from coder's Agent result):
   ```bash
   cd {worktree_path} && git add -A && git commit -m "feat({story.id}): {story.title}

   Co-Authored-By: ralph-coder <noreply@anthropic.com>"
   ```
2. Merge worktree branch to main (sequentially, one story at a time):
   ```bash
   git checkout main && git merge {worktree_branch} --no-edit
   ```
   The `{worktree_branch}` is the branch name returned from the coder Agent's result metadata.
3. If merge conflict → **STOP.** Mark story as "failed" with conflict details in `lastAttemptLog`. Do NOT try to resolve conflicts automatically — ask the user.
4. Clean up the worktree after successful merge:
   ```bash
   git worktree remove {worktree_path} --force
   git branch -d {worktree_branch}
   ```
5. Update prd.json: set `status = "done"`, set `completedAt` to ISO timestamp

**If tester returns `status: "failed"`:**
1. Do NOT commit
2. Clean up the worktree (discard the failed work):
   ```bash
   git worktree remove {worktree_path} --force
   git branch -D {worktree_branch}
   ```
3. Update prd.json: set `status = "failed"`, write tester's `failure_details` to `lastAttemptLog`
4. Log failure to progress.txt

**l. Update tracking files**
- `tasks/prd.json` — story statuses (done or failed)
- `tasks/progress.txt` — append learnings from this batch
- `tasks/test-log.md` — already updated by tester subagents (verify entries exist)
- `tasks/review-notes.md` — already updated by tester subagents (verify entries exist)
- `tasks/common_knowledge.md` — already updated by both coder and tester subagents. **Read it now** — check for actionable discoveries (warnings, required manual steps, blockers for upcoming stories). If common_knowledge contains info that affects upcoming batches, factor it into routing decisions or warn the user.

**m. Display batch summary**
```
BATCH [N] COMPLETE:
  ✓ US-001: Add DB schema — DONE (merged to main)
  ✓ US-005: Add export feature — DONE (merged to main)
  ✗ US-003: Add notifications — FAILED (API endpoint returns 404)
```

**n. Increment iterations**
`iterations += 1` (count completed batches, not individual stories — each batch loop is one iteration regardless of how many parallel stories it contains)

**End of LOOP**

**5. Report final status**
- If all stories done → "All [N] stories completed successfully!"
- If loop exhausted → "Reached max iterations ([N]). [X] stories remaining. Run again to continue."
- If blocked → "All remaining stories are blocked or exhausted. Review failed stories in prd.json."

**STOP and ask the user for instructions if any stories remain incomplete.**
</step>

</process>

<parallel_execution_example>
```
prd.json stories:
  US-001: Add DB schema        (blockedBy: [])         → BATCH 1
  US-002: Add API endpoint     (blockedBy: [US-001])    → BATCH 2
  US-003: Add CLI command      (blockedBy: [US-001])    → BATCH 2
  US-004: Add UI dashboard     (blockedBy: [US-002])    → BATCH 3
  US-005: Add export feature   (blockedBy: [])           → BATCH 1

Execution:
  BATCH 1 (iteration 1 — 2 stories in parallel):
    Phase 1: Agent(ralph-coder, US-001, isolation:worktree) + Agent(ralph-coder, US-005, isolation:worktree)
    Phase 2: Agent(ralph-tester, US-001, cd worktree) + Agent(ralph-tester, US-005, cd worktree)
    Merge: US-001 → main, US-005 → main, git worktree remove both

  BATCH 2 (iteration 2 — 2 stories, after BATCH 1 merged):
    Phase 1: Agent(ralph-coder, US-002, isolation:worktree) + Agent(ralph-coder, US-003, isolation:worktree)
    Phase 2: Agent(ralph-tester, US-002, cd worktree) + Agent(ralph-tester, US-003, cd worktree)
    Merge: US-002 → main, US-003 → main, git worktree remove both

  BATCH 3 (iteration 3 — 1 story):
    Phase 1: Agent(ralph-coder, US-004, isolation:worktree)
    Phase 2: Agent(ralph-tester, US-004, cd worktree)
    Merge: US-004 → main, git worktree remove
```
</parallel_execution_example>

<success_criteria>
- [ ] prd.json validated (preferably with new schema)
- [ ] Framework detected and agent routing table built
- [ ] Ralph executed via subagent loop with parallel batches
- [ ] All stories have `status: "done"` with verification commands passed
- [ ] All worktree branches merged to main
- [ ] progress.txt updated with batch learnings
- [ ] test-log.md updated by tester agents with test registry
- [ ] review-notes.md updated by tester agents with improvement recommendations
- [ ] common_knowledge.md updated by both agents with shared patterns and discoveries
- [ ] docs/ folder updated by agents with new features, APIs, and test documentation
</success_criteria>
