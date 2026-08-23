# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Renamed the public project and Copilot extension branding to RepoAnalyzer.
- Added uninstall instructions for Claude Code, GitHub Copilot, and Antigravity.

### Added
- GitHub Actions release workflow publishing Copilot VSIX and Antigravity skill archives from version tags.
- VS Code extension manifest with `contributes.chatSkills`, bundling the repository intelligence skill for GitHub Copilot installation.
- GitHub Copilot instruction adapter at `adapters/github-copilot/repo-analyze.instructions.md`.
- Antigravity Agent Skills installer for workspace and global installation.

## [2.1.0]

### Changed
- **Caveman-terse chat prose.** All output (receipts, change plans, impact/status reports, free-form answers) drops articles, filler, and hedging for ~75% fewer words at zero technical loss. Exact-by-rule items are never compressed: `file:line`, code, commands, config keys, error strings, invariants, security warnings, blast-radius warnings, and the command footer stay verbatim. Complements the receipt rule — that cuts *what* prints, this cuts *how* it's phrased.
- **Token-frugal chat output.** Analysis now reports a ≤10-line receipt (identity, health, store location, token economy) instead of re-dumping the full knowledge graph into chat. New principle: the store is the deliverable, chat is a receipt — the graph on disk is never reprinted in the conversation. Ask for "the full breakdown here" to get the detailed in-chat summary.
- **Command footer printed once.** The "🧭 What you can do next" table prints only on the first build for a repo; `--update`/`--rebuild`/later runs print a single-line pointer instead.
- **Leaner first message.** Mode/prior-knowledge/next-step preamble collapsed from three lines to one.
- **Smaller index template.** The knowledge-index template now ships one worked Q&A example instead of six language-specific blocks, cutting context loaded during every build.
- Removed the "What I Can Answer Without Reading Code" filler from the report and `--status` output.
- **Graph-driven, size-scaled edits.** `--change` now reads the plan's raw material from the existing graph (file-index) and opens source only at verify-before-edit — no re-scan for facts already indexed. Plan output scales with blast radius: SURGICAL edits get a 2–4 line plan and proceed directly; WIDE/BREAKING get the full plan and a confirmation gate.

### Added
- `--help` — prints the command reference and stops, no analysis or graph required.
- **Output intensity levels** (`--verbosity lite|full|ultra`, default full) mirroring caveman, with the same carve-outs (code/file:line/keys/errors never abbreviated).
- **Caveman-compressed knowledge store.** The knowledge files — and the CLAUDE.md `## Repo Intelligence` section — are now written in caveman prose. Since `index.md` is re-read on every request, this cuts *input* tokens on every future recall, compounding over the store's lifetime (the caveman-compress idea applied to the graph). Carve-outs preserved: file:line, paths, symbols, keys, code, quoted errors stay exact.
- **Recall-savings metric** on the Token economy line: store size vs. the source-token size it maps (`~P% smaller than ~S-token source`), so the savings caveman-stats shows for output are visible here for recall.

[2.1.0]: https://github.com/ded-lmfao/jinxx-repo-analyzer/releases/tag/v2.1.0

## [2.0.0]

### Added
- Exact `file:line` symbol index with cross-references and change-propagation chains.
- `--change <intent>` verified, ordered edit planning with blast-radius classification and verify-before-edit.
- `--impact`, `--flow`, `--model`, and `--module` consume modes.
- Schema versioning (v2) plus store-integrity and validation gates.
- Incremental updates driven by `git diff`, and a `--status` freshness/coverage report.
- Monorepo support via multi-service stores under `.claude/repo-knowledge/<service>/`.
- One-time, narrowly scoped permission setup (read/search + write only to the knowledge store).

### Notes
- Knowledge graphs from before schema v2 should be regenerated with `/repo-analyze --rebuild`.

[2.0.0]: https://github.com/ded-lmfao/jinxx-repo-analyzer/releases/tag/v2.0.0
