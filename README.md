# ReadingProjectTemplate

Template for academic reading projects — structured LaTeX note-taking with PDF extraction, Zotero integration, and reading logs.

## Quick Start

```bash
git clone https://github.com/mArc0v0mag1c/ReadingProjectTemplate.git
cd ReadingProjectTemplate
./create_project.sh MacroTheory
```

This creates a ready-to-go project at `MacroTheory/` with everything set up.

### With cloud storage (optional)

```bash
./create_project.sh --drive ~/Dropbox/Reading MacroTheory
```

This puts `Readings/` (PDFs) and `Output/` (compiled notes) in Dropbox, symlinked into the project.

## What You Get

```
MacroTheory/
├── Notes/              LaTeX reading notes (git-tracked)
│   ├── STYLE-GUIDE.md  How to write notes
│   ├── references.bib  Shared bibliography
│   └── <reading>/      One folder per paper/chapter, multiple .tex files
├── Extracted/          PDF-to-markdown conversions (git-tracked)
├── Readings/           PDFs (gitignored, optionally cloud-synced)
├── Output/             Compiled PDF notes (gitignored, optionally cloud-synced)
├── READING-LOG.md      Tracks what you've read, notes locations, up-next queue
├── CLAUDE.md           AI instructions for Claude
├── .env                API keys (gitignored)
└── setup_mac.sh        Environment setup (already run by create_project.sh)
```

## Workflow

1. **Place a PDF** in `Readings/` (manually or via Zotero skill)
2. **Extract to markdown** using the `mistral-pdf-to-markdown` skill → saves to `Extracted/`
3. **Write LaTeX notes** in `Notes/<reading-name>/` using `marcoreport.sty`
4. **Update `READING-LOG.md`** so Claude knows your reading history
5. **Copy final PDFs** to `Output/` for cloud sync when done

## Prerequisites

- **macOS** with Homebrew
- **TinyTeX** for LaTeX (`brew install --cask tinytex`)
- **VS Code/Cursor** with [LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop) extension (for live preview)
- **marcoreport.sty** installed at `~/Library/TinyTeX/texmf-local/tex/latex/marco/` (see `Notes/STYLE-GUIDE.md` for setup)

### API Keys (optional)

After creating a project, fill in `.env`:
- `mistral_api_key` — for PDF-to-markdown OCR ([Mistral](https://console.mistral.ai/))
- `ZOTERO_API_KEY` — for Zotero paper fetching ([Zotero](https://www.zotero.org/settings/keys))

## Built-in Tools

| Tool | What it does |
|------|-------------|
| `mistral-pdf-to-markdown` | Converts PDFs to markdown via Mistral OCR API |
| `zotero-paper-reader` | Fetches papers from Zotero, downloads to `Readings/`, converts to markdown |
| `note-checker` agent | Validates your LaTeX notes against extracted source material |

## Design Principles

- **One project per topic/course** — multiple readings and notes inside
- **PDF annotation in Acrobat** (or your preferred reader) — this template is for structured LaTeX notes
- **Draft-first workflow** — Claude writes a plain text draft, you approve, then LaTeX
- **Reading log as memory** — `READING-LOG.md` gives Claude persistent context about your reading history
