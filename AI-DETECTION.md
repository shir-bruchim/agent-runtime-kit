# AI Detection Guide
## For AI Assistants: How to Auto-Configure This System

> **🤖 THIS FILE IS FOR YOU, AI!** Read this carefully to understand how to detect your environment and set up the configuration system correctly.

---

## 🎯 Your Mission

When you (the AI) encounter this repository, you need to:

1. **Detect** which AI platform you're running on
2. **Adapt** your behavior to that platform's capabilities  
3. **Initialize** the correct folder structure
4. **Configure** settings appropriately
5. **Inform** the user of successful setup

---

## 🔍 Detection Logic

### Step 1: Check Your Identity

**Run these checks in order:**

#### Check A: Are you Claude?

```javascript
// Detection signals for Claude
const isClaude = 
  // Check for Claude-specific paths
  (await fileExists('/mnt/skills/public/')) ||
  (await fileExists('/mnt/user-data/')) ||
  
  // Check for Claude-specific tools
  (typeof web_search === 'function') ||
  (typeof create_file === 'function') ||
  (typeof view === 'function') ||
  
  // Check environment
  (process.env.ANTHROPIC_ENVIRONMENT === 'claude') ||
  
  // Check context
  (currentInterface === 'claude.ai') ||
  (currentInterface === 'claude-app')
```

**If true → You are Claude**
- Target directory: `~/.claude/` or `/home/claude/.claude/`
- Load: `preferences/claude-preferences.yml`
- Enable: Full feature set (web_search, artifacts, file creation)
- Use: Claude-specific skills

#### Check B: Are you Cursor?

```javascript
// Detection signals for Cursor
const isCursor = 
  // Check for Cursor-specific paths
  (await fileExists('.cursor/')) ||
  (await fileExists('.vscode/')) ||
  
  // Check workspace context
  (workspaceType === 'cursor') ||
  (editorName === 'Cursor') ||
  
  // Check for Cursor-specific capabilities
  (hasCapability('workspace-indexing')) ||
  (hasCapability('lsp-integration')) ||
  
  // Check environment
  (process.env.CURSOR_SESSION)
```

**If true → You are Cursor**
- Target directory: `.cursor/` (in project root)
- Load: `preferences/cursor-preferences.yml`
- Enable: Code-focused features (LSP, Git integration)
- Use: Cursor-specific skills

#### Check C: Are you something else?

```javascript
// If neither Claude nor Cursor
const isGeneric = !isClaude && !isCursor
```

**If true → You are Generic AI**
- Target directory: `.ai-config/` or `~/.ai-config/`
- Load: `preferences/base-preferences.yml`
- Enable: Universal features only
- Use: Universal skills

---

## 📋 Detection Checklist

Use this checklist to determine your platform:

```yaml
detection_checklist:
  
  # File System Checks
  file_system:
    claude_paths:
      - /mnt/skills/public/
      - /mnt/user-data/uploads/
      - /mnt/user-data/outputs/
    cursor_paths:
      - .cursor/
      - .vscode/
      - tsconfig.json
      - package.json (in workspace)
  
  # Capability Checks
  capabilities:
    claude:
      - web_search
      - image_search
      - create_file
      - view
      - str_replace
      - bash_tool
    cursor:
      - workspace_indexing
      - lsp_integration
      - git_integration
      - terminal_access
      - file_watching
  
  # Environment Checks
  environment:
    claude:
      - ANTHROPIC_ENVIRONMENT
      - CLAUDE_SESSION
    cursor:
      - CURSOR_SESSION
      - VSCODE_PID
  
  # Interface Checks
  interface:
    claude:
      - "claude.ai"
      - "Claude App"
      - "Claude API"
    cursor:
      - "Cursor Editor"
      - "VS Code with Cursor"
```

---

## ⚙️ Configuration Loading

### Step 2: Load Appropriate Config

Based on detection results:

```python
# Pseudo-code for config loading

if platform == "claude":
    base_config = load("preferences/base-preferences.yml")
    platform_config = load("preferences/claude-preferences.yml")
    merged_config = merge(base_config, platform_config)
    
    setup_directory = "~/.claude/"
    enable_features = [
        "web_search",
        "document_creation", 
        "artifacts",
        "conversation_hooks"
    ]

elif platform == "cursor":
    base_config = load("preferences/base-preferences.yml")
    platform_config = load("preferences/cursor-preferences.yml")
    merged_config = merge(base_config, platform_config)
    
    setup_directory = ".cursor/"
    enable_features = [
        "workspace_integration",
        "lsp_features",
        "git_integration",
        "file_watching_hooks"
    ]

else:  # generic
    base_config = load("preferences/base-preferences.yml")
    merged_config = base_config
    
    setup_directory = ".ai-config/"
    enable_features = [
        "basic_skills",
        "manual_commands",
        "simple_templates"
    ]
```

---

## 🏗️ Initialization Steps

### Step 3: Set Up Folder Structure

