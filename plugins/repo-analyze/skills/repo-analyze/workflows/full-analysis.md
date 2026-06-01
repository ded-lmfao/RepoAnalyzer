<process>
Phase 0 runs in SKILL.md before this workflow loads. By the time you are here, prior knowledge was confirmed absent and a full analysis is needed.

<token_budget>
Target ceilings for the whole analysis. If a phase blows its budget, you are reading too much — switch to grep/stop-early. These are guides, not hard stops, but treat overshoot as a signal.

| Phase | Read budget | Technique that keeps you under it |
|-------|------------|-----------------------------------|
| 1 Discovery | ~15 files | Glob + read manifests/configs only; classify dirs by name, don't open them |
| 2 Architecture | ~10–20 files | Read only Tier-1 files (entry, router, db, auth, config). Pattern-collapse repeated handlers. |
| 2.6 Symbol index | **0 file reads** | Grep declaration patterns — file:line without bodies |
| 3 Dependencies | imports only | Stop at first non-import line; grep import statements in bulk |
| 4 Flows | 0 new reads | Compose from route map + module graph already built |
| 5 Store | 0 reads | Write compressed knowledge; total store < 3,000 tokens |

A small repo (<50 files) should cost well under 30 file reads total. A large repo should cost no more than ~50 — the rest is grep.
</token_budget>

---

## Phase 1 — Discovery

**[Load now: references/discovery.md, references/file-selection.md]**

**1.0 Reuse prior docs first** (see discovery.md `<prior_documentation>`): read any existing `CLAUDE.md` / `AGENTS.md` / `README.md` and extract claimed stack, entry points, run commands, and conventions as **unverified claims**. Skip repo-analyze's own `## Repo Intelligence` section in CLAUDE.md. These claims *target* the sub-phases below so you verify instead of search — and any claim that contradicts the code becomes a recorded discrepancy.

Then run all five sub-phases in **[PARALLEL]** — issue all reads simultaneously:
- **[PARALLEL]** 1.1 Manifest detection (see discovery.md)
- **[PARALLEL]** 1.2 Entry point detection (see discovery.md)
- **[PARALLEL]** 1.3 Directory classification — list top-level + 2 levels deep, classify each (see discovery.md)
- **[PARALLEL]** 1.4 Config surface — read .env.example and equivalents (see discovery.md)
- **[PARALLEL]** 1.5 Toolchain detection — note what exists, do not fully read (see discovery.md)

**Stop early:** Once you have language, entry point(s), and a classified directory map — that is enough to proceed to Phase 2. Do not enumerate every file.

**Classify the repo class** (see discovery.md `<repo_class_detection>`): APPLICATION / LIBRARY / CONTENT_DOCS / IAC_CONFIG / DATA / PROMPT_SKILL / META_MONOREPO. This decides which Phase 2 sub-phases apply. If there is no manifest AND no entry point, the repo is a non-application class — do **not** fire the "no entry point" failure mode; switch to the content-mapping path in specialized-detection.md.

**After Phase 1:** Check references/specialized-detection.md to see which domain patterns apply (monorepo, multi-tenant, content/declarative repo, etc.) and adjust the remaining phases accordingly.

**Output — Repository Identity Card:**
```
Name, Repo class, Language(s), Framework(s), Type, Entry points, Directory map, Config keys, Toolchain
```

Mark index.md with `PARTIAL_ANALYSIS: true / BLOCKED_AT: Phase 1` if you must stop here.

---

## Phase 2 — Architecture Core

**[Load now: references/architecture.md]**

**First, branch on repo class (from Phase 1):**
- `APPLICATION` → run 2.1–2.6 as written.
- `LIBRARY` → run 2.1 (bootstrap = public entry), skip 2.2/2.4; replace 2.3 with "public API surface + exported symbols"; run 2.5–2.6.
- `CONTENT_DOCS` / `IAC_CONFIG` / `DATA` / `PROMPT_SKILL` → **skip 2.2 routing, 2.3 data layer, 2.4 auth entirely.** They do not exist. Instead map the structure for that class (see specialized-detection.md `<content_or_declarative_repo>`), then run 2.6 symbol indexing adapted to the unit of that repo (document, module, resource, skill file). Do not escalate over missing routes/models.

