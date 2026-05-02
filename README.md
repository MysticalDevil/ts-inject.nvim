# ts-inject.nvim

Static and generated Tree-sitter injections for Neovim.

`ts-inject.nvim` now has two layers:

- stable static host support from `0.1` (SQL, GraphQL, and Regex)
- a small `0.2` framework for generated queries and experimental rules

The project favors stable, host-native heuristics over a generic rule engine.

## Installation

Requirements:

- Neovim `0.11+`
- Tree-sitter `sql` parser (for SQL injection)
- Tree-sitter `graphql` parser (for GraphQL injection in Go, JavaScript, TypeScript, Python, Rust, Java, Kotlin, C#, PHP, and Scala)
- Tree-sitter `regex` parser (for Regex injection in Java, C#, and PHP)
- Tree-sitter host parsers for every language you enable

`ts-inject.nvim` uses Neovim's built-in `vim.treesitter` APIs. It does not
require `nvim-treesitter` as a hard dependency.

`nvim-treesitter` was archived upstream. That is unfortunate, and this project
owes a lot to its years of work for the Neovim Tree-sitter ecosystem. Thank you
to its maintainers and contributors.

If you already use `nvim-treesitter`, it remains a convenient way to install and
manage parsers and query files. Treat it as a helpful manager, not a required
dependency.

### lazy.nvim

```lua
{
  "MysticalDevil/ts-inject.nvim",
  lazy = false, -- load before opening target buffers
  opts = {
    enable = {
      bash = true,
      go = true,
      python = true,
      rust = true,
      zig = true,
    },
  },
}
```

### vim.pack (Neovim 0.12+)

```lua
vim.pack.add({
  "https://github.com/MysticalDevil/ts-inject.nvim",
})

require("ts_inject").setup({
  enable = {
    bash = true,
    go = true,
    python = true,
    rust = true,
    zig = true,
  },
})
```

`vim.pack` is still marked experimental upstream, but suitable for daily use.

## Important Notes

- Load `ts-inject.nvim` before opening target buffers.
  - Avoid late lazy-loading events like `VeryLazy`.
  - Recommended plugin-spec setting: `lazy = false`.
- Some LSP servers' semantic tokens can visually override injected SQL
  highlighting. If SQL highlighting seems missing after LSP attach, disable
  semantic tokens for that server.

Example (`gopls`):

```lua
gopls = {
  settings = {
    gopls = {
      semanticTokens = false,
    },
  },
}
```

Current C / C++ support:

For `c`:

```c
const char *summary_sql = "  SELECT status "
                          "FROM users "
                          "ORDER BY status";
```

Backslash continuation (`"..." \`) is intentionally not supported
because Neovim's `injection.combined` merges across **all matches**
of a pattern, not just within a single `string_literal`.  A C file
with multiple SQL-hinted variables would end up with a single giant
injection spanning the entire declaration block, breaking every
injection.

Use adjacent string concatenation instead — it is equivalent C and
produces the same `concatenated_string` tree-sitter node, so the
injection works identically.

For `cpp`:

```cpp
const char *schema_sql = R"sql(  CREATE TABLE audit_logs (
  id INTEGER PRIMARY KEY,
  message TEXT NOT NULL
))sql";

// sql
auto marked_query = "SELECT id FROM marked_users";

auto inline_marked = /* sql */ R"sql(
  DELETE FROM marked_users
  WHERE active = false
)sql";

