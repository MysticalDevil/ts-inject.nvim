; extends

; === Variable naming heuristics ===
; my/our/state/local $VARIABLE_NAME_SQL = "..."
(
  (expression_statement
    (assignment_expression
      left: (variable_declaration
        variable: (scalar
          (varname) @_name))
      right: [
        (string_literal
          (string_content) @injection.content)
        (interpolated_string_literal
          (string_content) @injection.content)
      ]))
  (#lua-match? @_name "^[A-Z][A-Z0-9_]*_SQL$")
  (#set! injection.language "sql")
)

; camelCase ending with Sql
(
  (expression_statement
    (assignment_expression
      left: (variable_declaration
        variable: (scalar
          (varname) @_name))
      right: [
        (string_literal
          (string_content) @injection.content)
        (interpolated_string_literal
          (string_content) @injection.content)
      ]))
  (#lua-match? @_name "^[a-z][a-zA-Z0-9]*Sql$")
  (#set! injection.language "sql")
)

; snake_case ending with _sql
(
  (expression_statement
    (assignment_expression
      left: (variable_declaration
        variable: (scalar
          (varname) @_name))
      right: [
        (string_literal
          (string_content) @injection.content)
        (interpolated_string_literal
          (string_content) @injection.content)
      ]))
  (#lua-match? @_name "^[a-z][a-z0-9_]*_sql$")
  (#set! injection.language "sql")
)

; === DBI method calls (single argument) ===
; $dbh->prepare("...")
(
  (method_call_expression
    method: (method) @_fn
    arguments: [
      (string_literal
        (string_content) @injection.content)
      (interpolated_string_literal
        (string_content) @injection.content)
    ])
  (#any-of? @_fn "prepare" "execute" "do" "selectall_arrayref"
    "selectall_hashref" "selectcol_arrayref" "selectrow_array"
    "selectrow_arrayref" "selectrow_hashref")
  (#set! injection.language "sql")
)

; === DBI method calls (multiple arguments, SQL is first) ===
; $dbh->selectall_arrayref("SELECT ...", { Slice => {} })
(
  (method_call_expression
    method: (method) @_fn
    arguments: (list_expression
      .
      [
        (string_literal
          (string_content) @injection.content)
        (interpolated_string_literal
          (string_content) @injection.content)
      ]))
  (#any-of? @_fn "prepare" "execute" "do" "selectall_arrayref"
    "selectall_hashref" "selectcol_arrayref" "selectrow_array"
    "selectrow_arrayref" "selectrow_hashref")
  (#set! injection.language "sql")
)

; === Bare function calls ===
; prepare("...")
(
  (function_call_expression
    function: (function) @_fn
    [
      (string_literal
        (string_content) @injection.content)
      (interpolated_string_literal
        (string_content) @injection.content)
    ])
  (#any-of? @_fn "prepare" "execute")
  (#set! injection.language "sql")
)

; === String concatenation with naming heuristics ===
; 2-part: $name = "..." . "..."
(
  (expression_statement
    (assignment_expression
      left: (variable_declaration
        variable: (scalar
          (varname) @_name))
      right: (binary_expression
        left: [
          (string_literal
            (string_content) @injection.content)
          (interpolated_string_literal
            (string_content) @injection.content)
        ]
        operator: "."
        right: [
          (string_literal
            (string_content) @injection.content)
          (interpolated_string_literal
            (string_content) @injection.content)
        ])))
  (#lua-match? @_name "^[A-Z][A-Z0-9_]*_SQL$")
  (#set! injection.language "sql")
)

(
  (expression_statement
    (assignment_expression
      left: (variable_declaration
        variable: (scalar
          (varname) @_name))
      right: (binary_expression
        left: [
          (string_literal
            (string_content) @injection.content)
          (interpolated_string_literal
            (string_content) @injection.content)
        ]
        operator: "."
        right: [
          (string_literal
            (string_content) @injection.content)
          (interpolated_string_literal
            (string_content) @injection.content)
        ])))
  (#lua-match? @_name "^[a-z][a-zA-Z0-9]*Sql$")
  (#set! injection.language "sql")
)

(
  (expression_statement
    (assignment_expression
      left: (variable_declaration
        variable: (scalar
          (varname) @_name))
      right: (binary_expression
        left: [
          (string_literal
            (string_content) @injection.content)
          (interpolated_string_literal
            (string_content) @injection.content)
        ]
        operator: "."
        right: [
          (string_literal
            (string_content) @injection.content)
          (interpolated_string_literal
            (string_content) @injection.content)
        ])))
  (#lua-match? @_name "^[a-z][a-z0-9_]*_sql$")
  (#set! injection.language "sql")
)

; 3-part left-associative: $name = ("..." . "...") . "..."
(
  (expression_statement
    (assignment_expression
      left: (variable_declaration
        variable: (scalar
          (varname) @_name))
      right: (binary_expression
        left: (binary_expression
          left: [
            (string_literal
              (string_content) @injection.content)
            (interpolated_string_literal
              (string_content) @injection.content)
          ]
          operator: "."
          right: [
            (string_literal
              (string_content) @injection.content)
            (interpolated_string_literal
              (string_content) @injection.content)
          ])
        operator: "."
        right: [
          (string_literal
            (string_content) @injection.content)
          (interpolated_string_literal
            (string_content) @injection.content)
        ])))
  (#lua-match? @_name "^[A-Z][A-Z0-9_]*_SQL$")
  (#set! injection.language "sql")
)

(
  (expression_statement
    (assignment_expression
      left: (variable_declaration
        variable: (scalar
          (varname) @_name))
      right: (binary_expression
        left: (binary_expression
          left: [
            (string_literal
              (string_content) @injection.content)
            (interpolated_string_literal
              (string_content) @injection.content)
          ]
          operator: "."
          right: [
            (string_literal
              (string_content) @injection.content)
            (interpolated_string_literal
              (string_content) @injection.content)
          ])
        operator: "."
        right: [
          (string_literal
            (string_content) @injection.content)
          (interpolated_string_literal
            (string_content) @injection.content)
        ])))
  (#lua-match? @_name "^[a-z][a-zA-Z0-9]*Sql$")
  (#set! injection.language "sql")
)

(
  (expression_statement
    (assignment_expression
      left: (variable_declaration
        variable: (scalar
          (varname) @_name))
      right: (binary_expression
        left: (binary_expression
          left: [
            (string_literal
              (string_content) @injection.content)
            (interpolated_string_literal
              (string_content) @injection.content)
          ]
          operator: "."
          right: [
            (string_literal
              (string_content) @injection.content)
            (interpolated_string_literal
              (string_content) @injection.content)
          ])
        operator: "."
        right: [
          (string_literal
            (string_content) @injection.content)
          (interpolated_string_literal
            (string_content) @injection.content)
        ])))
  (#lua-match? @_name "^[a-z][a-z0-9_]*_sql$")
  (#set! injection.language "sql")
)

; === DBI helpers with concatenated strings ===
; $dbh->prepare("..." . "...")
(
  (method_call_expression
    method: (method) @_fn
    arguments: (binary_expression
      left: [
        (string_literal
          (string_content) @injection.content)
        (interpolated_string_literal
          (string_content) @injection.content)
      ]
      operator: "."
      right: [
        (string_literal
          (string_content) @injection.content)
        (interpolated_string_literal
          (string_content) @injection.content)
      ]))
  (#any-of? @_fn "prepare" "execute" "do" "selectall_arrayref"
    "selectall_hashref" "selectcol_arrayref" "selectrow_array"
    "selectrow_arrayref" "selectrow_hashref")
  (#set! injection.language "sql")
)

; 3-part left-associative
(
  (method_call_expression
    method: (method) @_fn
    arguments: (binary_expression
      left: (binary_expression
        left: [
          (string_literal
            (string_content) @injection.content)
          (interpolated_string_literal
            (string_content) @injection.content)
        ]
        operator: "."
        right: [
          (string_literal
            (string_content) @injection.content)
          (interpolated_string_literal
            (string_content) @injection.content)
        ])
      operator: "."
      right: [
        (string_literal
          (string_content) @injection.content)
        (interpolated_string_literal
          (string_content) @injection.content)
      ]))
  (#any-of? @_fn "prepare" "execute" "do" "selectall_arrayref"
    "selectall_hashref" "selectcol_arrayref" "selectrow_array"
    "selectrow_arrayref" "selectrow_hashref")
  (#set! injection.language "sql")
)

; === Heredoc SQL ===
; my $query = <<'SQL'; ... SQL
(
  (heredoc_content
    (heredoc_end) @_end)
  (#lua-match? @_end "^[Ss][Qq][Ll]$")
  (#set! injection.language "sql")
)
