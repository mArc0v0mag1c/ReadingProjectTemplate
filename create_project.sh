#!/bin/bash

# Project template generator for academic reading projects
# Creates a project for reading papers/textbooks and writing LaTeX notes
#
# Usage:
#   ./create_project.sh <project-name>                           # Local project
#   ./create_project.sh --drive <cloud-path> <project-name>      # Literature & Output in cloud storage

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
            echo "  $0 --drive <cloud-path> <project-name>      # Literature & Output in cloud storage"
            echo ""
            echo "Options:"
            echo "  --drive       Cloud storage path for Literature/ and Output/ (e.g., Google Drive, Dropbox)"
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
mkdir -p Notes Extracted Literature Output QuickNotes

# Copy Notes/STYLE-GUIDE.md
if [ -f "$SCRIPT_DIR/ReadingExample/Notes/STYLE-GUIDE.md" ]; then
    if [ ! -f Notes/STYLE-GUIDE.md ]; then
        cp "$SCRIPT_DIR/ReadingExample/Notes/STYLE-GUIDE.md" Notes/STYLE-GUIDE.md
        echo "Copied Notes/STYLE-GUIDE.md"
    fi
fi

# Copy Notes/references.bib
if [ -f "$SCRIPT_DIR/ReadingExample/Notes/references.bib" ]; then
    if [ ! -f Notes/references.bib ]; then
        cp "$SCRIPT_DIR/ReadingExample/Notes/references.bib" Notes/references.bib
        echo "Copied Notes/references.bib"
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
# Step 3: .env template
# ============================================================

echo "Creating .env template..."
if [ ! -f .env ]; then
    cat > .env << ENV_EOF
# Environment Variables for $PROJECT_NAME
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
    echo "Created .env template"
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
# Step 7: .mcp.json
# ============================================================

echo "Copying .mcp.json configuration..."
if [ -f "$SCRIPT_DIR/ReadingExample/.mcp.json" ]; then
    cp "$SCRIPT_DIR/ReadingExample/.mcp.json" .mcp.json
    echo "Copied .mcp.json configuration"
fi

# ============================================================
# Step 8: .claude/ folder (agents, skills, settings)
# ============================================================

echo "Copying .claude configuration..."
if [ -d "$SCRIPT_DIR/ReadingExample/.claude" ]; then
    cp -r "$SCRIPT_DIR/ReadingExample/.claude" .claude
    find .claude -type f \( -name "*.md" -o -name "*.json" \) -exec sed -i '' "s/ReadingExample/$PROJECT_NAME/g" {} \;
    echo "Copied .claude configuration with agents and skills"
fi

# ============================================================
# Step 9: README
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
# Step 10: PR template
# ============================================================

echo "Creating PR template..."
if [ -f "$SCRIPT_DIR/ReadingExample/.github/PULL_REQUEST_TEMPLATE.md" ]; then
    mkdir -p .github
    if [ ! -f .github/PULL_REQUEST_TEMPLATE.md ]; then
        cp "$SCRIPT_DIR/ReadingExample/.github/PULL_REQUEST_TEMPLATE.md" .github/PULL_REQUEST_TEMPLATE.md
        echo "Created .github/PULL_REQUEST_TEMPLATE.md"
    fi
fi

# ============================================================
# Step 11: Symlinks (only when --drive is used)
# ============================================================

if [ -n "$DRIVE_PATH" ]; then
    echo "Setting up cloud storage symlinks..."

    # Create cloud directories
    mkdir -p "$DRIVE_ABS_PATH/Literature" "$DRIVE_ABS_PATH/Output"

    # Replace local dirs with symlinks
    for folder_name in Literature Output; do
        if [ -d "./$folder_name" ] && [ ! -L "./$folder_name" ]; then
            rmdir "./$folder_name" 2>/dev/null || true
        fi
        if [ ! -L "./$folder_name" ]; then
            ln -s "$DRIVE_ABS_PATH/$folder_name" "./$folder_name"
            echo "Created symlink: ./$folder_name -> $DRIVE_ABS_PATH/$folder_name"
        fi
    done
fi

# ============================================================
# Step 12: .gitignore
# ============================================================

echo "Creating .gitignore..."
if [ -f "$SCRIPT_DIR/ReadingExample/.gitignore" ]; then
    cp "$SCRIPT_DIR/ReadingExample/.gitignore" .gitignore
else
    echo "Warning: ReadingExample/.gitignore not found, creating basic .gitignore"
    cat > .gitignore << 'EOF'
# Basics
.env
.venv
.DS_Store
Literature
Output
uv.lock
*.pdf
EOF
fi

# ============================================================
# Step 13: Git init
# ============================================================

echo "Initializing git repository..."
git init
echo "Creating test branch..."
git checkout -b test

# ============================================================
# Step 14: Run setup
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
echo "    ├── Notes/                 - LaTeX reading notes (git-tracked)"
echo "    ├── Extracted/             - PDF-to-markdown extractions (git-tracked)"
if [ -n "$DRIVE_PATH" ]; then
    echo "    ├── Literature/              - PDFs ($CLOUD_TYPE, symlinked)"
    echo "    ├── Output/                - Compiled PDF notes ($CLOUD_TYPE, symlinked)"
else
    echo "    ├── Literature/              - PDFs (gitignored, local)"
    echo "    ├── Output/                - Compiled PDF notes (gitignored, local)"
fi
echo "    ├── QuickNotes/            - Lightweight discussion notes (git-tracked)"
echo "    ├── READING-LOG.md         - Reading tracker"
echo "    ├── CLAUDE.md              - AI instructions"
echo "    ├── .env                   - API keys (gitignored)"
echo "    ├── pyproject.toml         - Python environment"
echo "    ├── setup_mac.sh           - Setup script"
echo "    └── README.md              - Setup instructions"
echo ""
echo "Branch: test (auto-created — all work happens here, PR to main when ready)"
echo ""
echo "Next steps:"
echo "1. Fill in API keys: edit .env"
if [ -n "$DRIVE_PATH" ]; then
    echo "2. Literature/ and Output/ are synced via $CLOUD_TYPE at: $DRIVE_ABS_PATH"
else
    echo "2. Optionally sync Literature/ and Output/ via cloud storage"
fi
echo "3. Place PDFs in Literature/ and start taking notes!"
