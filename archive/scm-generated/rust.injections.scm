; Rust injections are defined as a full query so we can override the default
; macro token-tree injection from nvim-treesitter for sqlx SQL macros.

(macro_invocation
  macro: [
    (scoped_identifier
      name: (_) @_macro_name)
    (identifier) @_macro_name
  ]
  (token_tree) @injection.content
  (#not-any-of? @_macro_name "slint" "html" "json" "query" "query_as" "query_scalar")
  (#set! injection.language "rust")
  (#set! injection.include-children))

(macro_invocation
  macro: [
    (scoped_identifier
      name: (_) @injection.language)
    (identifier) @injection.language
  ]
  (token_tree) @injection.content
  (#any-of? @injection.language "slint" "html" "json")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children))

(macro_definition
  (macro_rule
    left: (token_tree_pattern) @injection.content
    (#set! injection.language "rust")))

(macro_definition
  (macro_rule
    right: (token_tree) @injection.content
    (#set! injection.language "rust")))

([
  (line_comment)
  (block_comment)
] @injection.content
  (#set! injection.language "comment"))

(call_expression
  function: (scoped_identifier
    path: (identifier) @_regex
    (#any-of? @_regex "Regex" "RegexBuilder")
    name: (identifier) @_new
    (#eq? @_new "new"))
  arguments: (arguments
    (raw_string_literal
      (string_content) @injection.content))
  (#set! injection.language "regex"))

(call_expression
  function: (scoped_identifier
    path: (scoped_identifier
      (identifier) @_regex
      (#any-of? @_regex "Regex" "RegexBuilder") .)
    name: (identifier) @_new
    (#eq? @_new "new"))
  arguments: (arguments
    (raw_string_literal
      (string_content) @injection.content))
  (#set! injection.language "regex"))

(call_expression
  function: (scoped_identifier
    path: (identifier) @_regex
    (#any-of? @_regex "RegexSet" "RegexSetBuilder")
    name: (identifier) @_new
    (#eq? @_new "new"))
  arguments: (arguments
    (array_expression
      (raw_string_literal
        (string_content) @injection.content)))
  (#set! injection.language "regex"))

(call_expression
  function: (scoped_identifier
    path: (scoped_identifier
      (identifier) @_regex
      (#any-of? @_regex "RegexSet" "RegexSetBuilder") .)
    name: (identifier) @_new
    (#eq? @_new "new"))
  arguments: (arguments
    (array_expression
      (raw_string_literal
        (string_content) @injection.content)))
  (#set! injection.language "regex"))

((block_comment) @injection.content
  (#match? @injection.content "/\\*!([a-zA-Z]+:)?re2c")
  (#set! injection.language "re2c"))

; SQL variable by suffix like `schema_sql` or `schemaSql`.
(
  (let_declaration
    pattern: (identifier) @_name
    value: [
      (string_literal
        (string_content) @injection.content)
      (raw_string_literal
        (string_content) @injection.content)
    ])
  (#lua-match? @_name "^[%a_][%w_]*[Ss][Qq][Ll]$")
  (#set! injection.language "sql"))

; SQL variable by recognizable SQL content.
(
  (let_declaration
    pattern: (identifier)
    value: [
      (string_literal
        (string_content) @injection.content)
      (raw_string_literal
        (string_content) @injection.content)
    ])
  (#lua-match? @injection.content "^%s*[Ss][Ee][Ll][Ee][Cc][Tt]%s+")
  (#set! injection.language "sql"))

(
  (let_declaration
    pattern: (identifier)
    value: [
      (string_literal
        (string_content) @injection.content)
      (raw_string_literal
        (string_content) @injection.content)
    ])
  (#lua-match? @injection.content "^%s*[Ii][Nn][Ss][Ee][Rr][Tt]%s+[Ii][Nn][Tt][Oo]%s+")
  (#set! injection.language "sql"))

(
  (let_declaration
    pattern: (identifier)
    value: [
      (string_literal
        (string_content) @injection.content)
      (raw_string_literal
        (string_content) @injection.content)
    ])
  (#lua-match? @injection.content "^%s*[Uu][Pp][Dd][Aa][Tt][Ee]%s+")
  (#set! injection.language "sql"))

(
  (let_declaration
    pattern: (identifier)
    value: [
      (string_literal
        (string_content) @injection.content)
      (raw_string_literal
        (string_content) @injection.content)
    ])
  (#lua-match? @injection.content "^%s*[Dd][Ee][Ll][Ee][Tt][Ee]%s+[Ff][Rr][Oo][Mm]%s+")
  (#set! injection.language "sql"))

(
  (let_declaration
    pattern: (identifier)
    value: [
      (string_literal
        (string_content) @injection.content)
      (raw_string_literal
        (string_content) @injection.content)
    ])
  (#lua-match? @injection.content "^%s*[Cc][Rr][Ee][Aa][Tt][Ee]%s+")
  (#set! injection.language "sql"))

(
  (let_declaration
    pattern: (identifier)
    value: [
      (string_literal
        (string_content) @injection.content)
      (raw_string_literal
        (string_content) @injection.content)
    ])
  (#lua-match? @injection.content "^%s*[Ww][Ii][Tt][Hh]%s+")
  (#set! injection.language "sql"))

; sqlx / diesel function calls with string or raw string SQL.
(
  (call_expression
    function: [
      (identifier) @_fn
      (scoped_identifier
        name: (identifier) @_fn)
    ]
    arguments: (arguments
      [
        (string_literal
          (string_content) @injection.content)
        (raw_string_literal
          (string_content) @injection.content)
      ]
      . (_)*))
  (#any-of? @_fn "query" "query_as" "query_scalar" "sql_query" "prepare")
  (#set! injection.language "sql"))

; Generic sqlx functions like `sqlx::query_as::<_, T>("...")`.
(
  (call_expression
    function: (generic_function
      function: [
        (identifier) @_fn
        (scoped_identifier
          name: (identifier) @_fn)
      ])
    arguments: (arguments
      [
        (string_literal
          (string_content) @injection.content)
        (raw_string_literal
          (string_content) @injection.content)
      ]
      . (_)*))
  (#any-of? @_fn "query" "query_as" "query_scalar" "query_file_as")
  (#set! injection.language "sql"))

; SeaORM statement builders with SQL as the second argument.
(
  (call_expression
    function: (scoped_identifier
      name: (identifier) @_fn)
    arguments: (arguments
      (_)
      [
        (string_literal
          (string_content) @injection.content)
        (raw_string_literal
          (string_content) @injection.content)
      ]
      . (_)*))
  (#any-of? @_fn "from_string" "from_sql_and_values")
  (#set! injection.language "sql"))

; Common Rust DB wrapper methods with SQL as the first argument.
(
  (call_expression
    function: (field_expression
      field: (field_identifier) @_method)
    arguments: (arguments
      [
        (string_literal
          (string_content) @injection.content)
        (raw_string_literal
          (string_content) @injection.content)
      ]
      . (_)*))
  (#any-of? @_method
    "exec"
    "exec_stmt"
    "execute"
    "execute_unprepared"
    "fetch"
    "fetch_all"
    "fetch_one"
    "fetch_optional"
    "prepare"
    "query"
    "query_all"
    "query_one")
  (#set! injection.language "sql"))

; sqlx macros like `query!`, `query_as!`, `query_scalar!`.
(
  (macro_invocation
    macro: [
      (identifier) @_macro
      (scoped_identifier
        name: (identifier) @_macro)
    ]
    (token_tree
      [
        (string_literal
          (string_content) @injection.content)
        (raw_string_literal
          (string_content) @injection.content)
      ]
      . (_)*))
  (#any-of? @_macro "query" "query_as" "query_scalar")
  (#set! injection.language "sql"))

; === GraphQL ===

; GraphQL variable by suffix like `get_users_gql` or `getUsersGraphql`.
(
  (let_declaration
    pattern: (identifier) @_name
    value: [
      (string_literal
        (string_content) @injection.content)
      (raw_string_literal
        (string_content) @injection.content)
    ])
  (#lua-match? @_name "^[%a_][%w_]*[Gg][Qq][Ll]$")
  (#set! injection.language "graphql"))

(
  (let_declaration
    pattern: (identifier) @_name
    value: [
      (string_literal
        (string_content) @injection.content)
      (raw_string_literal
        (string_content) @injection.content)
    ])
  (#lua-match? @_name "^[%a_][%w_]*[Gg][Rr][Aa][Pp][Hh][Qq][Ll]$")
  (#set! injection.language "graphql"))

; GraphQL by recognizable content prefix.
(
  (let_declaration
    pattern: (identifier)
    value: [
      (string_literal
        (string_content) @injection.content)
      (raw_string_literal
        (string_content) @injection.content)
    ])
  (#lua-match? @injection.content "^%s*[Qq][Uu][Ee][Rr][Yy]%s+")
  (#set! injection.language "graphql"))

(
  (let_declaration
    pattern: (identifier)
    value: [
      (string_literal
        (string_content) @injection.content)
      (raw_string_literal
        (string_content) @injection.content)
    ])
  (#lua-match? @injection.content "^%s*[Mm][Uu][Tt][Aa][Tt][Ii][Oo][Nn]%s+")
  (#set! injection.language "graphql"))

(
  (let_declaration
    pattern: (identifier)
    value: [
      (string_literal
        (string_content) @injection.content)
      (raw_string_literal
        (string_content) @injection.content)
    ])
  (#lua-match? @injection.content "^%s*[Ss][Uu][Bb][Ss][Cc][Rr][Ii][Pp][Tt][Ii][Oo][Nn]%s+")
  (#set! injection.language "graphql"))

(
  (let_declaration
    pattern: (identifier)
    value: [
      (string_literal
        (string_content) @injection.content)
      (raw_string_literal
        (string_content) @injection.content)
    ])
  (#lua-match? @injection.content "^%s*[Ff][Rr][Aa][Gg][Mm][Ee][Nn][Tt]%s+")
  (#set! injection.language "graphql"))

; GraphQL macros like `graphql!`, `gql!`.
(
  (macro_invocation
    macro: [
      (identifier) @_macro
      (scoped_identifier
        name: (identifier) @_macro)
    ]
    (token_tree
      [
        (string_literal
          (string_content) @injection.content)
        (raw_string_literal
          (string_content) @injection.content)
      ]
      . (_)*))
  (#any-of? @_macro "graphql" "gql")
  (#set! injection.language "graphql"))
