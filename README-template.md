# ReadingExample

Academic reading project created with [ReadingProjectTemplate](https://github.com/mArc0v0mag1c/ReadingProjectTemplate).

## Project Organization

```
ReadingProjects/ReadingExample/
├── Notes/           - Markdown discussion notes per paper (git-tracked)
├── Extracted/       - PDF-to-markdown conversions (git-tracked)
├── Output/          - LaTeX reading notes (git-tracked; compiled PDFs gitignored)
│   ├── STYLE-GUIDE.md
│   ├── references.bib
│   ├── Compiled/    - Auto-copied PDFs synced to Dropbox (<foldername>.pdf)
│   └── <reading>/   - One folder per paper/chapter
├── Literature/      - PDF files (gitignored, auto-synced to Dropbox)
└── READING-LOG.md   - Reading tracker
```

## Setup Instructions

### Prerequisites

- **macOS**: Homebrew installed ([https://brew.sh](https://brew.sh))
- **Git**: For cloning the repository
- **TinyTeX**: For LaTeX compilation (`brew install --cask tinytex`)
- **VSCode/Cursor**: Recommended, with LaTeX Workshop extension

### Installation

```bash
git clone <repository-url>
cd ReadingExample
./setup_mac.sh
```

The setup script will:
- Install `uv` and Python dependencies (PDF processing, Mistral OCR, Zotero)
- Create a virtual environment at `~/.venvs/ReadingExample`

### API Keys

Fill in your API keys in the root `.env` (shared across all projects):
- `mistral_api_key` — For PDF-to-markdown conversion ([Mistral API](https://console.mistral.ai/))
- `ZOTERO_API_KEY` — For Zotero paper fetching ([Zotero API](https://www.zotero.org/settings/keys))

### Verification

After setup, you should have:
- Python environment ready with `uv sync`
- Local `Notes/` and `Extracted/` folders in the repository
- `Literature/` symlinked to Dropbox (if detected)
- `Output/` for LaTeX notes (compiled PDFs gitignored)
- `Output/Compiled/` symlinked to Dropbox (auto-copies PDFs on every build)

**Important:** Open this project folder in VS Code (not the template root) so LaTeX Workshop picks up `.vscode/settings.json` for auto-build and auto-copy.