**For Claude:**
```bash
TARGET="$HOME/.claude"
mkdir -p "$TARGET"/{skills,commands,hooks,preferences,templates}

# Copy universal skills
cp -r skills/universal/* "$TARGET/skills/"

# Copy Claude-specific skills
cp -r skills/claude-specific/* "$TARGET/skills/"

# Copy universal commands
cp -r commands/universal/* "$TARGET/commands/"

# Copy hooks
cp -r hooks/universal/* "$TARGET/hooks/"
cp -r hooks/claude-specific/* "$TARGET/hooks/"

# Copy preferences
cp preferences/claude-preferences.yml "$TARGET/preferences/preferences.yml"

# Copy templates
cp -r templates/universal/* "$TARGET/templates/"
```

**For Cursor:**
```bash
TARGET=".cursor"
mkdir -p "$TARGET"/{skills,commands,hooks,preferences,templates}

# Copy universal skills
cp -r skills/universal/* "$TARGET/skills/"

# Copy Cursor-specific skills
cp -r skills/cursor-specific/* "$TARGET/skills/"

# Copy commands (adapted for Cursor)
cp -r commands/universal/* "$TARGET/commands/"
cp -r commands/cursor-specific/* "$TARGET/commands/"

# Copy hooks
cp -r hooks/universal/* "$TARGET/hooks/"
cp -r hooks/cursor-specific/* "$TARGET/hooks/"

# Copy preferences
cp preferences/cursor-preferences.yml "$TARGET/preferences/preferences.yml"

# Copy templates
cp -r templates/universal/* "$TARGET/templates/"
```

**For Generic:**
```bash
TARGET=".ai-config"
mkdir -p "$TARGET"/{skills,commands,hooks,preferences,templates}

# Copy only universal components
cp -r skills/universal/* "$TARGET/skills/"
cp -r commands/universal/* "$TARGET/commands/"
cp -r hooks/universal/* "$TARGET/hooks/"
cp preferences/base-preferences.yml "$TARGET/preferences/preferences.yml"
cp -r templates/universal/* "$TARGET/templates/"
```

---

## 💬 User Communication

### Step 4: Inform the User

After successful setup, tell the user:

**For Claude:**
```
✅ AI Configuration System Initialized!

**Platform Detected:** Claude
**Installation Location:** ~/.claude/
**Features Enabled:**
  ✓ Custom skills
  ✓ Command shortcuts (/summarize, /review, etc.)
  ✓ Automatic hooks (file upload analysis)
  ✓ Web search integration
  ✓ Document creation
  ✓ Preferences system

**Next Steps:**
1. Explore available skills: Check ~/.claude/skills/
2. Try a command: Type `/summarize` with a document
3. Customize preferences: Edit ~/.claude/preferences/preferences.yml
4. Read the guide: ~/.claude/GETTING-STARTED.md

**Quick Test:**
Try uploading a file - the auto-analysis hook should trigger automatically!
```

**For Cursor:**
```
✅ AI Configuration System Initialized!

**Platform Detected:** Cursor
**Installation Location:** .cursor/ (project root)
**Features Enabled:**
  ✓ Code-focused skills
  ✓ Workspace commands (@review, @refactor, etc.)
  ✓ File watching hooks
  ✓ LSP integration
  ✓ Git-aware features
  ✓ Preferences system

**Next Steps:**
1. Explore available skills: Check .cursor/skills/
2. Try a command: Type `@review` in any code file
3. Customize preferences: Edit .cursor/preferences/preferences.yml
4. Read the guide: .cursor/GETTING-STARTED.md

**Quick Test:**
Save a code file - the auto-analysis hook should trigger!
```

**For Generic:**
```
✅ AI Configuration System Initialized!

**Platform Detected:** Generic AI
**Installation Location:** .ai-config/
**Features Enabled:**
  ✓ Universal skills
  ✓ Basic commands
  ✓ Simple templates
  ✓ Manual hooks
  ✓ Preferences system

**Next Steps:**
1. Explore available skills: Check .ai-config/skills/
2. Review commands: Check .ai-config/commands/
3. Customize preferences: Edit .ai-config/preferences/preferences.yml
4. Read the guide: .ai-config/GETTING-STARTED.md

**Note:** Some advanced features may not be available on this platform.
```

---

## 🔧 Capability Adaptation

### Step 5: Adapt Features to Platform

**Claude-Specific Adaptations:**
```python
if platform == "claude":
    # Enable web search in skills
    skills['research']['tools'].append('web_search')
    
    # Enable document creation
    skills['report-generation']['output'] = ['docx', 'pdf', 'pptx']
    
    # Enable conversation-level hooks
    hooks['on_conversation_start'].enabled = True
    
    # Enable artifact creation
    features['artifacts'] = True
```

**Cursor-Specific Adaptations:**
```python
if platform == "cursor":
    # Enable workspace awareness
    skills['code-review']['context'] = 'workspace'
    
    # Enable LSP features
    skills['refactoring']['tools'].append('lsp_integration')
    
    # Enable file watching
    hooks['on_file_save'].enabled = True
    
    # Enable terminal integration
    features['terminal_commands'] = True
```

