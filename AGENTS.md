# Repository Guidelines

## Scope

These instructions apply to the entire repository.

## AST inspection

- Prefer `ast-grep` for language AST exploration when shaping or debugging injection rules.
- Use `ast-grep` to identify common assignment, call, macro, and string-node patterns before writing or changing Tree-sitter queries.
- Treat `ast-grep` as a discovery tool. Final verification still needs to use the actual Tree-sitter grammar, Neovim query behavior, and `:TSInjectDebug`.

## Example projects

- Example projects and temporary exploration files should use standard ecosystem layouts where practical.
- Prefer complete, realistic project shapes over single loose files.
- Current preferred layouts:
  - Go: normal module with `go.mod`
  - Python: standard `uv` project with `pyproject.toml` and `src/` layout
  - Rust: standard Cargo project with `Cargo.toml` and `src/`

## SQL example coverage

- SQL examples should cover more than simple `SELECT`.
- Injection naming heuristics should follow each host language's idioms and common community conventions.
- Do not keep awkward cross-language compatibility naming just for symmetry.
- Prefer language-native naming signals over generic ones.
- Examples:
  - JavaScript and TypeScript: prefer camelCase or PascalCase forms like `userSql`, `userQuery`, or `sql`; uppercase constants like `USERS_SQL` are also common and should be supported when they read naturally as constants
  - Python: prefer snake_case forms like `user_sql`
  - Go and Rust: prefer mixedCaps forms like `userQuery` or `userSQL`
- When adding or updating examples, aim to cover a representative mix of common SQL forms:
  - DDL like `CREATE TABLE`, `CREATE INDEX`, and `ALTER TABLE`
  - DML like `SELECT`, `INSERT`, `UPDATE`, and `DELETE`
  - CTEs
  - joins
  - subqueries
  - aggregates with `GROUP BY` and `HAVING`
  - transactions
  - placeholders and bound parameters
  - dialect-friendly features like `RETURNING`, `ON CONFLICT`, or window functions when relevant

## GraphQL example coverage

- GraphQL examples should cover more than simple `query` fields.
- When adding or updating examples, aim to cover a representative mix of common GraphQL forms:
  - Queries with variables (`query GetUser($id: ID!)`)
  - Mutations with input objects (`mutation CreateUser($input: CreateUserInput!)`)
  - Subscriptions (`subscription OnUserUpdated(...)`)
  - Fragment definitions and spreads (`fragment UserFields on User { ... }` / `...UserFields`)
  - Aliases (`activeUsers: users(...)`)
  - Directives (`@include(if: $bool)`)
  - Inline fragments (`... on User { ... }` / `... on Organization { ... }`)
  - Meta fields (`__typename`)
  - Nested selections

## Scripts

- `scripts/preview-inject.sh` is the local verification script for previewing injection highlights.
- It supports `--lang`, `--inject`, `--line`, and `--list` flags.
- See `./scripts/preview-inject.sh --help` for usage.

## Smoke tests

- Smoke tests live in `tests/smoke/` and are organized as:
  - `tests/smoke/init.lua`: shared utilities (returned as a module table)
  - `tests/smoke/lang/*.lua`: per-language / per-injection-type assertion modules
  - `tests/smoke/integration/*.lua`: integration tests (debug, health, reload, custom_rules, legacy)
- Submodules must use `local smoke = require("tests.smoke.init")` and call functions via the module table.
- Do not inject test utilities into `_G`.

## Code style

- Lua code must pass `stylua --check lua tests/smoke.lua tests/smoke/`.
- Lua code must pass `selene lua tests/`.
- Run both before committing.

## Troubleshooting injection highlights

- When investigating "injection query matches but colors do not appear in the
  editor", **first rule out LSP semantic tokens**.
  - LSP semantic highlighting (default priority 125) overrides tree-sitter
    (default 100). A `string` semantic token from the LSP will mask injected
    SQL keyword highlights.
  - Quick confirmation: run `:lua vim.lsp.semantic_tokens.stop(0)` in the
    buffer. If SQL colors immediately appear, semantic tokens are the cause.
  - Common servers that emit `string` tokens: `zls` (Zig), `gopls` (Go).
  - Only after confirming LSP is not the cause should you investigate query
    correctness, node ranges, or parser state.

## Validation

- When adjusting injection behavior, prefer verifying with both:
  - repo smoke tests
  - the preview script (`scripts/preview-inject.sh --lang <host> --inject <type>`)
