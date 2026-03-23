#!/bin/bash

# Project template generator for academic reading projects
# Creates a project inside ReadingProjects/ for reading papers/textbooks and writing LaTeX notes
#
# Usage:
#   ./create_project.sh <project-name>                           # Auto-detects Dropbox, or local
#   ./create_project.sh --drive <cloud-path> <project-name>      # Literature in cloud storage (manual)

set -e  # Exit on any error

# Get the directory where create_project.sh is located (before changing directories)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ============================================================
# Argument parsing
# ============================================================
DRIVE_PATH=""
POSITIONAL_ARG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --drive)
            DRIVE_PATH="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage:"
            echo "  $0 <project-name>                           # Auto-detects ~/Dropbox/ReadingProjects, or local"
            echo "  $0 --drive <cloud-path> <project-name>      # Literature in cloud storage (manual)"
            echo ""
            echo "Options:"
            echo "  --drive       Cloud storage path for Literature/ (e.g., Google Drive, Dropbox)"
            echo "  -h, --help    Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 MacroTheory"
            echo "  $0 --drive ~/GoogleDrive/Reading MacroTheory"
            exit 0
            ;;
        *)
            POSITIONAL_ARG="$1"
            shift
            ;;
    esac
done

if [ -z "$POSITIONAL_ARG" ]; then
    echo "Error: No project name provided."
    echo "Run '$0 --help' for usage."
    exit 1
fi

PROJECT_NAME="$POSITIONAL_ARG"

echo "Creating reading project: $PROJECT_NAME"

# ============================================================
# Auto-detect Dropbox
# ============================================================

if [ -z "$DRIVE_PATH" ]; then
    DROPBOX_ROOT=""
    for candidate in "$HOME/Dropbox" "$HOME/Library/CloudStorage/Dropbox"; do
        if [ -d "$candidate" ]; then
            DROPBOX_ROOT="$candidate"
            break
        fi
    done

    if [ -n "$DROPBOX_ROOT" ]; then
        DRIVE_PATH="$DROPBOX_ROOT/ReadingProjects"
        mkdir -p "$DRIVE_PATH"
        echo "Auto-detected Dropbox: $DRIVE_PATH"
    fi
fi

# Resolve --drive path
if [ -n "$DRIVE_PATH" ]; then
    DRIVE_PATH="${DRIVE_PATH/#\~/$HOME}"

    if [ ! -d "$DRIVE_PATH" ]; then
        echo "Error: Drive path '$DRIVE_PATH' does not exist."
        echo "Please create it first, or check that your cloud storage is mounted."
        exit 1
    fi

    DRIVE_ABS_PATH="$(cd "$DRIVE_PATH" && pwd)/$PROJECT_NAME"
    echo "Cloud storage: $DRIVE_PATH/$PROJECT_NAME"

    # Detect cloud storage type
    CLOUD_TYPE="cloud storage"
    case "$DRIVE_PATH" in
        *Dropbox*|*dropbox*)                       CLOUD_TYPE="Dropbox" ;;
        *GoogleDrive*|*"Google Drive"*|*gdrive*)   CLOUD_TYPE="Google Drive" ;;
    esac
fi
echo ""

# ============================================================
# Step 0: Global ~/.claude/CLAUDE.md (user-level Claude Code config)
# ============================================================

if [ ! -f "$HOME/.claude/CLAUDE.md" ]; then
    mkdir -p "$HOME/.claude"
    if [ -f "$SCRIPT_DIR/CLAUDE-global-template.md" ]; then
        cp "$SCRIPT_DIR/CLAUDE-global-template.md" "$HOME/.claude/CLAUDE.md"
        echo "Installed ~/.claude/CLAUDE.md (global Claude Code instructions)"
        echo "  Edit the 'Who I Am' section to personalize it."
    fi
else
    echo "~/.claude/CLAUDE.md already exists — skipping."
fi

# Check for ResearchHub (optional, needed for research-junshi and method-tracker)
RESEARCHHUB_DIR="$HOME/vscodeproject/ResearchHub"
if [ ! -d "$RESEARCHHUB_DIR" ]; then
    echo ""
    echo "Note: ResearchHub not found at $RESEARCHHUB_DIR"
    echo "  For cross-project features (research-junshi, method-tracker), set up ResearchHub:"
    echo "  git clone https://github.com/mArc0v0mag1c/ResearchHub.git $RESEARCHHUB_DIR"
    echo "  Skills will work without it, but cross-project features will be limited."
    echo ""
fi

# ============================================================
# Step 1: Create project directory inside ReadingProjects/
# ============================================================

