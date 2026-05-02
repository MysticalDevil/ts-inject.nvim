; extends

; SQL variables initialized from C++ string literals:
; - regular strings, including backslash-continued physical lines
; - adjacent literals: "SELECT " "FROM users"
; - raw strings with or without custom delimiters: R"sql(...)sql"
; - UTF/wide-prefixed strings and raw strings
; - C++ string literal suffixes such as "..."s
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
        (raw_string_literal
          (raw_string_content) @injection.content)
        (user_defined_literal
          (string_literal
            (string_content) @injection.content))
        (parenthesized_expression
          (string_literal
            (string_content) @injection.content)+)
        (parenthesized_expression
          (concatenated_string
            (string_literal
              (string_content) @injection.content)+))
        (parenthesized_expression
          (raw_string_literal
            (raw_string_content) @injection.content))
        (cast_expression
          value: (string_literal
            (string_content) @injection.content)+)
        (cast_expression
          value: (concatenated_string
            (string_literal
              (string_content) @injection.content)+))
        (cast_expression
          value: (raw_string_literal
            (raw_string_content) @injection.content))
      ]))
  (#lua-match? @_decl "[%a_][%w_]*[Ss][Qq][Ll]")
  (#set! injection.language "sql")
)

; Explicit SQL marker comments before a variable declaration.
(
  (_
    (comment) @_marker
    .
    (declaration
      declarator: (init_declarator
        value: [
          (string_literal
            (string_content) @injection.content)+
          (concatenated_string
            (string_literal
              (string_content) @injection.content)+)
          (raw_string_literal
            (raw_string_content) @injection.content)
          (user_defined_literal
            (string_literal
              (string_content) @injection.content))
          (parenthesized_expression
            (string_literal
              (string_content) @injection.content)+)
          (parenthesized_expression
            (concatenated_string
              (string_literal
                (string_content) @injection.content)+))
          (parenthesized_expression
            (raw_string_literal
              (raw_string_content) @injection.content))
          (cast_expression
            value: (string_literal
              (string_content) @injection.content)+)
          (cast_expression
            value: (concatenated_string
              (string_literal
                (string_content) @injection.content)+))
          (cast_expression
            value: (raw_string_literal
              (raw_string_content) @injection.content))
        ])))
  (#lua-match? @_marker "[Ss][Qq][Ll]")
  (#set! injection.language "sql")
)

; Explicit SQL marker comments inside a variable initializer.
(
  (declaration
    declarator: (init_declarator
      (comment) @_marker
      value: [
        (string_literal
          (string_content) @injection.content)+
        (concatenated_string
          (string_literal
            (string_content) @injection.content)+)
        (raw_string_literal
          (raw_string_content) @injection.content)
        (user_defined_literal
          (string_literal
            (string_content) @injection.content))
        (parenthesized_expression
          (string_literal
            (string_content) @injection.content)+)
        (parenthesized_expression
          (concatenated_string
            (string_literal
              (string_content) @injection.content)+))
        (parenthesized_expression
          (raw_string_literal
            (raw_string_content) @injection.content))
        (cast_expression
          value: (string_literal
            (string_content) @injection.content)+)
        (cast_expression
          value: (concatenated_string
            (string_literal
              (string_content) @injection.content)+))
        (cast_expression
          value: (raw_string_literal
            (raw_string_content) @injection.content))
      ]))
  (#lua-match? @_marker "[Ss][Qq][Ll]")
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
      (raw_string_literal
        (raw_string_content) @injection.content)
      (user_defined_literal
        (string_literal
          (string_content) @injection.content))
      (parenthesized_expression
        (string_literal
          (string_content) @injection.content)+)
      (parenthesized_expression
        (concatenated_string
          (string_literal
            (string_content) @injection.content)+))
      (parenthesized_expression
        (raw_string_literal
          (raw_string_content) @injection.content))
      (cast_expression
        value: (string_literal
          (string_content) @injection.content)+)
      (cast_expression
        value: (concatenated_string
          (string_literal
            (string_content) @injection.content)+))
      (cast_expression
        value: (raw_string_literal
          (raw_string_content) @injection.content))
    ])
  (#lua-match? @_name "^[%a_][%w_]*[Ss][Qq][Ll]$")
  (#set! injection.language "sql")
)

; Common C++ database wrapper functions with SQL as the first argument.
(
  (call_expression
    function: (identifier) @_fn
    arguments: (argument_list
      .
      [
        (string_literal
          (string_content) @injection.content)+
        (concatenated_string
          (string_literal
            (string_content) @injection.content)+)
        (raw_string_literal
          (raw_string_content) @injection.content)
        (user_defined_literal
          (string_literal
            (string_content) @injection.content))
        (parenthesized_expression
          (string_literal
            (string_content) @injection.content)+)
        (parenthesized_expression
          (concatenated_string
            (string_literal
              (string_content) @injection.content)+))
        (parenthesized_expression
          (raw_string_literal
            (raw_string_content) @injection.content))
        (cast_expression
          value: (string_literal
            (string_content) @injection.content)+)
        (cast_expression
          value: (concatenated_string
            (string_literal
              (string_content) @injection.content)+))
        (cast_expression
          value: (raw_string_literal
            (raw_string_content) @injection.content))
      ]))
  (#any-of? @_fn
    "exec"
    "execute"
    "prepare"
    "query")
  (#set! injection.language "sql")
)

; Common C++ database query constructors with SQL as the first argument.
(
  (declaration
    type: [
      (type_identifier) @_type
      (qualified_identifier
        name: (type_identifier) @_type)
    ]
    declarator: (init_declarator
      value: (argument_list
        .
        [
          (string_literal
            (string_content) @injection.content)+
          (concatenated_string
            (string_literal
              (string_content) @injection.content)+)
          (raw_string_literal
            (raw_string_content) @injection.content)
          (user_defined_literal
            (string_literal
              (string_content) @injection.content))
          (parenthesized_expression
            (string_literal
              (string_content) @injection.content)+)
          (parenthesized_expression
            (concatenated_string
              (string_literal
                (string_content) @injection.content)+))
          (parenthesized_expression
            (raw_string_literal
              (raw_string_content) @injection.content))
          (cast_expression
            value: (string_literal
              (string_content) @injection.content)+)
          (cast_expression
            value: (concatenated_string
              (string_literal
                (string_content) @injection.content)+))
          (cast_expression
            value: (raw_string_literal
              (raw_string_content) @injection.content))
        ])))
  (#any-of? @_type
    "QSqlQuery"
    "query"
    "statement")
  (#set! injection.language "sql")
)

; SQLiteCpp-style constructors with SQL as the second argument.
(
  (declaration
    type: (qualified_identifier
      name: (type_identifier) @_type)
    declarator: (init_declarator
      value: (argument_list
        (_)
        .
        [
          (string_literal
            (string_content) @injection.content)+
          (concatenated_string
            (string_literal
              (string_content) @injection.content)+)
          (raw_string_literal
            (raw_string_content) @injection.content)
          (user_defined_literal
            (string_literal
              (string_content) @injection.content))
          (parenthesized_expression
            (string_literal
              (string_content) @injection.content)+)
          (parenthesized_expression
            (concatenated_string
              (string_literal
                (string_content) @injection.content)+))
          (parenthesized_expression
            (raw_string_literal
              (raw_string_content) @injection.content))
          (cast_expression
            value: (string_literal
              (string_content) @injection.content)+)
          (cast_expression
            value: (concatenated_string
              (string_literal
                (string_content) @injection.content)+))
          (cast_expression
            value: (raw_string_literal
              (raw_string_content) @injection.content))
        ])))
  (#eq? @_type "Statement")
  (#set! injection.language "sql")
)

; SOCI-style SQL stream expressions: sql << "SELECT ...".
(
  (binary_expression
    left: [
      (identifier) @_stream
      (field_expression
        field: (field_identifier) @_stream)
    ]
    right: [
      (string_literal
        (string_content) @injection.content)+
      (concatenated_string
        (string_literal
          (string_content) @injection.content)+)
      (raw_string_literal
        (raw_string_content) @injection.content)
      (user_defined_literal
        (string_literal
          (string_content) @injection.content))
      (parenthesized_expression
        (string_literal
          (string_content) @injection.content)+)
      (parenthesized_expression
        (concatenated_string
          (string_literal
            (string_content) @injection.content)+))
      (parenthesized_expression
        (raw_string_literal
          (raw_string_content) @injection.content))
      (cast_expression
        value: (string_literal
          (string_content) @injection.content)+)
      (cast_expression
        value: (concatenated_string
          (string_literal
            (string_content) @injection.content)+))
      (cast_expression
        value: (raw_string_literal
          (raw_string_content) @injection.content))
    ])
  (#any-of? @_stream
    "sql"
    "prepare")
  (#set! injection.language "sql")
)

; C and C++ database APIs with SQL as the second argument.
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
        (raw_string_literal
          (raw_string_content) @injection.content)
        (user_defined_literal
          (string_literal
            (string_content) @injection.content))
        (parenthesized_expression
          (string_literal
            (string_content) @injection.content)+)
        (parenthesized_expression
          (concatenated_string
            (string_literal
              (string_content) @injection.content)+))
        (parenthesized_expression
          (raw_string_literal
            (raw_string_content) @injection.content))
        (cast_expression
          value: (string_literal
            (string_content) @injection.content)+)
        (cast_expression
          value: (concatenated_string
            (string_literal
              (string_content) @injection.content)+))
        (cast_expression
          value: (raw_string_literal
            (raw_string_content) @injection.content))
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
        (raw_string_literal
          (raw_string_content) @injection.content)
        (user_defined_literal
          (string_literal
            (string_content) @injection.content))
        (parenthesized_expression
          (string_literal
            (string_content) @injection.content)+)
        (parenthesized_expression
          (concatenated_string
            (string_literal
              (string_content) @injection.content)+))
        (parenthesized_expression
          (raw_string_literal
            (raw_string_content) @injection.content))
        (cast_expression
          value: (string_literal
            (string_content) @injection.content)+)
        (cast_expression
          value: (concatenated_string
            (string_literal
              (string_content) @injection.content)+))
        (cast_expression
          value: (raw_string_literal
            (raw_string_content) @injection.content))
      ]))
  (#any-of? @_fn
    "PQprepare"
    "PQsendPrepare")
  (#set! injection.language "sql")
)

; Common C++ database wrapper methods with SQL as the first argument.
(
  (call_expression
    function: (field_expression
      field: (field_identifier) @_method)
    arguments: (argument_list
      .
      [
        (string_literal
          (string_content) @injection.content)+
        (concatenated_string
          (string_literal
            (string_content) @injection.content)+)
        (raw_string_literal
          (raw_string_content) @injection.content)
        (user_defined_literal
          (string_literal
            (string_content) @injection.content))
        (parenthesized_expression
          (string_literal
            (string_content) @injection.content)+)
        (parenthesized_expression
          (concatenated_string
            (string_literal
              (string_content) @injection.content)+))
        (parenthesized_expression
          (raw_string_literal
            (raw_string_content) @injection.content))
        (cast_expression
          value: (string_literal
            (string_content) @injection.content)+)
        (cast_expression
          value: (concatenated_string
            (string_literal
              (string_content) @injection.content)+))
        (cast_expression
          value: (raw_string_literal
            (raw_string_content) @injection.content))
      ]))
  (#any-of? @_method
    "exec"
    "execute"
    "prepare"
    "query")
  (#set! injection.language "sql")
)

; Inline assembly (GCC extended asm)
(
  (gnu_asm_expression
    [
      (string_literal
        (string_content) @injection.content)+
      (concatenated_string
        (string_literal
          (string_content) @injection.content)+)
    ])
  (#set! injection.language "asm")
)

; === Regex ===

; std::regex rx("pattern") / regex re("pattern")
(
  (declaration
    type: [
      (qualified_identifier
        (type_identifier) @_class)
      (type_identifier) @_class
    ]
    declarator: (init_declarator
      declarator: (identifier)
      value: (argument_list
        .
        (string_literal
          (string_content) @injection.content))))
  (#eq? @_class "regex")
  (#set! injection.language "regex")
)

; std::regex("pattern") as expression
(
  (call_expression
    function: [
      (qualified_identifier
        (identifier) @_class)
      (identifier) @_class
    ]
    arguments: (argument_list
      .
      (string_literal
        (string_content) @injection.content)))
  (#eq? @_class "regex")
  (#set! injection.language "regex")
)

