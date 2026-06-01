<overview>
Compression rules, knowledge file formats, and freshness tracking.
</overview>

<compression_rules>
Apply before writing anything to the knowledge store. Target: entire codebase in under 3,000 tokens across all knowledge files.

**Pattern collapse:** N files with the same pattern → write the pattern once + count.
- BAD: `src/handlers/users.py, src/handlers/orders.py, src/handlers/products.py ...`
- GOOD: `12 handler files — src/handlers/<domain>.py, each registers CRUD routes for one domain`

**Structure compression:** Shared base → write the base once.
- BAD: `User{id int, created_at, email} Order{id int, created_at, total} Product{id int, created_at, name}`
- GOOD: `All models inherit Base(id: int, created_at, updated_at). User adds: email, password_hash. Order adds: total, status. Product adds: name, price.`

**Route compression:** Group by domain, not individual entries.
- BAD: `GET /users, POST /users, GET /users/:id, PUT /users/:id, DELETE /users/:id`
- GOOD: `users: full CRUD (5 routes), auth required, RBAC: users.view/create/edit/delete`

**Dependency compression:** Describe patterns, not exhaustive lists.
- BAD: `A imports B, A imports C, A imports D, A imports E`
- GOOD: `A is a hub module (12 importers). Imports: B(config), C(db), D(auth).`

**Never quote code.** Describe what code does — never reproduce it.

**Never store secret values.** When capturing config, record the key name and what it controls — never the value. If a config file, source file, or `.env` contains an inline credential (API key, password, token, connection string, private key), write `[secret — value not stored]` in its place. The knowledge graph is a structural map, not a copy of the repo's secrets. This holds even if the value is already committed in the repo.

**Mark provenance on load-bearing facts.** This skill infers aggressively to save tokens (deriving auth from a dependency, a model pattern from 2 samples, a flow from the route+module maps without reading bodies). Inference can be wrong. Any fact that was *not directly read* but *deduced* must carry `(inferred)` — e.g., `Auth: JWT HS256 (inferred from golang-jwt dependency + middleware name, not read)`. Facts confirmed by reading the relevant file need no mark. The rule for the consumer: **an `(inferred)` fact must be verified before code is changed on the strength of it.** This is what makes confident-but-wrong knowledge detectable instead of silently load-bearing.
</compression_rules>

<knowledge_file_formats>
**`index.md`** — master index, loaded first on every future request. See templates/knowledge-index.md.

**`architecture.md`** — identity + bootstrap + technology decisions

**`routes.md`** — complete route/command registry compressed by domain

**`data-model.md`** — all models/tables, key fields, all relationships

**`dependencies.md`** — module graph (hub modules, cycles, leaves), external services, event system

**`flows.md`** — 3–5 critical execution traces in `Trigger → ... → Response` format

**`config.md`** — every config key: type, default, what it controls, what breaks without it
</knowledge_file_formats>

<freshness_tracking>
Every `index.md` must have:
```
Schema version: 2
Store status: COMPLETE          ← COMPLETE only after all Phase 5 files are written + validated
Last full analysis: [ISO date]
Last incremental update: [ISO date or "none"]
Git HEAD at last analysis: [commit hash or "no git"]
Files analyzed: [count]
Index confidence: [N validated / M sampled]   ← from Phase 5.5
Stale risk: LOW / MEDIUM / HIGH
```

**Schema version** = the knowledge-store format this skill writes. Current: **2** (adds file-index.md, Invariants & Gotchas, repo class, provenance marks). On read, if the stored `Schema version` is missing or lower than current, the graph predates the current format and is missing layers — treat as a structural rebuild candidate: warn and recommend `--rebuild` (CONSUME modes may still answer from what exists, but flag that file-index/invariants may be absent).

**Store status** guards against half-written graphs. Write `Store status: WRITING` to index.md is unnecessary — instead **write index.md LAST** (Phase 5), so the presence of a complete index.md with `Store status: COMPLETE` is itself the atomic signal that the store finished. If a run finds knowledge files but index.md is missing or says anything other than COMPLETE, the previous write was interrupted → the store is untrusted → rebuild.

Stale risk:
- `LOW` — within 7 days AND fewer than 20 commits
- `MEDIUM` — 7–30 days OR 20–50 commits
- `HIGH` — 30+ days OR 50+ commits OR user reports major refactor

When stale risk is HIGH: recommend full re-analysis before impact analysis or code changes. **Regardless of stale risk, any agent about to EDIT code from file-index.md must verify the target symbol's current line before editing** (see plan-change.md verify-before-edit) — line numbers drift on every edit and a confident wrong line causes a wrong edit.

**Partial analysis flag** — if analysis was interrupted, set in index.md:
```
PARTIAL_ANALYSIS: true
BLOCKED_AT: Phase [N]
```
On next invocation, read checkpoints to resume from Phase N without re-running completed phases. Remove these flags on successful completion.
</freshness_tracking>

<resume_on_partial>
When `index.md` has `PARTIAL_ANALYSIS: true`:

1. Read `BLOCKED_AT` phase number
2. Each phase writes a summary comment at the end of the relevant knowledge file when it completes:
   `<!-- phase[N] complete: [ISO date] -->`
3. Find the last knowledge file with a complete marker to confirm what was actually finished
4. Load the workflow and skip to the blocked phase
5. Do not re-run completed phases
</resume_on_partial>
