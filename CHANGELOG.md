# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [0.3.0] - 2026-05-03

### Added

- All 19 host languages now use **generated runtime queries** (was 5 in `0.2`):
  - New generated builders: `c`, `cpp`, `bash`, `perl`, `php`, `c_sharp`, `kotlin`, `elixir`, `java`, `scala`, `xml`, `zig`
  - Shared engine modules: `_util.lua`, `_concat.lua`, `_c_family.lua`
- **GraphQL injection support** across 9 hosts:
  - JavaScript / TypeScript: `gql` / `graphql` / `gqlRequest` template tags
  - Rust: `*_gql` / `*Graphql` naming suffix, content prefix, and `graphql!` / `gql!` macros
  - Python, Go, Java, Kotlin, C#, PHP, Scala: content-prefix or call-site based
- **Regex injection support** across 6 hosts:
  - Java: `Pattern.compile(...)` and `String.matches(...)` arguments
  - C#: `Regex.Match(...)` / `Regex.Replace(...)` and `new Regex(...)` arguments
  - PHP: `preg_match` / `preg_replace` / `preg_split` first argument
  - Scala: `"...".r` suffix and `new Regex(...)` arguments
  - C: `regcomp(...)` second argument
  - C++: `std::regex(...)` constructor arguments
- C inline assembly injection (`asm`, `__asm__`, `__asm__ volatile`) via `gnu_asm_expression`.
- Elixir SQL injection support (strings, sigils, `<>` concatenation, Ecto calls, `# sql` comment marker).
- Perl SQL injection support (strings, heredocs, DBI call sites).
- XML MyBatis mapper SQL tag injection.
- Bash heredoc delimiter mappings expanded to 10 languages (SQL, Python, Lua, JavaScript, TypeScript, Ruby, Perl, GraphQL, JSON, Regex).
- `:TSInjectDebug` and `:TSInjectHealth` now open in a centered floating window with `q` / `<Esc>` to close.
- `tests/comprehensive.lua`: 200-assertion headless validation suite covering all 19 hosts, custom rules, debug, and health commands.
- `scripts/preview-inject.sh` (moved from `tmp/`) with `--list`, `--line`, parser checks, and colorized output.

### Changed

- **Builder architecture refactored:**
  - All 17 generated builders now use `util.build_dispatcher()` instead of hand-written `M.build()` dispatch loops.
  - `concat.expand()` replaces `for depth = 2, MAX_CONCAT_DEPTH` loops across 9 builders.
  - `util.arg_prefix()` unifies arg-index prefix generation for `go`, `rust`, `zig`, and `c`/`cpp`.
  - `rules.name_pattern_for()` rewritten as lookup tables instead of 13 repetitive `if` branches.
- `query_builder.lua` now validates rule kinds early and rejects unknown kinds with a clear error.
- README/help docs reorganized: installation front-loaded, verification sections removed, configuration boundaries documented.
- Smoke test architecture refactored into modular structure (`tests/smoke/init.lua`, `tests/smoke/lang/*.lua`, `tests/smoke/integration/*.lua`).
- `selene.toml` cleaned up after module-pattern refactor.

### Fixed

- `build_dispatcher` static_preamble ordering: `; extends` was being placed after preamble instead of before, breaking bash heredoc and all other preamble-bearing hosts.
- `health.lua` crash when generated query errors contained newlines (`gsub("\n", " ")` sanitization).
- PHP nowdoc SQL injection: replaced `injection.combined` with `(nowdoc_string)+` fragment matching.
- Kotlin annotation injection rules corrected.

### Testing

- Expanded smoke coverage for:
  - all 19 language fixtures with DDL, CTE, JOIN, subquery, aggregate, window function examples
  - GraphQL assertions for JS/TS, Rust, Python, Go, Java, Kotlin, C#, PHP, Scala
  - Regex assertions for Java, C#, PHP, Scala, C, C++
  - `lua`/`ruby` configurable generated rules, `template_tag` user rules
  - warning reporting in `TSInjectHealth` for unsupported host/rule combinations

## [0.2.0] - 2026-03-15

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