QSqlQuery qt_query("SELECT id FROM qt_users");
SQLite::Statement statement(db, "SELECT id FROM sqlite_users");
sql << "SELECT id FROM soci_users";
```

C++ SQL injection supports common string forms and DB call sites:

- variable names ending in `sql` / `Sql` / `SQL`
- assignment to SQL-named variables
- regular, adjacent, raw, UTF/wide-prefixed, suffixed, parenthesized, and casted
  C++ string literals
- explicit `sql` comments before declarations or inside initializers
- C APIs such as `sqlite3_exec`, `sqlite3_prepare_v2`, `PQexec`,
  `PQexecParams`, `PQprepare`, `mysql_query`, `SQLExecDirect`
- C++ helpers named `exec`, `execute`, `prepare`, or `query`
- query constructors such as `QSqlQuery`, `query`, `statement`, and
  `SQLite::Statement`
- SOCI-style stream expressions such as `sql << "..."` and
  `sql.prepare << "..."`
- inline assembly (`asm`, `__asm__`, `__asm__ volatile`) injected as `asm`
  (C and C++)

## Configuration

Default Settings:

```lua
---@type TSInjectOpts
{
  -- Command name used for the debug buffer.
  -- type: string
  debug_command = "TSInjectDebug",
  -- Explicit host opt-in. Empty means no injections are enabled.
  -- key options:
  --   bash | c | cpp | c_sharp | go | java | javascript | kotlin
  --   lua | php | python | ruby | scala | rust | typescript | xml | zig
  -- value: boolean
  enable = {},
  -- Optional per-host mode override.
  -- key options: same as `enable`
  -- value options: "generated" | "static"
  -- Defaults:
  -- - generated-capable hosts => "generated"
  -- - all other hosts => "static"
  query_mode = {},
  -- Optional experimental user rules for configurable generated hosts.
  -- Hosts: python, javascript, typescript, lua, ruby
  -- rule kinds:
  -- - var_suffix: { kind = "var_suffix", suffix = "..." [, lang = "sql"] }
  -- - call: { kind = "call", fn = "..." | { "...", ... } [, lang = "sql"] }
  -- - template_tag (javascript/typescript only):
  --   { kind = "template_tag", fn = "..." | { "...", ... } [, lang = "sql"] }
  -- - content_prefix (python/ruby/lua only):
  --   { kind = "content_prefix", patterns = { "...", ... } [, lang = "sql"] }
  -- host rule forms:
  -- - list form: rules.<host> = { <rule>, ... }
  -- - object form:
  --   rules.<host> = { builtin = boolean, items = { <rule>, ... } }
  rules = {},
}
```

Example:

```lua
---@type TSInjectOpts
require("ts_inject").setup({
  enable = {
    bash = true,
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
    xml = true,
    zig = true,
  },
  query_mode = {
    -- Optional per-host override:
    -- "generated" (default for generated-capable hosts) or "static" (legacy)
    python = "generated",
  },
  rules = {
    python = {
      builtin = false,
      items = {
        { kind = "call", fn = { "run_sql" }, lang = "sql" },
      },
    },
  },
})
```

`enable = {}` by default, so nothing is injected unless you explicitly enable hosts.

`rules` supports two forms for configurable generated hosts:

```lua
-- legacy list form (builtin rules stay enabled)
rules = {
  python = {
    { kind = "call", fn = { "run_sql" }, lang = "sql" },
  },
}

