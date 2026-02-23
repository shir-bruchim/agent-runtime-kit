# AI Configuration System
## Universal Setup for Claude, Cursor, and Other AI Assistants

> **🤖 AI Auto-Detection**: This configuration system automatically detects which AI assistant is reading this file and adapts accordingly.

---

## 🎯 Quick Auto-Setup

### For AI Assistants Reading This

**If you're Claude:**
- Clone this to: `~/.claude/` or `/home/claude/.claude/`
- Use skills, commands, hooks, preferences, and templates as designed
- Follow Claude-specific patterns in documentation

**If you're Cursor:**
- Clone this to: `.cursor/` in the project root
- Adapt skills to Cursor's code-focused capabilities
- Use inline commands and workspace-aware features
- Follow Cursor-specific patterns for code intelligence

**If you're another AI:**
- Clone this to: `.ai-config/` or appropriate location
- Adapt patterns to your specific capabilities
- Follow the generic patterns and customize

### Detection Script

```bash
# Auto-detect and setup
if command -v claude &> /dev/null; then
    TARGET_DIR="$HOME/.claude"
elif [ -f ".cursor" ] || [ -d ".cursor" ]; then
    TARGET_DIR=".cursor"
else
    TARGET_DIR=".ai-config"
fi

# Clone repository
git clone <repo-url> "$TARGET_DIR"
cd "$TARGET_DIR"

# Run setup
./setup.sh
```

---

## 📁 Universal Folder Structure

```
.ai-config/  (or .claude/ or .cursor/)
│
├── README.md                    # This file - AI reads this first
├── AI-DETECTION.md              # How AIs should detect their environment
├── GETTING-STARTED.md           # Universal getting started guide
├── CHEATSHEET.md                # Quick reference
│
├── skills/                      # Reusable knowledge & workflows
│   ├── README.md               
│   ├── _template/              # Universal template
│   ├── universal/              # Works for any AI
│   ├── claude-specific/        # Claude optimizations
│   └── cursor-specific/        # Cursor optimizations
│
├── commands/                    # Quick shortcuts
│   ├── README.md
│   ├── universal/              # Works for any AI
│   └── platform-specific/      # Platform adaptations
│
├── hooks/                       # Event-based automation
│   ├── README.md
│   ├── universal/              # Generic hooks
│   └── platform-specific/      # Platform adaptations
│
├── preferences/                 # Configuration & settings
│   ├── README.md
│   ├── base-preferences.yml    # Universal defaults
│   ├── claude-preferences.yml  # Claude-specific
│   └── cursor-preferences.yml  # Cursor-specific
│
├── templates/                   # Reusable structures
│   ├── README.md
│   └── universal/              # Cross-platform templates
│
└── scripts/                     # Setup & utility scripts
    ├── setup.sh                # Auto-detection & setup
    ├── detect-ai.sh            # AI detection script
    └── migrate.sh              # Migration helper
```

---

## 🔍 AI Self-Detection Guide

### For AIs: How to Detect Your Environment

**Detection Checklist:**

1. **Check Context Variables**
   ```
   - Running in claude.ai interface? → Claude
   - Running in VS Code with Cursor? → Cursor  
   - Running in terminal/API? → Determine by capabilities
   ```

2. **Check File System**
   ```bash
   # Claude indicators
   - /mnt/skills/public/ exists
   - /mnt/user-data/ exists
   - Running in container environment
   
   # Cursor indicators
   - .cursor/ directory exists
   - .vscode/ directory exists
   - Project workspace context
   
   # Generic indicators
   - .git/ exists → Project-based
   - No special paths → Generic setup
   ```

3. **Check Capabilities**
   ```
   Claude:
   - web_search tool available
   - bash_tool in container
   - create_file, view, str_replace tools
   - Artifact creation
   
   Cursor:
   - Code completion
   - Workspace file access
   - Terminal integration
   - Git integration
   ```

