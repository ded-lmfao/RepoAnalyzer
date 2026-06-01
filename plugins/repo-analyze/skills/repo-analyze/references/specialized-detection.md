<overview>
Domain-specific detection patterns. Apply these after Phase 1 when the repo type is identified. Never assume these patterns apply — check for them first.
</overview>

<monorepo>
**Trigger:** multiple packages/services found at root (more than 2 distinct manifests or service directories).

If more than 5 distinct services: escalate — ask user which to prioritize.

Analysis approach:
1. Run Phase 1 at workspace root to identify all packages
2. Classify each: `FRONTEND`, `BACKEND_API`, `WORKER`, `SHARED_LIB`, `CLI`, `MOBILE`, `INFRA`
3. Build one knowledge file set per package under `.claude/repo-knowledge/<service-name>/`
4. Build workspace-level `index.md` mapping all services and their contracts
5. Identify cross-service contracts: shared type packages, inter-service API calls, shared DB, shared event bus, shared config

Knowledge loading for future requests:
- Single-service request → workspace `index.md` + that service's files
- Cross-service request → workspace `index.md` + the two relevant service files
</monorepo>

<event_driven>
**Trigger:** event emitters, message queues, pub/sub patterns detected in Phase 3.

Additional analysis:
- Build full event catalog: `Event → Producer(s) → Consumer(s) → Trigger condition`
- Identify ordering guarantees (none / at-least-once / exactly-once)
- Identify what happens on consumer failure
- Map async boundaries in flows.md
</event_driven>

<microservices>
**Trigger:** multiple services, inter-service HTTP/gRPC calls detected.

Additional analysis:
- Map all inter-service calls (service A calls service B at endpoint X)
- Identify shared databases (flag as coupling risk)
- Identify API gateway or service mesh if present
- Map which service owns which domain (who is authoritative for what data)
</microservices>

<multi_tenant>
**Trigger:** `org_id`, `tenant_id`, `account_id`, or row-level security patterns detected.

Additional analysis:
- Identify tenant isolation mechanism: row-level security / schema-per-tenant / DB-per-tenant
- Map every location where tenant scoping is enforced
- Flag any routes or queries that appear to be missing tenant scoping
- Add to index.md Quick Reference: how tenant isolation works
</multi_tenant>

<cli_tool>
**Trigger:** CLI framework detected (Cobra, Click, Commander, Clap, urfave/cli, etc.).

Additional analysis:
- Map all commands and subcommands (full tree)
- Map flags and arguments per command
- Map execution paths per command
- Note: routes.md becomes commands.md for CLI tools
</cli_tool>

<mobile>
**Trigger:** Flutter/Dart, React Native, Swift, Kotlin detected.

Additional analysis:
- Map screen/route tree (navigation structure)
- Map state management domains
- Map all API call sites (what screen calls what endpoint)
- Map native bridge calls (what goes through platform channels/native modules)
</mobile>

<content_or_declarative_repo>
**Trigger:** repo class is CONTENT_DOCS, IAC_CONFIG, DATA, or PROMPT_SKILL (no executable entry point by design — see discovery.md repo_class_detection).

These repos have no routes, models, or auth. Do not look for them and do not escalate over their absence. Map the structure native to the class instead:

**CONTENT_DOCS** (mkdocs/docusaurus/sphinx/hugo/jekyll, or a bare `.md` tree):
- Map the document tree and navigation/sidebar config (the "routes" of a docs site)
- Record the build + publish command (the "entry point")
- index.md Quick Reference answers: "where does topic X live", "how do I add a page", "how is it built/deployed"

**IAC_CONFIG** (Terraform, k8s, Ansible, Helm, Pulumi, Nix):
- Inventory modules/resources and what each provisions
- Map environments (dev/stage/prod var files or workspaces)
- Flag secrets handling and state backend
- Quick Reference: "what does module X create", "how to apply", "where do env values come from"

**DATA** (datasets, notebooks, SQL seed):
- Inventory datasets/tables with their schema (columns + types) — this replaces data-model.md
- Map any pipeline/transform scripts and their order
- Quick Reference: "what is in dataset X", "how is it regenerated"

**PROMPT_SKILL** (SKILL.md + workflows/references/templates, or a `commands/` library):
- Map the router → workflow → reference → template structure and the load order (what loads when)
- Inventory each skill/command with its trigger and one-line purpose
- Flag duplication (two definitions of the same skill/command name) and dead references (a workflow that loads a file that doesn't exist)
- Quick Reference: "what does skill X do", "which file handles mode Y", "what loads on invocation"

For all four: file-index.md still applies — the "symbol" is the document/resource/dataset/skill-file, and the cross-reference is which other files reference it (nav entries, module `source =`, import statements, `[Load now: ...]` directives).
</content_or_declarative_repo>

<discord_bot>
**Trigger:** discord.js, discord.py, discordgo, serenity detected.

Additional analysis:
- Map all slash commands, message commands, context menus
- Map all event handlers (messageCreate, interactionCreate, ready, etc.)
- Map permission checks per command
- Map state persistence (what data survives restarts)
</discord_bot>