For APPLICATION repos, continue as written. Read minimum files per question. Stop reading each file as soon as the question is answered.

**2.1 Bootstrap** — read each entry point. Extract: init order, middleware registered, ports bound, background processes, shutdown sequence. Stop at the first non-assembly line.

**2.2 Routing** — find route/command registry files (see architecture.md for framework patterns). Read every registration file.
- **Stop early:** Once you have a complete domain list and total route count, stop. A partial route list annotated "N more routes in [file]" is better than over-reading.
- Extract per-route: path, method, handler reference, middleware, auth requirement.

**2.3 Data layer** — find model/schema files. Read newest 3 migration files only (structure, not data). For models: name, PK, top 5–8 fields, all relationships, soft-delete/audit patterns.
- **Stop early:** If 10+ models follow the same base pattern, confirm with 2 samples and apply pattern to the rest.

**2.4 Auth** — find auth middleware and JWT/session logic. Extract: mechanism, token claims, expiry, multi-tenant isolation, permission model.

**2.5 Services** — list every service/domain object by name from DOMAIN-classified directories. One-sentence responsibility per service derived from file name and exported function names only. **Do NOT read service bodies.**

**2.6 Symbol Indexing** — **[Load now: references/symbol-indexing.md, templates/file-index.md]**

This phase builds the precise, non-compressed file map that agents use when making changes. Run while the files from 2.1–2.5 are still in context — do not re-read.

**Do not read files for this phase.** Use the grep declaration patterns in symbol-indexing.md — one search per language pattern returns every symbol's `file:line` across the whole repo. This is the cheapest, most complete way to build the index.

Record for every key symbol:
- Exact file path + line number (straight from the grep hit)
- What it is (struct, function, interface, type, config field)
- **[PARALLEL]** Cross-reference: which other files use this symbol — grep the symbol name (`rg -n "SymbolName\b"`); the match lines are the usages. This is self-contained — do **not** wait for Phase 3.

Then for each key domain entity, write its **change propagation chain** (the ordered list of files that must be edited when that entity changes). See symbol-indexing.md for format.

Also build the **Route → Handler → Service → DB map** (one entry per route) using the data from 2.2.

Output goes to `file-index.md` in the knowledge store. See templates/file-index.md for format.

**Stop early:** Index the top 5–10 most-changed domain entities deeply. For less central entities, record file path only — skip cross-references. An 80% complete symbol index is far more useful than no index.

Mark `BLOCKED_AT: Phase 2` if you must stop here.

---

## Phase 3 — Dependency Graph

**[Load now: references/dependencies.md]**

Read only import/require/use statements — not function bodies. Stop at the first non-import line in each file.

- **[PARALLEL]** Module map: build `A → imports → B` for DOMAIN, API, INFRA files simultaneously
- **[PARALLEL]** External service scan: search for HTTP client, DB, broker, storage, email, payment patterns
- Event/message system: only if event patterns were detected in Phase 1

Identify: hub modules (5+ importers), leaf modules, cycles, god files.

**Stop early:** Once hub modules are identified and external services are mapped, move on. You do not need to map every leaf module's imports.

Mark `BLOCKED_AT: Phase 3` if you must stop here.

---

## Phase 4 — Execution Flow Tracing

**No new files to load.** Use route map and module graph already built — do not read source file bodies.

Trace 3–5 critical flows in priority order:
1. Most common user-facing operation (primary CRUD)
2. Authentication flow
3. Most complex flow (most service hops)
4. Async/background flow (if present)
5. Payment or safety-critical flow (if present)

Format per flow:
```
Trigger → [Middleware] → Handler → [Service] → [DB/Cache] → [External?] → [Event?] → Response
```
Note: where auth is verified, where input is validated, where errors branch, what side effects occur.

**Stop early:** 3 flows is sufficient for most repos. Only trace 4–5 if the complexity clearly warrants it.

Mark `BLOCKED_AT: Phase 4` if you must stop here.

---

## Phase 5 — Compress and Store

**[Load now: references/knowledge-store.md, references/health-scoring.md, templates/analysis-report.md, templates/knowledge-index.md]**

Apply compression rules (knowledge-store.md) before writing anything.