-- host-object form
rules = {
  python = {
    builtin = false, -- replace builtin rules for this host
    items = {
      { kind = "call", fn = { "run_sql" }, lang = "sql" },
    },
  },
}
```

Configurable generated hosts for `rules`:

- `python`
- `javascript`
- `typescript`
- `lua`
- `ruby`

Rule kinds:

- `var_suffix`
  - required: `suffix`
  - optional: `lang` (defaults to `"sql"`)
  - hosts: `python`, `javascript`, `typescript`, `lua`, `ruby`
- `call`
  - required: `fn` (string or list of strings)
  - optional: `lang` (defaults to `"sql"`)
  - hosts: `python`, `javascript`, `typescript`, `lua`, `ruby`
- `template_tag`
  - required: `fn` (string or list of strings)
  - optional: `lang` (defaults to `"sql"`)
  - hosts: `javascript`, `typescript`
- `content_prefix`
  - required: `patterns` (non-empty list of Lua-pattern strings)
  - optional: `lang` (defaults to `"sql"`)
  - hosts: `python`, `ruby`, `lua`

Lua-specific note for user rules:

- `var_suffix` is expanded internally to include `:format(...)` assignment forms.
- `call` is expanded internally to include `:format(...)` call-argument forms.

`query_mode` is optional and host-specific:

- generated-capable hosts default to `generated`
- all other hosts are `static`
- setting `query_mode.<host> = "static"` on a generated-capable host enables
  a legacy path and is not recommended

## Current Main Branch

Current main keeps the `0.1` compatibility path while adding `0.2+` features:

- static runtime-installed queries for most hosts
- generated runtime queries for `python`, `javascript`, `typescript`, `lua`,
  and `ruby`
- experimental additive `rules` support for `python`, `javascript`,
  `typescript`, `lua`, and `ruby`
- `:TSInjectDebug`, `:TSInjectReload`, and `:TSInjectHealth`
- built-in delimiter-driven shell heredoc injections for `bash`

Generated-host static query snapshots are kept in `archive/scm-generated/` for
reference only; runtime loading uses generated queries for those hosts.

Supported hosts:

- `bash`
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
- `xml`
- `zig`

## Host Matrix

| Host | Primary naming / signal | Stable string forms | Notes |
| --- | --- | --- | --- |
| `bash` | heredoc delimiters | heredoc bodies | built-in `SQL`, `PY`, `LUA`, `JS`, `TS`, `RB`/`RUBY`, `PL`/`PERL` delimiter mapping |
| `c` | `*_sql`, DB API calls | adjacent string literals | includes SQLite/libpq/MySQL/ODBC APIs; also injects `asm` into `gnu_asm_expression` |
| `cpp` | `*_sql`, DB API calls, `sql` comments | regular, adjacent, raw, prefixed, suffixed, parenthesized, casted | includes SQLite/libpq/MySQL/ODBC, Qt, SQLiteCpp, SOCI, common wrappers |
| `c_sharp` | `camelCase ...Sql`, `..._SQL`, DB calls | regular, concatenated, verbatim | SQL: common `Query` / `Execute` / `Prepare` paths; GraphQL: `*_GQL` / `*Gql` suffix; Regex: `Regex.Match` / `Regex.Replace` / `new Regex(...)` |
| `go` | Go-style `userQuery`, SQL-looking content | raw and interpreted strings | SQL: favors obvious SQL text; GraphQL: content prefix (query/mutation/subscription/fragment) |
| `java` | `camelCase ...Sql`, `..._SQL`, DB calls, SQL annotations | regular, concatenated, text blocks, annotation strings/arrays | SQL: JDBC, JdbcTemplate, JDBI, JPA/Hibernate query APIs, jOOQ plain SQL, MyBatis annotations; GraphQL: `*_GQL` / `*Gql` suffix; Regex: `Pattern.compile(...)` / `String.matches(...)` |
| `javascript` | `camelCase ...Sql`, `PascalCase ...Sql`, `..._SQL` | template strings, concatenation | SQL: common query / execute call sites; GraphQL: `gql`/`graphql`/`gqlRequest` template tags |
| `kotlin` | `camelCase ...Sql`, `..._SQL`, DB calls | raw strings, `trimIndent`, `trimMargin`, concatenation | SQL: common Kotlin SQL shapes; GraphQL: `*_GQL` / `*Gql` suffix |
| `lua` | `snake_case ..._sql`, `..._SQL`, DB calls | long strings, concatenation, `:format(...)` | Lua-specific helper syntax is supported |
| `php` | `$camelCaseSql`, `..._SQL`, DB calls | regular strings, concatenation, heredoc/nowdoc | SQL: common PDO-style usage; GraphQL: `*_GQL` / `*Gql` suffix; Regex: `preg_match` / `preg_replace` / `preg_split` first argument |
| `python` | `snake_case ..._sql`, obvious SQL content, DB calls | regular, triple-quoted, concatenated | SQL: `execute` / `executemany` / `executescript`; GraphQL: content prefix (query/mutation/subscription/fragment) |
| `ruby` | `snake_case ..._sql`, `..._SQL`, DB calls | regular strings, SQL heredocs | includes `execute`, `exec`, `prepare`, `find_by_sql` |
| `scala` | `camelCase ...Sql`, `..._SQL`, DB calls | regular and triple-quoted strings | SQL: common `execute` / `exec` / `prepare` / `query` call sites; GraphQL: `*_GQL` / `*Gql` suffix |
| `rust` | `userSql`, `USER_SQL`, crate call sites | regular and raw strings | SQL: sqlx, diesel, SeaORM, and common wrapper methods; GraphQL: `*_gql` / `*Graphql` suffix, content prefix, `graphql!` / `gql!` macros |
| `typescript` | `camelCase ...Sql`, `PascalCase ...Sql`, `..._SQL` | template strings, concatenation | SQL: mirrors the JS strategy; GraphQL: same template_tag support as JS |
| `xml` | MyBatis mapper SQL tags | element text and CDATA | injects SQL in `select`, `insert`, `update`, `delete`, and `sql` mapper tags |
| `elixir` | `snake_case ..._sql`, `camelCase ...Sql`, `UPPER_SNAKE_CASE_SQL`, DB calls | regular strings, sigils, concatenation (`<>`) | includes `Ecto.Adapters.SQL.query!` and comment-marker `# sql` |
| `zig` | `camelCase ...Sql`, DB calls | multiline literals and direct call-site strings | tuned for common Zig naming |

