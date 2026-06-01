<overview>
Phase 2 patterns. Read the files that define HOW the system is assembled. Read minimum files per question — stop as soon as each is answered.
</overview>

<bootstrap_sequence>
Read each entry point fully. Extract only:
- What gets initialized and in what order
- What middleware/plugins/modules are registered
- What ports/addresses are bound
- What background processes are started
- What the graceful shutdown sequence is

Do NOT extract implementation logic — only the assembly sequence.
</bootstrap_sequence>

<routing_discovery>
The route/command registry is the most important structural file. Find it by:

**File name patterns:** `router`, `routes`, `routing`, `dispatch`, `urls`, `commands`, `handlers`

**Framework-specific patterns:**

| Framework | Patterns to grep |
|-----------|-----------------|
| Express/Fastify/Hono/Koa | `app.use(`, `.get(`, `.post(`, `Router()` |
| NestJS | `@Controller(`, `@Get(`, `@Post(` (decorator-based) |
| Gin/Chi/Echo/Fiber | `router.GET`, `r.POST`, `e.GET`, `group.` |
| FastAPI/Flask | `@app.route`, `@router.get`, `@router.post` |
| Django | `path(`, `urlpatterns`, `include(` |
| Rust (Axum/Actix/Rocket) | `.route(`, `#[get(`, `#[post(`, `App::new().service(` |
| Spring | `@RequestMapping`, `@GetMapping`, `@PostMapping` |
| Ktor (Kotlin) | `routing {`, `get("`, `post("` |
| Phoenix (Elixir) | `scope "`, `get "`, `post "`, `resources "` in `router.ex` |
| Rails | `resources :`, `get '`, `post '`, `namespace` |
| Laravel/Symfony | `Route::get`, `Route::post`, `#[Route(` (PHP attributes) |
| Vapor (Swift) | `app.get(`, `app.post(`, `routes.grouped(` |
| .NET | `MapGet(`, `MapPost(`, `[Route(`, `[HttpGet` |
| GraphQL | schema files, resolver registration |
| gRPC | `.proto` files, service registration |
| CLI (Cobra/Click/Commander/Clap/Thor) | command registration patterns |

Extract for each route/command:
- Path/name, method/type, handler reference, middleware applied, auth required
- Group/namespace patterns
- Public vs authenticated distinction
</routing_discovery>

<data_layer_discovery>
Find schema/model definitions:

**ORM model files:** files importing ActiveRecord, Eloquent, SQLAlchemy, GORM, Prisma, TypeORM, Mongoose, Sequelize, Hibernate, etc.

**Schema files:** `schema.prisma`, `*.graphql` (schema), `schema.rb`, `models.py`

**Migrations:** list only the 3 most recent. Read structure only, not data. Skip older migrations.

**Raw SQL schemas:** `schema.sql`, `*.sql` in migrations/ — read structure only.

For each model/table:
- Name, primary key type
- Top 5–8 most important fields (name, type)
- All relationships (belongs_to, has_many, many_to_many, polymorphic)
- Soft-delete, audit, or timestamp patterns
</data_layer_discovery>

<auth_discovery>
Find auth logic by searching for files/patterns containing:

**Keywords:** `jwt`, `token`, `session`, `cookie`, `oauth`, `passport`, `devise`, `sanctum`, `guardian`

**Middleware names:** `auth`, `authentication`, `authorization`, `protect`, `guard`, `verify`

Extract:
- Auth mechanism (JWT / session / OAuth / API key / magic link / other)
- Token structure if JWT (what claims)
- Token expiry rules
- Multi-tenant isolation if present
- Permission/role system structure
</auth_discovery>

<service_layer_discovery>
Find business logic by looking at DOMAIN-classified directories from Phase 1.

List every service/use-case/domain object by **name**.
For each: one sentence describing its single responsibility — derived from file name and exported function names only.

**Do NOT read service implementations.** Names and exported signatures are sufficient.
</service_layer_discovery>
