<overview>
What to capture during symbol indexing (Phase 2.6), and why. The symbol index is the opposite of compression — it stores exact file:line for every boundary-crossing symbol so an agent can navigate directly to the right location before making any change.
</overview>

<language_vocabulary>
The same universal concept has different syntax in every language. Map what you find to the universal terms used in this skill:

| Universal term | Go | Python | TypeScript/JS | Rust | C++ | C | Java/Kotlin |
|---|---|---|---|---|---|---|---|
| **Entity type** | `struct` | `class`, `dataclass`, `BaseModel` (Pydantic) | `interface`, `type`, `class` | `struct` | `struct`, `class` | `struct` | `class`, `record` |
| **Type contract** | `interface` | `Protocol`, `ABC` | `interface` | `trait` | abstract class, pure virtual | header `.h` declaration | `interface` |
| **Route handler** | `func(c *gin.Context)` | `async def endpoint(...)` | `(req, res) => {}` | `async fn handler(State(...))` | method on controller class | function pointer in route table | `@GetMapping` method |
| **Service** | exported struct with methods | class with methods | class or module with exported functions | `impl ServiceName` | class with public methods | function group in `.c` file | `@Service` class |
| **Data access** | repository struct with DB methods | SQLAlchemy session / ORM manager | Prisma client / ORM model class | `sqlx` query functions | DAO class | SQL functions in `.c` file | `@Repository` / JPA |
| **Entry point** | `func main()` in `cmd/` or `main.go` | `if __name__ == "__main__"` / `app.py` / `main.py` | `index.ts/js`, `server.ts`, `main.tsx` | `fn main()` in `src/main.rs` | `int main()` in `.cpp`/`.c` | `int main()` in `.c` | `public static void main()` |
| **Exported symbol** | Capitalized name | No `_` prefix, in `__all__` or `__init__.py` | `export` keyword | `pub` keyword | `public:` / header declaration | declared in `.h`, defined in `.c` | `public` modifier |
| **Module/package** | package name in `go.mod` | `__init__.py` directory or `.py` file | `package.json` workspace / file with exports | `mod` in `Cargo.toml` | compilation unit / namespace | `.h`+`.c` file pair | package directory |
| **Config binding** | Viper / env struct tags | `os.environ`, `pydantic.BaseSettings` | `process.env`, `dotenv` | `std::env::var`, `config` crate | preprocessor `#define`, getenv | `getenv()` | `@Value`, application.properties |

Use these terms when writing `file-index.md` regardless of which language the repo uses.
</language_vocabulary>

<what_counts_as_a_key_symbol>
Index these — they cross module/layer boundaries and are the primary targets of change:

**Entity types** — every core data structure shared across layers
- The type/class/struct that represents the main domain objects
- DTOs and request/response types passed between layers
- Interface/trait/protocol definitions that define contracts between layers

**Route/command handlers** — the entry point for every user action
- Every handler function with its method, path, and file:line
- Middleware/interceptors applied to routes

**Service methods** — exported public methods that implement business logic
- Constructor/factory functions that wire dependencies
- Every public method that handlers call

**Data access** — exported functions/methods that touch the database or storage
- Query, insert, update, delete operations
- Any function that builds SQL or calls an ORM

**Frontend counterparts** (if fullstack)
- Type definitions that mirror backend entities
- API call functions that hit the backend
- Key UI components bound to those entities

**Config bindings** — every env var or config key mapped to the variable that reads it

**Do NOT index:**
- Private/unexported/internal helpers
- Test functions and fixtures
- Generated code (`*.pb.go`, `*_gen.ts`, `schema.prisma` client output, etc.)
- Anything in vendor/, node_modules/, .venv/, target/, dist/
</what_counts_as_a_key_symbol>

<how_to_extract>
**Extract with search, not reads.** A declaration's `file:line` is on the declaration line itself — you do not need the body to record it. One `grep -n` per language pattern returns every definition across the whole repo with exact line numbers, for a fraction of the tokens of reading files. This is the core token-saving move of symbol indexing: you already read the Tier-1 architecture files in Phases 2.1–2.5; for everything else, **grep for declarations, never open the file.**

Process:
1. Run the declaration patterns below for the repo's language(s). Each hit is `file:line:declaration` — that is a complete symbol-index entry already.
2. Run the route/endpoint patterns to get every handler's `file:line` without reading handler bodies.
3. For the 5–10 key domain entities only, build the "used by" cross-reference by grepping the symbol name itself (see cross_reference_format). Do not read the using files — the grep line number + surrounding match text is enough context.
4. Only fall back to reading a file when grep output is ambiguous (e.g., overloaded names, macro-generated symbols).

If a file is too large and you read only the first 50 lines (Tier 3 rule): grep still gives you every declaration line — prefer grep over the partial read. Flag `(grep-indexed, body unread)` only if it matters.

Approximate line numbers (±5 lines) are acceptable. The right file matters more than the exact line.
</how_to_extract>

