<required_reading>
Load before proceeding:
1. `.claude/repo-knowledge/index.md` — architecture context (and Invariants & Gotchas)
2. `.claude/repo-knowledge/file-index.md` — symbol locations and change propagation chains

**Monorepo:** if the store is `.claude/repo-knowledge/<service>/`, read the workspace index.md first, resolve which service(s) the change targets, and load those services' index.md + file-index.md. A change that crosses a service boundary (shared type, API contract) must plan edits in every affected service.

**Integrity:** if index.md lacks `Store status: COMPLETE` or `Schema version: 2`, the graph is incomplete or outdated — tell the user and recommend `--rebuild` before planning edits; do not plan from a store missing the file-index layer.
</required_reading>

<process>
## --change <intent>

Given a natural language description of what the user wants to change, produce a precise, ordered file change plan with exact file paths and line numbers. Do not start making changes — only plan them.

---

**Step 1 — Parse intent**

Identify from the user's description:
- **Target entity/symbol** — what is being changed (e.g., "User model", "payment flow", "auth middleware", "build command")
- **Change type:**
  - `ADD_FIELD` — new property on a model/type
  - `ADD_ENDPOINT` — new route + handler
  - `ADD_FEATURE` — new domain capability (spans multiple layers)
  - `MODIFY_BEHAVIOR` — change how an existing function works
  - `RENAME` — rename a symbol (highest blast radius)
  - `REMOVE` — delete a feature/field (check all usages first)
  - `FIX_BUG` — targeted fix in a specific location
- **Scope** — which layers are involved (backend only? fullstack? config?)

If the intent is ambiguous → ask one clarifying question before proceeding.

---

**Step 2 — Look up the target in file-index.md**

Find the target entity in the Symbol Cross-Reference section. Extract:
- Definition file:line
- All usage files with their line numbers
- Change propagation chain (already written during analysis)
- DB / migration implications
- Frontend mirror type location

If the symbol is not in file-index.md: check routes.md and data-model.md. As a last resort, grep the source. Note any symbol found via grep as "not pre-indexed — verify location before editing."

**Also read the Invariants & Gotchas section of index.md.** Any invariant touching the target entity (tenant scoping, serialization tags, generated files, type mirrors, migration rules) becomes a mandatory line item in the plan — surface it, do not let the edit silently violate it.

---

**Step 3 — Classify the blast radius**

Using the cross-reference data:

| Blast radius | Criteria |
|-------------|----------|
| SURGICAL | 1–2 files, no DB change, no interface change |
| MODERATE | 3–5 files, or DB migration needed, or type interface changes |
| WIDE | 6+ files, or public API change, or cross-service impact |
| BREAKING | Rename or remove of a heavily-used symbol; test suite likely needs updates too |

Announce the blast radius before showing the plan.

---

**Step 4 — Output the change plan**

Format:

```
## Change Plan: [intent summary]

Blast radius: [SURGICAL / MODERATE / WIDE / BREAKING]
DB migration needed: [Yes / No / Maybe — reason]
Frontend changes needed: [Yes / No]

### Files to change (in this order):

1. [file path]:[approximate line]
   What: [exactly what to add/modify/remove]
   Why:  [which dependency forces this change]

2. [file path]:[approximate line]
   What: [exactly what to add/modify/remove]
   Why:  [which dependency forces this change]

...

### Files that do NOT need changes:
- [file] — [one-line reason it's unaffected]

### Invariants this change must respect:
- [each relevant invariant from index.md — e.g., "keep the JSON tag so wire format is unchanged", "add a migration; don't rely on AutoMigrate"]

### Unknowns / verify before starting:
- [anything the agent should confirm before editing — e.g., "verify no raw SQL uses column name directly"]

### Suggested edit order:
[Same as the numbered list above, but call out any parallel edits]
Step 1: Edit [file] (unblocked)
Step 2: Edit [file] (depends on step 1 compiling)
Step 3: Edit [file A] and [file B] in parallel (independent)
```

---

**Step 5 — Offer to execute**

After delivering the plan, ask:
"Ready to start making these changes? I'll follow the order above and verify each file before editing."

Do not begin editing until the user confirms.

---

**Step 6 — Verify-before-edit (MANDATORY at point of use)**

file-index.md line numbers are a cache. They drift on every edit above them and go stale silently between analysis runs. **Never edit at a remembered line number without re-confirming it first.** Immediately before touching each target file:

1. Grep the symbol name in that file to get its CURRENT line (`rg -n "func Create" internal/services/user_service.go`).
2. If the symbol is found at/near the indexed line → proceed.
3. If it moved → use the new line; silently correct, and note that the index was stale.
4. If it is GONE (renamed/removed since analysis) → STOP. The plan is built on outdated knowledge. Re-grep the repo for the symbol, and if truly absent, tell the user the index is stale and offer `--update` before continuing.
5. Any fact marked `(inferred)` in the knowledge graph that this edit depends on → confirm it by reading the relevant line before relying on it.

This step is cheap (one grep per target) and is the difference between a knowledge graph that is *advisory* and one you can *act on*. A stale line number that lands an edit in the wrong place is the most damaging failure this skill can cause — this gate prevents it.

---

## Special handling by change type

**ADD_FIELD on a model:**
- Always check if migration is needed (SQL schema change vs. JSONB/computed field)
- Check if repository uses explicit SELECT column lists (breaks if column added but not selected)
- Check if frontend type mirror exists — add field there too

**ADD_ENDPOINT:**
- New handler function → new route registration → middleware chain → service method (may be new or existing) → repository (may be new or existing) → frontend API call → frontend UI if applicable

**RENAME:**
- Highest risk. Use grep to find ALL occurrences before planning.
- Check: serialized data (JSON field names), DB column names, API request/response field names, frontend keys, test fixtures, documentation.
- Plan: rename definition first, then each usage in dependency order.

**REMOVE:**
- Check for usages before confirming removal is safe.
- If heavily used: flag as BREAKING and recommend deprecation path instead.

**FIX_BUG:**
- Identify the exact file:line from the stack trace or description.
- Use file-index.md to understand which layer owns the bug.
- Check if the fix requires changes in callers (input validation) or callees (return value handling).
</process>

<success_criteria>
- [ ] Intent parsed and change type classified
- [ ] Target symbol located in file-index.md (or sourced from grep with caveat)
- [ ] Blast radius classified and communicated
- [ ] Relevant invariants from index.md surfaced as plan line items
- [ ] Change plan lists every affected file with exact path and approximate line
- [ ] Unaffected files listed with reasons
- [ ] Edit order accounts for compile-time and runtime dependencies
- [ ] DB migration need assessed
- [ ] Frontend impact assessed
- [ ] User confirmed before any editing begins
- [ ] Each target symbol's current line re-grepped immediately before its edit (verify-before-edit)
- [ ] Any `(inferred)` fact the change depends on was confirmed by reading before being relied on
</success_criteria>
