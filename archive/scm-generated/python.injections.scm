; extends

; SQL assignment by variable suffix like `schema_sql = """..."""`.
(
  (expression_statement
    (assignment
      left: (identifier) @_name
      right: (string
        (string_content) @injection.content)))
  (#lua-match? @_name "^[%a_][%w_]*[Ss][Qq][Ll]$")
  (#set! injection.language "sql"))

; SQL assignment by variable suffix with concatenated strings.
(
  (expression_statement
    (assignment
      left: (identifier) @_name
      right: (parenthesized_expression
        (concatenated_string
          (string
            (string_content) @injection.content)+))))
  (#lua-match? @_name "^[%a_][%w_]*[Ss][Qq][Ll]$")
  (#set! injection.combined)
  (#set! injection.language "sql"))

; SQL assignment by recognizable SQL content, even without a *_sql name.
(
  (expression_statement
    (assignment
      left: (identifier)
      right: (string
        (string_content) @injection.content)))
  (#lua-match? @injection.content "^%s*[Ss][Ee][Ll][Ee][Cc][Tt]%s+")
  (#set! injection.language "sql"))

(
  (expression_statement
    (assignment
      left: (identifier)
      right: (string
        (string_content) @injection.content)))
  (#lua-match? @injection.content "^%s*[Ii][Nn][Ss][Ee][Rr][Tt]%s+[Ii][Nn][Tt][Oo]%s+")
  (#set! injection.language "sql"))

(
  (expression_statement
    (assignment
      left: (identifier)
      right: (string
        (string_content) @injection.content)))
  (#lua-match? @injection.content "^%s*[Uu][Pp][Dd][Aa][Tt][Ee]%s+")
  (#set! injection.language "sql"))

(
  (expression_statement
    (assignment
      left: (identifier)
      right: (string
        (string_content) @injection.content)))
  (#lua-match? @injection.content "^%s*[Dd][Ee][Ll][Ee][Tt][Ee]%s+[Ff][Rr][Oo][Mm]%s+")
  (#set! injection.language "sql"))

(
  (expression_statement
    (assignment
      left: (identifier)
      right: (string
        (string_content) @injection.content)))
  (#lua-match? @injection.content "^%s*[Cc][Rr][Ee][Aa][Tt][Ee]%s+")
  (#set! injection.language "sql"))

(
  (expression_statement
    (assignment
      left: (identifier)
      right: (string
        (string_content) @injection.content)))
  (#lua-match? @injection.content "^%s*[Aa][Ll][Tt][Ee][Rr]%s+")
  (#set! injection.language "sql"))

(
  (expression_statement
    (assignment
      left: (identifier)
      right: (string
        (string_content) @injection.content)))
  (#lua-match? @injection.content "^%s*[Ww][Ii][Tt][Hh]%s+")
  (#set! injection.language "sql"))

(
  (expression_statement
    (assignment
      left: (identifier)
      right: (string
        (string_content) @injection.content)))
  (#lua-match? @injection.content "^%s*[Bb][Ee][Gg][Ii][Nn]%s*;")
  (#set! injection.language "sql"))

; Concatenated SQL assignment without a *_sql suffix.
(
  (expression_statement
    (assignment
      left: (identifier)
      right: (parenthesized_expression
        (concatenated_string
          (string
            (string_content) @injection.content)+))))
  (#any-lua-match? @injection.content "^%s*[Ss][Ee][Ll][Ee][Cc][Tt]%s+")
  (#set! injection.combined)
  (#set! injection.language "sql"))

(
  (expression_statement
    (assignment
      left: (identifier)
      right: (parenthesized_expression
        (concatenated_string
          (string
            (string_content) @injection.content)+))))
  (#any-lua-match? @injection.content "^%s*[Ii][Nn][Ss][Ee][Rr][Tt]%s+[Ii][Nn][Tt][Oo]%s+")
  (#set! injection.combined)
  (#set! injection.language "sql"))

(
  (expression_statement
    (assignment
      left: (identifier)
      right: (parenthesized_expression
        (concatenated_string
          (string
            (string_content) @injection.content)+))))
  (#any-lua-match? @injection.content "^%s*[Uu][Pp][Dd][Aa][Tt][Ee]%s+")
  (#set! injection.combined)
  (#set! injection.language "sql"))

(
  (expression_statement
    (assignment
      left: (identifier)
      right: (parenthesized_expression
        (concatenated_string
          (string
            (string_content) @injection.content)+))))
  (#any-lua-match? @injection.content "^%s*[Dd][Ee][Ll][Ee][Tt][Ee]%s+[Ff][Rr][Oo][Mm]%s+")
  (#set! injection.combined)
  (#set! injection.language "sql"))

(
  (expression_statement
    (assignment
      left: (identifier)
      right: (parenthesized_expression
        (concatenated_string
          (string
            (string_content) @injection.content)+))))
  (#any-lua-match? @injection.content "^%s*[Cc][Rr][Ee][Aa][Tt][Ee]%s+")
  (#set! injection.combined)
  (#set! injection.language "sql"))

(
  (expression_statement
    (assignment
      left: (identifier)
      right: (parenthesized_expression
        (concatenated_string
          (string
            (string_content) @injection.content)+))))
  (#any-lua-match? @injection.content "^%s*[Aa][Ll][Tt][Ee][Rr]%s+")
  (#set! injection.combined)
  (#set! injection.language "sql"))

(
  (expression_statement
    (assignment
      left: (identifier)
      right: (parenthesized_expression
        (concatenated_string
          (string
            (string_content) @injection.content)+))))
  (#any-lua-match? @injection.content "^%s*[Ww][Ii][Tt][Hh]%s+")
  (#set! injection.combined)
  (#set! injection.language "sql"))

(
  (expression_statement
    (assignment
      left: (identifier)
      right: (parenthesized_expression
        (concatenated_string
          (string
            (string_content) @injection.content)+))))
  (#any-lua-match? @injection.content "^%s*[Bb][Ee][Gg][Ii][Nn]%s*;")
  (#set! injection.combined)
  (#set! injection.language "sql"))

; SQL passed directly to DB execute-style calls as a single string.
(
  (expression_statement
    (call
      function: (attribute
        attribute: (identifier) @_fn)
      arguments: (argument_list
        (string
          (string_content) @injection.content)
        . (_)*)))
  (#any-of? @_fn "execute" "executemany" "executescript")
  (#set! injection.language "sql"))

; SQL passed as concatenated adjacent strings.
(
  (expression_statement
    (call
      function: (attribute
        attribute: (identifier) @_fn)
      arguments: (argument_list
        (concatenated_string
          (string
            (string_content) @injection.content)+)
        . (_)*)))
  (#any-of? @_fn "execute" "executemany" "executescript")
  (#set! injection.combined)
  (#set! injection.language "sql"))

; SQL passed as parenthesized concatenated strings.
(
  (expression_statement
    (call
      function: (attribute
        attribute: (identifier) @_fn)
      arguments: (argument_list
        (parenthesized_expression
          (concatenated_string
            (string
              (string_content) @injection.content)+))
        . (_)*)))
  (#any-of? @_fn "execute" "executemany" "executescript")
  (#set! injection.combined)
  (#set! injection.language "sql"))
