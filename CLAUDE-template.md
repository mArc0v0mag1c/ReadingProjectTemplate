
# Academic Reading Project Instructions for Claude

## Reading Order (Priority)

1. **`READING-LOG.md`** — Read FIRST. What's been read, current readings, notes locations, up-next queue.
2. **This file (`CLAUDE.md`)** — Project structure, note-taking conventions.
3. **`Extracted/`** — Read the relevant extracted markdown before discussing any paper.
4. **`Notes/`** — Check for existing discussion notes; update or create new ones during discussion.
5. **`Output/STYLE-GUIDE.md`** — LaTeX note-writing workflow and formatting rules.
6. **`.claude/skills/`** — Available skills (mistral-pdf-to-markdown, zotero-paper-reader).
7. **`.claude/agents/`** — Specialized agents (note-checker).

## Working Directory Context

You are working in the `ReadingProjects/ReadingExample/` folder, an academic reading and note-taking project.

- Git-tracked folders: `Notes/`, `Extracted/`, `Output/` (LaTeX source; compiled PDFs gitignored)
- Gitignored folders: `Literature/` (PDFs) — auto-synced to Dropbox if detected
- `../../.env` — Shared API keys at repo root (gitignored)
- Symlinked from `../../config/`: `.claude/`, `.mcp.json`, `.gitignore`, `.github/`, `.vscode/`, `Output/STYLE-GUIDE.md`
- Shared scripts at `../../config/scripts/` (used by skills)

## Project Structure

```
ReadingProjects/ReadingExample/
├── Notes/           - Markdown discussion notes per paper (git-tracked)
├── Extracted/       - PDF-to-markdown conversions (git-tracked)
├── Output/          - LaTeX reading notes (git-tracked; compiled PDFs gitignored)
│   ├── STYLE-GUIDE.md  → config/ (symlink)
│   ├── references.bib  - Per-project bibliography
│   ├── Compiled/    → Dropbox (symlink; auto-copied as <foldername>.pdf)
│   └── <reading>/   - One folder per paper/chapter (multiple .tex files allowed)
├── Literature/      - PDF files (gitignored, auto-synced to Dropbox)
├── READING-LOG.md   - Reading tracker (Claude reads this first)
├── .claude/         → config/.claude (symlink: skills, agents, settings)
├── .mcp.json        → config/.mcp.json (symlink)
├── .gitignore       → config/.gitignore (symlink)
├── .github/         → config/.github (symlink: PR template)
└── .vscode/         → config/.vscode (symlink: LaTeX Workshop auto-copy)
```

**Important:** Files symlinked from `config/` are shared across all projects. Edits to these files affect every project. Per-project files (CLAUDE.md, READING-LOG.md, references.bib, pyproject.toml, setup_mac.sh) are local to this project.

## Reading Log

`READING-LOG.md` tracks your full reading history across sessions:
- **Currently Reading**: active papers/chapters with notes locations
- **Completed**: finished readings with key takeaways
- **Up Next**: planned readings with context for why they're queued

**Always read this file first** when starting a new session. Update it when:
- Starting a new reading (add to Currently Reading)
- Finishing a reading (move to Completed with a one-liner takeaway)
- Discovering related papers to read later (add to Up Next)

## Notes

`Notes/<paper-name>.md` — lightweight companion notes captured during discussion. These track key insights, logic chains, and brainstorms as you read. When you later write formal LaTeX notes, refer to these as source material.

Each file follows this structure:

```markdown
# Author (Year) — Title: Companion Notes

## 1. Short descriptive title

**Reference:** where in the paper (e.g., Abstract (p. 529); Section I (pp. 530–532))

Key quote or claim, then the unpacked logic chain or analysis with precise citations (page, paragraph).

## 2. Next topic

Same pattern. Each numbered section is one self-contained insight, argument, or brainstorm.
```

Guidelines:
- One file per paper, append new sections as discussion continues
- Each section needs a **Reference** line pointing to the paper
- Logic chains should be numbered steps with citations
- Brainstorms and cross-paper connections are welcome — label them clearly

## LaTeX Output

LaTeX notes live in `Output/<reading-name>/` using `\usepackage{marcoreport}`.
Each folder can have multiple `.tex` files (e.g., `main.tex`, `chapter3.tex`, `proofs.tex`).
Compiled PDFs are gitignored but can be synced to Dropbox.
**Read `Output/STYLE-GUIDE.md` before writing any note.**

### Workflow

1. Place PDF in `Literature/` (manually or via Zotero skill)
2. Extract PDF to markdown: use `mistral-pdf-to-markdown` skill → saves to `Extracted/`
3. Read the extracted markdown; identify key passages
4. Create `Output/<reading-name>/main.tex` for structured LaTeX notes
5. Quote relevant passages with page references
6. Add BibTeX entry to `Output/references.bib`

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
Compiled PDFs are **auto-copied** to `Output/Compiled/<foldername>.pdf` on every build (via LaTeX Workshop recipe). `Compiled/` is symlinked to Dropbox, so PDFs sync automatically.

Example: `Output/Noise/main.pdf` → `Output/Compiled/Noise.pdf` → Dropbox.

## Python Environment

- Uses `uv` for dependency management
- Virtual environment located at `~/.venvs/ReadingExample`
- Run commands with `uv run <command>` (e.g., `uv run python script.py`)
- Add dependencies with `uv add package`

Whenever calling Python-related programs, use `uv` unless it is infeasible.
