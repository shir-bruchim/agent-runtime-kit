# AI Config System - Quick Reference

## 🚀 Installation

```bash
# Auto-setup (recommended)
git clone <repo-url>
cd agent-runtime-kit
./scripts/setup.sh

# Manual setup - Claude
git clone <repo-url> ~/.claude

# Manual setup - Cursor
cd your-project && git clone <repo-url> .cursor

# Manual setup - Generic
git clone <repo-url> .ai-config
```

---

## 📁 Locations

| Platform | Location | Path |
|----------|----------|------|
| Claude | Home | `~/.claude/` |
| Claude | Container | `/home/claude/.claude/` |
| Cursor | Project | `.cursor/` |
| Generic | Anywhere | `.ai-config/` |

---

## 🎯 Command Triggers

| Platform | Syntax | Example |
|----------|--------|---------|
| Claude | `/command` | `/review` |
| Cursor | `@command` | `@review` |
| Generic | `#command` | `#review` |

---

## 📂 Folder Structure

```
.ai-config/
├── skills/           # Knowledge & workflows
│   ├── universal/    # Works everywhere
│   ├── claude-specific/
│   └── cursor-specific/
├── commands/         # Quick shortcuts
├── hooks/           # Auto-triggers
├── preferences/     # Settings
└── templates/       # Reusable structures
```

---

## 🛠️ Create New Skill

```bash
# Copy template
cp skills/universal/SKILL-TEMPLATE.md skills/universal/my-skill.md

# Edit
nano skills/universal/my-skill.md

# Test with your AI
```

---

## ⚙️ Create New Command

```yaml
# commands/universal/my-command.yml
name: "My Command"
triggers:
  claude: "/mycmd"
  cursor: "@mycmd"
  generic: "#mycmd"

action:
  type: "workflow"
  steps:
    - prompt: "What to do"
```

---

## 🪝 Create New Hook

```yaml
# hooks/universal/my-hook.yml
name: "My Hook"
event: "on_file_upload"  # or on_file_save

conditions:
  - type: "file_extension"
    values: [".py", ".js"]

action:
  type: "workflow"
  steps:
    - prompt: "What to do automatically"

enabled: true
```

---

## 🎨 Platform Features

| Feature | Claude | Cursor | Generic |
|---------|--------|--------|---------|
| Skills | ✅ | ✅ | ✅ |
| Commands | ✅ | ✅ | ✅ |
| Auto Hooks | ✅ | ✅ | ❌ |
| Web Search | ✅ | ❌ | ❌ |
| LSP | ❌ | ✅ | ❌ |
| Documents | ✅ | ❌ | ⚠️ |
| Git | ⚠️ | ✅ | ❌ |

---

## 🔍 Detection Check

```yaml
# ai-config.yml
platform: "auto"  # or "claude" or "cursor"

# Override detection
platform: "claude"
```

---

## 📋 Skill Template (Minimal)

```markdown
# Skill Name

## Description
What this does

## Platform Compatibility
- ✅ Claude: Full support
- ✅ Cursor: Full support
- ⚠️ Generic: Basic support

## Trigger Conditions
- When to use

## Instructions
1. Step 1
2. Step 2
3. Step 3

## Examples
Input → Output
```

---

## 💡 Quick Examples

### Universal Code Review
```yaml
# commands/universal/review.yml
name: "Code Review"
triggers:
  claude: "/review"
  cursor: "@review"

action:
  claude:
    - Read code
    - Search web for best practices
    - Create DOCX report
  cursor:
    - Use LSP for analysis
    - Check workspace conventions
    - Inline suggestions
```

### Auto-Analyze on Upload (Claude)
```yaml
# hooks/claude-specific/auto-analyze.yml
name: "Auto Analyze"
event: "on_file_upload"

conditions:
  - type: "file_extension"
    values: [".pdf", ".docx"]

action:
  prompt: "Analyze this document and summarize"
```

### Auto-Format on Save (Cursor)
```yaml
# hooks/cursor-specific/auto-format.yml
name: "Auto Format"
event: "on_file_save"

conditions:
  - type: "file_extension"
    values: [".py", ".js"]

action:
  command: "format_file"
```

---

## 🐛 Troubleshooting

**Platform not detected?**
```bash
# Check manually
cat ai-config.yml

# Override
echo 'platform: "claude"' > ai-config.yml
```

**Skill not working?**
- Check filename: `SKILL.md` or `*.md`
- Check location: `skills/universal/`
- Check syntax: Valid markdown

**Command not found?**
- Check trigger matches platform
- Check YAML syntax
- Check file location

**Hook not triggering?**
- Check `enabled: true`
- Check event type matches platform
- Check conditions are met

---

## 📚 Files to Know

| File | Purpose |
|------|---------|
| `README.md` | Main overview |
| `AI-DETECTION.md` | For AI to read |
| `GETTING-STARTED.md` | Detailed guide |
| `CHEATSHEET.md` | This file |
| `ai-config.yml` | Main config |
| `preferences/*.yml` | Settings |

---

## 🎓 Learning Path

**Beginner:**
1. Run setup.sh
2. Try example command
3. Create first skill
4. Customize preferences

**Intermediate:**
5. Create multiple skills
6. Set up auto-hooks
7. Platform-specific optimizations
8. Share with team

**Advanced:**
9. Multi-platform projects
10. CI/CD integration
11. Custom platforms
12. Contribute back

---

## 💻 Useful Commands

```bash
# Check structure
tree -L 2

# Test YAML syntax
python3 -c "import yaml; yaml.safe_load(open('file.yml'))"

# Find all skills
find skills -name "*.md"

# List enabled hooks
grep "enabled: true" hooks/*.yml

# Backup config
tar -czf ai-config-backup.tar.gz .ai-config/

# Update from git
git pull origin main
```

---

## 🔗 Quick Links

- Detailed Guide: `GETTING-STARTED.md`
- AI Instructions: `AI-DETECTION.md`
- Skills Folder: `skills/`
- Examples: `skills/universal/`

---

**TIP:** Start with one skill, one command, and one hook. Build from there!

**Version:** 1.0.0  
**Platform:** Universal (Claude, Cursor, Generic)
