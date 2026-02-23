#!/bin/bash

# AI Configuration System - Auto Setup Script
# This script automatically detects the AI platform and sets up the configuration

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║         AI Configuration System - Auto Setup              ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Detect AI Platform
detect_platform() {
    print_info "Detecting AI platform..."
    
    # Check for Claude
    if [ -d "/mnt/skills/public" ] || [ -d "/mnt/user-data" ]; then
        echo "claude"
        return
    fi
    
    # Check for Cursor
    if [ -d ".cursor" ] || [ -n "$CURSOR_SESSION" ] || [ -n "$VSCODE_PID" ]; then
        echo "cursor"
        return
    fi
    
    # Check if running in Claude container
    if [ -d "/home/claude" ] && [ "$(whoami)" = "claude" ]; then
        echo "claude"
        return
    fi
    
    # Default to generic
    echo "generic"
}

# Get target directory based on platform
get_target_dir() {
    local platform=$1
    
    case $platform in
        claude)
            if [ -d "/home/claude" ]; then
                echo "/home/claude/.claude"
            else
                echo "$HOME/.claude"
            fi
            ;;
        cursor)
            echo ".cursor"
            ;;
        generic)
            echo ".ai-config"
            ;;
        *)
            echo ".ai-config"
            ;;
    esac
}

# Create folder structure
create_structure() {
    local target=$1
    
    print_info "Creating folder structure in $target..."
    
    mkdir -p "$target"/{skills,commands,hooks,preferences,templates}
    mkdir -p "$target"/scripts
    
    print_success "Folder structure created"
}

# Copy files based on platform
copy_files() {
    local platform=$1
    local target=$2
    local source_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
    
    print_info "Copying configuration files..."
    
    # Copy main documentation
    cp "$source_dir/README.md" "$target/"
    cp "$source_dir/AI-DETECTION.md" "$target/"
    cp "$source_dir/GETTING-STARTED.md" "$target/"
    cp "$source_dir/CHEATSHEET.md" "$target/"
    
    # Copy universal skills
    if [ -d "$source_dir/skills/universal" ]; then
        cp -r "$source_dir/skills/universal/"* "$target/skills/" 2>/dev/null || true
    fi
    
    # Copy platform-specific skills
    if [ -d "$source_dir/skills/${platform}-specific" ]; then
        cp -r "$source_dir/skills/${platform}-specific/"* "$target/skills/" 2>/dev/null || true
    fi
    
    # Copy commands
    if [ -d "$source_dir/commands/universal" ]; then
        cp -r "$source_dir/commands/universal/"* "$target/commands/" 2>/dev/null || true
    fi
    
    if [ -d "$source_dir/commands/${platform}-specific" ]; then
        cp -r "$source_dir/commands/${platform}-specific/"* "$target/commands/" 2>/dev/null || true
    fi
    
    # Copy hooks
    if [ -d "$source_dir/hooks/universal" ]; then
        cp -r "$source_dir/hooks/universal/"* "$target/hooks/" 2>/dev/null || true
    fi
    
    if [ -d "$source_dir/hooks/${platform}-specific" ]; then
        cp -r "$source_dir/hooks/${platform}-specific/"* "$target/hooks/" 2>/dev/null || true
    fi
    
    # Copy preferences
    if [ -f "$source_dir/preferences/${platform}-preferences.yml" ]; then
        cp "$source_dir/preferences/${platform}-preferences.yml" "$target/preferences/preferences.yml"
    else
        cp "$source_dir/preferences/base-preferences.yml" "$target/preferences/preferences.yml"
    fi
    
    # Copy templates
    if [ -d "$source_dir/templates/universal" ]; then
        cp -r "$source_dir/templates/universal/"* "$target/templates/" 2>/dev/null || true
    fi
    
    # Copy scripts
    cp -r "$source_dir/scripts/"* "$target/scripts/" 2>/dev/null || true
    chmod +x "$target/scripts/"*.sh 2>/dev/null || true
    
    print_success "Files copied"
}

# Create configuration file
create_config() {
    local platform=$1
    local target=$2
    
    print_info "Creating configuration file..."
    
    cat > "$target/ai-config.yml" << EOF
# AI Configuration System
# Auto-generated on $(date)

platform: "$platform"
version: "1.0.0"

paths:
  skills: "skills/"
  commands: "commands/"
  hooks: "hooks/"
  preferences: "preferences/"
  templates: "templates/"

features:
  skills: true
  commands: true
  hooks: true
  templates: true
  
detection:
  auto_detect: true
  platform_override: null
EOF
    
    print_success "Configuration file created"
}

# Platform-specific setup
platform_setup() {
    local platform=$1
    local target=$2
    
    case $platform in
        claude)
            print_info "Applying Claude-specific configuration..."
            # Claude-specific setup
            ;;
        cursor)
            print_info "Applying Cursor-specific configuration..."
            # Cursor-specific setup
            ;;
        generic)
            print_info "Applying generic configuration..."
            # Generic setup
            ;;
    esac
}

# Main installation
main() {
    echo ""
    
    # Detect platform
    PLATFORM=$(detect_platform)
    print_success "Platform detected: ${YELLOW}${PLATFORM}${NC}"
    
    # Get target directory
    TARGET_DIR=$(get_target_dir "$PLATFORM")
    print_info "Installation directory: ${YELLOW}${TARGET_DIR}${NC}"
    
    # Confirm with user
    echo ""
    read -p "Continue with installation? (y/n) " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Installation cancelled"
        exit 0
    fi
    
    echo ""
    
    # Create structure
    create_structure "$TARGET_DIR"
    
    # Copy files
    copy_files "$PLATFORM" "$TARGET_DIR"
    
    # Create config
    create_config "$PLATFORM" "$TARGET_DIR"
    
    # Platform-specific setup
    platform_setup "$PLATFORM" "$TARGET_DIR"
    
    # Success message
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                           ║${NC}"
    echo -e "${GREEN}║              ✓ Installation Complete!                    ║${NC}"
    echo -e "${GREEN}║                                                           ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    print_info "Platform: ${YELLOW}${PLATFORM}${NC}"
    print_info "Location: ${YELLOW}${TARGET_DIR}${NC}"
    
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo "  1. Explore skills: ${TARGET_DIR}/skills/"
    echo "  2. Try commands: Check ${TARGET_DIR}/commands/"
    echo "  3. Read guide: ${TARGET_DIR}/GETTING-STARTED.md"
    echo "  4. Customize: ${TARGET_DIR}/preferences/preferences.yml"
    
    if [ "$PLATFORM" = "claude" ]; then
        echo ""
        echo -e "${BLUE}Quick Test:${NC}"
        echo "  Upload a file and see the auto-analysis hook trigger!"
    elif [ "$PLATFORM" = "cursor" ]; then
        echo ""
        echo -e "${BLUE}Quick Test:${NC}"
        echo "  Save a code file to trigger file watching hooks!"
    fi
    
    echo ""
}

# Run main
main
