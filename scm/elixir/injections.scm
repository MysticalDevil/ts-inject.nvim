; extends

; === Comment marker SQL ===
; Pattern: `# sql` comment on the line before a string assignment
(
  (comment) @_comment
  (binary_operator
    left: [(identifier) (alias)]
    operator: "="
    right: (string
      (quoted_content) @injection.content))
  (#lua-match? @_comment "^[ ]*#+[ ]*[Ss][Qq][Ll][ ]*$")
  (#set! injection.language "sql")
)

; === Variable naming heuristics ===
; UPPER_SNAKE_CASE ending with _SQL
(
  (binary_operator
    left: [(identifier) (alias)] @_name
    operator: "="
    right: (string
      (quoted_content) @injection.content))
  (#lua-match? @_name "^[A-Z][A-Z0-9_]*_SQL$")
  (#set! injection.language "sql")
)

; camelCase ending with Sql
(
  (binary_operator
    left: [(identifier) (alias)] @_name
    operator: "="
    right: (string
      (quoted_content) @injection.content))
  (#lua-match? @_name "^[a-z][a-zA-Z0-9]*Sql$")
  (#set! injection.language "sql")
)

; snake_case ending with _sql
(
  (binary_operator
    left: [(identifier) (alias)] @_name
    operator: "="
    right: (string
      (quoted_content) @injection.content))
  (#lua-match? @_name "^[a-z][a-z0-9_]*_sql$")
  (#set! injection.language "sql")
)

; === Sigil naming heuristics ===
; UPPER_SNAKE_CASE ending with _SQL (sigil)
(
  (binary_operator
    left: [(identifier) (alias)] @_name
    operator: "="
    right: (sigil
      (quoted_content) @injection.content))
  (#lua-match? @_name "^[A-Z][A-Z0-9_]*_SQL$")
  (#set! injection.language "sql")
)

; camelCase ending with Sql (sigil)
(
  (binary_operator
    left: [(identifier) (alias)] @_name
    operator: "="
    right: (sigil
      (quoted_content) @injection.content))
  (#lua-match? @_name "^[a-z][a-zA-Z0-9]*Sql$")
  (#set! injection.language "sql")
)

; snake_case ending with _sql (sigil)
(
  (binary_operator
    left: [(identifier) (alias)] @_name
    operator: "="
    right: (sigil
      (quoted_content) @injection.content))
  (#lua-match? @_name "^[a-z][a-z0-9_]*_sql$")
  (#set! injection.language "sql")
)

; === DB helper method calls ===
; <obj>.execute("...")
(
  (call
    (dot
      (identifier)
      "."
      (identifier) @_fn)
    (arguments
      (string
        (quoted_content) @injection.content)))
  (#any-of? @_fn "execute" "query" "query!" "prepare" "prepare!")
  (#set! injection.language "sql")
)

; <obj>.execute(~S"...")
(
  (call
    (dot
      (identifier)
      "."
      (identifier) @_fn)
    (arguments
      (sigil
        (quoted_content) @injection.content)))
  (#any-of? @_fn "execute" "query" "query!" "prepare" "prepare!")
  (#set! injection.language "sql")
)

; <obj>.execute("""...""")
(
  (call
    (dot
      (identifier)
      "."
      (identifier) @_fn)
    (arguments
      (string
        (quoted_content) @injection.content)))
  (#any-of? @_fn "execute" "query" "query!" "prepare" "prepare!")
  (#set! injection.language "sql")
)

; === Ecto.Adapters.SQL.query!/4 ===
(
  (call
    (dot
      (alias)
      "."
      (identifier) @_fn)
    (arguments
      (_)
      (string
        (quoted_content) @injection.content)))
  (#any-of? @_fn "query" "query!" "execute" "execute!")
  (#set! injection.language "sql")
)

(
  (call
    (dot
      (alias)
      "."
      (identifier) @_fn)
    (arguments
      (_)
      (sigil
        (quoted_content) @injection.content)))
  (#any-of? @_fn "query" "query!" "execute" "execute!")
  (#set! injection.language "sql")
)

; === String concatenation with naming heuristics ===
; 2-part concat
(
  (binary_operator
    left: [(identifier) (alias)] @_name
    operator: "="
    right: (binary_operator
      left: (string (quoted_content) @injection.content)
      operator: "<\>"
      right: (string (quoted_content) @injection.content)))
  (#lua-match? @_name "^[A-Z][A-Z0-9_]*_SQL$")
  (#set! injection.language "sql")
)

(
  (binary_operator
    left: [(identifier) (alias)] @_name
    operator: "="
    right: (binary_operator
      left: (string (quoted_content) @injection.content)
      operator: "<\>"
      right: (string (quoted_content) @injection.content)))
  (#lua-match? @_name "^[a-z][a-zA-Z0-9]*Sql$")
  (#set! injection.language "sql")
)

(
  (binary_operator
    left: [(identifier) (alias)] @_name
    operator: "="
    right: (binary_operator
      left: (string (quoted_content) @injection.content)
      operator: "<\>"
      right: (string (quoted_content) @injection.content)))
  (#lua-match? @_name "^[a-z][a-z0-9_]*_sql$")
  (#set! injection.language "sql")
)

; 3-part concat LEFT-associative: ((a <> b) <> c)
(
  (binary_operator
    left: [(identifier) (alias)] @_name
    operator: "="
    right: (binary_operator
      left: (binary_operator
        left: (string (quoted_content) @injection.content)
        operator: "<\>"
        right: (string (quoted_content) @injection.content))
      operator: "<\>"
      right: (string (quoted_content) @injection.content)))
  (#lua-match? @_name "^[A-Z][A-Z0-9_]*_SQL$")
  (#set! injection.language "sql")
)

(
  (binary_operator
    left: [(identifier) (alias)] @_name
    operator: "="
    right: (binary_operator
      left: (binary_operator
        left: (string (quoted_content) @injection.content)
        operator: "<\>"
        right: (string (quoted_content) @injection.content))
      operator: "<\>"
      right: (string (quoted_content) @injection.content)))
  (#lua-match? @_name "^[a-z][a-zA-Z0-9]*Sql$")
  (#set! injection.language "sql")
)

(
  (binary_operator
    left: [(identifier) (alias)] @_name
    operator: "="
    right: (binary_operator
      left: (binary_operator
        left: (string (quoted_content) @injection.content)
        operator: "<\>"
        right: (string (quoted_content) @injection.content))
      operator: "<\>"
      right: (string (quoted_content) @injection.content)))
  (#lua-match? @_name "^[a-z][a-z0-9_]*_sql$")
  (#set! injection.language "sql")
)

; 3-part concat RIGHT-associative: (a <> (b <> c))  -- Elixir <> is right-associative
(
  (binary_operator
    left: [(identifier) (alias)] @_name
    operator: "="
    right: (binary_operator
      left: (string (quoted_content) @injection.content)
      operator: "<\>"
      right: (binary_operator
        left: (string (quoted_content) @injection.content)
        operator: "<\>"
        right: (string (quoted_content) @injection.content))))
  (#lua-match? @_name "^[A-Z][A-Z0-9_]*_SQL$")
  (#set! injection.language "sql")
)

(
  (binary_operator
    left: [(identifier) (alias)] @_name
    operator: "="
    right: (binary_operator
      left: (string (quoted_content) @injection.content)
      operator: "<\>"
      right: (binary_operator
        left: (string (quoted_content) @injection.content)
        operator: "<\>"
        right: (string (quoted_content) @injection.content))))
  (#lua-match? @_name "^[a-z][a-zA-Z0-9]*Sql$")
  (#set! injection.language "sql")
)

(
  (binary_operator
    left: [(identifier) (alias)] @_name
    operator: "="
    right: (binary_operator
      left: (string (quoted_content) @injection.content)
      operator: "<\>"
      right: (binary_operator
        left: (string (quoted_content) @injection.content)
        operator: "<\>"
        right: (string (quoted_content) @injection.content))))
  (#lua-match? @_name "^[a-z][a-z0-9_]*_sql$")
  (#set! injection.language "sql")
)

; === DB helpers with concatenated strings ===
; 2-part
(
  (call
    (dot
      (identifier)
      "."
      (identifier) @_fn)
    (arguments
      (binary_operator
        left: (string (quoted_content) @injection.content)
        operator: "<\>"
        right: (string (quoted_content) @injection.content))))
  (#any-of? @_fn "execute" "query" "query!" "prepare" "prepare!")
  (#set! injection.language "sql")
)

; 3-part LEFT-associative
(
  (call
    (dot
      (identifier)
      "."
      (identifier) @_fn)
    (arguments
      (binary_operator
        left: (binary_operator
          left: (string (quoted_content) @injection.content)
          operator: "<\>"
          right: (string (quoted_content) @injection.content))
        operator: "<\>"
        right: (string (quoted_content) @injection.content))))
  (#any-of? @_fn "execute" "query" "query!" "prepare" "prepare!")
  (#set! injection.language "sql")
)

; 3-part RIGHT-associative
(
  (call
    (dot
      (identifier)
      "."
      (identifier) @_fn)
    (arguments
      (binary_operator
        left: (string (quoted_content) @injection.content)
        operator: "<\>"
        right: (binary_operator
          left: (string (quoted_content) @injection.content)
          operator: "<\>"
          right: (string (quoted_content) @injection.content)))))
  (#any-of? @_fn "execute" "query" "query!" "prepare" "prepare!")
  (#set! injection.language "sql")
)

; === Comment marker for concatenated strings ===
(
  (comment) @_comment
  (binary_operator
    left: [(identifier) (alias)]
    operator: "="
    right: (binary_operator
      left: (string (quoted_content) @injection.content)
      operator: "<\>"
      right: (string (quoted_content) @injection.content)))
  (#lua-match? @_comment "^[ ]*#+[ ]*[Ss][Qq][Ll][ ]*$")
  (#set! injection.language "sql")
)
