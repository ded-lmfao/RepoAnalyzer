<overview>
Repo health scoring rubrics. Computed during Phase 5. Score each dimension 1–10.
</overview>

<documentation_health>
Check for: `README.md`, `CONTRIBUTING.md`, `CHANGELOG.md`, `docs/` directory, `LICENSE`, inline documentation density (sample 3 files for comment-to-code ratio).

| Score | Criteria |
|-------|----------|
| 10 | README + API docs + contributing guide + inline docs + changelog |
| 7 | README + some API docs, no contributing guide |
| 4 | README only, sparse |
| 1 | No README or empty README |
</documentation_health>

<dependency_health>
Count total dependencies from manifest. Flag obviously outdated major versions (e.g., React 16 when 19 exists, Node 14 when 22 is LTS, Go 1.18 when 1.22 is current). Flag known vulnerability patterns only if clearly detectable from version numbers.

| Score | Criteria |
|-------|----------|
| 10 | All dependencies recent, no flags |
| 7 | 1–3 outdated minor versions |
| 5 | Some outdated major versions |
| 2 | Very outdated stack (2+ major versions behind) |
| 1 | Known vulnerable versions detected |
</dependency_health>

<test_coverage_signal>
Count test files vs source files. Check if CI runs tests.

| Score | Criteria |
|-------|----------|
| 10 | Test dir exists, test files >20% of source count, CI runs tests |
| 7 | Test dir exists with reasonable coverage |
| 4 | Some test files but sparse |
| 1 | No test files found |
</test_coverage_signal>

<cicd_maturity>
Check for CI config files: `.github/workflows/`, `.circleci/`, `Jenkinsfile`, etc.

| Score | Criteria |
|-------|----------|
| 10 | CI config + CD pipeline + branch protection + linting + type checking |
| 7 | CI with tests, no CD |
| 4 | CI config present but minimal (no test run) |
| 1 | No CI/CD found |
</cicd_maturity>

<activity_level>
Qualitative only — not scored:
- `Active` — git commits within 30 days (or recent file changes if no git)
- `Maintained` — commits within 90 days
- `Slow` — commits within 12 months
- `Dormant` — last commit >12 months ago or unknown

**Overall health score:** average of the four numeric scores, rounded to one decimal.

Only report recommendations when a dimension scores below 7.
</activity_level>
