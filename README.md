# ts-inject.nvim

Static Tree-sitter SQL injections for Neovim.

`ts-inject.nvim` keeps 0.1 intentionally simple:

- static per-language injection queries
- explicit opt-in in `setup()`
- one debug command: `:TSInjectDebug`

The project favors stable, host-native heuristics over a generic rule engine.

## Quick Start

Requirements:

- Neovim `0.11+`
- Tree-sitter `sql` parser
- Tree-sitter host parsers for every language you enable

Setup:

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
    ruby = true,
    scala = true,
    rust = true,
    typescript = true,
    zig = true,
  },
})
```

Nothing is enabled by default.

## What 0.1 Covers

The current release is static and conservative:

- no runtime DSL
- no merge engine
- no attempt to guess every string-shaped SQL fragment
- host-language heuristics that follow common local naming and call-site patterns

Supported hosts:

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

## Host Matrix

| Host | Primary naming / signal | Stable string forms | Notes |
| --- | --- | --- | --- |
| `c` | `*_sql`, DB API calls | backslash-continued multiline strings | plain single-line variable strings are intentionally left alone |
| `cpp` | `*_sql`, DB API calls | raw strings | plain regular C++ string literals are intentionally left alone |
| `c_sharp` | `camelCase ...Sql`, `..._SQL`, DB calls | regular, concatenated, verbatim | common `Query` / `Execute` / `Prepare` paths |
| `go` | Go-style `userQuery`, SQL-looking content | raw and interpreted strings | favors obvious SQL text |
| `java` | `camelCase ...Sql`, `..._SQL`, DB calls | regular, concatenated, text blocks | common JDBC-style call sites |
| `javascript` | `camelCase ...Sql`, `PascalCase ...Sql`, `..._SQL` | template strings, concatenation | common query / execute call sites |
| `kotlin` | `camelCase ...Sql`, `..._SQL`, DB calls | raw strings, `trimIndent`, `trimMargin`, concatenation | focuses on common Kotlin SQL shapes |
| `lua` | `snake_case ..._sql`, `..._SQL`, DB calls | long strings, concatenation, `:format(...)` | Lua-specific helper syntax is supported |
| `php` | `$camelCaseSql`, `..._SQL`, DB calls | regular strings, concatenation, heredoc/nowdoc | common PDO-style usage |
| `python` | `snake_case ..._sql`, obvious SQL content, DB calls | regular, triple-quoted, concatenated | includes `execute` / `executemany` / `executescript` |
| `ruby` | `snake_case ..._sql`, `..._SQL`, DB calls | regular strings, SQL heredocs | includes `execute`, `exec`, `prepare`, `find_by_sql` |
| `scala` | `camelCase ...Sql`, `..._SQL`, DB calls | regular and triple-quoted strings | includes common `execute` / `exec` / `prepare` / `query` call sites |
| `rust` | `userSql`, `USER_SQL`, crate call sites | regular and raw strings | covers common SQL crate usage |
| `typescript` | `camelCase ...Sql`, `PascalCase ...Sql`, `..._SQL` | template strings, concatenation | mirrors the JS strategy |
| `zig` | `camelCase ...Sql`, DB calls | multiline literals and direct call-site strings | tuned for common Zig naming |

### Current C / C++ Constraints

For `c`:

```c
const char *summary_sql = "  SELECT status \
  FROM users \
  ORDER BY status";
```

For `cpp`:

```cpp
const char *schema_sql = R"sql(  CREATE TABLE audit_logs (
  id INTEGER PRIMARY KEY,
  message TEXT NOT NULL
))sql";
```

## Debugging

Inspect the current buffer:

```vim
:TSInjectDebug
```

Or force the target language:

```vim
:TSInjectDebug sql
```

The debug view reports:

- parser paths
- active query files
- captures under cursor
- current node info
- nested language trees

## Verification

### Smoke test

```sh
env XDG_DATA_HOME=./tmp/test-data \
  XDG_STATE_HOME=./tmp/test-state \
  XDG_CACHE_HOME=./tmp/test-cache \
  /home/omega/.local/share/mise/installs/neovim/nightly/bin/nvim \
  --headless -u NONE -i NONE -n -l tests/smoke.lua
```

### Local example projects

The ignored example projects under `tmp/` use standard layouts where practical.

Open one with:

```sh
./tmp/verify-nvim-mini.sh --lang scala
```

Supported values:

- `c`
- `cpp`
- `csharp`
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

## LSP Notes

If SQL injection highlighting disappears after `gopls` attaches, disable
`gopls` semantic tokens in your LSP config so Tree-sitter injection highlighting
stays visible.

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
