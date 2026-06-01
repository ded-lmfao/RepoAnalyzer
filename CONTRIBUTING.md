# Contributing

Thanks for your interest in improving **repo-analyze**! Issues and pull requests are welcome.

## Repository layout

```
.
├── .claude-plugin/
│   └── marketplace.json          # Marketplace manifest (lists the plugin)
├── plugins/
│   └── repo-analyze/
│       ├── .claude-plugin/
│       │   └── plugin.json        # Plugin manifest
│       └── skills/
│           └── repo-analyze/
│               ├── SKILL.md       # Skill entry point (modes, phases, routing)
│               ├── workflows/     # Build/update/on-demand/plan-change workflows
│               ├── references/    # Discovery, architecture, indexing, recovery, etc.
│               └── templates/     # Report and index templates
├── CHANGELOG.md
├── LICENSE
└── README.md
```

## Testing a change locally

You can install the marketplace straight from a local clone:

```text
/plugin marketplace add /absolute/path/to/this/repo
/plugin install repo-analyze@repo-analyze
```

Then reload skills (or restart Claude Code) and exercise the commands documented in the
[README](README.md#command-reference) against a sample repository.

## Guidelines

- Keep `SKILL.md` and the workflow/reference files focused and token-efficient — brevity is a feature here.
- Update [CHANGELOG.md](CHANGELOG.md) for any user-facing change.
- Bump the `version` in both `plugin.json` and `marketplace.json` together, following [SemVer](https://semver.org/).
- Validate that `marketplace.json` and `plugin.json` remain valid JSON before opening a PR.

## Reporting issues

When filing a bug, please include the repository type/language, the command you ran, and what
you expected versus what happened. Logs or the generated `index.md` are helpful.
