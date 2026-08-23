**The full graph lives in `.claude/repo-knowledge/` — the chat report is a receipt, not a copy of it.** Do not reprint route lists, model fields, flows, or config keys in chat; they are already on disk and re-printing them doubles the token cost of the analysis. The user asks follow-ups and you answer from the store.

Default to the **RECEIPT** format below for every repo. Only expand to **DETAIL** if the user explicitly asks for a full written summary in chat (e.g. "give me the whole breakdown here").

---

# RECEIPT FORMAT (default)

```
# [Project Name] — analyzed

[Stack] · [Type] · [N source files] · Health [X.X/10]
Entry: [path → what it starts]
Knowledge store: .claude/repo-knowledge/ (8 files, ~[K] tokens)
[Top recommendation — only if any health dimension < 7, one line]

Token economy: read [N] files · grep-indexed [M] symbols · store ~[K] tokens (~[P]% smaller than the ~[S]-token source it maps) · confidence [N/M]
```

`[S]` = rough token size of the source the graph covers; `[P]` = `(1 - K/S) * 100`. This is the recall savings — every future question answered from ~[K] tokens instead of re-reading ~[S].

Then the COMMAND REFERENCE FOOTER (first build → full table once; later runs → one-liner). Nothing else. Routes, models, flows, config are in the store — point, don't print.

---

# DETAIL FORMAT (only on explicit request)

Use only when the user asks for the breakdown in chat. Keep one line per item; never reproduce code or field-by-field model dumps already in the store.

```
# [Project Name] — Repository Intelligence

What: [2 sentences — language, type, purpose, scale]
Pattern: [core architectural pattern, 1 line]

Stack: [one line per real layer: HTTP / DB+ORM / Auth / Cache / Queue / Frontend — omit absent ones]
Entry: [path → what it starts]
Modules: [domain: one-sentence responsibility — one line each]
Routes: [domain group: N routes, auth requirement — one line per group]
Models: [Name: key fields → relations — one line each]
Deps: hubs [list+counts] · external [list] · events [if any]
Flows: [name: trigger → key steps → outcome — one line each]
Config: [KEY: what it controls — one line each]

Health [X.X/10]: Doc [X] · Deps [X] · Tests [X] · CI [X] · Activity [level]
Recommendations: [1–3, only for dimensions < 7]

Store: .claude/repo-knowledge/ — index, architecture, routes, data-model, dependencies, flows, config, file-index
Token economy: read [N] · grep-indexed [M] · store ~[K] tokens (~[P]% smaller than ~[S]-token source) · confidence [N/M]
```

---

# COMMAND REFERENCE FOOTER

**First build for this repo only** (no prior graph existed): print the full table once so the user learns the commands. On `--update`, `--rebuild`, or any later run where a graph already existed: print the **one-liner** instead — the user has seen the table.

One-liner (default for repeat runs):
```
Next: ask me anything (answered from the graph) · `--change <intent>` to plan an edit · `--status` for freshness · `--help` for all commands.
```

Full table (first build only):
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
