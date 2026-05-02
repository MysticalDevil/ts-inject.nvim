; extends

; Explicit SQL marker comments before a variable declaration.
(
  (_
    [
      (line_comment) @_marker
      (block_comment) @_marker
    ]
    .
    (local_variable_declaration
      declarator: (variable_declarator
        value: [
          (string_literal
            (string_fragment) @injection.content)
          (string_literal
            (multiline_string_fragment) @injection.content)
          (binary_expression
            left: (string_literal
              (string_fragment) @injection.content)
            right: (string_literal
              (string_fragment) @injection.content))
          (binary_expression
            left: (binary_expression
              left: (string_literal
                (string_fragment) @injection.content)
              right: (string_literal
                (string_fragment) @injection.content))
            right: (string_literal
              (string_fragment) @injection.content))
        ])))
  (#lua-match? @_marker "[Ss][Qq][Ll]")
  (#set! injection.language "sql")
)

; Explicit SQL marker comments inside a variable initializer.
(
  (local_variable_declaration
    declarator: (variable_declarator
      [
        (line_comment) @_marker
        (block_comment) @_marker
      ]
      value: [
        (string_literal
          (string_fragment) @injection.content)
        (string_literal
          (multiline_string_fragment) @injection.content)
        (binary_expression
          left: (string_literal
            (string_fragment) @injection.content)
          right: (string_literal
            (string_fragment) @injection.content))
        (binary_expression
          left: (binary_expression
            left: (string_literal
              (string_fragment) @injection.content)
            right: (string_literal
              (string_fragment) @injection.content))
          right: (string_literal
            (string_fragment) @injection.content))
      ]))
  (#lua-match? @_marker "[Ss][Qq][Ll]")
  (#set! injection.language "sql")
)

; MyBatis SQL annotations with direct SQL strings.
(
  (annotation
    name: (identifier) @_annotation
    arguments: (annotation_argument_list
      (string_literal
        (string_fragment) @injection.content)))
  (#any-of? @_annotation
    "Select"
    "Insert"
    "Update"
    "Delete")
  (#set! injection.language "sql")
)

; MyBatis SQL annotations with string array fragments.
(
  (annotation
    name: (identifier) @_annotation
    arguments: (annotation_argument_list
      (element_value_array_initializer
        (string_literal
          (string_fragment) @injection.content)+)))
  (#any-of? @_annotation
    "Select"
    "Insert"
    "Update"
    "Delete")
  (#set! injection.language "sql")
)

; Spring Data JPA native SQL queries.
(
  (annotation
    name: (identifier) @_annotation
    arguments: (annotation_argument_list
      (element_value_pair
        key: (identifier) @_key
        value: (string_literal
          (string_fragment) @injection.content))
      (element_value_pair
        key: (identifier) @_native_key
        value: (true))))
  (#eq? @_annotation "Query")
  (#eq? @_key "value")
  (#eq? @_native_key "nativeQuery")
  (#set! injection.language "sql")
)

(
  (annotation
    name: (identifier) @_annotation
    arguments: (annotation_argument_list
      (element_value_pair
        key: (identifier) @_native_key
        value: (true))
      (element_value_pair
        key: (identifier) @_key
        value: (string_literal
          (string_fragment) @injection.content))))
  (#eq? @_annotation "Query")
  (#eq? @_key "value")
  (#eq? @_native_key "nativeQuery")
  (#set! injection.language "sql")
)

; JPA and Hibernate native SQL annotations.
(
  (annotation
    name: (identifier) @_annotation
    arguments: (annotation_argument_list
      (string_literal
        (string_fragment) @injection.content)))
  (#any-of? @_annotation
    "Subselect")
  (#set! injection.language "sql")
)

(
  (annotation
    name: (identifier) @_annotation
    arguments: (annotation_argument_list
      (element_value_pair
        key: (identifier) @_key
        value: (string_literal
          (string_fragment) @injection.content))))
  (#any-of? @_annotation
    "NamedNativeQuery"
    "Subselect")
  (#any-of? @_key
    "query"
    "value")
  (#set! injection.language "sql")
)

(
  (annotation
    name: (identifier) @_annotation
    arguments: (annotation_argument_list
      (element_value_pair
        key: (identifier) @_key
        value: (string_literal
          (string_fragment) @injection.content))))
  (#any-of? @_annotation
    "SQLDelete"
    "SQLInsert"
    "SQLSelect"
    "SQLUpdate"
    "Where")
  (#any-of? @_key
    "sql"
    "clause")
  (#set! injection.language "sql")
)

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

; JDBC, JdbcTemplate, JDBI, Hibernate native SQL, and jOOQ plain-SQL helpers.
(
  (method_invocation
    name: (identifier) @_fn
    arguments: (argument_list
      .
      (string_literal
        (multiline_string_fragment) @injection.content)))
  (#any-of? @_fn
    "addBatch"
    "batchUpdate"
    "createCall"
    "createNativeQuery"
    "createQuery"
    "createUpdate"
    "execute"
    "executeQuery"
    "executeUpdate"
    "fetch"
    "fetchAny"
    "fetchMany"
    "fetchOne"
    "fetchOptional"
    "prepareCall"
    "prepareStatement"
    "query"
    "queryForList"
    "queryForMap"
    "queryForObject"
    "resultQuery"
    "update")
  (#set! injection.language "sql")
)

(
  (method_invocation
    name: (identifier) @_fn
    arguments: (argument_list
      .
      (string_literal
        (string_fragment) @injection.content)))
  (#any-of? @_fn
    "addBatch"
    "batchUpdate"
    "createCall"
    "createNativeQuery"
    "createQuery"
    "createUpdate"
    "execute"
    "executeQuery"
    "executeUpdate"
    "fetch"
    "fetchAny"
    "fetchMany"
    "fetchOne"
    "fetchOptional"
    "prepareCall"
    "prepareStatement"
    "query"
    "queryForList"
    "queryForMap"
    "queryForObject"
    "resultQuery"
    "update")
  (#set! injection.language "sql")
)

(
  (method_invocation
    name: (identifier) @_fn
    arguments: (argument_list
      .
      (binary_expression
        left: (string_literal
          (string_fragment) @injection.content)
        right: (string_literal
          (string_fragment) @injection.content))))
  (#any-of? @_fn
    "addBatch"
    "batchUpdate"
    "createCall"
    "createNativeQuery"
    "createQuery"
    "createUpdate"
    "execute"
    "executeQuery"
    "executeUpdate"
    "fetch"
    "fetchAny"
    "fetchMany"
    "fetchOne"
    "fetchOptional"
    "prepareCall"
    "prepareStatement"
    "query"
    "queryForList"
    "queryForMap"
    "queryForObject"
    "resultQuery"
    "update")
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

; === GraphQL ===

; GQL suffix with text blocks
(
  (local_variable_declaration
    type: (type_identifier)
    declarator: (variable_declarator
      name: (identifier) @_name
      value: (string_literal
        (multiline_string_fragment) @injection.content)))
  (#lua-match? @_name "^[%u][%u%d_]*_GQL$")
  (#set! injection.language "graphql")
)

(
  (local_variable_declaration
    type: (type_identifier)
    declarator: (variable_declarator
      name: (identifier) @_name
      value: (string_literal
        (multiline_string_fragment) @injection.content)))
  (#lua-match? @_name "^[%l][%w]*Gql$")
  (#set! injection.language "graphql")
)

; GQL suffix with single-line strings
(
  (local_variable_declaration
    type: (type_identifier)
    declarator: (variable_declarator
      name: (identifier) @_name
      value: (string_literal
        (string_fragment) @injection.content)))
  (#lua-match? @_name "^[%u][%u%d_]*_GQL$")
  (#set! injection.language "graphql")
)

(
  (local_variable_declaration
    type: (type_identifier)
    declarator: (variable_declarator
      name: (identifier) @_name
      value: (string_literal
        (string_fragment) @injection.content)))
  (#lua-match? @_name "^[%l][%w]*Gql$")
  (#set! injection.language "graphql")
)
