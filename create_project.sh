#!/bin/bash

# Project template generator for academic reading projects
# Creates a project for reading papers/textbooks and writing LaTeX notes
#
# Usage:
#   ./create_project.sh <project-name>                           # Local project
#   ./create_project.sh --drive <cloud-path> <project-name>      # Literature in cloud storage

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
            echo "  $0 <project-name>                           # Local project"
            echo "  $0 --drive <cloud-path> <project-name>      # Literature in cloud storage"
            echo ""
            echo "Options:"
            echo "  --drive       Cloud storage path for Literature/ (e.g., Google Drive, Dropbox)"
            echo "  -h, --help    Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 MacroTheory"
            echo "  $0 --drive ~/Dropbox/Reading MacroTheory"
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

# ============================================================
# Setup
# ============================================================

PROJECT_PATH="$POSITIONAL_ARG"

if [[ "$PROJECT_PATH" == */* ]]; then
    PROJECT_DIR=$(dirname "$PROJECT_PATH")
    PROJECT_NAME=$(basename "$PROJECT_PATH")
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR"
else
    PROJECT_NAME="$PROJECT_PATH"
    PROJECT_DIR="."
fi

echo "Creating reading project: $PROJECT_NAME"
echo "Location: $(pwd)"

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
# Step 1: Create project directory
# ============================================================

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

echo "Creating project directories..."
mkdir -p Notes Extracted Literature Output

# Symlink Output/STYLE-GUIDE.md to shared
if [ ! -e Output/STYLE-GUIDE.md ]; then
    ln -s ../../shared/STYLE-GUIDE.md Output/STYLE-GUIDE.md
    echo "Linked Output/STYLE-GUIDE.md -> shared/"
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
# Step 6: CLAUDE.md
# ============================================================

echo "Creating CLAUDE.md..."
CLAUDE_TEMPLATE="$SCRIPT_DIR/CLAUDE-template.md"

if [ -f "$CLAUDE_TEMPLATE" ]; then
    cp "$CLAUDE_TEMPLATE" CLAUDE.md
    sed -i '' "s/ReadingExample/$PROJECT_NAME/g" CLAUDE.md
    if [ -n "$DRIVE_PATH" ]; then
        sed -i '' "s/synced via cloud storage (e.g., Dropbox, Google Drive)/synced via $CLOUD_TYPE/g" CLAUDE.md
    fi
else
    echo "Warning: CLAUDE template not found, skipping CLAUDE.md creation"
fi

# AGENTS.md symlink
if [ -f "CLAUDE.md" ]; then
    ln -sf CLAUDE.md AGENTS.md
    echo "Created AGENTS.md -> CLAUDE.md symlink"
fi

# ============================================================
# Step 7: Symlink shared config (.mcp.json, .claude/, .github/, .gitignore)
# ============================================================

echo "Linking shared configuration..."

# .mcp.json
if [ ! -e .mcp.json ]; then
    ln -s ../shared/.mcp.json .mcp.json
    echo "Linked .mcp.json -> shared/"
fi

# .claude/ (agents, skills, settings)
if [ ! -e .claude ]; then
    ln -s ../shared/.claude .claude
    echo "Linked .claude/ -> shared/"
fi

# .github/ (PR template)
if [ ! -e .github ]; then
    ln -s ../shared/.github .github
    echo "Linked .github/ -> shared/"
fi

# .gitignore
if [ ! -e .gitignore ]; then
    ln -s ../shared/.gitignore .gitignore
    echo "Linked .gitignore -> shared/"
fi

# ============================================================
# Step 8: README
# ============================================================

echo "Creating README..."
if [ -f "$SCRIPT_DIR/README-template.md" ]; then
    cp "$SCRIPT_DIR/README-template.md" README.md
    sed -i '' "s/ReadingExample/$PROJECT_NAME/g" README.md
else
    echo "# $PROJECT_NAME" > README.md
    echo "" >> README.md
    echo "Academic reading project: $PROJECT_NAME" >> README.md
fi

# ============================================================
# Step 9: Symlinks (only when --drive is used)
# ============================================================

if [ -n "$DRIVE_PATH" ]; then
    echo "Setting up cloud storage symlinks..."

    # Create cloud directory for Literature
    mkdir -p "$DRIVE_ABS_PATH/Literature"

    # Replace local Literature/ with symlink
    if [ -d "./Literature" ] && [ ! -L "./Literature" ]; then
        rmdir "./Literature" 2>/dev/null || true
    fi
    if [ ! -L "./Literature" ]; then
        ln -s "$DRIVE_ABS_PATH/Literature" "./Literature"
        echo "Created symlink: ./Literature -> $DRIVE_ABS_PATH/Literature"
    fi
fi

# ============================================================
# Step 10: Git init
# ============================================================

echo "Initializing git repository..."
git init
echo "Creating test branch..."
git checkout -b test

# ============================================================
# Step 11: Run setup
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
echo "  $PROJECT_NAME/"
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
echo "    ├── pyproject.toml         - Python environment"
echo "    ├── setup_mac.sh           - Setup script"
echo "    ├── README.md              - Setup instructions"
echo "    └── (symlinked from shared/: .claude/, .mcp.json, .gitignore, .github/)"
echo ""
echo "Shared resources (repo root):"
echo "    ├── .env                   - API keys (all projects)"
echo "    ├── scripts/               - Python scripts (all projects)"
echo "    └── shared/                - Config, skills, agents, templates"
echo ""
echo "Branch: test (auto-created — all work happens here, PR to main when ready)"
echo ""
echo "Next steps:"
echo "1. Fill in API keys: edit .env at the repo root"
if [ -n "$DRIVE_PATH" ]; then
    echo "2. Literature/ is synced via $CLOUD_TYPE at: $DRIVE_ABS_PATH"
else
    echo "2. Optionally sync Literature/ and Output/ via cloud storage"
fi
echo "3. Place PDFs in Literature/ and start taking notes!"
