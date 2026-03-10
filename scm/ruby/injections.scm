; extends

(
  (assignment
    left: (identifier) @_name
    right: (string
      (string_content) @injection.content))
  (#lua-match? @_name "^[%l_][%w_]*_sql$")
  (#set! injection.language "sql")
)

(
  (assignment
    left: (constant) @_name
    right: (string
      (string_content) @injection.content))
  (#lua-match? @_name "^[%u][%u%d_]*_SQL$")
  (#set! injection.language "sql")
)

(
  (call
    method: (identifier) @_method
    arguments: (argument_list
      (string
        (string_content) @injection.content)))
  (#any-of? @_method "execute" "exec" "prepare" "find_by_sql")
  (#set! injection.language "sql")
)

(
  (call
    receiver: (_)
    method: (identifier) @_method
    arguments: (argument_list
      (string
        (string_content) @injection.content)))
  (#any-of? @_method "execute" "exec" "prepare" "find_by_sql")
  (#set! injection.language "sql")
)
