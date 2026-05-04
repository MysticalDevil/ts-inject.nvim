# ts-inject.nvim Plan

## Status Snapshot

Current repository status as of 2026-05-03:

- `0.1` was a static multi-language SQL injection release
- `0.2` introduced the generated-query framework and experimental rules
- `0.3` unified all 19 hosts under generated queries with shared engine modules
- the public entrypoint is `require("ts_inject").setup({ enable = { ... } })`
- current commands are `:TSInjectDebug`, `:TSInjectReload`, and `:TSInjectHealth`
- runtime query files are installed under `stdpath("data") .. "/ts-inject/queries/<lang>/injections.scm"`
- the project ships injection support for:
  - `bash` heredoc delimiter mappings (10 languages)
  - `c` (SQL, asm, regex)
  - `cpp` (SQL, regex)
  - `c_sharp` (SQL, GraphQL, regex)
  - `elixir` (SQL)
  - `go` (SQL, GraphQL)
  - `java` (SQL, GraphQL, regex)
  - `javascript` (SQL, GraphQL)
  - `kotlin` (SQL, GraphQL)
  - `lua` (SQL)
  - `perl` (SQL)
  - `php` (SQL, GraphQL, regex)
  - `python` (SQL, GraphQL)
  - `ruby` (SQL)
  - `scala` (SQL, GraphQL, regex)
  - `rust` (SQL, GraphQL)
  - `typescript` (SQL, GraphQL)
  - `xml` (MyBatis mapper tags)
  - `zig` (SQL)

This file is the current implementation plan and release-tracking document.

## What `0.1` Means

`0.1` is intentionally narrow:

- static per-language `scm/<lang>/injections.scm`
- explicit host opt-in in `setup()`
- runtime installation of generated query files
- one debug workflow via `:TSInjectDebug`
- smoke-test verification and ignored ecosystem-style example projects under `tmp/`

`0.1` does not include:

- a generic Lua rule DSL
- a host adapter abstraction layer
- runtime query synthesis from declarative rules
- shell or non-SQL embedded-language support
- extra command families like `TSInjectReload` or `TSInjectHealth`
- semantic-token conflict management inside the plugin itself

## Implemented In `0.1`

### Core behavior

- static SQL injection queries are shipped per host language
- query files are installed into a plugin-owned runtime directory
- no host language is enabled by default
- query caches are cleared after setup so updated runtime queries are used
- `:TSInjectDebug` reports parser paths, active query files, captures, node info, and language trees

### Validation

- `tests/smoke.lua` covers the current stable SQL injection paths across the implemented host languages
- `tmp/verify-nvim-mini.sh` opens ignored example projects through `nvim-mini`
- example projects use ecosystem-shaped layouts where practical

### Current host constraints

Stable constraints that are already part of the shipped contract:

- `c`
  - supports adjacent-string and backslash-continued `*_sql` declarations
    and explicit DB API call sites (`sqlite3_exec`, `sqlite3_prepare_v2`,
    `PQexec`, `PQprepare`, etc.)
  - injects `asm` into `gnu_asm_expression` (basic asm, `__asm__`, `__asm__ volatile`)
  - plain single-line C string assignments are intentionally left as normal strings
- `cpp`
  - supports raw-string `*_sql` declarations
  - supports raw-string arguments in `sqlite3_exec`, `sqlite3_prepare_v2`, `PQexec`, and `PQprepare`
  - plain regular C++ string literals are intentionally left as normal strings

## `0.1` Remaining

The codebase is close to a complete `0.1`, but a few release-closeout items remain.

### Release tracking matrix

| Host | Implemented | Smoke-covered | Notes |
| --- | --- | --- | --- |
| `c` | yes | yes | SQL via adjacent and backslash-continued strings and DB calls; also `asm` injection |
| `cpp` | yes | yes | SQL via raw strings, comments, and DB calls |
| `c_sharp` | yes | yes | regular, concatenated, verbatim strings |
| `go` | yes | yes | SQL-looking strings and Go-style naming |
| `java` | yes | yes | regular strings, concatenation, text blocks |
| `javascript` | yes | yes | template strings, concatenation, common DB calls |
| `kotlin` | yes | yes | raw strings, trim helpers, concatenation |
| `lua` | yes | yes | long strings, concatenation, `:format(...)` |
| `php` | yes | yes | regular strings, concatenation, heredoc/nowdoc |
| `python` | yes | yes | triple-quoted strings, concatenation, execute-family calls |
| `ruby` | yes | yes | regular strings, SQL heredocs, and common DB call sites are smoke-covered |
| `scala` | yes | yes | regular strings, triple-quoted strings, common DB calls |
| `rust` | yes | yes | regular and raw strings, sqlx generics, SeaORM, DB wrapper methods |
| `typescript` | yes | yes | mirrors the JS strategy |
| `elixir` | yes | yes | strings, sigils, `<>` concatenation, Ecto calls |
| `perl` | yes | yes | regular strings, heredocs, DBI call sites |
| `xml` | yes | yes | MyBatis `select`/`insert`/`update`/`delete`/`sql` tags |
| `zig` | yes | yes | multiline literals and direct DB call-site strings |

