; extends

; SQL assignment like `const USERS_SQL = <<<'SQL' ... SQL;` or `$summarySql = "..."`
(
  (const_declaration
    (const_element
      (name) @_name
      (nowdoc
        (nowdoc_body
          (nowdoc_string)+ @injection.content))))
  (#lua-match? @_name "^[%u][%u%d_]*_SQL$")
  (#set! injection.language "sql")
)

(
  (expression_statement
    (assignment_expression
      left: (variable_name
        (name) @_name)
      right: (nowdoc
        (nowdoc_body
          (nowdoc_string)+ @injection.content))))
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#set! injection.language "sql")
)

(
  (expression_statement
    (assignment_expression
      left: (variable_name
        (name) @_name)
      right: (encapsed_string
        (string_content) @injection.content)))
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#set! injection.language "sql")
)

(
  (expression_statement
    (assignment_expression
      left: (variable_name
        (name) @_name)
      right: (binary_expression
        left: (encapsed_string
          (string_content) @injection.content)
        right: (encapsed_string
          (string_content) @injection.content))))
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#set! injection.language "sql")
)

(
  (expression_statement
    (assignment_expression
      left: (variable_name
        (name) @_name)
      right: (binary_expression
        left: (binary_expression
          left: (encapsed_string
            (string_content) @injection.content)
          right: (encapsed_string
            (string_content) @injection.content))
        right: (encapsed_string
          (string_content) @injection.content))))
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#set! injection.language "sql")
)

(
  (expression_statement
    (assignment_expression
      left: (variable_name
        (name) @_name)
      right: (binary_expression
        left: (binary_expression
          left: (binary_expression
            left: (encapsed_string
              (string_content) @injection.content)
            right: (encapsed_string
              (string_content) @injection.content))
          right: (encapsed_string
            (string_content) @injection.content))
        right: (encapsed_string
          (string_content) @injection.content))))
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#set! injection.language "sql")
)

; SQL passed to PHP DB helpers.
(
  (member_call_expression
    object: (variable_name)
    name: (name) @_fn
    arguments: (arguments
      .
      (argument
        (nowdoc
          (nowdoc_body
            (nowdoc_string)+ @injection.content)))))
  (#any-of? @_fn "query" "execute" "prepare")
  (#set! injection.language "sql")
)

(
  (member_call_expression
    object: (variable_name)
    name: (name) @_fn
    arguments: (arguments
      .
      (argument
        (string
          (string_content) @injection.content))))
  (#any-of? @_fn "query" "execute" "prepare")
  (#set! injection.language "sql")
)

(
  (member_call_expression
    object: (variable_name)
    name: (name) @_fn
    arguments: (arguments
      .
      (argument
        (encapsed_string
          (string_content) @injection.content))))
  (#any-of? @_fn "query" "execute" "prepare")
  (#set! injection.language "sql")
)

(
  (member_call_expression
    object: (variable_name)
    name: (name) @_fn
    arguments: (arguments
      .
      (argument
        (binary_expression
          left: (encapsed_string
            (string_content) @injection.content)
          right: (encapsed_string
            (string_content) @injection.content)))))
  (#any-of? @_fn "query" "execute" "prepare")
  (#set! injection.language "sql")
)

(
  (member_call_expression
    object: (variable_name)
    name: (name) @_fn
    arguments: (arguments
      .
      (argument
        (binary_expression
          left: (binary_expression
            left: (encapsed_string
              (string_content) @injection.content)
            right: (encapsed_string
              (string_content) @injection.content))
          right: (encapsed_string
            (string_content) @injection.content)))))
  (#any-of? @_fn "query" "execute" "prepare")
  (#set! injection.language "sql")
)

(
  (member_call_expression
    object: (variable_name)
    name: (name) @_fn
    arguments: (arguments
      .
      (argument
        (binary_expression
          left: (binary_expression
            left: (binary_expression
              left: (encapsed_string
                (string_content) @injection.content)
              right: (encapsed_string
                (string_content) @injection.content))
            right: (encapsed_string
              (string_content) @injection.content))
          right: (encapsed_string
            (string_content) @injection.content)))))
  (#any-of? @_fn "query" "execute" "prepare")
  (#set! injection.language "sql")
)

(
  (member_call_expression
    object: (variable_name)
    name: (name) @_fn
    arguments: (arguments
      .
      (argument
        (binary_expression
          left: (binary_expression
            left: (binary_expression
              left: (binary_expression
                left: (encapsed_string
                  (string_content) @injection.content)
                right: (encapsed_string
                  (string_content) @injection.content))
              right: (encapsed_string
                (string_content) @injection.content))
            right: (encapsed_string
              (string_content) @injection.content))
          right: (encapsed_string
            (string_content) @injection.content)))))
  (#any-of? @_fn "query" "execute" "prepare")
  (#set! injection.language "sql")
)
