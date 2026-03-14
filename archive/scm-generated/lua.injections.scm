; extends

; SQL assignment like `local users_sql = [[...]]` or `"..." .. "..."`.
(
  (assignment_statement
    (variable_list
      (identifier) @_name)
    (expression_list
      (string
        (string_content) @injection.content)))
  (#lua-match? @_name "^[%a_][%w_]*_?[Ss][Qq][Ll]$")
  (#set! injection.language "sql")
)

(
  (assignment_statement
    (variable_list
      (identifier) @_name)
    (expression_list
      (binary_expression
        left: (string
          (string_content) @injection.content)
        right: (string
          (string_content) @injection.content))))
  (#lua-match? @_name "^[%a_][%w_]*_?[Ss][Qq][Ll]$")
  (#set! injection.language "sql")
)

(
  (assignment_statement
    (variable_list
      (identifier) @_name)
    (expression_list
      (binary_expression
        left: (string
          (string_content) @injection.content)
        right: (binary_expression
          left: (string
            (string_content) @injection.content)
          right: (string
            (string_content) @injection.content)))))
  (#lua-match? @_name "^[%a_][%w_]*_?[Ss][Qq][Ll]$")
  (#set! injection.language "sql")
)

(
  (assignment_statement
    (variable_list
      (identifier) @_name)
    (expression_list
      (binary_expression
        left: (string
          (string_content) @injection.content)
        right: (binary_expression
          left: (string
            (string_content) @injection.content)
          right: (binary_expression
            left: (string
              (string_content) @injection.content)
            right: (string
              (string_content) @injection.content))))))
  (#lua-match? @_name "^[%a_][%w_]*_?[Ss][Qq][Ll]$")
  (#set! injection.language "sql")
)

(
  (assignment_statement
    (variable_list
      (identifier) @_name)
    (expression_list
      (function_call
        name: (method_index_expression
          (parenthesized_expression
            (string
              (string_content) @injection.content))
          .
          (identifier) @_format)
        arguments: (arguments))))
  (#lua-match? @_name "^[%a_][%w_]*_?[Ss][Qq][Ll]$")
  (#eq? @_format "format")
  (#set! injection.language "sql")
)

; SQL passed directly to Lua DB helpers.
(
  (function_call
    name: [
      (identifier) @_fn
      (method_index_expression
        method: (identifier) @_fn)
      (dot_index_expression
        field: (identifier) @_fn)
    ]
    arguments: (arguments
      "("
      .
      (string
        (string_content) @injection.content)
      . [
        ","
        ")"
      ]))
  (#any-of? @_fn "query" "execute" "exec" "prepare")
  (#set! injection.language "sql")
)

(
  (function_call
    name: [
      (identifier) @_fn
      (method_index_expression
        method: (identifier) @_fn)
      (dot_index_expression
        field: (identifier) @_fn)
    ]
    arguments: (arguments
      "("
      .
      (function_call
        name: (method_index_expression
          (parenthesized_expression
            (string
              (string_content) @injection.content))
          .
          (identifier) @_format)
        arguments: (arguments))
      . [
        ","
        ")"
      ]))
  (#any-of? @_fn "query" "execute" "exec" "prepare")
  (#eq? @_format "format")
  (#set! injection.language "sql")
)

(
  (function_call
    name: [
      (identifier) @_fn
      (method_index_expression
        method: (identifier) @_fn)
      (dot_index_expression
        field: (identifier) @_fn)
    ]
    arguments: (arguments
      "("
      .
      (binary_expression
        left: (string
          (string_content) @injection.content)
        right: (string
          (string_content) @injection.content))
      . [
        ","
        ")"
      ]))
  (#any-of? @_fn "query" "execute" "exec" "prepare")
  (#set! injection.language "sql")
)

(
  (function_call
    name: [
      (identifier) @_fn
      (method_index_expression
        method: (identifier) @_fn)
      (dot_index_expression
        field: (identifier) @_fn)
    ]
    arguments: (arguments
      "("
      .
      (binary_expression
        left: (string
          (string_content) @injection.content)
        right: (binary_expression
          left: (string
            (string_content) @injection.content)
          right: (binary_expression
            left: (string
              (string_content) @injection.content)
            right: (binary_expression
              left: (string
                (string_content) @injection.content)
              right: (string
                (string_content) @injection.content)))))
      . [
        ","
        ")"
      ]))
  (#any-of? @_fn "query" "execute" "exec" "prepare")
  (#set! injection.language "sql")
)
(
  (function_call
    name: [
      (identifier) @_fn
      (method_index_expression
        method: (identifier) @_fn)
      (dot_index_expression
        field: (identifier) @_fn)
    ]
    arguments: (arguments
      "("
      .
      (binary_expression
        left: (string
          (string_content) @injection.content)
        right: (binary_expression
          left: (string
            (string_content) @injection.content)
          right: (string
            (string_content) @injection.content)))
      . [
        ","
        ")"
      ]))
  (#any-of? @_fn "query" "execute" "exec" "prepare")
  (#set! injection.language "sql")
)

(
  (function_call
    name: [
      (identifier) @_fn
      (method_index_expression
        method: (identifier) @_fn)
      (dot_index_expression
        field: (identifier) @_fn)
    ]
    arguments: (arguments
      "("
      .
      (binary_expression
        left: (string
          (string_content) @injection.content)
        right: (binary_expression
          left: (string
            (string_content) @injection.content)
          right: (binary_expression
            left: (string
              (string_content) @injection.content)
            right: (string
              (string_content) @injection.content))))
      . [
        ","
        ")"
      ]))
  (#any-of? @_fn "query" "execute" "exec" "prepare")
  (#set! injection.language "sql")
)
