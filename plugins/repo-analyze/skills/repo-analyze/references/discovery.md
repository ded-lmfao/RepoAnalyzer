<overview>
Phase 1 discovery patterns. Run all sub-phases in parallel. Do not assume — discover everything.
Run `<prior_documentation>` FIRST; it can turn much of discovery into cheap verification.
</overview>

<prior_documentation>
**Reuse existing docs before rediscovering — but verify, never trust blindly.** A well-documented repo often hands you the stack, entry points, run/build/test commands, and conventions for near-zero cost. Read these first (one pass, before the parallel sub-phases) and let them *target* the rest of discovery.

Read if present:
- `CLAUDE.md` (root + nested) — the always-loaded agent context, often authored by `/init`. **Skip this skill's own `## Repo Intelligence` section** if present — that is repo-analyze's prior output, not independent evidence. Read the human/`/init`-authored parts.
- `AGENTS.md`, `.cursor/rules`, `.cursorrules`, `.github/copilot-instructions.md` — other agents' notes
- `README.md`, `CONTRIBUTING.md`, `docs/` index — overview, build/test/run, architecture

Extract as **claims**: stack, entry point(s), run/build/test commands, architecture pattern, conventions, known gotchas.

**Every claim is `(inferred — from <file>, unverified)` until confirmed against actual code/manifest.** Docs drift. Use claims to shortcut discovery — jump straight to the named entry point, open the documented file paths — not to replace it. When a claim contradicts the code, **record the discrepancy**: stale docs are a real finding and a candidate Invariant or Coverage-gap note. A documented entry point you confirm by reading is no longer `(inferred)`; promote it to confirmed.

Net effect: fewer discovery reads — you verify a handful of claims instead of searching blind. If no such docs exist, proceed with full discovery as normal.
</prior_documentation>

<manifest_detection>
Search for any of the following (do not assume which exist). Read every manifest found. Extract: language(s), runtime version(s), project name, all dependencies with versions.

```
package.json / package-lock.json / yarn.lock / pnpm-lock.yaml / bun.lockb   (Node)
deno.json / deno.jsonc                                                       (Deno)
go.mod / go.sum
Cargo.toml / Cargo.lock
pyproject.toml / setup.py / setup.cfg / requirements.txt / Pipfile / poetry.lock / environment.yml
pom.xml / build.gradle / build.gradle.kts / settings.gradle
composer.json / composer.lock
Gemfile / Gemfile.lock
*.csproj / *.fsproj / *.sln / Directory.Build.props
CMakeLists.txt / Makefile / configure.ac / meson.build / conanfile.txt / vcpkg.json   (C/C++)
Package.swift / *.xcodeproj / *.xcworkspace / Podfile                        (Swift/ObjC)
*.cabal / stack.yaml / package.yaml                                          (Haskell)
deps.edn / project.clj / shadow-cljs.edn                                     (Clojure)
build.zig (Zig) / *.nimble (Nim) / dune-project (OCaml) / rebar.config (Erlang)
*.rockspec (Lua) / cpanfile / Makefile.PL (Perl) / DESCRIPTION (R)
foundry.toml / hardhat.config.{js,ts} / truffle-config.js                    (Solidity)
pubspec.yaml (Dart/Flutter) / mix.exs (Elixir) / build.sbt (Scala) / Project.toml (Julia)
```

If none of these exist, the project may be a single-language script repo (one `.py`/`.sh`/`.rb` + no deps), a CONTENT/IAC/DATA repo (see repo_class_detection below), or use a manifest not listed — infer the language from the dominant file extension and continue. Never stop just because the manifest is unfamiliar.
</manifest_detection>

<entry_point_detection>
Search for entry points by language-specific patterns:

```
Go:       **/main.go, **/cmd/*/main.go
JS/TS:    src/main.tsx, src/main.ts, src/index.ts, index.js, server.js, app.js
Python:   app.py, main.py, __main__.py, wsgi.py, asgi.py, manage.py, run.py
C/C++:    grep: "int main(" / "void main(" across *.c/*.cpp/*.cc; WinMain for Windows GUI
C#/F#:    Program.cs, Startup.cs, Program.fs (grep: Main(, top-level statements)
Java:     Main.java, Application.java (grep: SpringApplication.run, "static void main")
Kotlin:   grep: "fun main("  → Main.kt, Application.kt
Scala:    grep: "object * extends App", "@main", "def main("
Swift:    main.swift, @main attribute, AppDelegate.swift / App.swift (SwiftUI)
Ruby:     main.rb, config.ru, application.rb
PHP:      index.php, public/index.php, artisan (Laravel), bin/console (Symfony)
Dart:     lib/main.dart
Elixir:   mix.exs (grep: def application), application.ex
Rust:     src/main.rs (grep: "fn main"); src/lib.rs ⇒ library, no main
Haskell:  app/Main.hs, src/Main.hs (grep: "main ::")
Clojure:  grep: "(defn -main"
Shell:    entrypoint.sh, run.sh, start.sh, *.sh with shebang at repo root
Solidity: contracts/*.sol (entry = deploy scripts, not main)
Other:    grep the language's idiomatic entry keyword; if none, treat as library/script
```

