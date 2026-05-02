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

; === GraphQL ===

; GQL suffix
(
  (val_definition
    pattern: (identifier) @_name
    value: (string) @injection.content)
  (#lua-match? @_name "^[%l][%w]*Gql$")
  (#not-lua-match? @injection.content "^\"\"\"")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "graphql")
)

(
  (val_definition
    pattern: (identifier) @_name
    value: (string) @injection.content)
  (#lua-match? @_name "^[%l][%w]*Gql$")
  (#lua-match? @injection.content "^\"\"\"")
  (#offset! @injection.content 0 3 0 -3)
  (#set! injection.language "graphql")
)

(
  (val_definition
    pattern: (identifier) @_name
    value: (string) @injection.content)
  (#lua-match? @_name "^[%u][%u%d_]*_GQL$")
  (#lua-match? @injection.content "^\"\"\"")
  (#offset! @injection.content 0 3 0 -3)
  (#set! injection.language "graphql")
)

; === Regex ===

; *_REGEX / *Regex suffix variables
(
  (val_definition
    pattern: (identifier) @_name
    value: (string) @injection.content)
  (#lua-match? @_name "^[%l][%w]*Regex$")
  (#not-lua-match? @injection.content "^\"\"\"")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "regex")
)

(
  (val_definition
    pattern: (identifier) @_name
    value: (string) @injection.content)
  (#lua-match? @_name "^[%u][%u%d_]*_REGEX$")
  (#not-lua-match? @injection.content "^\"\"\"")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "regex")
)

; "pattern".r
(
  (field_expression
    (string) @injection.content
    (identifier) @_suffix)
  (#eq? @_suffix "r")
  (#not-lua-match? @injection.content "^\"\"\"")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "regex")
)

; new Regex("pattern")
(
  (instance_expression
    (type_identifier) @_class
    (arguments
      (string) @injection.content))
  (#eq? @_class "Regex")
  (#not-lua-match? @injection.content "^\"\"\"")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "regex")
)
