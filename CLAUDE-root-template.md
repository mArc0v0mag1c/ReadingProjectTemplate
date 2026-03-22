
# ReadingProjects — Root Instructions for Claude

This is the root of a multi-project academic reading workspace. Each subfolder is an independent reading project (e.g., a course, a research topic, a paper series).

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
├── CLAUDE.md            - This file (root-level: discussion rules, git, navigation)
├── .gitignore           - Shared gitignore
├── <ProjectName>/       - One folder per reading project
│   ├── CLAUDE.md        - Project-specific: structure, reading order, note format, LaTeX conventions
│   ├── READING-LOG.md   - Reading tracker
│   ├── Notes/           - Markdown discussion notes
│   ├── Extracted/       - PDF-to-markdown conversions
│   ├── Output/          - LaTeX notes (compiled PDFs gitignored)
│   ├── Literature/      - PDFs (gitignored, synced to Dropbox)
│   ├── .claude/         → config/.claude (symlink: skills, agents, settings)
│   ├── .mcp.json        → config/.mcp.json (symlink)
│   ├── .github/         → config/.github (symlink)
│   └── .vscode/         → config/.vscode (symlink: LaTeX Workshop)
└── ...
```

## How to Navigate

- **When the user references a specific project or paper**, read that project's `CLAUDE.md` first for project-specific details.
- **Each project's `CLAUDE.md`** has: reading order, project structure, note-taking format, LaTeX conventions, Python environment.
- **Shared config** lives in `../../config/` (relative to each project) — symlinked into every project. Edits affect all projects.

## Git

- All projects share one git repo.
- A `test` branch is **auto-created** during project setup. All work happens on `test` (or other feature branches).
- **Never commit directly to `main`**. `main` stays clean — it represents the last stable/accepted state.
- When changes are ready to be permanent, create a **pull request** from the working branch to `main`.
- Before committing, check you're on the right branch (`git branch`). If on `main`, switch to `test` first.
- `Literature/` and `Output/Compiled/` are gitignored (synced via Dropbox).