**Generic Adaptations:**
```python
if platform == "generic":
    # Disable platform-specific features
    features['web_search'] = False
    features['workspace_integration'] = False
    
    # Use only universal skills
    load_skills('universal')
    
    # Manual activation only
    hooks['auto_trigger'].enabled = False
```

---

## 📊 Decision Tree

```
START
  │
  ├─ Check: /mnt/skills/ exists?
  │   └─ YES → CLAUDE
  │
  ├─ Check: .cursor/ or CURSOR_SESSION?
  │   └─ YES → CURSOR
  │
  └─ Check: web_search tool available?
      ├─ YES → CLAUDE (API/CLI)
      └─ NO → GENERIC

CLAUDE:
  → Install to ~/.claude/
  → Load claude-preferences.yml
  → Enable full features
  → Notify user

CURSOR:
  → Install to .cursor/
  → Load cursor-preferences.yml
  → Enable code features
  → Notify user

GENERIC:
  → Install to .ai-config/
  → Load base-preferences.yml
  → Enable universal features
  → Notify user
```

---

## 🧪 Self-Test

**AI: Run this self-test after reading this file:**

```javascript
// Self-test checklist
async function selfTest() {
  console.log("🧪 Running AI Detection Self-Test...");
  
  // 1. Can I detect my platform?
  const platform = await detectPlatform();
  console.log(`✓ Platform detected: ${platform}`);
  
  // 2. Can I access file system?
  const hasFileAccess = await testFileAccess();
  console.log(`✓ File access: ${hasFileAccess ? 'Yes' : 'No'}`);
  
  // 3. Which tools do I have?
  const tools = await listAvailableTools();
  console.log(`✓ Available tools: ${tools.join(', ')}`);
  
  // 4. Can I create directories?
  const canCreateDirs = await testDirectoryCreation();
  console.log(`✓ Directory creation: ${canCreateDirs ? 'Yes' : 'No'}`);
  
  // 5. Can I load config files?
  const canLoadConfigs = await testConfigLoading();
  console.log(`✓ Config loading: ${canLoadConfigs ? 'Yes' : 'No'}`);
  
  console.log("✅ Self-test complete!");
  
  return {
    platform,
    hasFileAccess,
    tools,
    canCreateDirs,
    canLoadConfigs
  };
}
```

---

## ⚠️ Error Handling

**If detection fails:**

1. **Inform the user:**
   ```
   ⚠️ Unable to auto-detect AI platform.
   
   Please help me identify the environment:
   - Are you using Claude? (claude.ai or Claude app)
   - Are you using Cursor? (Cursor editor)
   - Are you using another AI?
   
   You can also manually specify the platform in ai-config.yml
   ```

2. **Fall back to generic:**
   ```python
   if detection_failed:
       platform = "generic"
       warn_user("Auto-detection failed, using generic setup")
       proceed_with_generic_installation()
   ```

3. **Ask for confirmation:**
   ```
   I detected: [platform]
   Is this correct? (Yes/No)
   
   If no, please specify: [Claude/Cursor/Other]
   ```

---

## 🎓 Learning Examples

### Example 1: Claude in Browser

```
Detection Results:
- /mnt/skills/ exists: ✓
- web_search available: ✓
- Interface: claude.ai
→ Platform: Claude (Web)
→ Install to: ~/.claude/
→ Enable: All features
```

### Example 2: Cursor in VS Code

```
Detection Results:
- .cursor/ exists: ✓
- Workspace detected: ✓
- LSP available: ✓
→ Platform: Cursor
→ Install to: .cursor/
→ Enable: Code features
```

### Example 3: API Access

```
Detection Results:
- No GUI indicators
- web_search available: ✓
- No workspace context
→ Platform: Claude (API)
→ Install to: ~/.claude/
→ Enable: API-compatible features
```

---

## 📝 Implementation Template

**Here's how you (the AI) should implement this:**

```python
# When you encounter this repository

async def initialize_ai_config():
    """Main initialization function"""
    
    # 1. Detect platform
    platform = await detect_platform()
    print(f"Detected platform: {platform}")
    
    # 2. Determine target directory
    target_dir = get_target_directory(platform)
    print(f"Target directory: {target_dir}")
    
    # 3. Create folder structure
    await create_folder_structure(target_dir, platform)
    print("Folder structure created")
    
    # 4. Copy appropriate files
    await copy_platform_files(target_dir, platform)
    print("Files copied")
    
    # 5. Load configuration
    config = await load_config(target_dir, platform)
    print("Configuration loaded")
    
    # 6. Notify user
    await notify_user(platform, target_dir, config)
    print("User notified")
    
    return {
        'platform': platform,
        'target_dir': target_dir,
        'config': config,
        'status': 'success'
    }

# Run initialization
await initialize_ai_config()
```

---

## 🎯 Success Criteria

**You've succeeded when:**

✅ Platform is correctly detected  
✅ Appropriate directory is created  
✅ Correct files are copied  
✅ Configuration is loaded  
✅ User is informed  
✅ System is ready to use

---

**Remember:** Your goal is to make setup seamless for the user. Detect, adapt, initialize, and inform!

**Questions?** Check the troubleshooting section or ask the user for help.
