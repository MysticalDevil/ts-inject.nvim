# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Fixed

- **C backslash-continued string injection:**
  - Replaced the `backslash_value` + `injection.combined` approach with a
    single `string_literal` pattern that captures all `string_content`
    fragments interleaved with `escape_sequence` nodes (`*` quantifier).
  - This removes the cross-match merging bug that caused multiple
    SQL-hinted backslash declarations to collapse into one giant injection.
  - Backslash-continued strings are now supported in `*_sql` declarations,
    assignments, and DB API call sites on par with adjacent concatenation.

### Changed

- `host/c.lua`: removed `backslash_value` config; `leaf_strings`,
  `parenthesized`, and `cast` patterns now use the unified
  `(string_content) ((escape_sequence) (string_content))*` form.
- `host/_c_family.lua`: removed `(#set! injection.combined)` from the
  backslash variant emitted by `value_pair()`.

## [0.3.2] - 2026-05-03

### Added

- **Auto-diagnose LSP semantic-token override in `TSInjectDebug` and `TSInjectHealth`:**
  - `TSInjectDebug` now shows a `diagnostics:` section that detects when LSP semantic tokens are enabled at the cursor position and warns if they may be overriding injected highlights (LSP priority 125 > tree-sitter priority 100).
  - `TSInjectHealth` now shows a `semantic_token risk:` section listing active LSP semantic-token providers and suggesting the global fix (`vim.hl.priorities.semantic_tokens = 90`).

### Changed

- Removed `archive/scm-generated/` directory. These were outdated generated-query snapshots serving as a second static fallback. All 19 hosts are now generated-capable; static mode remains as a legacy fallback only for languages with `scm/` injection files.
- Simplified `query_store.static_path()` to fall back directly to `scm/` without checking the now-removed `archive/` directory.

### Testing

- Added assertions for `diagnostics:` and `semantic_token risk:` sections in smoke and comprehensive tests.
- Removed `assert_legacy_static_mode` smoke test because it relied on Python's archived static query, which no longer exists after archive removal.

## [0.3.1] - 2026-05-03

### Changed

- **Internal refactoring and code quality:**
  - Extracted shared display helpers (`add`, `add_kv`, `list_or_none`, `append_section`, `open_float`) from `debug.lua` / `health.lua` into `host/_util.lua`. Removed ~90 lines of duplication.
  - `health.lua`: switched from `vim.fn.filereadable` to `vim.uv.fs_stat` for query file presence checks.
  - `rules.lua`: removed dead `copy_list()` helper; `clone_rules()` now delegates fully to `vim.deepcopy`.
  - `xml.lua`: removed private `join_tags()` and reused existing `util.join_fn_list()`.
  - `query_store.lua`: merged `generated_languages()` into an alias of `supported_languages()` (identical sets); replaced fragile chained `vim.fs.dirname` with `vim.fn.fnamemodify(..., ":p:h:h:h")`.
  - `runtime.lua`: standardized all path construction on `vim.fs.joinpath`.
  - `query_builder.lua`: unified list-append style (`table.insert` → `t[#t+1]`).
  - `config.lua`: added comment explaining `normalized.rules` / `normalized.query_mode` field aliasing for backward compatibility.
  - `host/lua.lua` and `host/python.lua`: added inline comments clarifying why `#any-lua-match?` is required for concatenated-string nodes with multiple captures.
  - `host/_util.lua`: added doc comments for `arg_prefix()`.

### Fixed

- **C/C++ name_pattern injection silently missed pointer/array declarations:**
  - `host/_c_family.lua` previously captured `declarator: (_)` which matched `pointer_declarator` (text `*summary_sql`). The anchored `^...$` Lua pattern therefore failed to match.
  - Fixed by explicitly matching `(identifier)`, `(pointer_declarator declarator: (identifier))`, and `(array_declarator declarator: (identifier))`.
- **Removed duplicate unanchored C/cpp `name_pattern` rules** from `builtin.lua` (`[%a_][%w_]*[Ss][Qq][Ll]` without `^...$`), which could incorrectly match mid-string identifiers.

### Refactored

- `host/_c_family.lua`: extracted `value_pair()` helper to deduplicate the four identical `if backslash_value_str then ... end` patterns in `render_name_pattern` and `render_call`, cutting ~13 lines of repetition.

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
