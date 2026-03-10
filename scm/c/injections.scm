; extends

(
  (declaration
    declarator: (init_declarator
      declarator: [
        (identifier) @_name
        (pointer_declarator
          declarator: (identifier) @_name)
      ]
      value: (string_literal
        "\""
        (string_content) @injection.content
        (escape_sequence)
        (string_content) @injection.content
        (escape_sequence)
        (string_content) @injection.content
        "\"")))
  (#lua-match? @_name "^[%l][%w_]*_sql$")
  (#set! injection.combined)
  (#set! injection.language "sql")
)

(
  (call_expression
    function: (identifier) @_fn
    arguments: (argument_list
      (_)
      .
      (string_literal
        "\""
        (string_content) @injection.content
        "\"")))
  (#eq? @_fn "sqlite3_prepare_v2")
  (#set! injection.language "sql")
)

(
  (call_expression
    function: (identifier) @_fn
    arguments: (argument_list
      (_)
      .
      (string_literal
        "\""
        (string_content) @injection.content
        (escape_sequence)
        (string_content) @injection.content
        (escape_sequence)
        (string_content) @injection.content
        "\"")))
  (#eq? @_fn "sqlite3_exec")
  (#set! injection.combined)
  (#set! injection.language "sql")
)

(
  (call_expression
    function: (identifier) @_fn
    arguments: (argument_list
      (_)
      .
      (string_literal
        "\""
        (string_content) @injection.content
        (escape_sequence)
        (string_content) @injection.content
        (escape_sequence)
        (string_content) @injection.content
        "\"")))
  (#eq? @_fn "PQexec")
  (#set! injection.combined)
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
      (string_literal
        "\""
        (string_content) @injection.content
        "\"")))
  (#eq? @_fn "PQprepare")
  (#set! injection.language "sql")
)
