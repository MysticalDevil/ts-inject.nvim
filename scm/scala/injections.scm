; extends

(
  (val_definition
    pattern: (identifier) @_name
    value: (string) @injection.content)
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#not-lua-match? @injection.content "^\"\"\"")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "sql")
)

(
  (val_definition
    pattern: (identifier) @_name
    value: (string) @injection.content)
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#lua-match? @injection.content "^\"\"\"")
  (#offset! @injection.content 0 3 0 -3)
  (#set! injection.language "sql")
)

(
  (val_definition
    pattern: (identifier) @_name
    value: (string) @injection.content)
  (#lua-match? @_name "^[%u][%u%d_]*_SQL$")
  (#lua-match? @injection.content "^\"\"\"")
  (#offset! @injection.content 0 3 0 -3)
  (#set! injection.language "sql")
)

(
  (call_expression
    function: (field_expression
      field: (identifier) @_method)
    arguments: (arguments
      (string) @injection.content))
  (#any-of? @_method "execute" "exec" "prepare" "query" "queryRaw")
  (#not-lua-match? @injection.content "^\"\"\"")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "sql")
)

(
  (call_expression
    function: (field_expression
      field: (identifier) @_method)
    arguments: (arguments
      (string) @injection.content))
  (#any-of? @_method "execute" "exec" "prepare" "query" "queryRaw")
  (#lua-match? @injection.content "^\"\"\"")
  (#offset! @injection.content 0 3 0 -3)
  (#set! injection.language "sql")
)