<grep_extraction_patterns>
Use the Grep tool with `-n` (line numbers) and `output_mode: "content"`. These return every declaration's `file:line` across the repo in one pass — no file reading. Adapt to the repo's actual conventions.

| Language | Definitions (types + functions) | Routes / endpoints |
|---|---|---|
| **Go** | `^(func\|type\|var\|const) ` (type filter `go`) | `\.(GET\|POST\|PUT\|DELETE\|PATCH\|Handle)\(` |
| **Python** | `^\s*(class \|def \|async def )` (type `py`) | `@(app\|router)\.(get\|post\|put\|delete\|patch)\(` |
| **TypeScript/JS** | `^\s*(export )?(default )?(async )?(function\|class\|interface\|type\|enum\|const) ` (type `ts`) | `(app\|router)\.(get\|post\|put\|delete\|patch\|use)\(` |
| **Rust** | `^\s*(pub )?(async )?(fn\|struct\|enum\|trait\|impl\|type) ` (type `rust`) | `\.route\(\|#\[(get\|post\|put\|delete)` |
| **Java/Kotlin** | `(public\|private\|protected).*(class\|interface\|enum\|record\|fun ) ` | `@(Get\|Post\|Put\|Delete\|Request)Mapping` |
| **C / C++** | structs: `(struct\|typedef struct\|class\|enum) `; header decls in `*.h`/`*.hpp`: `^[A-Za-z_].*\(.*\);` | route/dispatch tables: `\{.*".*".*\}` or function-pointer arrays |
| **Ruby** | `^\s*(class \|module \|def )` (type `ruby`) | `(get\|post\|put\|delete\|resources) ['"]` |
| **C#** | `(public\|internal\|private).*(class\|interface\|record\|enum\|void\|Task)` | `\[(Http(Get\|Post\|Put\|Delete)\|Route)\|Map(Get\|Post)\(` |
| **PHP** | `^\s*(class \|interface \|trait \|function )` (type `php`) | `Route::(get\|post\|put\|delete\|resource)` |
| **Swift** | `^\s*(public \|open \|final )?(class\|struct\|enum\|protocol\|func\|extension) ` | `\.(get\|post\|put\|delete)\(\|app\.on\(` (Vapor) |
| **Scala** | `^\s*(case )?(class\|object\|trait\|def\|val) ` | `(path\|get\|post)\(` (Akka/Play) |
| **Elixir** | `^\s*(defmodule\|def\|defp\|defstruct) ` (type `elixir`) | `(get\|post\|put\|delete) "` (Phoenix router) |
| **Dart** | `^\s*(class\|abstract class\|enum\|mixin\|[A-Za-z<>]+ \w+\() ` | `(get\|post)\(` (shelf/dart_frog) |
| **Haskell** | `^[a-zA-Z].* ::\|^data \|^newtype \|^type \|^class ` | route DSL varies (Servant type-level, Yesod) |
| **Solidity** | `(contract\|interface\|library\|function\|struct\|event\|modifier) ` | external/public functions = the ABI surface |
| **Shell** | `^\s*(function \w+\|^\w+\(\)\s*\{)` | n/a (commands = case branches / arg parsing) |

**Language not in this table?** Don't stall. Grep the language's definition keywords generically:
- **functions:** `func`/`fn`/`def`/`function`/`sub`/`proc`/`fun`/`defn`/`let .. =`
- **types:** `class`/`struct`/`type`/`interface`/`record`/`trait`/`enum`/`object`/`message`/`contract`/`data`/`newtype`
Combine into one alternation pattern and run it `-n` across the repo. The declaration line is the index entry. This generic path keeps symbol indexing working for any language, including ones invented after this skill was written.

**Config bindings (any language):** `getenv\|os\.environ\|process\.env\.\|viper\.Get\|std::env::var\|System\.getenv` — each hit maps an env key to the file:line that reads it.

**For C/C++ specifically:** declarations live in `.h`/`.hpp`. Grep headers first for the public surface, then grep `.c`/`.cpp` only for the matching definitions. If the project ships `tags`/`TAGS` (ctags) or `compile_commands.json`, those give exact symbol locations even more cheaply than grep — check for them first.

After grepping, the symbol index is ~80% built without opening a single body file. Spend reads only on the architecture files Phase 2.1–2.5 already required.
</grep_extraction_patterns>

<cross_reference_format>
For each key symbol, record definition location and every file that uses it. Build the "used by" list by grepping the symbol name itself (`rg -n "User\b"`) — the match lines give you the using files and line numbers directly. Do not read those files to build this list, and do not wait for the Phase 3 dependency graph; the grep is self-contained and cheaper.

