# [Project Name] — Repo Intelligence Index
Schema version: 2
Store status: COMPLETE
Generated: [ISO date]
Last incremental update: [ISO date or "none"]
Git HEAD at last analysis: [commit hash or "no git"]
Files analyzed: [count]
Index confidence: [N validated / M sampled]
Language(s): [list]
Framework(s): [list]
Repo class: [APPLICATION | LIBRARY | CONTENT_DOCS | IAC_CONFIG | DATA | PROMPT_SKILL | META_MONOREPO]
Type: [Web API | Frontend | CLI | Library | Monorepo | Worker | Docs | IaC/Config | Data | Prompt/Skill | Other]
Entry: [path(s)]
Stale risk: [LOW / MEDIUM / HIGH]

## Quick Reference

Write each entry as a predicted Q→A pair. Aim for answers that make reading any other file unnecessary.
Choose the 5–8 questions that will be asked most often for THIS specific repo.
The goal: answer 80% of future questions without loading any other knowledge file.

Questions that almost always apply (fill in answers from the analysis):

```
Q: What is the entry point and how is the app started?
A: [file:line]. Run with: [exact command from Makefile/scripts/README]

Q: How does authentication/authorization work?
A: [mechanism — JWT/session/API key/OAuth/none]. [Where enforced — middleware file:line].
   [Token/session structure if relevant]. [What happens on failure].

Q: Where are routes/commands registered and how many are there?
A: [file:line]. [N total]. [Pattern — e.g., grouped by domain, all under /api/v1/, public vs protected].

Q: What is the data layer? How does the app talk to storage?
A: [DB type]. [ORM/query library or raw SQL]. [Schema approach — migrations/auto/code-first].
   [Connection config — which env var].

Q: How do I add a new [route/command/feature] following existing patterns?
A: [The pattern — e.g., "create handler in handlers/, register in router.go, add service method in services/"]
```

Additional questions to add based on what this repo actually does:

```
Q: How does [the most complex or unusual thing in this repo] work?
A: [discovered answer]

Q: What env vars are required to run this?
A: [list the required ones with what they control]

Q: What happens when [the most common failure mode] occurs?
A: [discovered answer — e.g., 401 refresh flow, DB connection failure, queue consumer crash]
```

## Invariants & Gotchas

The rules an AI must not break when changing this code. This is the single most valuable section for safe edits — capture every cross-cutting constraint discovered during analysis. Keep it to hard rules, not style preferences.

```
- [Constraint that spans files — e.g., "every DB query must be scoped by tenant_id; unscoped queries leak data across tenants"]
- [Sync requirement — e.g., "the Prisma model, the TS DTO, and the zod schema must all carry the same fields or requests fail validation"]
- [Generated/derived artifact — e.g., "API types in src/types/api.gen.ts are generated; edit the OpenAPI spec, not the file"]
- [Ordering/transaction rule — e.g., "user.created event must fire after the DB commit, not before"]
- [Naming contract — e.g., "JSON field names are snake_case on the wire; renaming a struct field breaks clients unless the tag is preserved"]
- [Migration rule — e.g., "schema changes require a new migration file; AutoMigrate is debug-only"]
```

If none are discovered, write `None identified` — but look hard for multi-tenant scoping, serialization tags, generated files, and front/back type mirrors before concluding that.

---

Example answers for different project types (replace with real answers for THIS repo):

**Go REST API:**
```
Q: What is the entry point and how is the app started?
A: cmd/server/main.go:L1. Run: make dev (uses air for hot reload) or go run ./cmd/server.

Q: How does authentication work?
A: JWT HS256 in Authorization header. Verified in middleware/auth.go:L14 AuthRequired().
   Claims: {user_id, role, jti}. Access 15min, refresh 7d. Logout blacklists JTI in Redis.

Q: Where are routes registered?
A: internal/router/router.go. 42 routes grouped by domain under /api/v1/.
   Public: /auth/*, /health. All others require AuthRequired() middleware.

Q: What is the data layer?
A: PostgreSQL via GORM. Models in internal/models/. Migrations in migrations/ (run manually).
   Connect via DATABASE_URL env var.

Q: How do I add a new domain?
A: 1. Model in internal/models/. 2. Handler in internal/handlers/. 3. Register routes in router.go.
```

**Python FastAPI:**
```
Q: What is the entry point and how is the app started?
A: app/main.py:L1. Run: uvicorn app.main:app --reload or docker-compose up.

Q: How does authentication work?
A: OAuth2 password flow. JWT in Bearer header. Verified via Depends(get_current_user) in app/deps.py:L12.
   Token generated in app/routers/auth.py:L34.

Q: Where are routes registered?
A: app/main.py:L18 includes routers. Each domain has its own router in app/routers/.
   8 routers, all prefixed /api/v1/.

Q: What is the data layer?
A: PostgreSQL via SQLAlchemy async. Models in app/models/. Alembic migrations in alembic/versions/.
   Schema managed via SQLALCHEMY_DATABASE_URL env var.
```

**TypeScript CLI tool (Node):**
```
Q: What is the entry point?
A: src/index.ts:L1 → bin/cli.js after build. Run: npx ts-node src/index.ts or npm run build && ./bin/cli.

Q: How are commands registered?
A: src/commands/ — one file per command. Registered in src/index.ts:L18 via Commander.js.
   12 commands total.

Q: How does the tool persist state?
A: ~/.config/[toolname]/config.json — read/written via src/config.ts:L8.

Q: How do I add a new command?
A: 1. Create src/commands/mycommand.ts implementing Command interface (src/types.ts:L5).
   2. Register in src/index.ts:L18.
```

**Rust library (crate):**
```
Q: What is the public API surface?
A: src/lib.rs re-exports the public types. Key types: [list]. Key functions: [list].
   Full API in src/lib.rs:L1.

Q: How is the library structured internally?
A: src/lib.rs (public re-exports) → src/[module].rs (implementations).
   Feature flags in Cargo.toml control optional dependencies.

Q: How do I run tests?
A: cargo test. Integration tests in tests/. Doc tests inline in src/lib.rs.
```

**C embedded/systems:**
```
Q: What is the entry point?
A: src/main.c:L10 main(). Build: make all. Flash: make flash (uses OpenOCD).

Q: How is the project structured?
A: include/ — all headers (.h). src/ — all implementations (.c).
   HAL layer in src/hal/ abstracts hardware. Application logic in src/app/.

Q: How does configuration work?
A: Compile-time: include/config.h #defines. Runtime: config loaded from EEPROM in src/config.c:L12.
```

---

## Coverage Gaps / Known Unknowns
Declare the boundaries of this graph so a consumer knows where knowledge ends. List what was deliberately NOT analyzed or only partially covered — so the agent reads source there instead of trusting silence.
```
- [area stopped-early on — e.g., "only 5 of 18 services deep-indexed; rest are file-path-only"]
- [subsystem not traced — e.g., "background job internals not read, only entry points"]
- [anything flagged (inferred) that wasn't verified]
- [generated/vendor code intentionally skipped]
```
If coverage is total for this repo's size, write `None — full coverage for repo of this size`.

## Coverage
- architecture.md — identity, stack, bootstrap, toolchain
- routes.md — complete route/command registry
- data-model.md — all models, fields, relations
- dependencies.md — module graph, external services, events
- flows.md — critical execution paths
- config.md — all config keys and what controls them
- file-index.md — exact file:line symbol map + cross-references + change propagation chains

## Changelog
[date]: full analysis — [N] files, [stack summary]
[date]: incremental — updated [files] after [N] commits
