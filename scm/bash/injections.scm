; extends

; === Variable naming heuristics ===
(
  (variable_assignment
    name: (variable_name) @_name
    value: (string
      (string_content) @injection.content))
  (#lua-match? @_name "^[a-z][a-z0-9_]*_sql$")
  (#set! injection.language "sql")
)

(
  (variable_assignment
    name: (variable_name) @_name
    value: (string
      (string_content) @injection.content))
  (#lua-match? @_name "^[a-z][a-zA-Z0-9]*Sql$")
  (#set! injection.language "sql")
)

(
  (variable_assignment
    name: (variable_name) @_name
    value: (string
      (string_content) @injection.content))
  (#lua-match? @_name "^[A-Z][A-Z0-9_]*_SQL$")
  (#set! injection.language "sql")
)

; === Command calls with SQL arguments ===
; sqlite3 db "SELECT ..."
(
  (command
    name: (command_name (word) @_cmd)
    argument: (string
      (string_content) @injection.content))
  (#any-of? @_cmd "sqlite3" "psql" "mysql" "mariadb" "pg_dump")
  (#set! injection.language "sql")
)

; psql -c "SELECT ..."
(
  (command
    name: (command_name (word) @_cmd)
    argument: (word) @_flag
    argument: (string
      (string_content) @injection.content))
  (#any-of? @_cmd "psql" "mysql" "mariadb")
  (#any-of? @_flag "-c" "-e" "--command" "--execute")
  (#set! injection.language "sql")
)

; === Function calls ===
; run_query "SELECT ..."
(
  (command
    name: (command_name (word) @_cmd)
    argument: (string
      (string_content) @injection.content))
  (#any-of? @_cmd "run_query" "run_sql" "execute_sql" "exec_sql" "query_sql")
  (#set! injection.language "sql")
)

; === Here-string ===
; sqlite3 db <<< "SELECT ..."
(
  (herestring_redirect
    (string
      (string_content) @injection.content))
  (#set! injection.language "sql")
)

; === String concatenation ===
(
  (variable_assignment
    name: (variable_name) @_name
    value: (concatenation
      (string
        (string_content) @injection.content)+))
  (#lua-match? @_name "^[a-z][a-z0-9_]*_sql$")
  (#set! injection.language "sql")
)

(
  (variable_assignment
    name: (variable_name) @_name
    value: (concatenation
      (string
        (string_content) @injection.content)+))
  (#lua-match? @_name "^[a-z][a-zA-Z0-9]*Sql$")
  (#set! injection.language "sql")
)

(
  (variable_assignment
    name: (variable_name) @_name
    value: (concatenation
      (string
        (string_content) @injection.content)+))
  (#lua-match? @_name "^[A-Z][A-Z0-9_]*_SQL$")
  (#set! injection.language "sql")
)

; === Heredoc (existing) ===
((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
 (#eq? @_lang "SQL")
 (#set! injection.language "sql"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
 (#eq? @_lang "PY")
 (#set! injection.language "python"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
 (#eq? @_lang "LUA")
 (#set! injection.language "lua"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
 (#eq? @_lang "JS")
 (#set! injection.language "javascript"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
 (#eq? @_lang "TS")
 (#set! injection.language "typescript"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
 (#any-of? @_lang "RB" "RUBY")
 (#set! injection.language "ruby"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
 (#any-of? @_lang "PL" "PERL")
 (#set! injection.language "perl"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
 (#any-of? @_lang "GRAPHQL" "GQL")
 (#set! injection.language "graphql"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
 (#eq? @_lang "JSON")
 (#set! injection.language "json"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
 (#any-of? @_lang "REGEX" "RE")
 (#set! injection.language "regex"))