### Concrete remaining work

`0.1` is functionally complete. Remaining work is release discipline rather than
missing behavior:

1. Versioned release closeout
   - README, help doc, and this plan should stay aligned on supported hosts and constraints.
   - Smoke should pass before cutting a `0.1` tag or GitHub release.

## Deferred To `0.2+`

These items are intentionally postponed and should not block `0.1`:

- generic rule DSL
- normalized rule model and query builder
- host adapter abstraction layer
- shell heredoc and delimiter-based language injections
- more non-SQL embedded-language recipes
- non-SQL embedded language support
- health/reload command expansion
- richer conflict handling for semantic tokens and host highlight overrides

## `0.2` Goals

`0.2` is now underway.

Implemented or in-progress focus:

- small internal rule model for proven patterns
- generated query path for `python`, `javascript`, `typescript`, `lua`, and `ruby`
- host helper extraction for generated hosts
- `:TSInjectReload` and `:TSInjectHealth`
- built-in delimiter-driven `bash` heredoc injections
- updated docs for generated-vs-static host behavior
- generated-host static snapshots moved to `archive/scm-generated/`

The main purpose of `0.2` is to move from "bundle of stable static recipes" to
"small configurable injection framework" without jumping straight to a fully
generic DSL.

### Current `0.2` limits

- experimental `rules` only support:
  - `var_suffix`
  - `call`
  - `template_tag` (for `javascript` and `typescript`, supports `sql` and `graphql`)
  - `content_prefix` (for `go`, `python`, `ruby`, `lua`, and `rust`)
  - `macro` (for `rust` only)
- experimental `rules` only apply to:
  - `go`
  - `python`
  - `javascript`
  - `typescript`
  - `lua`
  - `ruby`
  - `rust`
  - `zig`
- configurable generated hosts can set `builtin = false`
- generated-capable hosts can be forced to `static` via `query_mode.<host> = "static"` (legacy, not recommended)
- there is still no per-rule precedence or partial builtin disable model
- non-SQL expansion includes built-in `bash` heredoc mappings and built-in
    GraphQL support for `go`, `javascript`, `typescript`, `python`, `rust`, `java`,
    `kotlin`, `c_sharp`, `php`, and `scala`

### `0.2` Closeout Checklist

1. `stylua --check lua tests/smoke.lua` passes. ✅
2. `selene lua tests` passes. ✅
3. Headless smoke test passes in the documented flow. ✅
4. `:TSInjectHealth` reports:
   - generated vs static hosts ✅
   - generated query file status ✅
   - builtin/user rule counts for generated hosts ✅
5. `README.md`, `doc/ts-inject.txt`, and `PLAN.md` are aligned. ✅
6. Branch is clean and pushed to `origin/main`. ✅

## `0.2` Completed

All `0.2` goals and closeout checklist items are complete as of 2026-05-02.
The release includes:

- generated query framework for `python`, `javascript`, `typescript`, `lua`, and `ruby`
- `:TSInjectReload` and `:TSInjectHealth` commands
- GraphQL injection support for 10 host languages
- static SQL injection support for 20 host languages
- bash heredoc delimiter mappings

## `0.3` Completed

All `0.3` goals are complete as of 2026-05-03.

- All 19 hosts unified under generated queries
- Shared engine modules extracted (`_util.lua`, `_concat.lua`, `_c_family.lua`)
- GraphQL injection for 9 hosts
- Regex injection for 6 hosts
- Bash heredoc expanded to 10 languages
- Builder architecture unified with `build_dispatcher` and `concat.expand`
- `tests/comprehensive.lua` (200 assertions) added for end-to-end validation

## `0.4` Goals

- richer per-rule precedence and partial builtin disable model
- more built-in non-SQL recipes (e.g., JSON, YAML, TOML embeddings)
- shell normalization features beyond heredoc (command substitution, process substitution)
- query diff / preview in `:TSInjectDebug`
- performance: lazy builder loading, query caching beyond nvim-treesitter's cache

## Recommended `0.1` Closeout Order

1. Keep README, help, and `PLAN.md` aligned.
2. Ensure `tests/smoke.lua` passes in the documented headless flow.
3. Tag and release `0.1`.