**Knowledge store location:**
1. `.claude/` exists at repo root → write to `.claude/repo-knowledge/`
2. Else if the target is the user's own writable project → create `.claude/repo-knowledge/` at its root.
3. **If the target is read-only, a vendored/dependency directory (`node_modules/`, `vendor/`, `site-packages/`, etc.), or otherwise not the user's project** → do NOT write inside it. Use a central store at `~/.claude/repo-knowledge/<repo-name>/` instead, and tell the user where the graph was written. Never create files inside a third-party or read-only tree.
4. If unsure whether writing is wanted (e.g., analyzing someone else's repo for reference), ask once before creating files.

If a `.gitignore` exists and the store is repo-local, note (don't force) that `.claude/repo-knowledge/` can be added to it so the graph isn't committed unless the user wants it.

**Write these files** (use templates/knowledge-index.md for index.md format). **Write index.md LAST** — its presence with `Store status: COMPLETE` is the atomic signal that the store finished; writing it last means an interrupted run leaves no false "complete" marker.
- `architecture.md` — identity, stack, bootstrap, toolchain
- `routes.md` — route/command registry compressed by domain (skip for non-application repo classes)
- `data-model.md` — all models, key fields, relationships (or dataset/resource inventory for DATA/IAC)
- `dependencies.md` — module graph, external services, events
- `flows.md` — 3–5 critical execution traces
- `config.md` — every config key, type, default, what breaks without it — **never the secret values**
- `file-index.md` — exact file:line symbol map + cross-references + change propagation chains (use templates/file-index.md)
- `index.md` — **written last** — master index with Q&A Quick Reference, Invariants & Gotchas, `Schema version: 2`, `Store status: COMPLETE`, `Index confidence` from 5.5

## Phase 5.5 — Validate before declaring COMPLETE

A knowledge graph that is confidently wrong is worse than none. Before writing `Store status: COMPLETE`, spot-check the index against reality — cheaply:

1. Sample 3–5 entries from file-index.md (prefer the key domain entities).
2. For each, grep the symbol in its claimed file (`rg -n "SymbolName" path`) and confirm it appears at/near the recorded line (±5).
3. Record the result in index.md: `Index confidence: [N validated / M sampled]`.
4. If any sampled entry is wrong by more than a few lines → the indexing drifted; re-grep that layer and fix before completing. If multiple are wrong → do not mark COMPLETE; mark `PARTIAL_ANALYSIS` and report the problem.

This costs a handful of greps and converts the index from "asserted" to "spot-verified."

**Remove** `PARTIAL_ANALYSIS` flag from index.md if present (only after 5.5 passes).

**CLAUDE.md integration:**
- Doesn't exist → create with architecture content, 500 tokens max
- Exists → append a clearly delimited `## Repo Intelligence` section

Compute health scores using references/health-scoring.md.

Deliver final report using templates/analysis-report.md. Use compact format if repo has fewer than 50 source files. End the report with one **Token economy** line: `Files read: [N] · Symbols grep-indexed: [M] · Knowledge store: ~[K] tokens · Index confidence: [N/M validated]` — this proves the analysis was cheap and spot-verified.

**Always finish with the COMMAND REFERENCE FOOTER from templates/analysis-report.md** — the "🧭 What you can do next" table — so the user sees exactly which command to run next.
</process>

<success_criteria>
- [ ] Repository Identity Card produced
- [ ] All routes/commands catalogued (or stop-early annotated)
- [ ] All models with relationships captured
- [ ] Auth mechanism documented
- [ ] Services listed with single-sentence responsibilities
- [ ] Hub modules and external services identified
- [ ] 3–5 execution flows traced
- [ ] Knowledge files written to `.claude/repo-knowledge/`
- [ ] file-index.md has symbol cross-references and change propagation chains for key entities
- [ ] Route → Handler → Service → DB map complete
- [ ] index.md Quick Reference uses Q&A format
- [ ] Invariants & Gotchas section filled (or "None identified" after a real search)
- [ ] Inferred (not-read) facts marked `(inferred)`; secret values never stored
- [ ] Phase 5.5 validation run; `Index confidence` recorded
- [ ] index.md written LAST with `Schema version: 2` and `Store status: COMPLETE`
- [ ] Token economy line reported (files read + symbols grep-indexed + store size)
- [ ] Health scores computed
- [ ] Final report delivered
</success_criteria>
