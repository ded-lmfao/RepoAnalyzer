<required_reading>
Load these knowledge files before proceeding:
1. `.claude/repo-knowledge/index.md` — architecture context + stale risk check
2. `.claude/repo-knowledge/file-index.md` — exact file:line locations + cross-references (load if present)
3. `templates/impact-report.md` — impact report format
</required_reading>

<process>
## On-Demand Queries

Used for `--impact`, `--flow`, `--model`, `--module` modes. These queries operate primarily from the existing knowledge graph — they should rarely need to read source files.

**Always start by loading the knowledge store:**
1. Read `.claude/repo-knowledge/index.md`. **Monorepo:** if the store is a multi-service layout (`.claude/repo-knowledge/<service>/`), read the workspace index.md first, map `<target>` to its owning service (by path prefix or the service that defines the symbol), then load that service's index.md + file-index.md. If the target spans services, load both and report the cross-service edge.
2. Check stale risk — if HIGH, warn the user before proceeding
3. Load the specific knowledge file relevant to the query

---

## --impact <target>

Produce an impact report for a file, function, module, model, or config key.

**Step 1 — Resolve the target**
- Match `<target>` against routes.md, data-model.md, dependencies.md, config.md
- If ambiguous (matches multiple), ask the user to clarify

**Step 2 — Look up the target in file-index.md first**
If the symbol is in file-index.md: use its exact file:line and pre-built cross-reference data — do not re-read source files.
If not in file-index.md: fall back to dependencies.md for module-level impact, then load architecture.md if needed.

**Step 3 — Deliver impact report** using templates/impact-report.md format.
When file-index.md is available, every entry in the report must include exact file:line — e.g., "src/handlers/users.py:L23 (create_user)" not just "users handler".

Risk classification:
- `LOW` — leaf module, no dependents, no DB schema change, well-tested
- `MEDIUM` — 1–5 dependents, or DB migration needed, or partial test coverage
- `HIGH` — hub module (5+ dependents), breaking API change, no test coverage, or cross-service impact

Always deliver this report before suggesting code changes.

---

## --flow <name>

Trace a named execution flow end-to-end.

1. Match `<name>` against flows.md (fuzzy match acceptable: "auth", "login", "create order", "checkout")
2. If found in flows.md: expand the trace with any detail the user needs
3. If not found: build the trace using routes.md + dependencies.md + data-model.md
   - Do NOT read handler/service bodies unless the knowledge files are insufficient
4. Present as: `Trigger → [step] → [step] → ... → Response` with auth, validation, and side-effect callouts

---

## --model <name>

Deep-dive on a data model and its relationships.

1. Load data-model.md, find the model
2. Report:
   - All fields with types
   - All relationships (direction, type, cardinality)
   - Which routes/endpoints touch this model (from routes.md)
   - Which services own this model (from dependencies.md)
   - Any soft-delete, audit, or timestamp patterns
   - Migration notes if present
3. Only read source model file if data-model.md is insufficient

---

## --module <name>

Deep-dive on a module, its callers, and its dependencies.

1. Load dependencies.md, find the module
2. Report:
   - Single-sentence responsibility
   - What it imports (outbound edges)
   - What imports it (inbound edges — its callers)
   - Routes that ultimately invoke it
   - External services it touches
   - Events it produces or consumes
3. Classify: hub / mid-tier / leaf module
4. Flag if it is a god file or has coupling risks (cycles)
</process>

<success_criteria>
- [ ] Knowledge store loaded before any source file read
- [ ] Stale risk checked and communicated if HIGH
- [ ] Target resolved without ambiguity (or user asked to clarify)
- [ ] Report delivered in correct template format
- [ ] Source files read only when knowledge files are insufficient
- [ ] For --impact: risk level assigned with justification
</success_criteria>
