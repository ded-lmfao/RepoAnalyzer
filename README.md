# repo-analyze

> A Claude Code plugin that turns **any repository, in any language**, into a durable, token-efficient **knowledge graph** — so an AI assistant can understand the codebase deeply and make **precise, safe code changes** without re-reading source on every request.

<p align="left">
  <img alt="Version" src="https://img.shields.io/badge/version-2.0.0-blue">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-green">
  <img alt="Claude Code" src="https://img.shields.io/badge/Claude%20Code-plugin-8A2BE2">
  <img alt="Languages" src="https://img.shields.io/badge/languages-~20%20%2B%20fallbacks-orange">
</p>

---

## Table of contents

- [Why](#why)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Command reference](#command-reference)
- [How it works](#how-it-works)
- [What gets generated](#what-gets-generated)
- [Permissions & security](#permissions--security)
- [FAQ](#faq)
- [Contributing](#contributing)
- [License](#license)

---

## Why

Every time an AI assistant works in a large codebase, it re-reads source files to rebuild context — burning tokens and time, and still missing cross-file coupling. `repo-analyze` solves this once: it performs a deep, structured pass over the repository and writes a compressed **knowledge graph** to `.claude/repo-knowledge/`. From then on, questions, impact assessments, and edit plans are answered from that graph (~200 tokens) instead of re-scanning the source.

The result: cheaper answers, fewer mistakes, and edit plans precise enough to be safe.

## Features

- **One-time analysis** builds `.claude/repo-knowledge/`: a compressed architecture map, an exact `file:line` symbol index, change-propagation chains, execution flows, a configuration map, a data model, and documented invariants.
- **Low-cost answers** drawn from the graph instead of re-reading source files.
- **Precise edit planning** — `--change <intent>` produces a verified, ordered `file:line` plan with **blast-radius classification** and **verify-before-edit**, so it never edits a stale line.
- **Impact analysis** — `--impact <symbol>` traces everything a change to a symbol would touch.
- **Flow tracing** — `--flow <name>` follows an execution path end to end.
- **Always current** — incremental updates driven by `git diff`, schema versioning, and store-integrity + validation gates.
- **Broad coverage** — application, library, documentation, infrastructure-as-code, data, and monorepo projects across ~20 languages, with generic fallbacks for the rest.
- **Monorepo-aware** — supports multi-service stores under `.claude/repo-knowledge/<service>/`.

## Requirements

- [Claude Code](https://docs.claude.com/en/docs/claude-code) — CLI, desktop, web, or an IDE extension.
- A **Git repository** (used for incremental updates and freshness tracking). Non-git folders are supported with a full re-analysis fallback.

## Installation

From within Claude Code:

```text
/plugin marketplace add ded-lmfao/jinxx-repo-analyzer
/plugin install repo-analyze@repo-analyze
```

After installation, reload skills or restart Claude Code.

To update later:

```text
/plugin marketplace update repo-analyze
```

## Quick start

```text
/repo-analyze            # Analyze the current repo and build the knowledge graph
```

Then simply ask questions in natural language — answers come from the graph:

```text
Where is authentication handled?
What would I need to change to add a new API endpoint?
Trace the request lifecycle from route to database.
```

Need a safe, ordered plan before editing?

```text
/repo-analyze --change "add rate limiting to the public API"
```

## Command reference

| Command | Description |
|---|---|
| `/repo-analyze` | Analyze the current repository (builds the graph). |
| `/repo-analyze <path>` | Analyze a specific repository at `<path>`. |
| `/repo-analyze --change <intent>` | Produce a verified, ordered `file:line` edit plan before touching code. |
| `/repo-analyze --impact <symbol>` | Assess the blast radius of changing a symbol. |
| `/repo-analyze --flow <name>` | Trace an execution flow end to end. |
| `/repo-analyze --model <name>` | Deep-dive a data model / schema. |
| `/repo-analyze --module <name>` | Deep-dive a module. |
| `/repo-analyze --update` | Refresh the graph after commits (incremental). |
| `/repo-analyze --rebuild` | Perform a clean, full re-analysis (overwrites the store). |
| `/repo-analyze --status` | Report freshness and coverage. |

You can also just **ask questions** about the repository after analysis — no flag required.

## How it works

1. **Prior-knowledge check.** Before doing anything, the skill looks for an existing graph and runs integrity + freshness gates (store complete? schema current? commits since last analysis?).
2. **Discovery.** Detects manifests, entry points, repo class, toolchain, and configuration surface.
3. **Architecture & symbols.** Captures structure — routing, data layer, auth, service layer — and extracts an exact `file:line` symbol index using grep patterns (without reading full file bodies).
4. **Dependencies & flows.** Builds the module graph, external-service map, and execution flows, plus change-propagation chains and invariants.
5. **Compression.** Writes everything to `.claude/repo-knowledge/` as compact, recall-optimized knowledge files.
6. **Incremental upkeep.** On later runs, only changed files (by `git diff`) are re-analyzed; schema and integrity are validated each time.

> Design principle: **architecture is permanent, implementation is ephemeral.** The graph captures durable structure and skips volatile detail, so it stays useful and cheap.

## What gets generated

All artifacts live under `.claude/repo-knowledge/` in your repository:

| File | Contents |
|---|---|
| `index.md` | Quick reference, freshness metadata, store status, schema version. |
| `architecture.md` | Stack, bootstrap, routing, data layer, auth, service layer. |
| `file-index.md` | Exact `file:line` symbol index + cross-references and propagation chains. |
| `flows.md` | End-to-end execution flows. |
| `data-model.md` | Entities, schemas, relationships. |
| `routes.md` | Endpoints / route map (when applicable). |
| `config.md` | Configuration and environment surface. |

You can safely commit this directory or keep it local — it is derived data.

## Permissions & security

On first run, the plugin offers to add **narrowly scoped** allow-rules to your `~/.claude/settings.json` so analysis does not prompt on every read and write:

- Read and search any file (`Read`, `Grep`, `Glob`).
- Write **only** to the knowledge store (`Write(.claude/repo-knowledge/**)`).

Edits to source code **always** require your explicit approval — that boundary is intentional and the plugin never requests broad write/edit access to source.

If you decline the permission setup, analysis still runs; you will just be prompted for individual actions.

## FAQ

**Does it work on non-git folders?**
Yes. Git enables cheap incremental updates and freshness tracking, but a non-git folder falls back to a full re-analysis.

**Will it modify my code?**
No. It only writes to `.claude/repo-knowledge/`. Any source edit goes through Claude Code's normal approval flow.

**How do I keep the graph fresh?**
Run `/repo-analyze --update` after commits, or `/repo-analyze --rebuild` for a clean rebuild after a major refactor.

**What languages are supported?**
~20 languages directly (Go, Python, TS/JS, Rust, C/C++, Java, and more) with generic fallbacks for anything else.

**Is the graph expensive to query?**
No — typical questions are answered from the index in roughly ~200 tokens.

## Contributing

Issues and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for the repository layout and how to test plugin changes locally.

## License

Released under the [MIT License](LICENSE).