4. **Read Configuration File**
   ```yaml
   # ai-config.yml (you should check this first!)
   platform: "auto"  # or "claude", "cursor", "generic"
   
   # If auto, detect based on above checklist
   ```

### AI Action Plan

When an AI assistant reads this README, it should:

1. **FIRST**: Read `AI-DETECTION.md` to understand detection logic
2. **DETECT**: Determine which AI platform it is running on
3. **ADAPT**: Load appropriate configuration files
4. **INITIALIZE**: Set up the correct folder structure
5. **NOTIFY**: Inform the user of successful setup

---

## 🚀 User Quick Start

### Installation

**Option 1: Auto Setup (Recommended)**
```bash
# Download and auto-setup
curl -sSL https://your-repo/setup.sh | bash

# Or with git
git clone https://github.com/your-username/agent-runtime-kit.git
cd agent-runtime-kit
./scripts/setup.sh
```

**Option 2: Manual Setup**

**For Claude Users:**
```bash
git clone <repo-url> ~/.claude
cd ~/.claude
```

**For Cursor Users:**
```bash
cd your-project
git clone <repo-url> .cursor
cd .cursor
```

**For Other AI Users:**
```bash
git clone <repo-url> .ai-config
cd .ai-config
```

---

## 🎨 Platform-Specific Features

### Claude Features
- ✅ Web search integration
- ✅ Multi-file creation
- ✅ Document generation (DOCX, PPTX, PDF)
- ✅ Conversation-level hooks
- ✅ Artifact creation
- ✅ Memory system

### Cursor Features
- ✅ Code completion enhancement
- ✅ Workspace awareness
- ✅ Multi-file refactoring
- ✅ Git integration
- ✅ Terminal commands
- ✅ LSP integration

### Universal Features (All Platforms)
- ✅ Custom skills
- ✅ Command shortcuts
- ✅ Template system
- ✅ Preference management
- ✅ Documentation generation

---

## 📖 Documentation Structure

### Essential Reading Order

1. **README.md** (this file) - Overview and setup
2. **AI-DETECTION.md** - For AI assistants
3. **GETTING-STARTED.md** - Detailed walkthrough
4. **CHEATSHEET.md** - Quick reference

### Detailed Guides

- `skills/README.md` - Creating custom skills
- `commands/README.md` - Setting up commands
- `hooks/README.md` - Automation triggers
- `preferences/README.md` - Configuration options
- `templates/README.md` - Template system

---

## 🔧 Configuration

### Basic Configuration File

Create `ai-config.yml` in the root:

```yaml
# AI Platform Configuration
platform: "auto"  # auto, claude, cursor, or generic

# Auto-detection preferences
detection:
  prefer_claude_paths: true
  prefer_cursor_workspace: true
  fallback: "generic"

# Feature flags
features:
  skills: true
  commands: true
  hooks: true
  templates: true
  web_search: auto  # true for Claude, false for Cursor
  workspace_integration: auto  # true for Cursor, false for Claude

# Paths (auto-configured based on platform)
paths:
  skills: "skills/"
  commands: "commands/"
  hooks: "hooks/"
  preferences: "preferences/"
  templates: "templates/"
  outputs: "auto"  # Platform-specific output location

# Performance
performance:
  cache_skills: true
  preload_common_skills: true
  lazy_load_large_skills: false

# User preferences
user:
  name: "User"
  experience_level: "intermediate"  # beginner, intermediate, advanced
  primary_use_case: "development"  # development, writing, analysis, general
```

---

## 🌟 Key Concepts

### Skills (Universal)
Reusable knowledge bundles that work across platforms. Each skill adapts to the AI's capabilities.

**Example:**
- **Claude**: Uses web_search and document creation
- **Cursor**: Uses file system access and code intelligence
- **Generic**: Uses available tools only

### Commands (Universal)
Quick shortcuts that trigger workflows. Syntax adapts to platform.

