# ts-inject.nvim

Minimal Tree-sitter injection helpers for Neovim.

Current MVP scope:

- Go and Python host buffers
- SQL string injection
- `:TSInjectDebug` for inspection

## Requirements

- Neovim 0.11+
- Tree-sitter Go parser if you enable Go injections
- Tree-sitter Python parser if you enable Python injections
- Tree-sitter SQL parser

## Installation

Add the plugin to your plugin manager, then:

```lua
require("ts_inject").setup({
  enable = {
    go = true,
    python = true,
  },
})
```

The plugin does not enable any host-language injections by default. You must
explicitly enable each supported language in `setup()`.

## What It Does

The plugin registers static injection queries at runtime for the languages you
explicitly enable. Current built-in hosts are `go` and `python`.

Go currently matches:

- common SQL statement keywords like `SELECT`, `INSERT`, `UPDATE`, `DELETE`
- common DDL and transaction fragments like `CREATE TABLE`, `ALTER TABLE`,
  `BEGIN`, and `COMMIT`
- SQL marker strings like `-- sql`

Python currently matches:

- assignments such as `QUERY_SQL = """..."""`
- parenthesized concatenated string assignments ending in `sql`
- `execute`, `executemany`, and `executescript` calls with string SQL arguments

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

The repo uses the same Lua tooling settings as `~/.config/nvim-lite`.

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