### Shell Heredoc Tags

Built-in shell delimiter mappings:

- `SQL` -> `sql`
- `PY` -> `python`
- `LUA` -> `lua`
- `JS` -> `javascript`
- `TS` -> `typescript`
- `RB`, `RUBY` -> `ruby`
- `PL`, `PERL` -> `perl`

A complete shell example covering every supported heredoc tag is described in
the ignored `tmp/shell-heredoc-all.sh` fixture path.

### Generated Hosts

Current generated hosts:

- `python`
- `javascript`
- `typescript`
- `lua`
- `ruby`

`python`, `javascript`, `typescript`, `lua`, and `ruby` accept experimental
additive rules in `setup({ rules = { ... } })`.

`scm/` now represents static-runtime hosts only. Generated-host snapshots live
under `archive/scm-generated/`.

Supported experimental rule kinds:

- `var_suffix`
- `call`
- `template_tag` (currently for `javascript` and `typescript`, supports `sql` and `graphql`)
- `content_prefix` (currently for `python`, `ruby`, and `lua`)

Current limits:

- built-in rules stay enabled unless a configurable generated host sets
  `builtin = false`
- user rules are additive by default
- no precedence / disable system yet
- no stable API guarantee yet
- invalid `rules` entries are ignored with runtime warnings
- invalid `query_mode` entries are ignored with runtime warnings

## Debugging

Inspect the current buffer:

```vim
:TSInjectDebug
```

Or force the target language:

```vim
:TSInjectDebug sql
```

Regenerate runtime queries:

```vim
:TSInjectReload
```

If injections still do not appear after startup-order fixes:

1. Run `:TSInjectReload`
2. Reopen the file (or restart Neovim)
3. Place cursor on an SQL keyword and run `:TSInjectDebug`

Inspect plugin/runtime state:

```vim
:TSInjectHealth
```

The debug and health views report:

- parser paths
- active query files
- captures under cursor
- current node info
- nested language trees
- enabled hosts
- static vs generated hosts
- generated query file presence
- builtin and user rule counts for generated hosts
- legacy static hosts (generated-capable hosts forced to `static`)
- runtime warnings

`TSInjectHealth` is the quickest way to confirm:

- a host is `generated` vs `static`
- `builtin` is on/off for configurable generated hosts
- generated query files are present on disk