**Example:**
- **Claude**: `/review` triggers code review skill
- **Cursor**: `@review` or `!review` triggers code review
- **Generic**: `#review` or configurable trigger

### Hooks (Platform-Specific)
Automatic triggers based on events.

**Example:**
- **Claude**: Triggers on file upload
- **Cursor**: Triggers on file save/open
- **Generic**: Triggers on manual activation

### Preferences (Universal)
Configuration that adapts to platform capabilities.

### Templates (Universal)
Reusable structures that work everywhere.

---

## 🔄 Migration Between Platforms

### Claude → Cursor
```bash
./scripts/migrate.sh --from claude --to cursor
```

### Cursor → Claude
```bash
./scripts/migrate.sh --from cursor --to claude
```

### Any → Generic
```bash
./scripts/migrate.sh --to generic
```

---

## 🤝 Contributing

This is a community-driven project. Contributions welcome for:

- New universal skills
- Platform-specific optimizations
- Documentation improvements
- Bug fixes
- Feature requests

### Adding Platform Support

1. Create platform-specific folder structure
2. Add detection logic to `scripts/detect-ai.sh`
3. Document platform capabilities
4. Create example configurations
5. Submit PR

---

## 📚 Examples

### Universal Code Review Skill
Works on Claude (with web search), Cursor (with LSP), and others.

### Universal Document Templates
Adapts to platform's document creation capabilities.

### Universal Command System
Consistent interface across all platforms.

---

## ⚙️ Advanced Configuration

### Multi-Platform Setup
Use the same config for both Claude and Cursor:

```bash
# Symlink approach
ln -s ~/.ai-config ~/.claude
ln -s ~/.ai-config ~/project/.cursor
```

### Workspace-Specific Config
Override global config for specific projects:

```
project/
├── .cursor/
│   └── ai-config.yml  # Project-specific overrides
└── .ai-config/
    └── ai-config.yml  # Global config
```

---

## 🆘 Support

**For Users:**
- Check `GETTING-STARTED.md` for detailed setup
- See `CHEATSHEET.md` for quick reference
- Review platform-specific docs

**For AI Assistants:**
- Read `AI-DETECTION.md` first
- Follow auto-detection logic
- Adapt to platform capabilities
- Inform user of setup status

---

## 📝 License

MIT License - Use freely, contribute back!

---

## 🗺️ Roadmap

- [x] Universal folder structure
- [x] Claude support
- [x] Cursor support
- [ ] GitHub Copilot support
- [ ] VS Code + Continue support
- [ ] Cody support
- [ ] Generic API support
- [ ] Cloud sync
- [ ] Team sharing features

---

**Version:** 1.0.0  
**Last Updated:** 2026-02-02  
**Compatible With:** Claude 4.5, Cursor 0.40+, Generic AI Systems

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│  PLATFORM DETECTION                                         │
├─────────────────────────────────────────────────────────────┤
│  Claude:   Check /mnt/skills/, web_search tool             │
│  Cursor:   Check .cursor/, workspace context               │
│  Generic:  No special indicators                           │
├─────────────────────────────────────────────────────────────┤
│  SETUP LOCATIONS                                            │
├─────────────────────────────────────────────────────────────┤
│  Claude:   ~/.claude/ or /home/claude/.claude/             │
│  Cursor:   .cursor/ (project root)                         │
│  Generic:  .ai-config/ or ~/.ai-config/                    │
├─────────────────────────────────────────────────────────────┤
│  FIRST STEPS                                                │
├─────────────────────────────────────────────────────────────┤
│  1. AI: Read AI-DETECTION.md                               │
│  2. AI: Detect platform                                     │
│  3. AI: Load appropriate config                            │
│  4. AI: Set up folder structure                            │
│  5. AI: Notify user of setup                               │
└─────────────────────────────────────────────────────────────┘
```

**🎯 Next Steps:**
1. AI: Read `AI-DETECTION.md` 
2. User: Run `./scripts/setup.sh`
3. Everyone: Customize to your needs!
