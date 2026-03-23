---
name: method-tracker
description: Track methods and techniques learned from readings. Scans Notes and Extracted papers for method discussions, maintains structured inventory in ResearchHub. Trigger on "track method", "add method", "what methods do I know", "methods I know", "method inventory", "update methods", "learned methods", "method list".
---

# Method Tracker (Reading Project)

Scans your Notes and Extracted papers for discussions of methods, techniques, and approaches. Builds and maintains a structured inventory at `~/vscodeproject/ResearchHub/method-tracker/methods.md`.

Designed to match your scholarly note-taking style — extracts methods from comparative tables, theoretical grounding, logic chains, and formulas.

---

## Configuration

- **Methods inventory**: `~/vscodeproject/ResearchHub/method-tracker/methods.md`
- **Scan locations**: `Notes/*.md`, `Notes/**/*.md`, `Extracted/*.md`

---

## When to Run

- User says "track method", "add method", "update methods", "what methods do I know", "method inventory"
- After completing a reading session — suggest: "Want me to check for new methods to track?"
- User says "run method-tracker"

---

## What to Look For

Same patterns as research project version:
1. Explicit method names (regression techniques, estimators, algorithms, statistical tests)
2. Comparative tables contrasting frameworks/approaches
3. Logic chains describing how a technique works
4. Theoretical grounding ("following [Author]'s framework...")
5. Testable predictions / Limitations sections
6. Formulas and equations describing estimators or models

**Reading-project specific**: Also scan `Extracted/*.md` for methods discussed in the papers themselves. These are PDF-to-markdown conversions and contain the full content of papers being read.

---

## Workflow

### Step 1: Read current inventory
Read `~/vscodeproject/ResearchHub/method-tracker/methods.md`

### Step 2: Scan Notes
Grep Notes/*.md and Notes/**/*.md for method-related content. For each match, read surrounding context.

### Step 3: Scan Extracted papers
Scan `Extracted/*.md` for methods. Focus on:
- Method sections of papers
- Theoretical frameworks introduced
- Estimators and their properties
- Mathematical formulations

**Note**: Methods from readings are typically "Learning" level unless the user has also applied them in a research project.

### Step 4: Cross-reference with READING-LOG.md
Associate methods with the papers they came from. Check READING-LOG.md to understand the context of each reading.

### Step 5: Cross-reference against inventory
Skip duplicates. Flag existing methods with new paper sources.

### Step 6: Present to user
Show findings with suggested entries. **Always confirm before appending.**

### Step 7: Update inventory
After confirmation, append to `~/vscodeproject/ResearchHub/method-tracker/methods.md`:

```markdown
### [Method Name]
- **What**: [1-2 sentence description]
- **Source**: [Paper citation from the reading]
- **Key reference**: [Paper with page numbers]
- **When added**: [Date]
- **Proficiency**: [Learning / Applied once / Comfortable / Fluent]
- **Used in**: [List of projects]
- **Notes**: [Key insight, gotcha, or connection to other methods]
```

---

## Proficiency Levels

- **Learning**: Read about it, understand the concept, haven't applied it
- **Applied once**: Used it in one project or exercise
- **Comfortable**: Used it across multiple projects, can implement without reference
- **Fluent**: Deep understanding, can teach it, know edge cases and limitations

Note: Methods discovered from reading (Extracted/) default to "Learning". Only upgrade when there's evidence of application in a research project.

---

## Integration with Research-Junshi

Research-junshi reads methods.md to generate better ideas. When it finds a paper using a method you know, it highlights the connection. When it finds a method you don't know, it can suggest adding it to your learning goals.

---

## Tone

Be precise and factual. Match the user's scholarly style. Reference specific papers, page numbers, and reading project names. Don't inflate proficiency — be honest about reading vs. applying.
