# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- C inline assembly injection (`asm`, `__asm__`, `__asm__ volatile`) via `gnu_asm_expression`.
- Elixir SQL injection support (strings, sigils, `<>` concatenation, Ecto calls, `# sql` comment marker).
- Perl SQL injection support (strings, heredocs, DBI call sites).
- PHP nowdoc SQL injection fixed by replacing `injection.combined` with `(nowdoc_string)+` fragment matching.
- XML MyBatis mapper SQL tag injection (static support).
- Experimental `template_tag` user rules for generated `javascript` and `typescript` hosts.
- Configurable generated-host rules for `lua` and `ruby` (matching `python`/`javascript`/`typescript` host-object flow).
- **GraphQL injection support:**
  - JavaScript / TypeScript: `gql` / `graphql` / `gqlRequest` template tags (including `member_expression` like `client.graphql`)
  - Rust: `*_gql` / `*Graphql` naming suffix, content prefix (`query` / `mutation` / `subscription` / `fragment`), and `graphql!` / `gql!` macros
  - Python: built-in `content_prefix` rules for GraphQL
  - Go: static regex-based content prefix rules for GraphQL
- `:TSInjectDebug` and `:TSInjectHealth` now open in a centered floating window with `q` / `<Esc>` to close.
- `scripts/preview-inject.sh` (moved from `tmp/`) with improved UX: `--list`, `--line`, parser availability checks, and colorized output.

### Changed

- README/help docs were reorganized:
  - installation moved earlier with `lazy.nvim` and `vim.pack` examples
  - important notes are now front-loaded (load order, semantic tokens, C/C++ constraints)
  - verification/tooling sections were removed
- README/help configuration sections now document:
  - configurable generated hosts for `rules`
  - rule kinds and required fields (`var_suffix`, `call`, `template_tag`, `content_prefix`)
  - per-kind host support boundaries and Lua `:format(...)` expansion behavior
- Smoke test architecture refactored from monolithic `tests/smoke/assertions.lua` into modular structure:
  - `tests/smoke/init.lua`: shared utilities returned as a module table
  - `tests/smoke/lang/*.lua`: per-language / per-injection-type assertions
  - `tests/smoke/integration/*.lua`: integration tests
  - Submodules use `require("tests.smoke.init")` instead of `_G` globals.
- `selene.toml` cleaned up; smoke test globals removed after module-pattern refactor.

### Testing

- Expanded smoke coverage for:
  - `lua`/`ruby` configurable generated rules (`builtin = false`, user rule counts, heredoc/format paths)
  - `template_tag` user-rule behavior in `javascript` and `typescript`
  - warning reporting for unsupported host/rule combinations in `TSInjectHealth`
  - SQL example coverage across all 19 language fixtures (DDL, CTE, JOIN, subquery, aggregate, window function)
  - GraphQL assertions for JavaScript, TypeScript, Rust, Python, and Go

## [0.2.0] - 2026-03-15

### Added

- `0.2` generated-query framework for host adapters and runtime query synthesis.
- Generated host support for `python`, `javascript`, `typescript`, `lua`, and `ruby`.
- `:TSInjectReload` and `:TSInjectHealth`.
- Experimental host-level rule configuration for configurable generated hosts:
  - `rules.<host>.builtin`
  - `rules.<host>.items`
- Optional per-host query mode override:
  - `query_mode.<host> = "generated" | "static"`

### Changed

- `lua` and `ruby` moved from static runtime queries to generated runtime queries.
- Generated-capable hosts default to generated mode; static mode is available as a legacy fallback.
- Health reporting now includes:
  - generated/static split
  - generated query file status
  - builtin/user rule counts
  - legacy static host status
- Static query snapshots for generated hosts moved to `archive/scm-generated/` (reference only).

### Testing

- Expanded smoke coverage for:
  - reload behavior
  - health output
  - generated-host migration paths
  - `builtin = false` behavior
  - legacy static mode behavior

## [0.1.0] - 2026-03-13

### Added

- Initial public release of `ts-inject.nvim`.
- Static SQL injection support across host languages:
  - `bash`, `c`, `cpp`, `c_sharp`, `go`, `java`, `javascript`, `kotlin`, `lua`,
    `php`, `python`, `ruby`, `scala`, `rust`, `typescript`, `zig`
- `setup({ enable = { ... } })` explicit host opt-in model.
- `:TSInjectDebug` command for runtime/parser/query inspection.
- Runtime-installed host query files for enabled languages.
- Project docs/help and baseline test fixtures/smoke validation.

### Notes

- `0.1.x` focused on stable static host-specific SQL recipes and debugging.
- Generic rule-engine style behavior was intentionally deferred to `0.2+`.
