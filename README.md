# ts-inject.nvim

Static Tree-sitter SQL injection helpers for Neovim.

Current 0.1 scope:

- static SQL injection queries for multiple host languages
- explicit opt-in per host language via `setup()`
- `:TSInjectDebug` for inspection

## Requirements

- Neovim 0.11+
- Tree-sitter SQL parser
- Tree-sitter host parsers for the languages you enable

## Installation

Add the plugin to your plugin manager, then:

```lua
require("ts_inject").setup({
  enable = {
    c = true,
    cpp = true,
    c_sharp = true,
    go = true,
    java = true,
    javascript = true,
    kotlin = true,
    lua = true,
    php = true,
    python = true,
    rust = true,
    typescript = true,
    zig = true,
  },
})
```

The plugin does not enable any host-language injections by default. You must
explicitly enable each supported language in `setup()`.

## What It Does

The plugin registers static injection queries at runtime for the languages you
explicitly enable.

Current built-in hosts:

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
- `rust`
- `typescript`
- `zig`

The matching strategy is host-specific and intentionally conservative. The
queries prefer language-native naming and call-site conventions instead of a
single cross-language rule set.

## Host Support

Current 0.1 support is static and conservative. The list below reflects the
intended stable paths, not every possible string shape.

- `c`
  - supports `sqlite3_exec`, `sqlite3_prepare_v2`, `PQexec`, `PQprepare`
  - supports backslash-continued multiline `*_sql` declarations
  - plain single-line C string assignments are intentionally treated as normal strings
- `cpp`
  - supports raw string `*_sql` declarations like `R"sql(... )sql"`
  - supports raw string arguments passed to `sqlite3_exec`, `sqlite3_prepare_v2`, `PQexec`, and `PQprepare`
  - plain regular C++ string literals are intentionally treated as normal strings
- `c_sharp`
  - supports `camelCase ...Sql`, `SCREAMING_SNAKE_CASE ..._SQL`, and common DB call sites
  - supports regular strings, concatenated strings, and verbatim strings
- `go`
  - supports SQL-looking raw strings and interpreted strings
  - favors Go-style names like `userQuery` and obvious SQL content
- `java`
  - supports `camelCase ...Sql`, `SCREAMING_SNAKE_CASE ..._SQL`, and common DB call sites
  - supports text blocks, regular strings, and concatenated strings
- `javascript`
  - supports `camelCase ...Sql`, `PascalCase ...Sql`, and `SCREAMING_SNAKE_CASE ..._SQL`
  - supports template strings, concatenated strings, and common DB call sites
- `kotlin`
  - supports `camelCase ...Sql`, `SCREAMING_SNAKE_CASE ..._SQL`, and common DB call sites
  - supports raw strings, `trimIndent()`/`trimMargin()`, and concatenated strings
- `lua`
  - supports `snake_case ..._sql`, `SCREAMING_SNAKE_CASE ..._SQL`, and DB-style call sites
  - supports long strings, concatenation, and `:format(...)`
- `php`
  - supports `$camelCaseSql`, `SCREAMING_SNAKE_CASE ..._SQL`, and common DB call sites
  - supports regular strings, concatenation, and heredoc/nowdoc forms
- `python`
  - supports `snake_case ..._sql` and obvious SQL content in assignment/call positions
  - supports triple-quoted strings, concatenation, and `execute`/`executemany`/`executescript`
- `rust`
  - supports Rust-style names like `userSql` / `USER_SQL` and common SQL crate call sites
  - supports normal strings and raw strings
- `typescript`
  - supports `camelCase ...Sql`, `PascalCase ...Sql`, and `SCREAMING_SNAKE_CASE ..._SQL`
  - supports template strings, concatenated strings, and common DB call sites
- `zig`
  - supports Zig-style `camelCase ...Sql` names and common DB call sites
  - supports multiline string literals and direct call-site SQL strings

Examples for the current C / C++ constraints:

```c
const char *summary_sql = "  SELECT status \
  FROM users \
  ORDER BY status";
```

```cpp
const char *schema_sql = R"sql(  CREATE TABLE audit_logs (
  id INTEGER PRIMARY KEY,
  message TEXT NOT NULL
))sql";
```

Example:

```go
query := `
SELECT id, name
FROM users
WHERE active = true
`
```

## Debugging

Run:

```vim
:TSInjectDebug
```

Or specify a target language explicitly:

```vim
:TSInjectDebug sql
```

The debug view reports parser paths, active injection query files, captures at
cursor, the current node, and nested language trees.

## LSP Semantic Tokens

If SQL injection highlighting disappears after `gopls` attaches, disable
`gopls` semantic tokens in your LSP config. This keeps Tree-sitter injection
highlighting visible instead of letting semantic tokens override it.

Recommended `gopls` setting:

```lua
gopls = {
  settings = {
    gopls = {
      semanticTokens = false,
    },
  },
}
```

## Tooling

```sh
stylua --check lua plugin
selene lua plugin
```

## Smoke Test

A minimal headless smoke test lives in `tests/smoke.lua`.

Run it with:

```sh
env XDG_DATA_HOME=/tmp/ts-inject-data \
  XDG_STATE_HOME=/tmp/ts-inject-state \
  XDG_CACHE_HOME=/tmp/ts-inject-cache \
  /home/omega/.local/share/mise/installs/neovim/nightly/bin/nvim \
  --headless --clean -u NONE -i NONE \
  --cmd 'set rtp+=.,/home/omega/.local/share/nvim/lazy/nvim-treesitter' \
  -c 'lua dofile("tests/smoke.lua")' \
  -c 'qa!'
```
