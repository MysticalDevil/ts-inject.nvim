; extends

(
  (declaration
    declarator: (init_declarator
      declarator: [
        (identifier) @_name
        (pointer_declarator
          declarator: (identifier) @_name)
      ]
      value: (raw_string_literal
        (raw_string_content) @injection.content)))
  (#lua-match? @_name "^[%l][%w_]*_sql$")
  (#set! injection.language "sql")
)

(
  (call_expression
    function: (identifier) @_fn
    arguments: (argument_list
      (_)
      .
      (raw_string_literal
        (raw_string_content) @injection.content)))
  (#eq? @_fn "sqlite3_prepare_v2")
  (#set! injection.language "sql")
)

(
  (call_expression
    function: (identifier) @_fn
    arguments: (argument_list
      (_)
      .
      (raw_string_literal
        (raw_string_content) @injection.content)))
  (#eq? @_fn "sqlite3_exec")
  (#set! injection.language "sql")
)

(
  (call_expression
    function: (identifier) @_fn
    arguments: (argument_list
      (_)
      .
      (raw_string_literal
        (raw_string_content) @injection.content)))
  (#eq? @_fn "PQexec")
  (#set! injection.language "sql")
)

(
  (call_expression
    function: (identifier) @_fn
    arguments: (argument_list
      (_)
      .
      (_)
      .
      (raw_string_literal
        (raw_string_content) @injection.content)))
  (#eq? @_fn "PQprepare")
  (#set! injection.language "sql")
)
