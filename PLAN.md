# ts-inject.nvim Plan

## Status Snapshot

Current repository status as of 2026-03-11:

- `0.1` is a static multi-language SQL injection release, not a generic rule engine
- the public entrypoint is `require("ts_inject").setup({ enable = { ... } })`
- the current debug command is `:TSInjectDebug`
- runtime query files are installed under `stdpath("data") .. "/ts-inject/queries/<lang>/injections.scm"`
- the project already ships SQL injection support for:
  - `c`
  - `cpp`
  - `c_sharp`
  - `go`
  - `java`
  - `javascript`
  - `kotlin`
  - `lua`
  - `php`
  - `python`
  - `ruby`
  - `scala`
  - `rust`
  - `typescript`
  - `zig`

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
- shell, markdown, or non-SQL embedded-language support
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
  - supports backslash-continued multiline `*_sql` declarations
  - supports explicit DB API call sites like `sqlite3_exec`, `sqlite3_prepare_v2`, `PQexec`, and `PQprepare`
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
| `c` | yes | yes | constrained to multiline declarations and explicit DB calls |
| `cpp` | yes | yes | constrained to raw strings and explicit DB calls |
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
| `rust` | yes | yes | regular and raw strings, crate call sites |
| `typescript` | yes | yes | mirrors the JS strategy |
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
- markdown fence alias normalization
- non-SQL embedded language support
- health/reload command expansion
- richer conflict handling for semantic tokens and host highlight overrides

## `0.2` Goals

`0.2` should be the first step beyond static SQL-only recipes, but it should
still stay implementation-driven rather than abstract-first.

Planned focus:

- introduce a small internal rule model only for patterns already proven by `0.1`
- start extracting repeated host logic into adapter-style helpers
- add health and reload workflows around the existing runtime query installation
- expand beyond SQL where the host/value is clear, especially shell heredoc style injections
- improve documentation per host so supported string shapes and limits are explicit

The main purpose of `0.2` is to move from "bundle of stable static recipes" to
"small configurable injection framework" without jumping straight to a fully
generic DSL.

## `0.3` Goals

`0.3` should broaden the plugin from SQL-oriented static workflows into a more
general embedded-language tool.

Planned focus:

- richer user-defined rule support built on top of the `0.2` internal model
- shell and markdown normalization features
- more built-in non-SQL recipes
- better override / merge semantics between built-in and user-provided rules
- stronger debugging and health reporting for generated or merged queries

The main purpose of `0.3` is to make the plugin broadly configurable without
losing the debuggability and host-specific correctness established in `0.1`.

## Recommended `0.1` Closeout Order

1. Keep README, help, and `PLAN.md` aligned.
2. Ensure `tests/smoke.lua` passes in the documented headless flow.
3. Tag and release `0.1`.