Also check: `Procfile`, `docker-compose.yml`, `Makefile`, shell scripts at root — these reveal the real startup sequence.

For each entry point: path, language, what it bootstraps.
</entry_point_detection>

<directory_classification>
List all top-level directories and 2 levels deep. Classify by name:

| Classification | Common names |
|---------------|-------------|
| ENTRY | cmd, bin, scripts, cli |
| DOMAIN | domain, core, business, features, modules, services, usecases, application |
| API | api, routes, controllers, handlers, resolvers, endpoints, graphql, grpc |
| CLIENT | src, frontend, client, ui, web, renderer, app, pages, views, components |
| DATA | models, entities, schemas, db, database, migrations, repositories, stores |
| INFRA | infra, infrastructure, adapters, integrations, providers, connectors |
| CONFIG | config, configs, settings, configuration, env |
| BUILD | .github, ci, docker, deploy, k8s, terraform, ansible, helm |
| TEST | test, tests, spec, specs, __tests__, e2e, integration |
| SHARED | shared, common, utils, helpers, lib, pkg, internal, types |
| GENERATED | generated, gen, dist, build, out, .next, .nuxt — **SKIP** |
| VENDOR | vendor, node_modules, .venv, __pycache__ — **SKIP** |
| DOCS | docs, documentation, wiki |

Any directory that matches none of the above: flag as UNKNOWN and investigate.
</directory_classification>

<config_surface>
Search for and read any of the following. Do NOT read actual `.env` or `.env.local` (may contain secrets). Extract every config key, its type/format, and what it controls.

```
.env.example / .env.sample / .env.template / .env.schema / env.d.ts
config.yaml / config.yml / config.json / config.toml
app.yaml / app.yml / application.yml / application.properties
settings.py / settings.py.example
appsettings.json / appsettings.Development.json
database.yml / secrets.yml.example
```

If no config template found: grep source files for env-var access to infer config keys from usage. Idioms by language:
`os.Getenv(` / `viper.Get(` (Go) · `process.env.` (Node) · `os.environ[` / `os.getenv(` (Python) · `std::env::var(` (Rust) · `System.getenv(` / `@Value(` (Java) · `getenv(` (C/C++) · `Environment.GetEnvironmentVariable(` (.NET) · `ENV[` (Ruby) · `$_ENV` / `getenv(` (PHP) · `System.get_env(` (Elixir) · `Sys.getenv(` (R). Each hit is a config key in use.
</config_surface>

<toolchain_detection>
Search for and note (do not fully read — just list what exists and available commands):

```
Makefile / makefile           → available make targets
Dockerfile / docker-compose   → containerization approach
.github/workflows/*.yml       → CI/CD pipeline
Jenkinsfile / .circleci/      → CI
.eslintrc / .prettierrc       → linting
jest.config.js / pytest.ini   → test runner
tsconfig.json / .babelrc      → build config
.air.toml / nodemon.json      → hot reload
```
</toolchain_detection>

<repo_class_detection>
**Classify the repo's class before Phase 2 — not every repo is executable application code.** This determines which Phase 2 sub-phases apply. Many repos have no entry point, no routes, and no data models *by design* — for those, looking for them wastes tokens and the "no entry point" failure mode must NOT fire.

| Repo class | Signals | What Phase 2 maps instead of routes/models/auth |
|-----------|---------|-------------------------------------------------|
| `APPLICATION` | Entry point + framework + (routes or CLI commands) | Normal Phase 2 (routes, models, auth, services) |
| `LIBRARY` | Manifest with a lib/package target, public API surface, no server bootstrap | Public API surface, exported symbols, semver/changelog |
| `CONTENT_DOCS` | Mostly `.md`/`.mdx`/`.rst`; docs generator (mkdocs, docusaurus, sphinx, hugo, jekyll); no source tree | Document tree, nav/sidebar structure, build/publish command |
| `IAC_CONFIG` | Terraform/`.tf`, k8s manifests, Ansible, Helm, Pulumi, Nix, dotfiles | Resource/module inventory, environments, what each module provisions |
| `DATA` | Mostly `.csv`/`.json`/`.parquet`/`.sql` seed data, notebooks, no app code | Dataset/schema inventory, pipeline scripts, data dictionary |
| `PROMPT_SKILL` | `SKILL.md`, agent/prompt `.md` files, `commands/`, no compiled code | Skill/command inventory, router→workflow→reference structure, load order |
| `META_MONOREPO` | Multiple manifests / workspaces at root | See specialized-detection.md monorepo path; classify each package |

**How to decide:** if Phase 1.1 found no manifest AND no entry point, the repo is almost certainly `CONTENT_DOCS`, `IAC_CONFIG`, `DATA`, or `PROMPT_SKILL` — pick by dominant file type. Only escalate "no entry point" for a repo that has application-language source files but no discoverable bootstrap.

Record the class on the Repository Identity Card. Phase 2 reads it first and skips inapplicable sub-phases.
</repo_class_detection>