mkdir -p "$SCRIPT_DIR/ReadingProjects/$PROJECT_NAME"

# Create root CLAUDE.md for ReadingProjects/ if it doesn't exist
if [ ! -f "$SCRIPT_DIR/ReadingProjects/CLAUDE.md" ] && [ -f "$SCRIPT_DIR/CLAUDE-root-template.md" ]; then
    cp "$SCRIPT_DIR/CLAUDE-root-template.md" "$SCRIPT_DIR/ReadingProjects/CLAUDE.md"
    echo "Created ReadingProjects/CLAUDE.md (root instructions)"
fi

cd "$SCRIPT_DIR/ReadingProjects/$PROJECT_NAME"

echo "Creating project directories..."
mkdir -p Notes/Brainstorm Extracted Literature Output

# Symlink Output/STYLE-GUIDE.md to config
if [ ! -e Output/STYLE-GUIDE.md ]; then
    ln -s ../../../config/STYLE-GUIDE.md Output/STYLE-GUIDE.md
    echo "Linked Output/STYLE-GUIDE.md -> config/"
fi

# Copy Output/references.bib
if [ -f "$SCRIPT_DIR/ReadingExample/Output/references.bib" ]; then
    if [ ! -f Output/references.bib ]; then
        cp "$SCRIPT_DIR/ReadingExample/Output/references.bib" Output/references.bib
        echo "Copied Output/references.bib"
    fi
fi

# ============================================================
# Step 2: READING-LOG.md
# ============================================================

echo "Creating reading log..."
if [ ! -f READING-LOG.md ]; then
    cat > READING-LOG.md << 'READINGLOG_EOF'
# Reading Log

## Currently Reading

| Material | Started | Notes | Status |
|----------|---------|-------|--------|

_No readings in progress yet._

## Completed

| Material | Read | Notes | Key Takeaway |
|----------|------|-------|--------------|

_No completed readings yet._

## Up Next

_Add readings you plan to get to:_

READINGLOG_EOF
    echo "Created READING-LOG.md"
fi

# ============================================================
# Step 3: .env template (shared at repo root)
# ============================================================

if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "Creating shared .env template at repo root..."
    cat > "$SCRIPT_DIR/.env" << ENV_EOF
# Shared Environment Variables (all reading projects)
# This file is gitignored — fill in your actual API keys below

# Mistral API (for mistral-pdf-to-markdown skill)
mistral_api_key=your_mistral_api_key_here

# Zotero API (for zotero-paper-reader skill and Zotero MCP)
ZOTERO_API_KEY=your_zotero_api_key_here

# Zotero Library Configuration
ZOTERO_LIBRARY_TYPE=user
ZOTERO_LIBRARY_ID=

# Local Zotero
ZOTERO_LOCAL=false
ENV_EOF
    echo "Created shared .env at repo root"
else
    echo "Shared .env already exists at repo root"
fi

# ============================================================
# Step 4: pyproject.toml
# ============================================================

echo "Creating Python environment..."
if [ -f "$SCRIPT_DIR/ReadingExample/pyproject.toml" ]; then
    cp "$SCRIPT_DIR/ReadingExample/pyproject.toml" pyproject.toml
    sed -i '' "s/readingexample/$(echo $PROJECT_NAME | tr '[:upper:]' '[:lower:]' | tr ' ' '-')/g" pyproject.toml
    sed -i '' "s/ReadingExample/$PROJECT_NAME/g" pyproject.toml
else
    cat > pyproject.toml << EOF
[project]
name = "$(echo $PROJECT_NAME | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
version = "0.1.0"
description = "Academic reading project: $PROJECT_NAME"
readme = "README.md"
requires-python = ">=3.12"
dependencies = []
EOF
fi

# ============================================================
# Step 5: setup_mac.sh
# ============================================================

echo "Creating setup script..."
if [ -f "$SCRIPT_DIR/ReadingExample/setup_mac.sh" ]; then
    cp "$SCRIPT_DIR/ReadingExample/setup_mac.sh" setup_mac.sh
    sed -i '' "s/ReadingExample/$PROJECT_NAME/g" setup_mac.sh
    # Override drive path if --drive was used
    if [ -n "$DRIVE_PATH" ]; then
        sed -i '' "s|DRIVE_PATH=\"\"|DRIVE_PATH=\"${DRIVE_ABS_PATH}\"|" setup_mac.sh
    fi
else
    echo "Warning: ReadingExample/setup_mac.sh not found, creating basic setup_mac.sh"
    cat > setup_mac.sh << 'SETUP_EOF'
