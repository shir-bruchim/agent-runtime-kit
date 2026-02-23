# Getting Started with AI Configuration System
## Universal Setup for Any AI Assistant

Welcome! This guide will help you set up and use this configuration system with Claude, Cursor, or any AI assistant.

---

## 🚀 Quick Start (60 Seconds)

### Automatic Setup

```bash
# Clone the repository
git clone https://github.com/your-username/agent-runtime-kit.git

# Run auto-setup
cd agent-runtime-kit
./scripts/setup.sh
```

**That's it!** The script will:
1. Detect your AI platform (Claude/Cursor/Generic)
2. Create the appropriate folder structure
3. Copy relevant files
4. Configure settings
5. Tell you what to do next

---

## 📖 Table of Contents

1. [What is This?](#what-is-this)
2. [Platform Detection](#platform-detection)
3. [Manual Setup](#manual-setup)
4. [Core Concepts](#core-concepts)
5. [Your First Customization](#your-first-customization)
6. [Platform Differences](#platform-differences)
7. [Examples](#examples)
8. [Troubleshooting](#troubleshooting)

---

## What is This?

A universal configuration system that works with multiple AI assistants:

- **Skills** - Reusable knowledge and workflows
- **Commands** - Quick shortcuts
- **Hooks** - Automatic triggers
- **Preferences** - Your settings
- **Templates** - Reusable structures

**Key Feature:** Write once, works everywhere (with platform-specific optimizations).

---

## Platform Detection

The system automatically detects which AI you're using:

### If You're Using Claude
**Detection:** Checks for `/mnt/skills/`, `web_search` tool  
**Location:** `~/.claude/` or `/home/claude/.claude/`  
**Features:** Full feature set including web search, document creation

### If You're Using Cursor
**Detection:** Checks for `.cursor/`, workspace context  
**Location:** `.cursor/` in project root  
**Features:** Code-focused with LSP, Git integration

### If You're Using Something Else
**Detection:** Falls back to generic  
**Location:** `.ai-config/`  
**Features:** Universal features only

---

## Manual Setup

### For Claude Users

```bash
# Clone to home directory
git clone <repo-url> ~/.claude
cd ~/.claude

# Or use the container path
git clone <repo-url> /home/claude/.claude
cd /home/claude/.claude
```

### For Cursor Users

```bash
# Clone to your project
cd your-project
git clone <repo-url> .cursor
cd .cursor
```

### For Other AI Users

```bash
# Clone anywhere
git clone <repo-url> .ai-config
cd .ai-config
```

---

## Core Concepts

### 1. Skills (Universal)

Skills are knowledge bundles that adapt to each platform.

**Structure:**
```
skills/
├── universal/          # Works everywhere
│   └── SKILL-TEMPLATE.md
├── claude-specific/    # Claude optimizations
└── cursor-specific/    # Cursor optimizations
```

**Example - Code Review Skill:**
- **Claude:** Uses web search for best practices, creates DOCX reports
- **Cursor:** Uses LSP for code intelligence, inline suggestions
- **Generic:** Basic text analysis

### 2. Commands (Platform-Adapted)

Quick shortcuts with platform-specific triggers.

**Claude:** `/command-name`
```yaml
trigger: "/review"
```

**Cursor:** `@command-name` or `!command-name`
```yaml
trigger: "@review"
```

**Generic:** `#command-name`
```yaml
trigger: "#review"
```

### 3. Hooks (Event-Based)

Automatic actions triggered by events.

**Claude Hooks:**
- `on_file_upload` - When user uploads files
- `on_conversation_start` - Beginning of chat

**Cursor Hooks:**
- `on_file_save` - When user saves code
- `on_workspace_open` - When project opens

**Generic Hooks:**
- Manual triggers only

### 4. Preferences (Universal Base + Platform-Specific)

**Inheritance chain:**
```
base-preferences.yml
    ↓
claude-preferences.yml (or cursor-preferences.yml)
    ↓
user-overrides.yml (optional)
```

### 5. Templates (Universal)

Reusable structures that work everywhere.

---

## Your First Customization

### Create Your First Skill

**Step 1: Copy the template**
```bash
# Adjust path based on your platform
cp skills/universal/SKILL-TEMPLATE.md skills/universal/my-first-skill.md
```

**Step 2: Edit the skill**
```markdown
# My First Skill

## Description
Analyzes financial reports and extracts key metrics

## Platform Compatibility
- ✅ Claude: Can search for industry benchmarks
- ✅ Cursor: Can analyze code-generated reports
- ✅ Generic: Basic text analysis

## Trigger Conditions
- User uploads financial documents
- Keywords: "financial analysis", "quarterly report"

## Instructions

### Universal Steps
1. Identify document type
2. Extract key numbers
3. Calculate ratios
4. Generate summary

### Claude-Specific
- Use web_search for industry averages
- Create formatted DOCX report
- Include charts/visualizations

### Cursor-Specific  
- Analyze any code that generates reports
- Suggest improvements to calculations
- Integrate with existing codebase

...
```

**Step 3: Test it**

**Claude:** Upload a financial document
**Cursor:** Save a financial report file
**Generic:** Provide text input

### Create Your First Command

**Step 1: Create command file**
```bash
# Location depends on platform
# Claude: ~/.claude/commands/
# Cursor: .cursor/commands/
# Generic: .ai-config/commands/

nano commands/universal/quick-summary.yml
```

**Step 2: Define the command**
```yaml
name: "Quick Summary"

# Platform-specific triggers
triggers:
  claude: "/summarize"
  cursor: "@summarize"
  generic: "#summarize"

description: "Create a quick summary"

action:
  type: "workflow"
  steps:
    - prompt: "Create a concise summary with key points"
    
parameters:
  - name: "length"
    type: "choice"
    options: ["brief", "standard", "detailed"]
    default: "standard"
```

**Step 3: Use it**

**Claude:** Type `/summarize` with a document
**Cursor:** Type `@summarize` in code comments
**Generic:** Type `#summarize` with text

---

## Platform Differences

### What Works Where

| Feature | Claude | Cursor | Generic |
|---------|--------|--------|---------|
| Skills | ✅ Full | ✅ Full | ✅ Basic |
| Commands | ✅ `/cmd` | ✅ `@cmd` | ✅ `#cmd` |
| Hooks | ✅ Auto | ✅ Auto | ⚠️ Manual |
| Web Search | ✅ Yes | ❌ No | ❌ No |
| LSP | ❌ No | ✅ Yes | ❌ No |
| Documents | ✅ Yes | ❌ No | ⚠️ Basic |
| Code Focus | ⚠️ General | ✅ Yes | ⚠️ General |

### Platform Strengths

**Claude Best For:**
- Research and web search
- Document creation (DOCX, PDF, PPTX)
- Multi-step workflows
- Conversation-based tasks

**Cursor Best For:**
- Code completion and refactoring
- Workspace-aware development
- LSP-powered intelligence
- Git integration

**Generic Best For:**
- Simple text processing
- Platform-independent tasks
- Portable workflows

---

## Examples

### Example 1: Code Review (Universal)

**Create the skill:**
```markdown
# Code Review

## Platform Compatibility
- ✅ Claude: Web search for best practices
- ✅ Cursor: LSP for deep code understanding
- ✅ Generic: Pattern-based review

## Claude Approach:
1. Read code with `view` tool
2. Search web for language best practices
3. Generate detailed DOCX report
4. Include examples from online sources

## Cursor Approach:
1. Use LSP to understand code structure
2. Check against workspace conventions
3. Provide inline suggestions
4. Integrate with existing tests

## Generic Approach:
1. Parse code as text
2. Check common patterns
3. Generate text report
4. Basic recommendations
```

### Example 2: Document Analysis

**Claude Version:**
```yaml
# commands/universal/analyze.yml
name: "Document Analyzer"
trigger: "/analyze"

action:
  claude:
    - Read file from /mnt/user-data/uploads/
    - Extract key information
    - Search web if clarification needed
    - Create formatted DOCX report
  
  generic:
    - Read provided text
    - Extract key information
    - Generate text summary
```

### Example 3: Project Setup

**Cursor Version:**
```yaml
# commands/cursor-specific/setup-project.yml
name: "Project Setup"
trigger: "@setup"

action:
  steps:
    - Create standard project structure
    - Initialize git repository
    - Add .gitignore
    - Create README.md
    - Set up linting configuration
    - Initialize package.json (if JS/TS)
```

---

## Folder Organization

### Recommended Structure

```
.ai-config/ (or .claude/ or .cursor/)
│
├── skills/
│   ├── universal/
│   │   ├── code-review.md
│   │   ├── document-analysis.md
│   │   └── data-processing.md
│   ├── claude-specific/
│   │   └── research-assistant.md
│   └── cursor-specific/
│       └── refactoring-helper.md
│
├── commands/
│   ├── universal/
│   │   ├── summarize.yml
│   │   └── analyze.yml
│   └── platform-specific/
│       ├── claude/
│       └── cursor/
│
├── hooks/
│   ├── universal/
│   ├── claude-specific/
│   │   └── auto-document-analysis.yml
│   └── cursor-specific/
│       └── on-file-save.yml
│
├── preferences/
│   ├── base-preferences.yml
│   ├── claude-preferences.yml
│   ├── cursor-preferences.yml
│   └── user-overrides.yml
│
└── templates/
    └── universal/
        ├── document-template.yml
        └── code-template.yml
```

---

## Best Practices

### Writing Universal Skills

✅ **DO:**
- Write clear trigger conditions
- Document platform differences
- Provide examples for each platform
- Test on multiple platforms
- Use feature detection

❌ **DON'T:**
- Assume platform-specific features
- Hardcode file paths
- Skip documentation
- Forget error handling

### Organizing Files

```bash
# Good structure
skills/universal/financial-analysis.md
skills/claude-specific/financial-research.md
skills/cursor-specific/financial-code-review.md

# Bad structure  
skills/skill1.md
skills/skill2.md
skills/temp.md
```

### Testing Workflow

1. **Test Locally** - Does it work on your platform?
2. **Test Generic** - Does it work without special features?
3. **Test Other Platforms** - If possible, verify elsewhere
4. **Document Limitations** - Note what doesn't work where

---

## Troubleshooting

### Common Issues

**Issue: Skill not triggering**
- Check trigger conditions
- Verify file is in correct location
- Check platform detection

**Issue: Command not recognized**
- Verify trigger syntax for your platform
- Check YAML syntax
- Ensure file is in commands/ folder

**Issue: Wrong platform detected**
- Check `ai-config.yml`
- Override with `platform: "claude"` or `platform: "cursor"`
- Check environment variables

### Platform-Specific Issues

**Claude:**
- Skills not reading? Check `/mnt/skills/public/`
- Files not saving? Check `/mnt/user-data/outputs/`
- Web search failing? Check network settings

**Cursor:**
- LSP not working? Check language server installation
- Workspace issues? Check project initialization
- Git problems? Check repository status

**Generic:**
- Limited features? Check `base-preferences.yml`
- Things not working? May need platform-specific version

---

## Advanced Topics

### Multi-Platform Projects

Use symlinks to share config:

```bash
# Share between Claude and project
ln -s ~/.claude ~/project/.ai-config

# Or use git submodules
git submodule add <repo-url> .cursor
```

### Custom Platforms

Add your own platform support:

1. Create `preferences/myplatform-preferences.yml`
2. Add detection logic to `scripts/detect-ai.sh`
3. Create platform-specific skills
4. Test and document

### CI/CD Integration

```yaml
# .github/workflows/test-skills.yml
name: Test Skills
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Test Skills
        run: ./scripts/test-skills.sh
```

---

## Next Steps

### Beginner Path
1. ✅ Run setup script
2. ✅ Read README.md
3. ✅ Try example command
4. ✅ Create first skill

### Intermediate Path
1. Create multiple skills
2. Set up custom commands
3. Configure preferences
4. Add platform-specific optimizations

### Advanced Path
1. Build skill libraries
2. Create complex workflows
3. Integrate with external tools
4. Contribute to community

---

## Resources

- **README.md** - System overview
- **AI-DETECTION.md** - For AI assistants
- **CHEATSHEET.md** - Quick reference
- **Platform Guides** - Platform-specific docs

---

## Community

- **GitHub**: [your-repo]
- **Issues**: [your-repo/issues]
- **Discussions**: [your-repo/discussions]
- **Contributing**: See CONTRIBUTING.md

---

**Version:** 1.0.0  
**Updated:** 2026-02-02  
**License:** MIT

---

Happy customizing! 🚀
