---
name: repo-analyze
description: Repository intelligence engine. Converts any codebase into a durable, compressed knowledge graph stored in .claude/repo-knowledge/. Use when asked to analyze a repo, understand a codebase, trace a flow, assess impact of changes, or refresh knowledge after commits.
---

<essential_principles>
**Discover, never assume.** Every repo is unique until proven otherwise.
**Architecture is permanent. Implementation is ephemeral.** Capture structure, skip bodies.
**Read once. Compress aggressively. Recall precisely.** Knowledge files are ground truth — never re-read a source file already captured there.
**Every file read must justify its token cost** with architectural insight not already in the knowledge graph.
**Prior knowledge always wins.** Check the knowledge store before touching any source file.
**The store is the deliverable; chat is a receipt.** Tokens printed to chat cost as much as tokens read. Never reprint in chat what was just written to the knowledge store — the user can read those files near-free. A finished build reports a ≤10-line receipt (identity, health, store location, token economy) + a one-line "ask me anything" pointer, not a copy of the graph. Answers to questions stay as tight as the question allows.
</essential_principles>

<first_run_setup>
**One-time per machine — runs before the first analysis, then never again.**
This skill reads many files and writes a knowledge store; without standing permissions every action prompts. Make it silent once:

1. Check `~/.claude/settings.json` → `permissions.allow`. If it already contains `Read` and `Write(.claude/repo-knowledge/**)`, setup is done — skip silently.
2. If missing → load `references/permission-setup.md` and apply it. This merges the analyzer's allow-rules into the **user/global** settings (covers every repo with a single approval — never per-repo). The user clicks yes once to the settings write.
3. If the user declines, or the file can't be written → proceed with analysis anyway. **Never block analysis on this** — it just means actions will prompt until set up.

Scope is deliberately narrow: read access + writes confined to `repo-knowledge/`. Never request broad write/edit access to source code.
</first_run_setup>

<output_style>
**All chat output is caveman-terse.** This compounds the receipt principle: that rule cuts *what* prints, this cuts *how* it is phrased. Roughly 75% fewer words, zero technical loss.

- Drop articles (a/an/the), filler (just/really/basically/simply/actually), pleasantries, hedging. Fragments OK. `[thing] [state] [reason].` over full sentences.
- Short synonyms: "big" not "extensive", "fix" not "implement a solution for".
- Receipts, change plans, impact reports, status, and free-form answers all use this voice.

**Intensity levels** (mirror caveman; default = full). Pick from the invocation or honor an active caveman level if one is set for the session:
- `lite` — professional but tight: no filler, keep articles + full sentences.
- `full` — **default**: drop articles, fragments OK, short synonyms.
- `ultra` — telegraphic: abbreviate prose words only; never abbreviate code symbols, function names, or file:line.
Select with `--verbosity lite|full|ultra` on any invocation. No level given → full.

**NEVER compress (reproduce exact, unchanged):**
- file:line refs, file paths, symbol names
- code blocks, commands, config keys, env var names
- error strings (quote verbatim)
- invariants / gotchas / security warnings (full clarity — see SKILL `<escalation_triggers>` and knowledge-store secret rules)
- the COMMAND REFERENCE FOOTER table (verbatim when printed)
- irreversible-action confirmations and WIDE/BREAKING blast-radius warnings — write these in plain full sentences so they cannot be misread.

Match the user's language; compress style, not language.
</output_style>

<phase0_prior_knowledge_check>
**Run this before loading any workflow. Do not proceed until complete.**

**`--help` short-circuits everything:** print the full footer table from templates/analysis-report.md and stop. No graph, preflight, or workflow needed.

First classify the invocation intent:
- **BUILD** — bare `/repo-analyze`, `--update`, or `--rebuild`: the goal is to create or refresh the knowledge graph.
- **CONSUME** — `--impact`, `--flow`, `--model`, `--module`, `--change`, `--status`, or any post-analysis question: the goal is to *use* the graph to answer something. Never short-circuit a CONSUME request with "knowledge is current" — current knowledge is exactly what lets you answer it.

