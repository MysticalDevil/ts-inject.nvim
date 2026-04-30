; extends

; SQL variables initialized from C string literals:
; - regular strings, including backslash-continued physical lines
; - adjacent literals: "SELECT " "FROM users"
; - UTF/wide-prefixed literals: u8"...", L"...", u"...", U"..."
; - parenthesized or casted string expressions
(
  (declaration
    declarator: (init_declarator
      declarator: (_) @_decl
      value: [
        (string_literal
          (string_content) @injection.content)+
        (concatenated_string
          (string_literal
            (string_content) @injection.content)+)
        (parenthesized_expression
          (string_literal
            (string_content) @injection.content)+)
        (parenthesized_expression
          (concatenated_string
            (string_literal
              (string_content) @injection.content)+))
        (cast_expression
          value: (string_literal
            (string_content) @injection.content)+)
        (cast_expression
          value: (concatenated_string
            (string_literal
              (string_content) @injection.content)+))
      ]))
  (#lua-match? @_decl "[%a_][%w_]*[Ss][Qq][Ll]")
  (#set! injection.language "sql")
)

; SQL variables assigned after declaration.
(
  (assignment_expression
    left: (identifier) @_name
    right: [
      (string_literal
        (string_content) @injection.content)+
      (concatenated_string
        (string_literal
          (string_content) @injection.content)+)
      (parenthesized_expression
        (string_literal
          (string_content) @injection.content)+)
      (parenthesized_expression
        (concatenated_string
          (string_literal
            (string_content) @injection.content)+))
      (cast_expression
        value: (string_literal
          (string_content) @injection.content)+)
      (cast_expression
        value: (concatenated_string
          (string_literal
            (string_content) @injection.content)+))
    ])
  (#lua-match? @_name "^[%a_][%w_]*[Ss][Qq][Ll]$")
  (#set! injection.language "sql")
)

; C database APIs with SQL as the second argument.
(
  (call_expression
    function: (identifier) @_fn
    arguments: (argument_list
      (_)
      .
      [
        (string_literal
          (string_content) @injection.content)+
        (concatenated_string
          (string_literal
            (string_content) @injection.content)+)
        (parenthesized_expression
          (string_literal
            (string_content) @injection.content)+)
        (parenthesized_expression
          (concatenated_string
            (string_literal
              (string_content) @injection.content)+))
        (cast_expression
          value: (string_literal
            (string_content) @injection.content)+)
        (cast_expression
          value: (concatenated_string
            (string_literal
              (string_content) @injection.content)+))
      ]))
  (#any-of? @_fn
    "sqlite3_exec"
    "sqlite3_prepare"
    "sqlite3_prepare_v2"
    "sqlite3_prepare_v3"
    "sqlite3_prepare16"
    "sqlite3_prepare16_v2"
    "sqlite3_prepare16_v3"
    "PQexec"
    "PQexecParams"
    "PQsendQuery"
    "PQsendQueryParams"
    "mysql_query"
    "mysql_real_query"
    "SQLExecDirect"
    "SQLPrepare")
  (#set! injection.language "sql")
)

; libpq APIs with SQL as the third argument.
(
  (call_expression
    function: (identifier) @_fn
    arguments: (argument_list
      (_)
      .
      (_)
      .
      [
        (string_literal
          (string_content) @injection.content)+
        (concatenated_string
          (string_literal
            (string_content) @injection.content)+)
        (parenthesized_expression
          (string_literal
            (string_content) @injection.content)+)
        (parenthesized_expression
          (concatenated_string
            (string_literal
              (string_content) @injection.content)+))
        (cast_expression
          value: (string_literal
            (string_content) @injection.content)+)
        (cast_expression
          value: (concatenated_string
            (string_literal
              (string_content) @injection.content)+))
      ]))
  (#any-of? @_fn
    "PQprepare"
    "PQsendPrepare")
  (#set! injection.language "sql")
)
