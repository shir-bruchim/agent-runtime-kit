# Claude Code best-practices reference

**Verify against the live docs before each `/strategic-compact` run.** Claude Code's knobs evolve quarterly — the bullets below are a snapshot. Live docs at `https://code.claude.com/docs/en/` (migrated from `docs.claude.com` in 2026). When the docs contradict this block, the docs win — recommend the user update this file in the next strategic-compact pass.

Verified as of 2026-06-29 against `code.claude.com/docs/en/features-overview`, `/skills`, `/sub-agents`, `/hooks`.

## The full Claude Code extension surface

Per `/en/features-overview`, an audit must cover ALL of these — not just skills:

| Extension | Doc | Lives at |
|---|---|---|
| CLAUDE.md | `/en/memory` | `~/.claude/CLAUDE.md`, project `./CLAUDE.md` |
| Skills | `/en/skills` | `~/.claude/skills/<name>/SKILL.md` |
| Rules | `/en/memory#organize-rules-with-claude/rules/` | `~/.claude/rules/<name>.md` |
| Subagents | `/en/sub-agents` | `~/.claude/agents/<name>.md` |
| Commands (merged into skills) | `/en/skills` | `~/.claude/commands/<name>.md` (legacy) |
| Hooks | `/en/hooks-guide`, `/en/hooks` | `~/.claude/settings.json` `hooks` key + `~/.claude/hooks/*.sh` |
| MCP servers | `/en/mcp` | `~/.claude/settings.json` `mcpServers` key |
| Plugins | `/en/plugins` | `~/.claude/plugins/` |
| Marketplaces | `/en/plugin-marketplaces` | `~/.claude/settings.json` `marketplaces` key |
| Agent teams (experimental) | `/en/agent-teams` | Settings flag + `agent-teams` config |
| Artifacts | `/en/artifacts` | Auto-published session output |
| Code intelligence (LSP) | `/en/tools-reference#lsp-tool-behavior` | Code-intelligence plugin per language |
| Context-window visualization | `/en/context-window` | `/context` slash-command |

The SCAN phase of `workflows/self-improvement-pass.md` (Steps 1–1i) inventories the first eight categories. Agent teams, artifacts, code intelligence, and context-window visualization are surfaced as drift recommendations rather than inventoried.

## Freshness check (run at the TOP of every self-improvement pass)

Same pattern as `~/.claude/skills/extend-agent/SKILL.md` `<freshness_check>`:

1. WebFetch `https://code.claude.com/docs/en/features-overview` FIRST — confirms the extension-surface table above is still current. New rows here trigger new SCAN steps.
2. WebFetch `https://code.claude.com/docs/en/skills` to confirm the frontmatter fields below.
3. WebFetch `https://code.claude.com/docs/en/hooks` if any candidate touches hooks.
4. WebFetch `https://code.claude.com/docs/en/sub-agents` if any candidate touches subagents.
5. WebFetch `https://code.claude.com/docs/en/mcp`, `/en/plugins`, or `/en/agent-teams` if a candidate touches those areas.
6. If any live doc contradicts this file, FIX this file AFTER the user's promotion decisions land (not mid-pass).

Token cost: ~15-50k for 2-6 WebFetch calls. It pays for itself by preventing a session-long detour fixing a wrong field name OR ignoring an extension category that's grown since the last run.

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

For each item below, ask: is this reflected in `~/.claude/skills/extend-agent/SKILL.md`, the user's `~/.claude/agents/` definitions, or their `~/.claude/settings.json`? If not, surface as a recommendation. The user decides whether to act.

### Hooks (`/en/hooks`, `/en/hooks-guide`)

- **Hook events.** The published roster has grown to ~30. Baseline: `PreToolUse`, `PostToolUse`, `UserPromptSubmit`, `Stop`, `SubagentStop`, `SessionStart`, `SessionEnd`, `PreCompact`, `Notification`. Newer additions include `PostCompact`, `Setup`, `UserPromptExpansion`, `PostToolBatch`, `PostToolUseFailure`, `PermissionRequest`/`PermissionDenied`, `SubagentStart`, `TaskCreated`/`TaskCompleted`, `MessageDisplay`, `InstructionsLoaded`, `ConfigChange`, `CwdChanged`, `FileChanged`, `WorktreeCreate`/`WorktreeRemove`, `TeammateIdle`, `Elicitation`/`ElicitationResult`. Confirm against `code.claude.com/docs/en/hooks` if a candidate mentions hooks.
- **Hook handler types.** Beyond `command`: `http`, `mcp_tool`, `prompt` (LLM-evaluated), `agent` (experimental, spawns a tool-capable subagent). Surface model + default-timeout details if a skill proposes a `prompt`-type hook.