1. Look for `.claude/repo-knowledge/index.md` at the target path.

2. **Knowledge found** — load it (~200 tokens). First run two integrity gates, then the freshness check:
   - **Integrity gate A — store complete?** If index.md is missing `Store status: COMPLETE` (or other knowledge files exist but index.md doesn't), the last write was interrupted → the store is untrusted. Announce it and treat as a rebuild (load `workflows/full-analysis.md`).
   - **Integrity gate B — schema current?** If `Schema version` is missing or < 2, the graph predates the current format (no file-index/invariants/provenance). For BUILD → rebuild. For CONSUME → warn ("graph is schema v[X]; file-index/invariants may be absent — run `--rebuild`"), then answer from what exists.
   - **Freshness:** extract `Git HEAD at last analysis`, run `git diff --name-only <last_commit> HEAD` (or `git log --oneline -5` if HEAD unknown):
     - **BUILD:** zero files changed → "Knowledge is current." stop. Files changed → list them, load `workflows/incremental-update.md`. No git → ask "Full re-analysis or incremental update?"
     - **CONSUME:** do **not** stop. If many files changed / stale risk is HIGH, warn once ("knowledge is N commits stale; answering from it anyway — run `--update` to refresh") then proceed to the mode's workflow. `--status` just reports freshness.

3. **Knowledge NOT found:**
   - **BUILD** (or bare invocation) → "No prior knowledge — beginning full analysis." Load `workflows/full-analysis.md`.
   - **CONSUME** → "No knowledge graph yet — building one first, then answering your request." Load `workflows/full-analysis.md`; **on completion, run the requested mode's workflow and deliver the original answer.** Do not drop the user's intent. Exception: `--status` → report "No knowledge graph found — run `/repo-analyze` to build one." and stop.

4. **`--update`** → always BUILD; go to step 2/3 as a refresh.
5. **`--rebuild`** → always BUILD a clean full analysis, ignoring and overwriting any existing store (used when stale risk is HIGH, schema is outdated, the store is corrupt, or after a major refactor). Load `workflows/full-analysis.md` directly; do not run incremental.

**Monorepo note:** if the store is a multi-service layout (`.claude/repo-knowledge/<service>/`), Phase 0 reads the workspace-level index.md first, then resolves which service store the request targets (see on-demand.md / plan-change.md monorepo resolution).
</phase0_prior_knowledge_check>

<operating_modes>
Detect mode from invocation **after** Phase 0 completes:

| Invocation | Mode | Load |
|------------|------|------|
| `/repo-analyze` or `/repo-analyze <path>` | Full analysis or incremental (Phase 0 decides) | see Phase 0 |
| `/repo-analyze --update` | Force incremental update | workflows/incremental-update.md |
| `/repo-analyze --rebuild` | Clean full re-analysis, overwrite store (stale/corrupt/schema-outdated) | workflows/full-analysis.md |
| `/repo-analyze --impact <target>` | Impact report | workflows/on-demand.md |
| `/repo-analyze --flow <name>` | Trace execution flow | workflows/on-demand.md |
| `/repo-analyze --model <name>` | Data model deep-dive | workflows/on-demand.md |
| `/repo-analyze --module <name>` | Module deep-dive | workflows/on-demand.md |
| `/repo-analyze --status` | Coverage + freshness report | workflows/status.md |
| `/repo-analyze --help` | Print the full "🧭 What you can do next" command table and stop | templates/analysis-report.md (footer table only) |
| `/repo-analyze --change <intent>` | Precise file change plan before editing | workflows/plan-change.md |
| Any question about the repo (post-analysis) | In-session query | see context_query below |

**Modifier (not a mode):** `--verbosity lite|full|ultra` on any invocation sets output compression level (see `<output_style>`). Default full.
</operating_modes>

<context_query>
**When knowledge exists and the user asks a question rather than invoking a mode:**

1. Read `index.md` Quick Reference (~200 tokens)
2. If the answer is in Quick Reference → answer immediately. Load nothing else.
3. If more detail needed → read only the one relevant knowledge file:
   - Route/endpoint question → `routes.md`
   - Model/schema question → `data-model.md`
   - "Who calls X" / coupling / "where is X defined" → `file-index.md`
   - "What do I need to change to do X" → load `file-index.md`, then run `workflows/plan-change.md`
   - Flow/sequence question → `flows.md`
   - Config/env question → `config.md`
   - Stack/architecture question → `architecture.md`
4. Read source files only if the knowledge file is insufficient.

**Never load a workflow for a context query.** Workflows are for building or updating the knowledge graph, not answering questions from it.
</context_query>

<preflight>
Execute before anything else. Stop if any check fails — report which check failed and what the user must provide.

- [ ] Target path exists and is a directory (not a file)
- [ ] At least one source file or manifest is present
- [ ] If `--impact`, `--flow`, `--model`, `--module`: target name was provided
- [ ] If path is remote (URL): a local clone or access method is available
</preflight>

<escalation_triggers>
Stop and ask — never guess — when:
- Multiple repos/services at root and unclear which to analyze first
- Analysis depth ambiguous on a large repo (500+ files) → ask "Quick overview or deep architectural analysis?"
- Conflicting entry points at same level with no clear primary
- `--impact` / `--flow` / `--model` / `--module` target is ambiguous (matches multiple things)
- Monorepo with more than 5 distinct services → ask which to prioritize
- No manifest AND no recognizable entry point → cannot determine language or purpose

**Wrong assumptions here corrupt the entire knowledge graph.**
</escalation_triggers>

<on_error>
The moment any workflow hits an error — unreadable file, failed git command, ambiguous structure, truncated read, parse failure — **load `references/recovery.md` and apply its 5-step protocol (PAUSE → DIAGNOSE → ADAPT → RETRY → ESCALATE).** Do not improvise error handling or silently skip. Max 3 retries per failure; on escalation, set `PARTIAL_ANALYSIS: true` / `BLOCKED_AT: Phase N` in index.md before stopping.
</on_error>

<first_message>
One line before doing anything: mode + prior-knowledge state + next action. E.g. `Full analysis (no prior graph) — beginning discovery.` or `Incremental (3 files changed) — refreshing.` No multi-line preamble.

Then proceed without waiting for confirmation unless an escalation trigger fires.
</first_message>

<reference_index>
Load only from within workflows as instructed — do not pre-load:

| Reference | Contents |
|-----------|----------|
| discovery.md | Phase 1: prior-doc reuse (CLAUDE.md/AGENTS.md/README), manifests, entry points, directory classification, repo class, config surface, toolchain |
| architecture.md | Phase 2: bootstrap, routing patterns, data layer, auth, service layer |
| dependencies.md | Phase 3: module graph, external services, event/message systems |
| symbol-indexing.md | Phase 2.6: language vocabulary, grep extraction patterns (file:line without reads), cross-reference + propagation chain format |
| file-selection.md | Smart file selection tiers + token optimization rules |
| knowledge-store.md | Compression rules, knowledge file formats, freshness tracking |
| specialized-detection.md | Domain patterns: monorepo, event-driven, multi-tenant, mobile, CLI, Discord, content/declarative (docs, IaC, data, prompt/skill) |
| health-scoring.md | Repo health scoring rubrics |
| recovery.md | 5-step recovery protocol, error types, failure modes |
| permission-setup.md | One-time: merge analyzer allow-rules into ~/.claude/settings.json (first_run_setup) |
</reference_index>

<workflows_index>
| Workflow | When to use |
|----------|------------|
| full-analysis.md | First-time analysis; no prior knowledge |
| incremental-update.md | `--update` flag or prior knowledge exists with changes |
| on-demand.md | `--impact`, `--flow`, `--model`, `--module` |
| plan-change.md | `--change <intent>` — precise file change plan before editing |
| status.md | `--status` flag |
</workflows_index>
