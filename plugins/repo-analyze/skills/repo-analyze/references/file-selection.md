<overview>
Smart file selection tiers and token optimization rules. Apply these before reading any source file.
</overview>

<selection_tiers>
**Tier 1 — Always read (critical architecture):**
- Entry point / bootstrap file
- Router / route registry
- Database connection / ORM setup
- Auth middleware
- Config schema / struct

**Tier 2 — Read on demand (when relevant to current task):**
- Individual handler/controller implementations
- Service method bodies
- Individual test files
- Specific UI components

**Tier 3 — Read only the first 50 lines:**
- Files over 500 lines
- Migration files (newest 3 only, structure only)
- Large configuration files

**Tier 4 — Never read unless explicitly requested:**
- Lock files (`*.lock`, `package-lock.json`, `go.sum`)
- Generated files
- `node_modules/`, `vendor/`, `.venv/`, `__pycache__/`, `.git/`
- `dist/`, `build/`, `out/`, `.next/`, `.nuxt/`
- Binary, image, font files
- Log and temp files
- Old migration files (more than 3 revisions back)
</selection_tiers>

<token_optimization_rules>
These rules are non-negotiable:

1. **Read once per session.** Track every file read. Never read it again.
2. **Knowledge files are ground truth.** If `routes.md` says a route exists, don't verify by re-reading source.
3. **Never quote code in knowledge files.** Describe what code does — never reproduce it.
4. **Stop reading early.** If the first 30 lines answer the question, stop at line 30.
5. **Parallel reads.** When multiple files are needed, read them all simultaneously.
6. **Pattern-match before reading.** If 8 files share a pattern, read 1 and apply the pattern to the other 7.
7. **Skip known-skip directories.** Never read: `node_modules/`, `vendor/`, `.git/`, `dist/`, `build/`, `__pycache__/`, `.venv/`, `*.lock`, generated files.
8. **Imports only for dependency mapping.** When building the dependency graph, read only import statements — not function bodies.
9. **Compress before storing.** Every knowledge file entry must be the most compressed accurate representation possible.
10. **Budget awareness.** Before reading a large file (>300 lines), ask: does this file earn its token cost? If it only confirms what the knowledge graph already says, skip it.
11. **Extract symbols with search, not reads.** A symbol's `file:line` is on its declaration line — `grep -n` returns it without opening the file. Never read a file body just to record where something is defined or used. Reading is for the handful of Tier-1 architecture files only; everything else is grep. (See symbol-indexing.md grep patterns.)
12. **One grep beats many reads.** A single `rg -n "<pattern>"` across the repo replaces opening dozens of files. Prefer a repo-wide search over per-file reads whenever you need the same kind of information from many files.
</token_optimization_rules>
