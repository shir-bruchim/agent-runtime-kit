# MCP Server Setup

> **MCP is OPT-IN.** Nothing is installed by default. Add only what you need.

MCP (Model Context Protocol) servers extend your AI agent with external tool access — GitHub, databases, search, observability, and more.

---

## Config Locations

| Platform | Scope | Path |
|----------|-------|------|
| Claude Code | Global (all projects) | `~/.claude.json` or `~/.claude/settings.json` |
| Claude Code | Project-only | `.claude/settings.json` |
| Cursor | Global (all projects) | `~/.cursor/mcp.json` |
| Cursor | Project-only | `.cursor/mcp.json` |

Add your chosen servers under `"mcpServers"`:

```json
{
  "mcpServers": {
    "server-name": { ... }
  }
}
```

After editing, restart Claude Code / Cursor to reload. Check with `claude mcp list` (Claude Code).

---

## Recommended Servers

### GitHub

Enables: PR management, issue tracking, code search, repository operations.

**Option A — Remote hosted** (Claude Code, no local install):
```json
"github": {
  "type": "sse",
  "url": "https://api.githubcopilot.com/mcp/"
}
```
Authenticate via `claude mcp add --transport sse github https://api.githubcopilot.com/mcp/`.

**Option B — Docker** (Claude Code + Cursor, works offline):
```json
"github": {
  "type": "stdio",
  "command": "docker",
  "args": ["run", "-i", "--rm",
    "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
    "ghcr.io/github/github-mcp-server"],
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_yourtoken"
  }
}
```

> **Do NOT use** `@modelcontextprotocol/server-github` (npm). It was deprecated in April 2025.

**Token scopes needed**: `repo`, `read:org`, `read:user`
**Docs**: https://github.com/github/github-mcp-server

---

### Atlassian (Jira + Confluence)

Enables: Jira issue management, Confluence page creation and editing.

Uses Atlassian's official **remote MCP server** — no local install required:

```json
"atlassian": {
  "type": "sse",
  "url": "https://mcp.atlassian.com/v1/sse"
}
```

Authenticate in-browser when prompted. Works with both Claude Code and Cursor.

**Docs**: https://developer.atlassian.com/cloud/jira/platform/mcp/

---

### PostgreSQL

Enables: Database introspection, query execution, schema exploration.

```json
"postgres": {
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-postgres",
           "postgresql://readonly_user:pass@localhost:5432/dbname"]
}
```

> Always use a **read-only** database user.

---

### Web Search (Tavily — recommended)

Enables: Web search for docs, current events, research within the agent.

```json
"websearch": {
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "tavily-mcp@0.1.4"],
  "env": { "TAVILY_API_KEY": "tvly-yourapikey" }
}
```

Get a key: https://tavily.com (free tier available)

**Alternative**: Brave Search — `npx @modelcontextprotocol/server-brave-search` + `BRAVE_API_KEY`

---

### Mermaid

Enables: Diagram rendering (flowchart, sequence, ERD) to images.

```json
"mermaid": {
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "@peng-shawn/mermaid-mcp-server"]
}
```

---

### Sentry

Enables: Error tracking — fetch issues, stack traces, release info.

```json
"sentry": {
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-sentry"],
  "env": {
    "SENTRY_AUTH_TOKEN": "sntrys_yourtoken",
    "SENTRY_ORG_SLUG": "your-org",
    "SENTRY_PROJECT_SLUG": "your-project"
  }
}
```

**Docs**: https://github.com/modelcontextprotocol/servers/tree/main/src/sentry

---

### groundcover (Observability)

Enables: APM, logs, metrics from groundcover's cloud-native observability platform.

```json
"groundcover": {
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "@groundcover/mcp-server"],
  "env": {
    "GROUNDCOVER_API_KEY": "your-api-key"
  }
}
```

**Docs**: https://docs.groundcover.com/docs/mcp

---

### Filesystem (optional)

Only add this if you need file access outside your project directory.

```json
"filesystem": {
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-filesystem",
           "/Users/yourname/Documents"]
}
```

> Security: list only paths you explicitly want the agent to access.

---

## Troubleshooting

**Server not connecting:**
```bash
# Test the package standalone
npx -y @modelcontextprotocol/server-postgres postgresql://... --help

# Check Claude Code sees it
claude mcp list
```

**Permission errors:**
- Check environment variables are set
- Verify API tokens have required scopes
- For filesystem: ensure listed paths exist

**Cursor MCP not loading:**
- Restart Cursor after editing `mcp.json`
- Validate JSON: `jq . .cursor/mcp.json` or `jq . ~/.cursor/mcp.json`