---
name: perplexity-deep-search
description: "Deep search via Perplexity API. Three modes: search (quick facts), reason (complex analysis), research (in-depth reports). Returns AI-grounded answers with citations."
---

<objective>
AI-powered web search with three depth levels via the Perplexity API. Use for research, fact-checking, technology comparisons, and staying current with rapidly-changing topics.
</objective>

<when_to_activate>
- Need current information beyond training data
- Technology comparison or evaluation
- Library/framework version-specific questions
- Market research or industry analysis
- Fact-checking before making architectural decisions
</when_to_activate>

<modes>

| Mode | Model | Best For | Cost |
|------|-------|----------|------|
| `search` (default) | `sonar-pro` | Quick facts, summaries, current events | Low (~$0.01/query) |
| `reason` | `sonar-reasoning-pro` | Complex analysis, comparisons, problem-solving | Medium (~$0.02/query) |
| `research` | `sonar-deep-research` | In-depth reports, market analysis, literature reviews | High (~$0.40/query) |

**Rule:** Use `search` for everyday queries. Reserve `research` for exhaustive analysis.
</modes>

<usage>

### Via Script (if installed)
```bash
# Quick search
~/.claude/scripts/perplexity_search.py "latest Python 3.13 features"

# Reasoning mode
~/.claude/scripts/perplexity_search.py --mode reason "compare FastAPI vs Django for enterprise APIs"

# Deep research
~/.claude/scripts/perplexity_search.py --mode research "enterprise AI adoption trends 2025"
```

### Via curl (fallback)
```bash
curl -s https://api.perplexity.ai/chat/completions \
  -H "Authorization: Bearer ${PERPLEXITY_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "sonar-pro",
    "messages": [{"role": "user", "content": "your query here"}]
  }' | python3 -c "import json,sys; print(json.load(sys.stdin)['choices'][0]['message']['content'])"
```

### Options
| Flag | Description | Default |
|------|-------------|---------|
| `--mode` | `search`, `reason`, `research` | `search` |
| `--recency` | `hour`, `day`, `week`, `month` | — |
| `--domains` | Comma-separated domain filter | — |
| `--json` | Raw JSON output | off |
</usage>

<api_key_setup>
Set `PERPLEXITY_API_KEY` environment variable, or store in a file:
```bash
mkdir -p ~/.config/perplexity
echo "your_key_here" > ~/.config/perplexity/api_key
chmod 600 ~/.config/perplexity/api_key
```
The script checks the env var first, then falls back to the file.
</api_key_setup>

<error_handling>

| Error | Cause | Solution |
|-------|-------|----------|
| `401 Unauthorized` | Invalid or missing API key | Check `PERPLEXITY_API_KEY` |
| `429 Rate Limited` | Too many requests | Wait and retry; use `search` instead of `research` |
| `500 Server Error` | Perplexity outage | Retry after 30s; fall back to web search |
| Timeout | `research` mode is slow (~3-5 min) | Expected for deep research |
</error_handling>

<success_criteria>
- [ ] Correct mode selected for query depth
- [ ] API key configured
- [ ] Results include citations/sources
- [ ] Answers are grounded in search results (not hallucinated)
</success_criteria>