```
[SymbolName] — [file:line]                          ← definition
  used by:
    [file] — L[n]([context]), L[n]([context])       ← usages with brief context
  DB: [table or collection name]                    ← if backed by storage
  migration: [migration file] ([what it defines])   ← if schema-managed
  frontend: [type file:line] → [component file:line] ← if fullstack

  Change propagation order:
    1. [file] — [what to change here]
    2. [file] — [what to change here]
    ...
```

**Go example:**
```
User{} — internal/models/user.go:L8
  used by:
    internal/handlers/auth.go — L34(Register), L89(Login)
    internal/services/auth_service.go — L12(constructor), L28(CreateUser)
    internal/repository/user_repo.go — L15(FindByEmail), L34(Create)
  DB: users table
  migration: migrations/001_create_users.sql

  Change propagation order:
    1. internal/models/user.go:L8 — update struct
    2. migrations/ — new SQL migration if column changes
    3. internal/repository/user_repo.go — update if explicit column lists
    4. internal/services/auth_service.go — update business logic
    5. internal/handlers/auth.go — update request/response handling
```

**Python (FastAPI) example:**
```
User — app/models/user.py:L12           ← SQLAlchemy model
  used by:
    app/routers/auth.py — L23(register), L67(login)
    app/services/auth_service.py — L8(import), L34(create_user)
    app/schemas/user.py — L5(UserCreate), L18(UserResponse)   ← Pydantic mirrors
  DB: users table (PostgreSQL via SQLAlchemy)
  migration: alembic/versions/001_create_users.py

  Change propagation order:
    1. app/models/user.py:L12 — update SQLAlchemy model
    2. alembic/versions/ — new Alembic migration
    3. app/schemas/user.py — update Pydantic schemas
    4. app/services/auth_service.py — update business logic
    5. app/routers/auth.py — update endpoint handlers
```

**TypeScript (Express/Prisma) example:**
```
User — prisma/schema.prisma:L14         ← Prisma model
  used by:
    src/routes/auth.ts — L18(register handler), L45(login handler)
    src/services/authService.ts — L12(createUser), L34(findByEmail)
    src/types/user.ts — L3(UserDTO), L12(CreateUserRequest)
    src/components/RegisterForm.tsx — L8(form)
  DB: users table (Prisma → PostgreSQL)
  migration: prisma/migrations/20240101_create_users/migration.sql

  Change propagation order:
    1. prisma/schema.prisma:L14 — update model
    2. npx prisma migrate dev — generate migration
    3. src/types/user.ts — update DTO types
    4. src/services/authService.ts — update service
    5. src/routes/auth.ts — update route handlers
    6. src/components/ — update UI if field is displayed
```

**Rust (Axum/sqlx) example:**
```
User — src/models/user.rs:L6            ← struct
  used by:
    src/handlers/auth.rs — L18(register), L52(login)
    src/services/auth_service.rs — L8(create_user), L24(find_by_email)
    src/db/user_queries.rs — L12(insert_user), L28(find_by_email)
  DB: users table (sqlx → PostgreSQL)
  migration: migrations/20240101_create_users.sql

  Change propagation order:
    1. src/models/user.rs:L6 — update struct + impl
    2. migrations/ — new SQL migration
    3. src/db/user_queries.rs — update queries
    4. src/services/auth_service.rs — update business logic
    5. src/handlers/auth.rs — update handlers
```

**C example (CLI tool):**
```
Config — include/config.h:L12           ← struct declaration
  defined in: src/config.c:L8
  used by:
    src/main.c — L34(parse_args fills Config)
    src/network.c — L12(cfg.host, cfg.port)
    src/storage.c — L8(cfg.data_dir)

  Change propagation order:
    1. include/config.h:L12 — add field to struct
    2. src/config.c:L8 — add parsing logic
    3. src/main.c:L34 — pass new field through
    4. src/network.c or src/storage.c — consume new field
```
</cross_reference_format>

<change_propagation_by_project_type>
Standard propagation chains by project type. Adapt to the actual layers discovered in Phase 1.

**Backend API (any language):**
1. Model/entity definition file
2. Database migration file (if schema change)
3. Data access / repository file
4. Service / business logic file
5. Route handler file
6. OpenAPI/Swagger spec (if present)

**Fullstack (backend + frontend):**
All of the above, plus:
7. Frontend type/interface mirror file
8. Frontend API client call file
9. Frontend UI component(s) that display or edit the field

**CLI tool:**
1. Config struct / args definition file (header or args parser)
2. Main entry point (where args are parsed)
3. Handler functions that consume the changed field/flag
4. Help text / man page (if present)

**Library:**
1. Public API declaration (header, .d.ts, __init__.py, lib.rs pub use)
2. Implementation file
3. Re-export file (index.ts, mod.rs pub mod, __init__.py)
4. CHANGELOG / semver — breaking change if public API changed

**C/C++ specific:**
Always check both the `.h` declaration AND the `.c`/`.cpp` definition. A change to a struct in a header can break many translation units — check every `.c`/`.cpp` that `#include`s that header.
</change_propagation_by_project_type>
