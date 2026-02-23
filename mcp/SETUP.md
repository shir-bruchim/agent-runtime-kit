# MCP Server Setup

MCP (Model Context Protocol) servers extend your AI agent with external tool access.

## Installation Locations

**Claude Code** — add to `~/.claude.json` or project `.claude/settings.json`:
```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-name"],
      "env": { "KEY": "value" }
    }
  }
}
```

**Cursor** — add to `~/.cursor/mcp.json` or project `.cursor/mcp.json`:
```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-name"],
      "env": { "KEY": "value" }
    }
  }
}
```

---

## GitHub MCP Server

Enables: PR management, issue tracking, code search, repository operations.

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_yourtoken"
      }
    }
  }
}
```

**Get a token**: GitHub → Settings → Developer settings → Personal access tokens → Generate new token
**Required scopes**: `repo`, `read:org`, `read:user`

---

## Filesystem MCP Server

Enables: File operations in directories outside the project.

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/yourname/Documents",
        "/Users/yourname/Desktop"
      ]
    }
  }
}
```

**Security**: Only list paths you explicitly want the agent to access.

---

## PostgreSQL MCP Server

Enables: Database introspection, query execution, schema exploration.

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_CONNECTION_STRING": "postgresql://user:pass@localhost:5432/dbname"
      }
    }
  }
}
```

**Security**: Use a read-only database user for safety.

---

## Brave Search MCP Server

Enables: Web search from within the agent (useful for docs lookup, current events).

```json
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "BSA_yourapikey"
      }
    }
  }
}
```

**Get a key**: https://api.search.brave.com/ → Create API Key (free tier available)

---

## Memory MCP Server

Enables: Persistent knowledge graph — agent can store and retrieve facts across sessions.

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

Good for: storing project context, user preferences, recurring patterns across conversations.

---

## Atlassian MCP Server

Enables: Jira issue management, Confluence page creation and editing.

```json
{
  "mcpServers": {
    "atlassian": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-atlassian"],
      "env": {
        "ATLASSIAN_URL": "https://yourcompany.atlassian.net",
        "ATLASSIAN_EMAIL": "you@company.com",
        "ATLASSIAN_API_TOKEN": "your-api-token"
      }
    }
  }
}
```

**Get a token**: https://id.atlassian.com/manage-profile/security/api-tokens

---

## Combined Setup

Copy the servers you want into a single config:

**Claude Code** (`~/.claude.json`):
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_yourtoken" }
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": { "BRAVE_API_KEY": "BSA_yourkey" }
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

---

## Troubleshooting

**Server not connecting:**
```bash
# Test if the package works standalone
npx -y @modelcontextprotocol/server-github --help

# Check Claude Code sees it
claude mcp list
```

**Permission errors:**
- Check environment variables are set correctly
- Verify API tokens have required scopes
- For filesystem: ensure paths listed in args actually exist

**Cursor MCP not loading:**
- Restart Cursor after editing `mcp.json`
- Check JSON syntax with: `jq . .cursor/mcp.json`
