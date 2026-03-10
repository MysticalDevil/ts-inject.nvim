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

### C note

`c` is currently restricted to explicit database API call sites plus
backslash-continued multiline `*_sql` declarations:

- `sqlite3_exec`
- `sqlite3_prepare_v2`
- `PQexec`
- `PQprepare`
- declarations like:

```c
const char *summary_sql = "  SELECT status \
    FROM users \
    ORDER BY status";
```

Plain C variable assignments such as `const char *query_sql = "...";` are
currently treated as normal strings. This is intentional for now because the
single-line declaration path has shown unstable highlight behavior.

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
