# Reading Notes Style Guide

## LaTeX Setup

- Each set of notes lives in `Output/<reading-name>/`
- Multiple `.tex` files per folder allowed (e.g., `main.tex`, `chapter3.tex`, `proofs.tex`)
- Use `\usepackage{marcoreport}` (shared style at `~/Library/TinyTeX/texmf-local/tex/latex/marco/`)
- Build: `latexmk -pdf main.tex` from within the note subfolder

### TinyTeX Package Installation

TinyTeX ships with a minimal set of packages. `marcoreport.sty` requires these additional packages:

```bash
# If TinyTeX is outdated vs the remote repo, point to the matching historic archive:
# tlmgr option repository https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2024/tlnet-final
# tlmgr update --self

# Core packages for marcoreport.sty
tlmgr install setspace titlesec fancyhdr mathtools pgf tcolorbox \
  environ fp trimspaces tikzfill pdfcol \
  listings listingsutf8 minted fvextra upquote lineno csquotes \
  varwidth needspace adjustbox collectbox colortbl oberdiek
```

After installing `marcoreport.sty` to `~/Library/TinyTeX/texmf-local/tex/latex/marco/`, run:

```bash
texhash ~/Library/TinyTeX/texmf-local
```

Verify with:

```bash
kpsewhich marcoreport.sty
# Should print: ~/Library/TinyTeX/texmf-local/tex/latex/marco/marcoreport.sty
```

### Available Commands from `marcoreport.sty`

| Command | Purpose | Example |
|---------|---------|---------|
| `\vct{x}` | Bold vector | $\boldsymbol{x}$ |
| `\mat{A}` | Bold matrix | $\mathbf{A}$ |
| `\RR` | Real numbers | $\mathbb{R}$ |
| `\EE` | Expectation | $\mathbb{E}$ |
| `\var` | Variance | $\text{Var}$ |
| `\argmin` | Argmin operator | $\mathrm{argmin}$ |
| `\argmax` | Argmax operator | $\mathrm{argmax}$ |

| Environment | Purpose |
|-------------|---------|
| `theorem`, `lemma` | Numbered theorems (plain style) |
| `definition` | Numbered definitions |
| `remark` | Unnumbered remarks |
| `remarkbox[Title]` | Blue highlighted box for key insights |
| `mynote` (tcolorbox) | Gray note box via `\begin{tcolorbox}[mynote, title=...]` |

### Shared Bibliography

All note files reference a shared BibTeX file at `Output/references.bib`:
```latex
\usepackage[backend=biber]{biblatex}
\addbibresource{../references.bib}
```

## Structure & Workflow

1. **You provide the structure**: The exact outline, section headings, and content flow. Claude follows it precisely.
2. **You provide the raw material**: Extracted markdown, annotations, key passages. Claude synthesizes and formats — not invents.
3. **Iterative refinement**: Work section by section. You signal when to move on.
4. **No over-generation**: Claude does not add extra sections, unnecessary remarks, or tangential content. If Claude thinks something should be added, it asks first with reasoning.

## Content Structure

Each note follows this framework:

| Step | Purpose | Example |
|------|---------|---------|
| **Overview** | What is this paper/chapter about? Setting, contribution | "This paper studies optimal consumption under uncertainty..." |
| **Key Arguments** | Main theoretical/empirical arguments | "The authors show via Bellman equation that..." |
| **Technical Details** | Derivations, proofs, methods worth recording | "Starting from the FOC, substitute envelope condition..." |
| **Takeaways** | Key results, connections to other readings | "This generalizes the result from [other paper]..." |

## Quoting from Sources

When incorporating content from extracted PDFs into LaTeX notes:

### Direct Quotes
```latex
\begin{quote}
``Exact text from the source'' \hfill (Author, Year, p.~12)
\end{quote}
```

### Paraphrased Content
Inline reference: the authors argue that X holds under Y (p.~15--17).

### Equations from Source
When reproducing an equation from the paper, note the equation number:
```latex
\begin{equation}
V(a) = \max_{c} u(c) + \beta V(a')  \tag{Source: eq.~3, p.~8}
\end{equation}
```

## Content Principles

- **Mathematical rigor**: Retain "minor but crucial" steps; don't skip algebra
- **Page references**: Every claim or quote cites a page number from the source
- **Connections**: Use remarkboxes to link concepts across readings in the same project

## Notation Conventions

- **Consistency**: Pick one notation and stick with it
- **Time-subscripts preferred**: $a_t, a_{t+1}, c_t^*$ for clarity in dynamic problems
- **Starred variables** for optima: $c_t^*$, not just $c_t$

## Formatting Preferences

- **`itemize`** for unordered lists / cases
- **`enumerate`** for sequential steps / numbered conditions
- **Nested lists** to consolidate related points
- **Boxes**: Only use `remarkbox` for now (key insights, intuition, connections). Other box types are available but should not be used unless explicitly requested.

## What NOT to Do

- Don't invent content beyond what was provided
- Don't add unnecessary caveats or hedging
- Don't create separate boxes when items can be nested
- Don't switch notation mid-section
- Don't generate the next section until explicitly told

## Workflow

```
1. User specifies reading/section
2. User provides: extracted markdown + annotations + key points to capture
3. Claude replies with a PLAIN TEXT DRAFT (not LaTeX) — outlining content,
   flow, and key equations in readable form
4. User reviews the draft → requests revisions
5. User approves: "yes, do latex" → Claude writes the .tex code
6. User inspects live in VS Code (LaTeX Workshop auto-rebuilds on save)
7. User says "move on" → next section
```

**Important**: Claude must NOT generate LaTeX code until the user explicitly approves the draft. The draft-first step ensures content is correct before formatting.

## PDF Output

LaTeX builds in-place for live preview (LaTeX Workshop auto-rebuilds on save).
Compiled PDFs stay in `Output/<reading-name>/` (gitignored). To sync to Dropbox:
```bash
../../config/scripts/sync_pdfs.sh              # sync all
../../config/scripts/sync_pdfs.sh <reading>    # sync one
```

## Live Preview Setup

Install the **LaTeX Workshop** extension in VS Code for auto-build and live PDF preview:

```bash
code --install-extension James-Yu.latex-workshop
```

Once installed, open any `.tex` file and press `Cmd+Shift+P` → "LaTeX Workshop: View LaTeX PDF". The PDF panel auto-refreshes on every save — no manual `latexmk` needed.

This replaces the build-inspect-rebuild cycle: just edit the `.tex`, save, and the preview updates instantly.