#!/bin/bash
set -e
echo "Setting up project..."
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    brew install uv
fi
export UV_PROJECT_ENVIRONMENT="$HOME/.venvs/$(basename "$PWD")"
uv sync
echo "Setup complete!"
SETUP_EOF
fi
chmod +x setup_mac.sh

# ============================================================
# Step 6: CLAUDE.md (root-level only, no per-project CLAUDE.md)
# ============================================================

# Per-project CLAUDE.md is no longer created — the root ReadingProjects/CLAUDE.md
# covers all projects. AGENTS.md symlinks to the root CLAUDE.md for Codex compatibility.
if [ -f "$SCRIPT_DIR/ReadingProjects/CLAUDE.md" ]; then
    ln -sf ../CLAUDE.md AGENTS.md
    echo "Linked AGENTS.md -> ../CLAUDE.md (root)"
fi

# ============================================================
# Step 7: Symlink config (.mcp.json, .claude/, .github/, .gitignore)
# ============================================================

echo "Linking shared configuration..."

# .mcp.json
if [ ! -e .mcp.json ]; then
    ln -s ../../config/.mcp.json .mcp.json
    echo "Linked .mcp.json -> config/"
fi

# .claude/ (agents, skills, settings)
if [ ! -e .claude ]; then
    ln -s ../../config/.claude .claude
    echo "Linked .claude/ -> config/"
fi

# .github/ (PR template)
if [ ! -e .github ]; then
    ln -s ../../config/.github .github
    echo "Linked .github/ -> config/"
fi

# .vscode/ (LaTeX Workshop settings with auto-copy)
if [ ! -e .vscode ]; then
    ln -s ../../config/.vscode .vscode
    echo "Linked .vscode/ -> config/"
fi

# .gitignore — handled by ReadingProjects root .gitignore (no per-project symlink needed)

# ============================================================
# Step 8: Symlinks (only when --drive is used)
# ============================================================

if [ -n "$DRIVE_PATH" ]; then
    echo "Setting up cloud storage symlinks..."

    # Create cloud directories
    mkdir -p "$DRIVE_ABS_PATH/Literature"
    mkdir -p "$DRIVE_ABS_PATH/Compiled"

    # Replace local Literature/ with symlink
    if [ -d "./Literature" ] && [ ! -L "./Literature" ]; then
        rmdir "./Literature" 2>/dev/null || true
    fi
    if [ ! -L "./Literature" ]; then
        ln -s "$DRIVE_ABS_PATH/Literature" "./Literature"
        echo "Created symlink: ./Literature -> $DRIVE_ABS_PATH/Literature"
    fi

    # Symlink Output/Compiled/ to Dropbox
    if [ ! -L "./Output/Compiled" ]; then
        ln -s "$DRIVE_ABS_PATH/Compiled" "./Output/Compiled"
        echo "Created symlink: ./Output/Compiled -> $DRIVE_ABS_PATH/Compiled"
    fi
fi

# ============================================================
# Step 10: Run setup
# ============================================================

echo ""
echo "Running automatic setup..."
./setup_mac.sh

# ============================================================
# Summary
# ============================================================

echo ""
echo "Reading project created successfully!"
echo ""
echo "Project structure:"
echo "  ReadingProjects/$PROJECT_NAME/"
echo "    ├── Notes/                 - Markdown discussion notes (git-tracked)"
echo "    ├── Extracted/             - PDF-to-markdown extractions (git-tracked)"
echo "    ├── Output/                - LaTeX notes (git-tracked; PDFs gitignored)"
if [ -n "$DRIVE_PATH" ]; then
    echo "    ├── Literature/          - PDFs ($CLOUD_TYPE, symlinked)"
else
    echo "    ├── Literature/          - PDFs (gitignored, local)"
fi
echo "    ├── READING-LOG.md         - Reading tracker"
echo "    ├── CLAUDE.md              - AI instructions"
echo "    └── (symlinked from config/: .claude/, .mcp.json, .github/, .vscode/)"
echo ""
echo "Shared resources (repo root):"
echo "    ├── .env                   - API keys (all projects)"
echo "    └── config/                - Skills, agents, scripts, templates"
echo ""
echo "Next steps:"
echo "1. Fill in API keys: edit .env at the repo root"
if [ -n "$DRIVE_PATH" ]; then
    echo "2. Literature/ is synced via $CLOUD_TYPE at: $DRIVE_ABS_PATH"
    echo "3. Compiled PDFs auto-copy to Dropbox via Output/Compiled/ on every build"
else
    echo "2. Optionally sync Literature/ via cloud storage"
fi
echo "4. Place PDFs in Literature/ and start taking notes!"
