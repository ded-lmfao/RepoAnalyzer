# RepoAnalyzer

> A Claude Code plugin that turns **any repository, in any language**, into a durable, token-efficient **knowledge graph** — so an AI assistant can understand the codebase deeply and make **precise, safe code changes** without re-reading source on every request.

<p align="left">
  <img alt="Version" src="https://img.shields.io/badge/version-2.1.0-blue">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-green">
  <img alt="Claude Code and GitHub Copilot" src="https://img.shields.io/badge/Claude%20Code%20%26%20GitHub%20Copilot-compatible-8A2BE2">
  <img alt="Languages" src="https://img.shields.io/badge/languages-~20%20%2B%20fallbacks-orange">
</p>

---

## Table of contents

- [Why](#why)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Uninstallation](#uninstallation)
- [GitHub Copilot](#github-copilot)
- [Antigravity](#antigravity)
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

Every time an AI assistant works in a large codebase, it re-reads source files to rebuild context — burning tokens and time, and still missing cross-file coupling. RepoAnalyzer solves this once: it performs a deep, structured pass over the repository and writes a compressed **knowledge graph** to `.claude/repo-knowledge/`. From then on, questions, impact assessments, and edit plans are answered from that graph (~200 tokens) instead of re-scanning the source.

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

- [Claude Code](https://docs.claude.com/en/docs/claude-code) or [VS Code with GitHub Copilot](https://code.visualstudio.com/docs/copilot/overview).
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

## Uninstallation

Remove the Claude Code plugin:

```text
/plugin uninstall repo-analyze@repo-analyze
```

Remove the VS Code extension:

```powershell
code --uninstall-extension justnixx.repoanalyzer-copilot
```

Remove the copied GitHub Copilot instruction file from the target repository:

```powershell
Remove-Item .\.github\instructions\repo-analyze.instructions.md
```

Remove the Antigravity skill from a workspace or from the global installation:

```powershell
Remove-Item .\.agents\skills\repo-analyze -Recurse -Force
Remove-Item "$HOME\.gemini\config\skills\repo-analyze" -Recurse -Force
```

Uninstallation does not delete `.claude/repo-knowledge/`. Remove that directory separately if you also want to delete the generated repository graph.

## GitHub Copilot

The analysis workflows are also available as a GitHub Copilot instruction adapter. Copy
[repo-analyze.instructions.md](adapters/github-copilot/repo-analyze.instructions.md) into the target repository's
`.github/instructions/` directory. Copilot will then use the same workflows and `.claude/repo-knowledge/` store.
For GitHub-hosted Copilot, copy the file's contents into `.github/copilot-instructions.md` instead.

For a one-command-style install in VS Code, package or install this repository as a VS Code extension. The root
`package.json` contributes the complete skill bundle through `chatSkills`:

```powershell
npx @vscode/vsce package
code --install-extension .\repoanalyzer-copilot-2.1.0.vsix
```

After installation, open any repository in VS Code and ask Copilot to analyze or refresh its knowledge graph.
The extension also adds the `/repo-analyze` prompt command, with modes such as `/repo-analyze --update`,
`/repo-analyze --status`, and `/repo-analyze --change "add rate limiting"`.
For Marketplace publishing, create a Visual Studio Marketplace publisher, set `publisher` in `package.json` to that
publisher ID, then run `npx @vscode/vsce publish`. A GitHub repository can distribute the VSIX through Releases
without Marketplace publishing.

```text
target-repo/.github/instructions/repo-analyze.instructions.md
```

Ask Copilot naturally to analyze or refresh the repository, query the graph, assess symbol impact, or plan a change.
The adapter shares the graph with Claude Code, so either assistant can consume knowledge produced by the other.

## How RepoAnalyzer compares

| Capability | RepoAnalyzer | General AI coding assistant | Traditional documentation |
|---|---|---|---|
| Repository understanding | Builds a durable, structured graph | Reconstructs context per conversation | Depends on manually maintained pages |
| Change planning | Exact symbols, propagation chains, and blast radius | Usually inferred from the current prompt | Rarely available |
| Freshness | Git-aware incremental updates and integrity gates | Session or index dependent | Manual |
| Assistant support | Claude Code, GitHub Copilot, and Antigravity | Usually one product ecosystem | Assistant-agnostic |
| Primary role | Context and safe-change layer | General coding, explanation, and generation | Human reference |

RepoAnalyzer complements coding assistants. It gives them a shared, inspectable repository map; they still handle implementation, review, and execution.

## Antigravity

Antigravity supports the open Agent Skills format. Install the complete skill for the current project:

```powershell
powershell -ExecutionPolicy Bypass -File .\adapters\antigravity\install.ps1 -Scope Workspace
```

Install globally instead:

```powershell
powershell -ExecutionPolicy Bypass -File .\adapters\antigravity\install.ps1 -Scope Global
```

See [the Antigravity adapter](adapters/antigravity/README.md) for installation into another project. Start a new
Antigravity conversation and ask it to analyze or refresh the repository. Antigravity, Copilot, and Claude Code
share the `.claude/repo-knowledge/` graph.

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
| `/repo-analyze --help` | Print the command reference and stop (no analysis). |
| `/repo-analyze --verbosity lite\|full\|ultra` | Set output compression level (modifier on any invocation; default `full`). |

You can also just **ask questions** about the repository after analysis — no flag required.

Output is **token-frugal by design**: the graph is written to disk and chat shows only a short receipt (identity, health, store location, token economy) plus a one-line command pointer — it never re-dumps the graph into the conversation. Ask for "the full breakdown here" if you want the detailed summary printed in chat.

Chat prose is also **caveman-terse** — drops articles, filler, and hedging for ~75% fewer words at zero technical loss. Pick a level with `--verbosity lite|full|ultra` (default `full`). Exact-by-rule items are never compressed: `file:line` refs, code, commands, config keys, error strings, invariants, security warnings, and blast-radius warnings stay full and verbatim.

The **knowledge store itself is written in the same compressed prose**. Because `index.md` is re-read on every request, this cuts input tokens on every future recall — the savings compound over the store's lifetime. The Token economy line reports how much smaller the graph is than the source it maps.

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
