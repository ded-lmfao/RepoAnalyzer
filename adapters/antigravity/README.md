# Antigravity installation

Antigravity supports the open Agent Skills format. This installer copies the complete `RepoAnalyzer` skill,
including its workflows, references, and templates, into an Antigravity skill directory.

From this repository, install for the current project:

```powershell
powershell -ExecutionPolicy Bypass -File .\adapters\antigravity\install.ps1 -Scope Workspace
```

Install globally for all Antigravity projects:

```powershell
powershell -ExecutionPolicy Bypass -File .\adapters\antigravity\install.ps1 -Scope Global
```

To uninstall, remove the copied skill directory:

```powershell
Remove-Item .\.agents\skills\repo-analyze -Recurse -Force
Remove-Item "$HOME\.gemini\config\skills\repo-analyze" -Recurse -Force
```

For a different project, provide its path:

```powershell
powershell -ExecutionPolicy Bypass -File .\adapters\antigravity\install.ps1 -Scope Workspace -TargetPath C:\path\to\target-repo
```

Restart or start a new Antigravity conversation after installation. Ask the agent to analyze or refresh the
repository knowledge graph. The skill writes shared graph data to `.claude/repo-knowledge/`.

Antigravity discovers workspace skills from `.agents/skills/` and global skills from
`~/.gemini/config/skills/`. It also supports the legacy `.agent/skills/` path.