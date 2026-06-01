<overview>
One-time setup invoked by SKILL.md `<first_run_setup>`. Grants the analyzer silent file reads and knowledge-store writes by merging allow-rules into the USER/GLOBAL settings, so a single approval covers EVERY repo — never per-repo. This is the only place the skill touches settings.json.
</overview>

<target>
**Always `~/.claude/settings.json` (user/global scope).**
Never write these to a project `.claude/settings.json` — that would re-prompt in every new repo, which defeats the purpose. Global = approve once, applies everywhere.
</target>

<rules_to_ensure>
These exact entries belong in `permissions.allow`:
```
Read
Grep
Glob
Write(.claude/repo-knowledge/**)
Edit(.claude/repo-knowledge/**)
Write(~/.claude/repo-knowledge/**)
Edit(~/.claude/repo-knowledge/**)
```
- `Read` / `Grep` / `Glob` → analysis reads/searches files without prompting.
- `Write`/`Edit(.claude/repo-knowledge/**)` → build the knowledge store inside any project.
- `Write`/`Edit(~/.claude/repo-knowledge/**)` → the central store for read-only/foreign repos.

**Scope discipline:** never add broad `Write(**)` / `Edit(**)` or source-code paths. The analyzer must stay able to *read* anything but only *write* the knowledge store — editing real source still requires the user's approval (that boundary is intentional; see plan-change.md).
</rules_to_ensure>

<procedure>
Merge-safe, idempotent — preserve everything already in the file:

1. Read `~/.claude/settings.json`. If it doesn't exist, start from `{}`.
2. Ensure `permissions` (object) and `permissions.allow` (array) exist. Do not disturb `permissions.deny`, `permissions.ask`, or any other key (model, env, hooks, etc.).
3. For each rule in `<rules_to_ensure>`, add it to `allow` only if not already present. Do not remove, reorder, or duplicate existing entries.
4. If nothing was missing → change nothing, say nothing (idempotent skip).
5. Otherwise write the merged JSON back. **This single write is the one approval the user clicks.** Before considering it done, validate the file still parses as JSON (a malformed settings.json silently disables ALL settings).
6. Confirm in one line: "Granted read + knowledge-store-write permissions globally — analysis won't prompt again."

**Decline / failure path:** if the user rejects the write or the file is not writable, do not retry in a loop and do not block — continue the analysis; actions will simply prompt individually until set up later.

**Optional (only if the user asks to silence the git freshness check too):** also add read-only git rules — `Bash(git diff:*)`, `Bash(git log:*)`, `Bash(git status:*)`, `Bash(git rev-parse:*)`. Do not add broad `Bash` access.
</procedure>
