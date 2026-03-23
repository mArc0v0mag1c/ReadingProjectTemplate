
# ReadingProjects — Instructions for Claude

This is the root of a multi-project academic reading workspace. Each subfolder is an independent reading project (e.g., a course, a research topic, a paper series).

## Reading Order (Priority)

1. **`<project>/READING-LOG.md`** — Read FIRST. What's been read, current readings, notes locations, up-next queue.
2. **This file (`CLAUDE.md`)** — Project structure, note-taking conventions.
3. **`<project>/Extracted/`** — Read the relevant extracted markdown before discussing any paper.
4. **`<project>/Notes/`** — Check for existing discussion notes; update or create new ones during discussion.
5. **`<project>/Output/STYLE-GUIDE.md`** — LaTeX note-writing workflow and formatting rules.
6. **`.claude/skills/`** — Available skills (method-tracker, mistral-pdf-to-markdown, research-junshi, zotero-paper-reader).
7. **`.claude/agents/`** — Specialized agents (note-checker).

## How We Work

The user discusses papers directly in chat. When they reference content from a paper:

1. **Always read the extracted markdown first** (`Extracted/`) to ground yourself in the paper's actual content before answering.
2. **Cite precisely**: refer to the specific paragraph, page, figure, table, or equation. Use formats like "(para. 2, p. 12)", "(Table 3, p. 8)", "(Figure 2, p. 15)". Look both above and below the referenced content for context.
3. **Answer directly** — lead with the substance, grounded in what the paper actually says.
4. **If the paper doesn't answer the question directly**, say so explicitly before providing your answer. Clearly separate what comes from the paper vs. what doesn't.
5. **External sources**: when the user asks for material beyond the paper, use only reliable sources — top-university lecture slides, top-journal papers, or their companion slides. Always provide:
   - A direct web link to the source
   - A precise reference within that source (e.g., "Slide 14", "Section 3, para. 2, p. 8", "Table 2, p. 12")

This interaction style will evolve over time. Follow user feedback on how to adjust.

## Repo Structure

```
ReadingProjects/
├── CLAUDE.md            - This file (all reading instructions)
├── .gitignore           - Shared gitignore
├── <ProjectName>/       - One folder per reading project
│   ├── READING-LOG.md   - Reading tracker
│   ├── Notes/           - Markdown discussion notes per paper (git-tracked)
│   │   └── Brainstorm/  - Research-junshi digests (auto-generated, git-tracked)
│   ├── Extracted/       - PDF-to-markdown conversions (git-tracked)
│   ├── Output/          - LaTeX reading notes (git-tracked; compiled PDFs gitignored)
│   │   ├── STYLE-GUIDE.md  → config/ (symlink)
│   │   ├── references.bib  - Per-project bibliography
│   │   ├── Compiled/    → Dropbox (symlink; auto-copied as <foldername>.pdf)
│   │   └── <reading>/   - One folder per paper/chapter (multiple .tex files allowed)
│   ├── Literature/      - PDF files (gitignored, auto-synced to Dropbox)
│   ├── .claude/         → config/.claude (symlink: skills, agents, settings)
│   ├── .mcp.json        → config/.mcp.json (symlink)
│   ├── .github/         → config/.github (symlink)
│   └── .vscode/         → config/.vscode (symlink: LaTeX Workshop auto-copy)
└── ...
```

**Important:** Files symlinked from `config/` are shared across all projects. Edits to these files affect every project. Per-project files (READING-LOG.md, references.bib, pyproject.toml, setup_mac.sh) are local to each project.

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

### Notes/Brainstorm/

`Notes/Brainstorm/` — auto-generated research digests from the research-junshi skill. Contains dated digest files (`YYYY-MM-DD.md`) with arXiv findings, idea connections, and brainstorm captures. These are git-tracked.

## LaTeX Output

LaTeX notes live in `Output/<reading-name>/` using `\usepackage{marcoreport}`.
Each folder can have multiple `.tex` files (e.g., `main.tex`, `chapter3.tex`, `proofs.tex`).
Compiled PDFs are gitignored but can be synced to Dropbox.
**Read `Output/STYLE-GUIDE.md` before writing any note.**

### Workflow

1. Place PDF in `Literature/` (manually or via Zotero skill)
2. Extract PDF to markdown: use `mistral-pdf-to-markdown` skill → saves to `Extracted/`
3. Read the extracted markdown; identify key passages

### Running Mistral PDF-to-Markdown

See `~/.claude/CLAUDE.md` for Mistral conventions. For reading projects, output goes to `Extracted/` (not `Literature/Extracted/`).
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

## Git

- All projects share one git repo.
- A `test` branch is **auto-created** during project setup. All work happens on `test` (or other feature branches).
- **Never commit directly to `main`**. `main` stays clean — it represents the last stable/accepted state.
- When changes are ready to be permanent, create a **pull request** from the working branch to `main`.
- Before committing, check you're on the right branch (`git branch`). If on `main`, switch to `test` first.
- `Literature/` and `Output/Compiled/` are gitignored (synced via Dropbox).

## Git Hooks (auto-configured)

- `pre-commit`: Scans staged files for leaked secrets (API keys, passwords, private keys) — blocks commit if found.
- Hooks location: `.githooks/`. Configured via `git config core.hooksPath .githooks`.

## Python Environment

See `~/.claude/CLAUDE.md` for Python/uv conventions. Each project has its virtual environment at `~/.venvs/<project-folder-name>`.

## Skills Available

- `method-tracker`: Track methods and techniques learned from readings; maintains inventory in ResearchHub (`.claude/skills/method-tracker`).
- `mistral-pdf-to-markdown`: Convert PDFs to Markdown with Mistral OCR, including image extraction (`.claude/skills/mistral-pdf-to-markdown`).
- `research-junshi`: Research advisor (军师) — scans arXiv/venues, reads brainstorm notes and extracted papers, generates idea digests in `Notes/Brainstorm/` (`.claude/skills/research-junshi`).
- `zotero-paper-reader`: Read papers from Zotero library, download PDFs, convert to markdown (`.claude/skills/zotero-paper-reader`).
