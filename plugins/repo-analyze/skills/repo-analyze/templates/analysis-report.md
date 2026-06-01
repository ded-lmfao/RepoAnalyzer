Select format based on repo size:
- **Compact** (fewer than 50 source files): use the compact template below
- **Full** (50+ source files): use the full template below

---

# COMPACT FORMAT

# [Project Name] — Repository Intelligence Report

**Stack:** [language + framework + DB in one line]
**Type:** [Web API | Frontend | CLI | Library | etc]
**Entry:** [path → what it starts]
**Auth:** [mechanism in one line]

**Routes/Commands:** [domain: N routes — one line per domain group]

**Models:** [Name: key fields → Relations — one line per model]

**Key dependencies:** [hub modules and external services — bullets]

**Critical flow:** [most important flow: trigger → path → outcome]

**Config:** [KEY: what it controls — one line each]

**Health:** [X.X/10] — Doc:[X] Deps:[X] Tests:[X] CI:[X] Activity:[level]

**Knowledge files:** `.claude/repo-knowledge/` — [list files written, including file-index.md]

**Token economy:** Files read: [N] · Symbols grep-indexed: [M] · Store: ~[K] tokens

[End with the COMMAND REFERENCE FOOTER below.]

---

# FULL FORMAT

# [Project Name] — Repository Intelligence Report

## What This Is
[2–3 sentences: language, type, purpose, scale]

## Architecture Pattern
[1–2 sentences: the core architectural pattern]

## Technology Stack
[One line per layer — only what actually exists]
- HTTP: [framework + version]
- Database: [DB + ORM]
- Auth: [mechanism]
- Cache: [if present]
- Realtime: [if present]
- Queue: [if present]
- Frontend: [if present]

## Entry Points
[path → what it starts]

## Module Map
[domain/module: one-sentence responsibility — all modules, one line each]

## Routes / Commands
[domain group: N routes/commands, auth requirement — one line per group]

## Data Model
[ModelName: key_field(type), ... → Relation(type)→OtherModel — one line per model]

## Dependency Highlights
- Hub modules: [list with importer counts]
- External services: [list]
- Event flows: [if present]

## Critical Flows
[flow name: trigger → [key steps] → outcome — one line each]

## Configuration
[KEY_NAME: what it controls — one line each]

## Repository Health
Overall: [X.X/10]
- Documentation:  [X/10] — [one-line reason]
- Dependencies:   [X/10] — [N total, N outdated majors]
- Test Coverage:  [X/10] — [one-line reason]
- CI/CD Maturity: [X/10] — [one-line reason]
- Activity Level: [Active | Maintained | Slow | Dormant]

## Top Recommendations
[1–3 improvements — only if any dimension scores below 7]

## Knowledge Files Written
[.claude/repo-knowledge/index.md]
[.claude/repo-knowledge/architecture.md]
[.claude/repo-knowledge/routes.md]
[.claude/repo-knowledge/data-model.md]
[.claude/repo-knowledge/dependencies.md]
[.claude/repo-knowledge/flows.md]
[.claude/repo-knowledge/config.md]
[.claude/repo-knowledge/file-index.md]

## What I Can Answer Without Reading Code Again
- [5 example questions this knowledge graph now answers instantly]

## Token Economy
Files read: [N] · Symbols grep-indexed: [M] · Knowledge store: ~[K] tokens

[End with the COMMAND REFERENCE FOOTER below.]

---

# COMMAND REFERENCE FOOTER

**Always print this block at the very bottom of any analysis or update report** (full analysis, `--update`, `--rebuild`). It tells the user exactly which command to run next. Reproduce it verbatim:

```
---

## 🧭 What you can do next

| Want to… | Run |
|----------|-----|
| Ask anything about this repo | just ask — I answer from the graph, no re-scan |
| Plan a change precisely (verified file:line plan before editing) | `/repo-analyze --change <intent>` |
| See the blast radius of editing a symbol | `/repo-analyze --impact <symbol>` |
| Trace an execution flow end-to-end | `/repo-analyze --flow <name>` |
| Deep-dive a data model + its relations | `/repo-analyze --model <name>` |
| Deep-dive a module + its callers | `/repo-analyze --module <name>` |
| Check freshness & coverage | `/repo-analyze --status` |
| Refresh after you commit | `/repo-analyze --update` |
| Force a clean rebuild (stale / corrupt / refactored) | `/repo-analyze --rebuild` |
```
