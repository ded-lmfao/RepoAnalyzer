# [Project Name] — Symbol & File Index

This file is the precise, non-compressed layer of the knowledge graph.
Every entry is an exact file path and approximate line number. Never compress or pattern-collapse here.
Use the language vocabulary from references/symbol-indexing.md to map language-specific terms to universal ones.

---

## Symbol Cross-Reference

For each key domain entity: its definition location, every usage site, DB backing, and the ordered change propagation chain.

```
[EntityName] — [file:line]
  used by:
    [file] — L[n]([context]), L[n]([context])
  DB: [table/collection] in [DB name]              ← omit if no DB
  migration: [file] ([what it defines])            ← omit if no migrations
  frontend: [type file:line] → [component file:line] ← omit if backend-only

  Change propagation order:
    1. [file:line] — [what to change]
    2. [file:line] — [what to change]
    ...
```

---

## File Map

Every non-trivial source file, grouped by layer. List key exported/public symbols with line numbers.
Do not list: generated files, vendor/, node_modules/, .venv/, target/, dist/, test files.

Layer names to use (adapt to what this repo actually has):
`Handlers/Routes/Controllers` · `Services/UseCases` · `Models/Entities/Schemas` · `Repository/DataAccess/Queries`
`Middleware/Interceptors` · `Config` · `CLI Commands` · `Frontend Types` · `Frontend Components` · `Frontend API`

```
## [Layer]
[file path]
  [SymbolName]  L[n]  — [one-line description]
  [SymbolName]  L[n]  — [one-line description]
```

---

## Entry Point → Execution Chain Map

For each user-visible entry point (HTTP route, CLI command, event handler, RPC method), trace the exact files it passes through.

**For HTTP APIs:**
```
[METHOD] [path]
  Handler:    [file:line] [function/method name]
  Middleware: [names in order]
  Service:    [file:line] [method]
  DataAccess: [file:line] [method]
  DB tables:  [names]
  Events:     [event emitted, if any]
```

**For CLI tools:**
```
[command] [subcommand]
  Entry:    [file:line] [function]
  Flags:    [flag names → config fields they set]
  Calls:    [file:line] [function] → [file:line] [function]
  Output:   [what it writes/returns]
```

**For libraries:**
```
[ExportedFunction/Type]
  Defined:  [file:line]
  Re-exported from: [file:line]   ← if different from definition
  Used in tests: [test file:line]
```

**For event/message consumers:**
```
[EventName / Topic / Queue]
  Consumer: [file:line] [function]
  Produces: [downstream event, if any]
  DB:       [tables read/written]
```

---

## Examples by language (remove this section from the actual file-index.md you write)

**Go (Gin + GORM):**
```
## Handlers
internal/handlers/users.go
  CreateUser   L18  — POST /api/v1/users
  GetUser      L52  — GET /api/v1/users/:id
  ListUsers    L87  — GET /api/v1/users

## Models
internal/models/user.go
  User{}       L8   — core entity, embeds Base{ID(uuid), CreatedAt, UpdatedAt}
  UserRole     L54  — enum: admin/member/viewer

## Services
internal/services/user_service.go
  NewUserService  L10  — constructor, injects DB
  Create          L28  — hashes password, persists, emits user.created
  FindByEmail     L55  — used by auth flow

## Repository
internal/repository/user_repo.go
  FindByEmail  L18  — SELECT with org_id scope
  Create       L34  — INSERT returning *User

## Entry Point Chain
POST /api/v1/users
  Handler:    internal/handlers/users.go:L18 CreateUser
  Middleware: AuthRequired(), RequirePermission("users.create")
  Service:    internal/services/user_service.go:L28 Create
  DataAccess: internal/repository/user_repo.go:L34 Create
  DB tables:  users, activity_logs
  Events:     user.created → ws broadcast
```

**Python (FastAPI + SQLAlchemy):**
```
## Routers
app/routers/users.py
  create_user  L14  — POST /users
  get_user     L38  — GET /users/{id}
  list_users   L62  — GET /users

## Models (SQLAlchemy ORM)
app/models/user.py
  User         L10  — ORM model, maps to users table

## Schemas (Pydantic)
app/schemas/user.py
  UserCreate   L8   — request body for POST /users
  UserResponse L22  — response shape

## Services
app/services/user_service.py
  create_user   L15  — validates, hashes password, persists
  get_by_email  L38  — used by auth

## Entry Point Chain
POST /users
  Handler:    app/routers/users.py:L14 create_user
  Middleware: get_current_user dependency (app/deps.py:L12)
  Service:    app/services/user_service.py:L15 create_user
  DataAccess: app/crud/user.py:L22 create (SQLAlchemy session)
  DB tables:  users
```

**TypeScript (Express + Prisma):**
```
## Routes
src/routes/users.ts
  POST /users     L12  — createUser handler
  GET  /users/:id L28  — getUserById handler

## Services
src/services/userService.ts
  createUser    L18  — validates, hashes, calls Prisma
  findByEmail   L42  — used by auth middleware

## Types
src/types/user.ts
  UserDTO        L4   — API response shape
  CreateUserBody L14  — POST /users request body

## Schema
prisma/schema.prisma
  model User     L22  — Prisma model → users table

## Entry Point Chain
POST /users
  Handler:    src/routes/users.ts:L12
  Middleware: authMiddleware (src/middleware/auth.ts:L8)
  Service:    src/services/userService.ts:L18 createUser
  DataAccess: prisma.user.create (Prisma client)
  DB:         users table
```

**Rust (Axum + sqlx):**
```
## Handlers
src/handlers/users.rs
  create_user  L12  — POST /users
  get_user     L38  — GET /users/:id

## Models
src/models/user.rs
  User         L6   — sqlx::FromRow, maps to users table
  CreateUser   L28  — request body struct

## Services
src/services/user_service.rs
  create_user  L15  — validates, hashes, calls db
  find_by_email L34 — used by auth

## Queries
src/db/user_queries.rs
  insert_user     L10  — INSERT INTO users
  find_by_email   L28  — SELECT WHERE email = $1

## Entry Point Chain
POST /users
  Handler:    src/handlers/users.rs:L12 create_user
  Middleware: auth_middleware (src/middleware/auth.rs:L8)
  Service:    src/services/user_service.rs:L15 create_user
  DataAccess: src/db/user_queries.rs:L10 insert_user
  DB:         users table
```

**C (CLI tool):**
```
## Headers
include/config.h
  Config{}     L8   — global config struct (host, port, data_dir, log_level)
include/db.h
  db_conn_t{}  L12  — opaque database connection handle

## Source
src/main.c
  main()       L10  — parses args → calls run()
  parse_args() L45  — fills Config{} from argv + env
src/config.c
  config_load  L12  — reads config file + env overrides
src/network.c
  server_start L18  — binds socket, enters accept loop
src/db.c
  db_open      L14  — opens SQLite, runs migrations
  db_close     L34  — flushes WAL, closes handle

## CLI Entry Chain
./myapp --port 8080
  Entry:    src/main.c:L10 main()
  ArgParse: src/main.c:L45 parse_args() → fills Config{}
  Calls:    src/config.c:L12 config_load → src/network.c:L18 server_start
```
