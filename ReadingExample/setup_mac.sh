#!/bin/bash

# Setup script for Mac users
# This script installs uv, syncs the Python project, and optionally creates cloud symlinks

set -e  # Exit on any error

echo "Setting up ReadingExample project..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew is not installed. Please install Homebrew first:"
    echo "https://brew.sh"
    exit 1
fi

# Install uv via Homebrew if not already installed
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    brew install uv
else
    echo "uv is already installed, skipping installation"
fi

# Set up UV environment variable for consistent venv location
export UV_PROJECT_ENVIRONMENT="$HOME/.venvs/$(basename "$PWD")"

# Install dependencies
echo "Installing Python packages..."

# Add zotero-mcp-server git source to pyproject.toml before installing dependencies
if ! grep -q "^zotero-mcp-server.*git" pyproject.toml; then
    if grep -q "\[tool.uv.sources\]" pyproject.toml; then
        sed -i '' 's/^# *zotero-mcp-server = { git.*/zotero-mcp-server = { git = "https:\/\/github.com\/54yyyu\/zotero-mcp.git" }/' pyproject.toml
    else
        echo "" >> pyproject.toml
        echo "[tool.uv.sources]" >> pyproject.toml
        echo "zotero-mcp-server = { git = \"https://github.com/54yyyu/zotero-mcp.git\" }" >> pyproject.toml
    fi
fi

# PDF processing
echo "Installing PDF processing packages..."
uv add pypdf pdf2image pillow

# Mistral OCR (for mistral-pdf-to-markdown skill)
uv add mistralai

# Zotero integration (for zotero-paper-reader skill)
uv add python-dotenv zotero-mcp-server

# Sync to ensure everything is installed
uv sync

echo "All dependencies installed"

# Create .venv symlink to the actual virtual environment location
echo "Creating .venv symlink..."
if [ ! -e ".venv" ]; then
    ln -s "$HOME/.venvs/$(basename "$PWD")" .venv
    echo "Created .venv -> $HOME/.venvs/$(basename "$PWD") symlink"
else
    echo ".venv already exists, skipping"
fi

# Cloud storage symlinks (set by create_project.sh when --drive is used)
DRIVE_PATH=""
if [ -n "$DRIVE_PATH" ]; then
    echo "Setting up cloud storage symlinks..."
    mkdir -p "$DRIVE_PATH/Literature" "$DRIVE_PATH/Output"

    for folder_name in Literature Output; do
        if [ -d "./$folder_name" ] && [ ! -L "./$folder_name" ]; then
            rmdir "./$folder_name" 2>/dev/null || true
        fi
        if [ ! -L "./$folder_name" ]; then
            ln -s "$DRIVE_PATH/$folder_name" "./$folder_name"
            echo "Created symlink: ./$folder_name -> $DRIVE_PATH/$folder_name"
        fi
    done
fi

# Initialize git repository if not already initialized
if [ ! -d .git ]; then
    echo "Initializing git repository..."
    git init

    # Set up secret-scanning pre-commit hook
    mkdir -p .githooks
    cat > .githooks/pre-commit << 'HOOKEOF'
#!/bin/sh
#
# pre-commit hook: scan staged files for leaked secrets
#
SECRETS_FOUND=0
STAGED_ALL=$(git diff --cached --name-only --diff-filter=ACM)

if [ -n "$STAGED_ALL" ]; then
    for FILE in $STAGED_ALL; do
        if file "$FILE" 2>/dev/null | grep -q "text"; then
            if git show ":$FILE" 2>/dev/null | grep -qEi \
                '(sk-[a-zA-Z0-9]{20,}|ANTHROPIC_API_KEY|OPENAI_API_KEY|MISTRAL_API_KEY|password\s*=\s*["'"'"'][^"'"'"']+|api_key\s*=\s*["'"'"'][^"'"'"']+|BEGIN (RSA |DSA |EC )?PRIVATE KEY)'; then
                echo "WARNING: Possible secret in $FILE"
                SECRETS_FOUND=1
            fi
        fi
    done
fi

if [ $SECRETS_FOUND -ne 0 ]; then
    echo ""
    echo "Commit blocked: potential secrets detected in staged files."
    echo "Review the files above. If intentional, use --no-verify (not recommended)."
    exit 1
fi
HOOKEOF
    chmod +x .githooks/pre-commit
    git config core.hooksPath .githooks
    echo "Installed secret-scanning pre-commit hook"

    # Add all files and make initial commit
    git add .
    git commit -m "Initial commit: ReadingExample reading project setup"
    echo "Created initial git commit"
else
    echo "Git repository already initialized"
fi

echo "Setup complete!"
