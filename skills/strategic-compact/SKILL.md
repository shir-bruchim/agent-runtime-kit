---
name: strategic-compact
description: Promotes recurring feedback into the right skill, then guides /compact at phase boundaries. User-invoked maintenance + checkpoint.
when_to_use: |
  Activate when the user types /strategic-compact, says "compact", "let's compact",
  "we've finished phase X what's next", or when at a clear phase boundary
  (PR merged, tests green, plan done) AND main-loop context is >50% full. Runs the
  skill-self-improvement pass against accumulated feedback memory before recommending.
disable-model-invocation: true
allowed-tools: Bash(ls:*), Bash(cat:*), Bash(grep:*), Bash(find:*), Bash(date:*), Bash(mkdir:*), Read, Write, Edit, WebFetch
---

<objective>
User-invoked maintenance + compaction checkpoint. Two phases, in order:

1. **Self-improvement pass.** Scan recent feedback memories + this session for rules that belong in a skill. Promote, shrink the source, mark MEMORY.md.
2. **Compaction recommendation.** Suggest `/compact` at a logical phase boundary with a paste-ready summary.

The skill is `disable-model-invocation: true` — zero context cost until the user types `/strategic-compact`.
</objective>

<universe>
Run at invocation. Output replaces these lines before Claude sees the body.

Skills on disk:
!`ls ~/.claude/skills/ 2>/dev/null | grep -v "^plugin_" | sort`

Today:
!`date -u +%Y-%m-%dT%H:%M:%SZ`
</universe>

<architecture>
The work splits into two phases that have DIFFERENT context requirements:

- **SCAN phase** is a heavy file-read sweep (universe, memory, session feedback, target SKILL.md contents). Delegate to a subagent so the main loop's context stays small.
- **APPLY phase** needs per-candidate `AskUserQuestion` prompts. Forked subagents CANNOT call `AskUserQuestion`. APPLY runs in the main loop.

This skill does NOT use `context: fork` in frontmatter (that would forbid `AskUserQuestion` across the whole run). Instead the body spawns a subagent for SCAN only, then continues in main-loop context for APPLY.
</architecture>

<run>
Execute in order:

1. **SCAN** — Spawn a `general-purpose` subagent with this prompt:

   > Read `~/.claude/skills/strategic-compact/workflows/self-improvement-pass.md` and execute it end-to-end. Your final output must be the candidate-list Markdown described in the "Output contract" section. ALSO write the same content to `~/.claude/tmp/strategic-compact-candidates-<UTC-timestamp>.md` (create the dir if missing). Return only the candidate list — no prose preamble.

   Wait for the agent return. Save the file path it created.

2. **APPLY** — Read `~/.claude/skills/strategic-compact/workflows/apply-edits.md` and execute it against the candidate list (prefer the subagent return; fall back to the file if truncated). Use `AskUserQuestion` for each candidate.

3. **DECIDE** — Read `~/.claude/skills/strategic-compact/workflows/compaction-decision.md` and emit a compaction recommendation with a paste-ready `/compact <summary>` line.

If the SCAN phase returns an empty candidate list AND the self-healing sweep found nothing, skip directly to DECIDE.
</run>

<skip_when>
- User explicitly says "skip self-improvement" or "just compact" → run only DECIDE.
- No `feedback_*` memories exist AND the session contained no corrections worth promoting → SCAN will report empty; skip to DECIDE.
- All candidate rules are project-specific (e.g., "PR #196 ships behind flag X") → SCAN drops them; skip to DECIDE.
</skip_when>

<workflows_index>
| Workflow | Role |
|----------|------|
| `workflows/self-improvement-pass.md` | SCAN — runs in a delegated subagent; produces candidate list |
| `workflows/apply-edits.md` | APPLY — runs in main loop; per-candidate y/n prompts + Edit + shrink source |
| `workflows/compaction-decision.md` | DECIDE — phase-boundary table + paste-ready `/compact` summary |
</workflows_index>

<references_index>
| Reference | When to read |
|-----------|--------------|
| `references/promotion-quality-gates.md` | During SCAN step 7b — every candidate must clear all 6 gates |
| `references/self-healing-checks.md` | During SCAN step 1c (early) and APPLY late-sweep |
| `references/claude-code-best-practices.md` | Pre-SCAN freshness check + drift-watch surfacing |
</references_index>

<success_criteria>
- [ ] SCAN delegated to a subagent — main-loop context stayed small.
- [ ] Candidate list received as agent return AND written to `~/.claude/tmp/`.
- [ ] Each candidate that cleared the 6 gates was prompted per-entry; declines noted.
- [ ] Approved edits applied; sources shrunk; MEMORY.md marked.
- [ ] Self-healing findings surfaced (early sweep + late re-check).
- [ ] Compaction recommendation paste-ready (`/compact <summary>` line).
- [ ] No important context lost without first being written to a durable location.
</success_criteria>