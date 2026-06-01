<required_reading>
Load references/knowledge-store.md for freshness fields.
</required_reading>

<process>
## Status Report

Triggered by `--status`. Produces a coverage and freshness report — does not analyze source files.

**Step 1 — Load knowledge store**
Read `.claude/repo-knowledge/index.md`. If not found, report "No knowledge graph found — run `/repo-analyze` to build one."

**Step 2 — Compute freshness**
Run: `git log --oneline -5` and `git diff --name-only <last_commit> HEAD` to count commits and changed files since last analysis.

**Step 3 — Deliver status report**

```
## Knowledge Graph Status: [repo name]

Schema version:          [N]  (current: 2 — if lower, recommend --rebuild)
Store status:            [COMPLETE / INCOMPLETE — if not COMPLETE, last write was interrupted]
Index confidence:        [N validated / M sampled]
Last full analysis:       [date]
Last incremental update:  [date or "none"]
Git HEAD at last analysis:[hash]
Current HEAD:             [hash]
Commits since analysis:   [N]
Files changed since:      [N]
Stale risk:               [LOW / MEDIUM / HIGH]

## Coverage
[✓] architecture.md    — [last updated]
[✓] routes.md          — [last updated]
[✓] data-model.md      — [last updated]
[✓] dependencies.md    — [last updated]
[✓] flows.md           — [last updated]
[✓] config.md          — [last updated]
[ ] flows.md           — MISSING (run full analysis to generate)

## What I Can Answer Without Reading Code
[List 5 questions this knowledge graph can answer instantly]

## Recommendation
[One of:]
- Knowledge is current. No action needed.
- [N] commits behind. Run `/repo-analyze --update` to refresh.
- HIGH STALE: Run `/repo-analyze --rebuild` for a clean full re-analysis before making changes.
- Schema v[X] < 2 OR Store status not COMPLETE: Run `/repo-analyze --rebuild` — the store is outdated or was left half-written.
```
</process>

<success_criteria>
- [ ] Knowledge store checked (or "not found" reported)
- [ ] Commit delta computed
- [ ] All knowledge files inventoried (present vs missing)
- [ ] Clear recommendation given
</success_criteria>
