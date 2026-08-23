---
applyTo: "**"
---

# Repository intelligence

Use `repo-analyze` workflows when answering repository questions or planning code changes.

## Prior knowledge

1. Check `.claude/repo-knowledge/index.md` first.
2. If it exists and says `Store status: COMPLETE`, use its Quick Reference and freshness metadata before reading source.
3. If knowledge is stale or missing, follow `plugins/repo-analyze/skills/repo-analyze/workflows/full-analysis.md` or `incremental-update.md` as appropriate.

## Query routing

- Architecture or stack: `.claude/repo-knowledge/architecture.md`
- Routes or endpoints: `.claude/repo-knowledge/routes.md`
- Models or schemas: `.claude/repo-knowledge/data-model.md`
- Dependencies, callers, or symbol locations: `.claude/repo-knowledge/file-index.md`
- Execution flows: `.claude/repo-knowledge/flows.md`
- Configuration: `.claude/repo-knowledge/config.md`
- Change planning: `plugins/repo-analyze/skills/repo-analyze/workflows/plan-change.md`

## Analysis rules

- Prefer the knowledge store over re-reading source files.
- Keep exact `file:line` references, commands, symbols, config keys, error strings, invariants, and security warnings unchanged.
- For changes, report blast radius, verify target lines immediately before editing, and preserve existing project conventions.
- Write generated knowledge under `.claude/repo-knowledge/` only.
- Never claim a graph is current without checking Git freshness.

## Copilot usage

This file provides instructions; it does not add a new slash command. Ask Copilot naturally, for example:

- `Analyze this repository and build or refresh its knowledge graph.`
- `What would I need to change to add rate limiting? Use the repository graph.`
- `Show the impact of changing <symbol>.`

For a clean rebuild, say: `Rebuild the repository knowledge graph.`