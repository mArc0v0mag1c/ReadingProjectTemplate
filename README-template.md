# ReadingExample

Academic reading project created with [ReadingProjectTemplate](https://github.com/marcozhang1/ReadingProjectTemplate).

## Project Organization

```
ReadingExample/
├── Notes/           - LaTeX reading notes (git-tracked)
│   ├── STYLE-GUIDE.md
│   ├── references.bib
│   └── <reading>/   - One folder per paper/chapter
├── Extracted/       - PDF-to-markdown conversions (git-tracked)
├── Literature/        - PDF files (gitignored)
├── Output/          - Compiled PDF notes (gitignored)
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
- `Literature/` and `Output/` directories for PDFs and compiled notes
