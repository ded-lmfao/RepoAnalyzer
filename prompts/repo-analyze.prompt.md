---
name: repo-analyze
description: Analyze, query, refresh, or plan changes for the current repository using its knowledge graph.
agent: agent
---

Use the bundled `repo-analyze` Agent Skill for this request.

Interpret any arguments after `/repo-analyze` as the requested mode:

- No arguments: build or incrementally refresh the repository knowledge graph.
- `--update`: refresh only changed files.
- `--rebuild`: perform a clean full analysis.
- `--status`: report graph freshness and coverage.
- `--impact <symbol>`: report symbol change impact.
- `--flow <name>`: trace an execution flow.
- `--model <name>`: inspect a data model.
- `--module <name>`: inspect a module.
- `--change <intent>`: create a verified change plan before editing.
- `--help`: show available commands and stop.

Follow the bundled `repo-analyze` skill and its referenced workflow files. Use `.claude/repo-knowledge/` as the shared knowledge-store location. If no mode is supplied, infer the user's natural-language request and choose the matching mode.