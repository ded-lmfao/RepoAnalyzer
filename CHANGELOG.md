# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
