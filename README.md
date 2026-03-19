# ReadingProjectTemplate

Template for academic reading projects — structured LaTeX note-taking with PDF extraction, Zotero integration, and Dropbox sync.

## Quick Start

```bash
git clone https://github.com/mArc0v0mag1c/ReadingProjectTemplate.git
cd ReadingProjectTemplate
./create_project.sh MacroTheory
```

If Dropbox is installed, `Literature/` auto-symlinks to `~/Dropbox/ReadingProjects/MacroTheory/Literature/`. No extra flags needed.

To use a custom cloud path:
```bash
./create_project.sh --drive ~/GoogleDrive/Reading MacroTheory
```

## What You Get

```
ReadingProjectTemplate/
├── .env                         Shared API keys (gitignored)
├── config/                      Shared skills, agents, scripts, templates
├── ReadingProjects/             All your projects live here
│   ├── MacroTheory/
│   │   ├── Notes/               Markdown discussion notes (git-tracked)
│   │   ├── Extracted/           PDF-to-markdown conversions (git-tracked)
│   │   ├── Output/              LaTeX notes (git-tracked; compiled PDFs gitignored)
│   │   │   ├── STYLE-GUIDE.md   How to write notes (→ config/)
│   │   │   ├── references.bib   Per-project bibliography
│   │   │   └── <reading>/       One folder per paper/chapter
│   │   ├── Literature/          PDFs (gitignored, auto-synced to Dropbox)
│   │   ├── READING-LOG.md       Tracks readings, notes locations, up-next queue
│   │   └── CLAUDE.md            AI instructions for Claude
│   └── AnotherProject/          Add as many projects as you want
└── ReadingExample/              Demo project (for reference)
```

## Workflow

1. **Place a PDF** in `Literature/` — syncs to Dropbox automatically (it's a symlink)
2. **Extract to markdown** using the `mistral-pdf-to-markdown` skill → saves to `Extracted/`
3. **Discuss the paper** with Claude — notes go to `Notes/<paper>.md`
4. **Write LaTeX notes** in `Output/<reading>/main.tex` using `marcoreport.sty`
5. **Sync compiled PDFs** to Dropbox: `../../config/scripts/sync_pdfs.sh`
6. **Update `READING-LOG.md`** so Claude knows your reading history

## Prerequisites

- **macOS** with Homebrew
- **TinyTeX** for LaTeX (`brew install --cask tinytex`)
- **VS Code/Cursor** with [LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop) extension (for live preview)
- **marcoreport.sty** installed at `~/Library/TinyTeX/texmf-local/tex/latex/marco/` (see `Output/STYLE-GUIDE.md`)

### API Keys (optional)

Fill in `.env` at the repo root (shared by all projects):
- `mistral_api_key` — for PDF-to-markdown OCR ([Mistral](https://console.mistral.ai/))
- `ZOTERO_API_KEY` — for Zotero paper fetching ([Zotero](https://www.zotero.org/settings/keys))

## Built-in Tools

| Tool | What it does |
|------|-------------|
| `mistral-pdf-to-markdown` | Converts PDFs to markdown via Mistral OCR API |
| `zotero-paper-reader` | Fetches papers from Zotero, downloads to `Literature/`, converts to markdown |
| `note-checker` agent | Validates your LaTeX notes against extracted source material |
| `sync_pdfs.sh` | Copies compiled PDFs from `Output/` to Dropbox |

## Design Principles

- **One project per topic/course** — multiple readings and notes inside
- **Shared config** — skills, agents, scripts live once in `config/`, symlinked per project
- **Dropbox auto-detection** — if `~/Dropbox` exists, PDFs sync automatically
- **Draft-first workflow** — Claude writes a plain text draft, you approve, then LaTeX
- **Reading log as memory** — `READING-LOG.md` gives Claude persistent context