### Skills + commands (`/en/skills`)

- **Commands merged into skills.** `.claude/commands/<name>.md` and `.claude/skills/<name>/SKILL.md` both create `/<name>`. New extensions should default to the skill form (richer features: subdirs, frontmatter for invocation control, dynamic context injection).
- **AgentSkills open standard.** Claude Code's skills follow `agentskills.io`; portable to other tools. If a candidate skill is generic enough, recommend the user publish it standalone.
- **Skill invocation control.** `disable-model-invocation: true` (zero context cost, user-only), `user-invocable: false` (auto-invoke only, no slash menu), `context: fork` (isolated subagent), `agent: <type>` (which agent runs the fork), `allowed-tools:` (defense-in-depth).
- **Skill listing budget.** Default is 1% of context window. Tune with `skillListingBudgetFraction` in settings. Per-skill overrides via `skillOverrides: {"<name>": "name-only"}` — drops description from listing.

### Subagents (`/en/sub-agents`)

- **Model lineup.** Re-check each run; haiku/sonnet/opus version numbers churn quarterly.
- **`skills:` preload.** Subagents fully load preloaded skills at startup (no on-demand). Use to inject specialist knowledge once instead of restating in the body.
- **`memory: user` / `memory: project`.** Persistent learning at `~/.claude/agent-memory/<name>/`. Good for review agents that should track repeat findings.
- **`maxTurns`, `isolation: worktree`.** Surface as recommendations for long-running or destructive agents.
- **Built-in Explore + Plan agents** omit CLAUDE.md and git status from their startup context. Surface as a recommendation when users build their own narrow research agents.

### MCP (`/en/mcp`)

- **Tool search on by default.** Idle MCP servers cost minimal context (tool names only). Full JSON schemas defer until use.
- **Automatic reconnection** for remote servers. Disconnected servers can be reconnected without restart.
- **`/mcp` slash-command** reports per-server status + token cost. Use as an audit input — the SCAN can't introspect this from a forked subagent; prompt the user to paste.
- **Scope precedence:** local > project > user. Same-name servers shadow.

### Plugins + marketplaces (`/en/plugins`, `/en/plugin-marketplaces`)

- A plugin bundles skills/hooks/subagents/MCP into one installable unit. Plugin skills are namespaced (`/my-plugin:review`).
- When multiple repos need the same kit, recommend packaging as a plugin. This is the "share once, install everywhere" surface — replaces ad-hoc copies between `~/.claude/skills/` directories.
- Marketplaces host plugin collections — recommend when a kit is mature enough to publish.

### Agent teams — experimental (`/en/agent-teams`)

- Coordinates multiple independent Claude Code sessions with shared tasks + peer-to-peer messaging.
- Disabled by default; enable via settings flag (re-verify the exact key each run).
- Recommend when SCAN sees parallel subagents hitting context limits OR when a workflow needs competing-hypothesis reasoning.

### Artifacts (`/en/artifacts`)

- Auto-publishes session output as a private, interactive web page.
- Recommend when a skill produces output the user would share visually (incident timelines, audit reports, dashboards) rather than pasting terminal text.

### Code intelligence (`/en/tools-reference#lsp-tool-behavior`)

- Language-server navigation + live type errors. Inactive until a code-intelligence plugin is installed for the language.
- Recommend when SCAN sees frequent grep-for-symbol calls in the visible conversation — LSP replaces broad file reads with cheap symbol lookups.

### Context window (`/en/context-window`)

- `/context` slash-command visualizes how each extension type is consuming the window.
- Surface as a recommendation when SCAN finds the user near a compaction boundary — they may want to see the breakdown before approving `/compact`.

### Settings keys worth knowing

- `skillListingBudgetFraction` — raises/lowers the 1% default listing budget.
- `skillOverrides` — per-skill name-only / disabled overrides without editing the skill file.
- `permissions` — auto-allow / auto-deny lists for tool calls.
- `env` — environment variables exposed to hooks and tool runs.
- `mcpServers` — MCP server configs (transport, command, env).
- `hooks` — event → matcher → handler config.
- `plugins`, `marketplaces` — plugin sources.

If any of the above is missing from the local `~/.claude/skills/extend-agent/SKILL.md` or `~/.claude/agents/` definitions, recommend adding it as a follow-up — even if it doesn't affect the current candidates. The user decides whether to act. The skill author surfaces drift.