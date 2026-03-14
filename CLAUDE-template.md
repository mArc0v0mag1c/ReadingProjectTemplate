
# Academic Reading Project Instructions for Claude

## Reading Order (Priority)

1. **`READING-LOG.md`** — Read FIRST. What's been read, current readings, notes locations, up-next queue.
2. **This file (`CLAUDE.md`)** — Project structure, note-taking conventions.
3. **`Notes/STYLE-GUIDE.md`** — LaTeX note-writing workflow and formatting rules.
4. **`.claude/skills/`** — Available skills (mistral-pdf-to-markdown, zotero-paper-reader).
5. **`.claude/agents/`** — Specialized agents (note-checker).

## Working Directory Context

You are working in the `ReadingExample/` folder, which is a Git repository for academic reading and note-taking.

- Git-tracked folders: `Notes/`, `Extracted/`
- Gitignored folders: `Literature/` (PDFs), `Output/` (compiled notes) — optionally synced via cloud storage (e.g., Dropbox, Google Drive)
- `.env` — API keys (gitignored)

## Project Structure

```
ReadingExample/
├── Notes/           - LaTeX reading notes (git-tracked)
│   ├── STYLE-GUIDE.md
│   ├── references.bib
│   └── <reading>/   - One folder per paper/chapter (multiple .tex files allowed)
├── Extracted/       - PDF-to-markdown conversions (git-tracked)
├── Literature/        - PDF files (gitignored, optionally cloud-synced)
├── Output/          - Compiled PDF notes (gitignored, optionally cloud-synced)
├── READING-LOG.md   - Reading tracker (Claude reads this first)
└── .env             - API keys (gitignored)
```

## Reading Log

`READING-LOG.md` tracks your full reading history across sessions:
- **Currently Reading**: active papers/chapters with notes locations
- **Completed**: finished readings with key takeaways
- **Up Next**: planned readings with context for why they're queued

**Always read this file first** when starting a new session. Update it when:
- Starting a new reading (add to Currently Reading)
- Finishing a reading (move to Completed with a one-liner takeaway)
- Discovering related papers to read later (add to Up Next)

## Reading Notes

Notes live in `Notes/<reading-name>/` using `\usepackage{marcoreport}`.
Each folder can have multiple `.tex` files (e.g., `main.tex`, `chapter3.tex`, `proofs.tex`).
**Read `Notes/STYLE-GUIDE.md` before writing any note.**

### Workflow

1. Place PDF in `Literature/` (manually or via Zotero skill)
2. Extract PDF to markdown: use `mistral-pdf-to-markdown` skill → saves to `Extracted/`
3. Read the extracted markdown; identify key passages
4. Create `Notes/<reading-name>/main.tex` for structured LaTeX notes
5. Quote relevant passages with page references
6. Add BibTeX entry to `Notes/references.bib`

### Quoting Convention

When quoting from a reading, use:
```latex
\begin{quote}
``Quoted text from the source'' \hfill (Author, Year, p.~12)
\end{quote}
```
For paraphrased content, note the page reference inline: (Author, Year, p.~15).

For reproduced equations, tag the source:
```latex
\begin{equation}
V(a) = \max_{c} u(c) + \beta V(a')  \tag{Source: eq.~3, p.~8}
\end{equation}
```

### PDF Output

LaTeX builds in-place for live preview (VS Code LaTeX Workshop).
When notes are finalized, copy compiled PDFs to `Output/` for cloud sync:
```bash
cp Notes/<reading>/*.pdf Output/
```

## Python Environment

- Uses `uv` for dependency management
- Virtual environment located at `~/.venvs/ReadingExample`
- Run commands with `uv run <command>` (e.g., `uv run python script.py`)
- Add dependencies with `uv add package`

Whenever calling Python-related programs, use `uv` unless it is infeasible.

## Git Branching

- A `test` branch is **auto-created** during project setup. All work happens on `test` (or other feature branches).
- **Never commit directly to `main`**. `main` stays clean — it represents the last stable/accepted state.
- When changes are ready to be permanent, create a **pull request** from the working branch to `main`.
- Before committing, check you're on the right branch (`git branch`). If on `main`, switch to `test` first.
