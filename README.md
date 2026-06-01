# repo-analyze

A Claude Code plugin that turns **any repository, in any language**, into a durable, token-efficient **knowledge graph** — so an AI can understand the codebase deeply and make **precise, safe code changes** without re-reading source every time.

## What it does

- **One-time analysis** builds `.claude/repo-knowledge/` — compressed architecture + an exact `file:line` symbol index, change-propagation chains, execution flows, config map, and invariants.
- **Answers questions cheaply** from the graph (~200 tokens) instead of re-scanning source.
- **Plans precise edits** — `--change <intent>` produces a verified, ordered file:line plan with blast-radius classification and *verify-before-edit* so it never edits a stale line.
- **Stays fresh** — incremental updates on git diff, schema versioning, store-integrity + validation gates.
- **Works on anything** — application / library / docs / IaC / data / monorepo repos, ~20 languages with generic fallbacks.

## Install

```text
/plugin marketplace add YOUR_GITHUB_USERNAME/repo-analyze-marketplace
/plugin install repo-analyze@repo-analyze-marketplace
```

> Replace `YOUR_GITHUB_USERNAME` with the account you push this repo to.

After install, reload skills (or restart Claude Code).

## Use

```text
/repo-analyze                 # analyze the current repo (builds the graph)
/repo-analyze <path>          # analyze a specific repo
/repo-analyze --change <x>    # verified, ordered edit plan before touching code
/repo-analyze --impact <sym>  # blast radius of changing a symbol
/repo-analyze --flow <name>   # trace an execution flow end-to-end
/repo-analyze --update        # refresh after commits (incremental)
/repo-analyze --rebuild       # clean full re-analysis
/repo-analyze --status        # freshness & coverage
```

You can also just **ask questions** about the repo after analysis — answers come from the graph.

## Permissions

On first run the skill offers to add narrow allow-rules to your `~/.claude/settings.json` so analysis doesn't prompt for every read/write:
- read/search any file (`Read`, `Grep`, `Glob`)
- write **only** the knowledge store (`.claude/repo-knowledge/**`)

Edits to real source code still require your approval — that boundary is intentional.

## License

MIT (or your choice — edit this section).
