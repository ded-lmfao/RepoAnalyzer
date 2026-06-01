<overview>
5-step recovery protocol for errors during analysis, plus failure modes for edge cases.
</overview>

<recovery_protocol>
When any phase encounters an error, apply this protocol. Do not skip steps.

**Step 1 — PAUSE**
Stop immediately. Record: which phase failed, which file/operation caused it, what data was successfully collected before the failure.

**Step 2 — DIAGNOSE**

| Error | Diagnosis | Action |
|-------|-----------|--------|
| File not found / path missing | Wrong path or file deleted mid-analysis | Re-check path, skip and continue |
| Permission denied | File ACL or OS restriction | Note as unreadable, continue with available files |
| File too large | Binary, minified, or massive generated file | Add to skip list, continue |
| Git command fails | No git installed, no repo, detached HEAD | Fall back to mtime-based freshness, note in index.md |
| Ambiguous structure | Cannot classify directory or language | Trigger escalation — ask user |
| Partial read (truncated) | File exceeded read limit | Read first 50 lines only, note as partially analyzed |
| Manifest parse error | Malformed package.json / go.mod / etc. | Note as unparseable, infer from directory structure |

**Step 3 — ADAPT**
- Unreadable critical file → infer its contents from files that import it
- Git unavailable → use file modification times for freshness tracking
- Missing manifest → infer language from file extensions in the directory

**Step 4 — RETRY**
Retry the failed operation with the adapted approach. Maximum 3 retry attempts per failure.

**Step 5 — ESCALATE**
If unresolved after 3 attempts:
- Save all collected data to checkpoint files
- Report: what failed, what was collected, what information is needed
- Set `PARTIAL_ANALYSIS: true` and `BLOCKED_AT: Phase N` in `index.md`
- Stop. Do not proceed until the user resolves the blocker.
</recovery_protocol>

<failure_modes>
**Repo too large to analyze fully:**
- Prioritize: entry point → routes → data models → auth → stop
- Save checkpoints for completed phases
- State: "Partial analysis completed. Covered: [X]. Not yet covered: [Y]. Resume with `/repo-analyze` to continue."

**Unknown language or framework:**
- Read the entry point anyway (bootstrap patterns are universal)
- Apply generic structural patterns
- Flag: "Framework not recognized. Applied generic analysis. Results may be incomplete."

**No entry point found:**
- **First check the repo class** (discovery.md repo_class_detection). CONTENT_DOCS, IAC_CONFIG, DATA, and PROMPT_SKILL repos have no entry point *by design* — do NOT escalate. Switch to the content-mapping path (specialized-detection.md `<content_or_declarative_repo>`).
- If it has application-language source but no bootstrap: check README.md for orientation clues; check Makefile, Procfile, docker-compose.yml for startup commands.
- Only then escalate: "I couldn't identify an entry point. Is this a library, a plugin, or is the entry in a non-standard location?"

**No version control:**
- Skip all git-based freshness tracking
- Track freshness by file modification times
- Note in `index.md`: "No git history. Freshness tracked by mtime."
</failure_modes>
