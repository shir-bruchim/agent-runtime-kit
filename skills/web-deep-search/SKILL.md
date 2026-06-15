---
name: web-deep-search
description: "Deep web research using built-in WebSearch + WebFetch. Three modes: search (quick facts), reason (multi-source analysis), research (in-depth report with citations). No external API key required."
---

<objective>
Multi-source web research with three depth levels using Claude Code's built-in `WebSearch` and `WebFetch` tools. Use for fact-checking, technology comparisons, and current information beyond training data.
</objective>

<when_to_activate>
- Need current information beyond training data
- Technology comparison or evaluation
- Library/framework version-specific questions
- Market research or industry analysis
- Fact-checking before making architectural decisions
</when_to_activate>

<modes>

| Mode | Approach | Best For |
|------|----------|----------|
| `search` (default) | 1–2 `WebSearch` calls, summarize titles/snippets | Quick facts, current events, quick lookups |
| `reason` | 2–4 `WebSearch` calls + `WebFetch` top results, cross-reference | Comparisons, problem-solving, multi-source analysis |
| `research` | Fan-out searches (different angles) + fetch primary sources + adversarial verification | In-depth reports, market analysis, literature reviews |

**Rule:** Default to `search`. Escalate to `reason` when sources disagree. Reserve `research` for exhaustive analysis with citations.
</modes>

<workflow>

### search mode
1. One targeted `WebSearch` query.
2. If results sufficient, synthesize answer with source URLs.
3. If insufficient, run one refined query.

### reason mode
1. Run 2–4 `WebSearch` queries from different angles (technical docs, comparison articles, recent posts).
2. `WebFetch` the top 2–3 most authoritative URLs.
3. Cross-reference claims; flag disagreements between sources.
4. Synthesize with inline citations: `[per docs.example.com]`.

### research mode
1. Decompose question into 4–6 sub-questions.
2. `WebSearch` each sub-question in parallel.
3. `WebFetch` primary sources (official docs, vendor announcements, peer-reviewed where applicable).
4. Adversarially verify key claims (search for counter-evidence).
5. Produce structured report: findings, evidence, contradictions, citations.
6. For very deep research, prefer the `deep-research` slash command which orchestrates a multi-agent harness.

</workflow>

<source_quality>
Prefer in this order:
1. **Primary sources** — official docs, RFCs, vendor announcements, source code
2. **Authoritative secondary** — well-maintained tech blogs, recognized publications
3. **Aggregators** — Stack Overflow, Reddit (only when corroborated)

Reject: SEO-spam content farms, AI-generated listicles, undated tutorials.

For version-specific questions, always verify the date — favor results from the last 12 months.
</source_quality>

<recency_filter>
`WebSearch` accepts no built-in recency flag, so add temporal hints to the query itself:
- `"FastAPI 2026 release notes"`
- `"Python 3.13 features site:python.org"`
- `"latest <topic> changelog 2026"`
</recency_filter>

<error_handling>

| Issue | Solution |
|-------|----------|
| Conflicting sources | Cite both, flag disagreement, prefer primary source |
| No relevant results | Refine query (more specific terms, add domain filter) |
| Stale information | Add year to query, prefer official changelogs/release notes |
| Paywall on key source | Search for the same content on the publisher's preview, or accept the limitation and cite the abstract |
</error_handling>

<success_criteria>
- [ ] Mode matches query depth (don't fan out for a fact lookup)
- [ ] Every non-trivial claim has a source URL
- [ ] Conflicts between sources are surfaced, not hidden
- [ ] Primary sources preferred over aggregators
- [ ] No hallucinated facts — if the web didn't say it, don't claim it
</success_criteria>