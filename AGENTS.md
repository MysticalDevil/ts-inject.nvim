# Repository Guidelines

## Scope

These instructions apply to the entire repository.

## AST inspection

- Prefer `ast-grep` for language AST exploration when shaping or debugging injection rules.
- Use `ast-grep` to identify common assignment, call, macro, and string-node patterns before writing or changing Tree-sitter queries.
- Treat `ast-grep` as a discovery tool. Final verification still needs to use the actual Tree-sitter grammar, Neovim query behavior, and `:TSInjectDebug`.

## Example projects

- Keep language examples in `tmp/` out of git unless explicitly requested otherwise.
- Example projects should use standard ecosystem layouts where practical.
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

## Validation

- When adjusting injection behavior, prefer verifying with both:
  - repo smoke tests
  - the ignored example project opened through the local verification script
