; extends

; SQL assignment like `String usersSql = """..."""` or `"..." + "..."`
(
  (local_variable_declaration
    type: (type_identifier)
    declarator: (variable_declarator
      name: (identifier) @_name
      value: (string_literal
        (multiline_string_fragment) @injection.content)))
  (#lua-match? @_name "^[%u][%u%d_]*_SQL$")
  (#set! injection.language "sql")
)

(
  (local_variable_declaration
    type: (type_identifier)
    declarator: (variable_declarator
      name: (identifier) @_name
      value: (string_literal
        (multiline_string_fragment) @injection.content)))
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#set! injection.language "sql")
)

(
  (local_variable_declaration
    type: (type_identifier)
    declarator: (variable_declarator
      name: (identifier) @_name
      value: (string_literal
        (string_fragment) @injection.content)))
  (#lua-match? @_name "^[%u][%u%d_]*_SQL$")
  (#set! injection.language "sql")
)

(
  (local_variable_declaration
    type: (type_identifier)
    declarator: (variable_declarator
      name: (identifier) @_name
      value: (string_literal
        (string_fragment) @injection.content)))
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#set! injection.language "sql")
)

(
  (local_variable_declaration
    type: (type_identifier)
    declarator: (variable_declarator
      name: (identifier) @_name
      value: (binary_expression
        left: (string_literal
          (string_fragment) @injection.content)
        right: (string_literal
          (string_fragment) @injection.content))))
  (#lua-match? @_name "^[%u][%u%d_]*_SQL$")
  (#set! injection.language "sql")
)

(
  (local_variable_declaration
    type: (type_identifier)
    declarator: (variable_declarator
      name: (identifier) @_name
      value: (binary_expression
        left: (string_literal
          (string_fragment) @injection.content)
        right: (string_literal
          (string_fragment) @injection.content))))
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#set! injection.language "sql")
)

(
  (local_variable_declaration
    type: (type_identifier)
    declarator: (variable_declarator
      name: (identifier) @_name
      value: (binary_expression
        left: (binary_expression
          left: (string_literal
            (string_fragment) @injection.content)
          right: (string_literal
            (string_fragment) @injection.content))
        right: (string_literal
          (string_fragment) @injection.content))))
  (#lua-match? @_name "^[%u][%u%d_]*_SQL$")
  (#set! injection.language "sql")
)

(
  (local_variable_declaration
    type: (type_identifier)
    declarator: (variable_declarator
      name: (identifier) @_name
      value: (binary_expression
        left: (binary_expression
          left: (string_literal
            (string_fragment) @injection.content)
          right: (string_literal
            (string_fragment) @injection.content))
        right: (string_literal
          (string_fragment) @injection.content))))
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#set! injection.language "sql")
)

(
  (local_variable_declaration
    type: (type_identifier)
    declarator: (variable_declarator
      name: (identifier) @_name
      value: (binary_expression
        left: (binary_expression
          left: (binary_expression
            left: (string_literal
              (string_fragment) @injection.content)
            right: (string_literal
              (string_fragment) @injection.content))
          right: (string_literal
            (string_fragment) @injection.content))
        right: (string_literal
          (string_fragment) @injection.content))))
  (#lua-match? @_name "^[%u][%u%d_]*_SQL$")
  (#set! injection.language "sql")
)

(
  (local_variable_declaration
    type: (type_identifier)
    declarator: (variable_declarator
      name: (identifier) @_name
      value: (binary_expression
        left: (binary_expression
          left: (binary_expression
            left: (string_literal
              (string_fragment) @injection.content)
            right: (string_literal
              (string_fragment) @injection.content))
          right: (string_literal
            (string_fragment) @injection.content))
        right: (string_literal
          (string_fragment) @injection.content))))
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#set! injection.language "sql")
)

; SQL passed to Java DB helpers.
(
  (method_invocation
    object: (identifier)
    name: (identifier) @_fn
    arguments: (argument_list
      (string_literal
        (multiline_string_fragment) @injection.content)))
  (#any-of? @_fn "execute" "query" "prepareStatement")
  (#set! injection.language "sql")
)

(
  (method_invocation
    object: (identifier)
    name: (identifier) @_fn
    arguments: (argument_list
      (string_literal
        (string_fragment) @injection.content)))
  (#any-of? @_fn "execute" "query" "prepareStatement")
  (#set! injection.language "sql")
)

(
  (method_invocation
    object: (identifier)
    name: (identifier) @_fn
    arguments: (argument_list
      (string_literal
        (string_fragment) @injection.content)))
  (#any-of? @_fn "execute" "query" "prepareStatement")
  (#set! injection.language "sql")
)

(
  (method_invocation
    object: (identifier)
    name: (identifier) @_fn
    arguments: (argument_list
      (binary_expression
        left: (string_literal
          (string_fragment) @injection.content)
        right: (string_literal
          (string_fragment) @injection.content))))
  (#any-of? @_fn "execute" "query" "prepareStatement")
  (#set! injection.language "sql")
)

(
  (method_invocation
    object: (identifier)
    name: (identifier) @_fn
    arguments: (argument_list
      (binary_expression
        left: (binary_expression
          left: (string_literal
            (string_fragment) @injection.content)
          right: (string_literal
            (string_fragment) @injection.content))
        right: (string_literal
          (string_fragment) @injection.content))))
  (#any-of? @_fn "execute" "query" "prepareStatement")
  (#set! injection.language "sql")
)

(
  (method_invocation
    object: (identifier)
    name: (identifier) @_fn
    arguments: (argument_list
      (binary_expression
        left: (binary_expression
          left: (binary_expression
            left: (string_literal
              (string_fragment) @injection.content)
            right: (string_literal
              (string_fragment) @injection.content))
          right: (string_literal
            (string_fragment) @injection.content))
        right: (string_literal
          (string_fragment) @injection.content))))
  (#any-of? @_fn "execute" "query" "prepareStatement")
  (#set! injection.language "sql")
)

(
  (method_invocation
    object: (identifier)
    name: (identifier) @_fn
    arguments: (argument_list
      (binary_expression
        left: (binary_expression
          left: (binary_expression
            left: (binary_expression
              left: (string_literal
                (string_fragment) @injection.content)
              right: (string_literal
                (string_fragment) @injection.content))
            right: (string_literal
              (string_fragment) @injection.content))
          right: (string_literal
            (string_fragment) @injection.content))
        right: (string_literal
          (string_fragment) @injection.content))))
  (#any-of? @_fn "execute" "query" "prepareStatement")
  (#set! injection.language "sql")
)
