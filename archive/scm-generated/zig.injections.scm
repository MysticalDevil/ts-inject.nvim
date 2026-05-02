; extends

; SQL assignment like `const usersSql = \\SELECT ...;`
(
  (variable_declaration
    (identifier) @_name
    (multiline_string) @injection.content)
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#set! injection.language "sql")
)

(
  (variable_declaration
    (identifier) @_name
    (string
      (string_content) @injection.content))
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#set! injection.language "sql")
)

; SQL passed to Zig DB helpers.
(
  (call_expression
    function: (field_expression
      object: (identifier)
      member: (identifier) @_fn)
    arguments: (arguments
      (multiline_string) @injection.content))
  (#any-of? @_fn "query" "execute" "prepare")
  (#set! injection.language "sql")
)

(
  (call_expression
    function: (field_expression
      object: (identifier)
      member: (identifier) @_fn)
    arguments: (arguments
      (multiline_string) @injection.content
      .))
  (#any-of? @_fn "query" "execute" "prepare")
  (#set! injection.language "sql")
)

(
  (call_expression
    function: (field_expression
      object: (identifier)
      member: (identifier) @_fn)
    arguments: (arguments
      (string
        (string_content) @injection.content)))
  (#any-of? @_fn "query" "execute" "prepare")
  (#set! injection.language "sql")
)

(
  (call_expression
    function: (field_expression
      object: (identifier)
      member: (identifier) @_fn)
    arguments: (arguments
      (string
        (string_content) @injection.content)
      .))
  (#any-of? @_fn "query" "execute" "prepare")
  (#set! injection.language "sql")
)
