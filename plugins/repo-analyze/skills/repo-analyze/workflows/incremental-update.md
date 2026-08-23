<required_reading>
Load these references before proceeding:
1. references/knowledge-store.md — file formats, freshness tracking
2. references/file-selection.md — what to read
</required_reading>

<process>
## Phase 6 — Incremental Update

Triggered by `--update` flag or when Phase 0 finds prior knowledge with changed files.

**Step 1 — Read existing knowledge store**

Load `.claude/repo-knowledge/index.md`. Extract:
- `Git HEAD at last analysis`
- `Last full analysis` date
- `Stale risk` level

If stale risk is HIGH (30+ days old or 50+ commits behind): recommend full re-analysis.
```
This knowledge graph is HIGH STALE ([days] old, [N] commits behind).
Re-running full analysis is strongly recommended before making changes.
Proceed with incremental update anyway? [Yes/No]
```

**Step 2 — Scope the Changes**

Run: `git diff --name-only <last_commit> HEAD`

Classify each changed file into which knowledge domain it affects:

| Changed file type | Update target |
|------------------|--------------|
| Route/handler files | routes.md **+ file-index.md** (handler line moved/added/removed) |
| Model files | data-model.md **+ file-index.md** (symbol line + propagation chain) |
| Config files | config.md |
| Entry/bootstrap files | architecture.md |
| Service/domain files | dependencies.md **+ file-index.md** (method lines) |
| New directories | re-classify directory map in architecture.md |
| Any structural change | re-check Invariants & Gotchas in index.md — add/remove constraints |

**file-index.md staleness is the most dangerous kind:** a wrong line number sends a future edit to the wrong place. For every changed source file, re-grep its declaration lines (symbol-indexing.md patterns) and update the `file:line` entries — this is cheap (grep, no reads) and keeps the change-planning layer trustworthy.

**Step 3 — Targeted Read**

For each changed file:
- Read only that file (apply file-selection.md tiers)
- Update only the affected section of the relevant knowledge document
- Apply compression rules (see knowledge-store.md) before writing
- Log: `Updated [knowledge-file] — [what changed in one line]`

**Step 4 — Impact Propagation**

For each changed module:
- Look up its entry in `dependencies.md` (do not re-read source files)
- Report: "Changing [X] may affect: [list of dependent modules]"

**Step 5 — Freshness Update**

Update `index.md` (preserve `Schema version: 2`; re-stamp `Store status: COMPLETE` only after all touched files are written — index.md last):
- New `Git HEAD`
- New `Last incremental update` date
- Append changelog: `[date]: updated [files] — [summary of what changed]`
- Recalculate `Stale risk`
- Re-validate (grep) the file-index entries for any symbol whose file changed; update `Index confidence`
- Update the Coverage Gaps section if a change opened or closed a gap

**Report format:**
```
## Incremental Update Complete

Changed files: [N]
Knowledge files updated: [list]
Impact summary: [any modules affected by changes]
New Git HEAD: [hash]
Stale risk: [LOW/MEDIUM/HIGH]
```

**Then finish with the one-liner footer from templates/analysis-report.md** (a graph already existed, so the user has seen the full table — do not reprint it):
`Next: ask me anything (answered from the graph) · \`--change <intent>\` to plan an edit · \`--status\` for freshness · \`--help\` for all commands.`
</process>

<success_criteria>
- [ ] Stale risk assessed before updating
- [ ] Only changed files read (no full re-analysis)
- [ ] Only affected knowledge sections updated
- [ ] file-index.md line numbers re-grepped for every changed source file
- [ ] Invariants re-checked for structural changes
- [ ] Impact of changes reported
- [ ] index.md freshness fields updated
- [ ] Changelog entry added
</success_criteria>
