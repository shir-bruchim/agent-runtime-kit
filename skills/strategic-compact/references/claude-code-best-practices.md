# Claude Code best-practices reference

**Verify against the live docs before each `/strategic-compact` run.** Claude Code's knobs evolve quarterly — the bullets below are a snapshot. Live docs at `https://code.claude.com/docs/en/` (migrated from `docs.claude.com` in 2026). When the docs contradict this block, the docs win — recommend the user update this file in the next strategic-compact pass.

Verified as of 2026-06-26 against `code.claude.com/docs/en/skills`, `/sub-agents`, `/hooks`.

## Freshness check (run at the TOP of every self-improvement pass)

Same pattern as `~/.claude/skills/extend-agent/SKILL.md` `<freshness_check>`:

1. WebFetch `https://code.claude.com/docs/en/skills` to confirm the frontmatter fields below.
2. WebFetch `https://code.claude.com/docs/en/hooks` if any candidate touches hooks.
3. WebFetch `https://code.claude.com/docs/en/sub-agents` if any candidate touches subagents.
4. If the live doc contradicts this file, FIX this file AFTER the user's promotion decisions land (not mid-pass).

Token cost: ~10-30k for 1-3 WebFetch calls. It pays for itself by preventing a session-long detour fixing a wrong field name.

## Skill efficiency

- Skills with `disable-model-invocation: true` cost zero context tokens until the user types `/<name>` — best for low-frequency, user-only skills.
- Skills with `user-invocable: false` still load `description:` into context — useful when Claude should auto-invoke without showing up in the `/` menu.
- Default skills cost the `description:` length per turn. Keep it tight.
- `description` + `when_to_use` cap = 1,536 characters combined in the skill listing. Put the key use-case first.
- Skill-description listing budget scales at 1% of the model's context window. Low-priority skill descriptions get dropped first when overflowing — `/doctor` reports which.
- `skillListingBudgetFraction` setting raises/lowers the listing budget (default ≈ 0.01 = 1% of context window).
- `skillOverrides` in `settings.json`: per-skill overrides. Setting an entry to `"name-only"` lists it without description (zero description-cost).
- For multi-section skills, use the router pattern: lean `SKILL.md` (under ~200 lines) routes to `workflows/`, `references/`, `templates/` subdirectories. Subdir content loads only when the body explicitly Reads it.
- `context: fork` runs the skill in a forked subagent. SKILL.md content drives the subagent; no conversation history. Skill must contain explicit instructions (a task) for fork mode to work — pure guidelines won't produce output.
- `agent: <subagent-type>` picks which subagent type runs the forked skill (e.g. `general-purpose`, `architect`, `Explore`, `Plan`).
- `allowed-tools:` restricts which tools the skill can use during its run (defense-in-depth).
- Dynamic context injection: `` !`<bash command>` `` lines in SKILL.md run at INVOCATION; their stdout replaces the line before Claude sees the body.

## Subagent efficiency

- Subagents start with their own fresh context — moving heavy work (sweeps, audits, parallel reviews) into a subagent SAVES the main loop's tokens.
- Each subagent invocation costs a system-prompt + the task brief. Worth it for >10 tool calls of work; not worth it for 1-2 quick reads.
- `model: haiku` for cheap scans / file enumeration / known-safe transformations.
- `model: sonnet` (default) for most coding/review work.
- `model: opus` ONLY for hard synthesis / cross-file reasoning / when sonnet hit a wall — opus is ~5× the cost.
- `memory: user` on a subagent persists learning at `~/.claude/agent-memory/<name>/` — good for review agents that should track repeat findings.
- **Forked subagents CANNOT call `AskUserQuestion`.** Per-candidate y/n loops must stay in the main loop.

## Parallelism

- Spawn independent subagents in ONE message (not sequential). They run concurrently and the main loop waits once.
- A 4-way fan-out (e.g., `tester` ×3 modules + `reviewer` on the diff) finishes in roughly the slowest single agent's time, not 4× sum.

## Context discipline

- Compact at phase boundaries (this skill's main purpose), not arbitrary thresholds.
- Anything important must survive compaction — write to a file, memory, or TodoWrite before compacting.
- After compaction, the next-turn system prompt rebuilds from CLAUDE.md + memory + skill descriptions. If a rule isn't in one of those, it's gone.

## Drift watch list (review against the live docs each run)

- **Hook events.** The published roster has grown to ~30. Baseline: `PreToolUse`, `PostToolUse`, `UserPromptSubmit`, `Stop`, `SubagentStop`, `SessionStart`, `SessionEnd`, `PreCompact`, `Notification`. Newer additions include `PostCompact`, `Setup`, `UserPromptExpansion`, `PostToolBatch`, `PostToolUseFailure`, `PermissionRequest`/`PermissionDenied`, `SubagentStart`, `TaskCreated`/`TaskCompleted`, `MessageDisplay`, `InstructionsLoaded`, `ConfigChange`, `CwdChanged`, `FileChanged`, `WorktreeCreate`/`WorktreeRemove`, `TeammateIdle`, `Elicitation`/`ElicitationResult`. Confirm against `code.claude.com/docs/en/hooks` if a candidate mentions hooks.
- **Hook handler types.** Beyond `command`: `http`, `mcp_tool`, `prompt` (LLM-evaluated), `agent` (experimental, spawns a tool-capable subagent). Surface model + default-timeout details if a skill proposes a `prompt`-type hook.
- **Commands merged into skills.** `.claude/commands/<name>.md` and `.claude/skills/<name>/SKILL.md` both create `/<name>`. New extensions should default to the skill form (richer features: subdirs, frontmatter for invocation control, dynamic context injection).
- **New invocation modes worth surfacing as recommendations:** subagent execution of skills, dynamic context injection, agent teams, background agents, the `context-window` visualization.
- **AgentSkills open standard.** Claude Code's skills follow `agentskills.io`; portable to other tools. If a candidate skill is generic enough, recommend the user publish it standalone.
- **Model lineup.** Re-check each run; haiku/sonnet/opus version numbers churn quarterly.

If any of the above is missing from the local `~/.claude/skills/extend-agent/SKILL.md` or `~/.claude/agents/` definitions, recommend adding it as a follow-up — even if it doesn't affect the current candidates. The user decides whether to act. The skill author surfaces drift.