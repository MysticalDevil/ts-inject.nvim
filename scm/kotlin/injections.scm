; extends

; MyBatis SQL annotations with direct SQL strings.
(
  (annotation
    (constructor_invocation
      (user_type
        (type_identifier) @_annotation)
      (value_arguments
        (value_argument
          (string_literal
            (string_content) @injection.content)))))
  (#any-of? @_annotation "Select" "Insert" "Update" "Delete")
  (#set! injection.language "sql")
)

; MyBatis SQL annotations with arrayOf string fragments.
(
  (annotation
    (constructor_invocation
      (user_type
        (type_identifier) @_annotation)
      (value_arguments
        (value_argument
          (call_expression
            (simple_identifier) @_array
            (call_suffix
              (value_arguments
                (value_argument
                  (string_literal
                    (string_content) @injection.content)))))))))
  (#any-of? @_annotation "Select" "Insert" "Update" "Delete")
  (#eq? @_array "arrayOf")
  (#set! injection.language "sql")
)

; Spring Data JPA native SQL queries.
(
  (annotation
    (constructor_invocation
      (user_type
        (type_identifier) @_annotation)
      (value_arguments
        (value_argument
          (simple_identifier) @_key
          (string_literal
            (string_content) @injection.content))
        (value_argument
          (simple_identifier) @_native_key
          (boolean_literal) @_native_value))))
  (#eq? @_annotation "Query")
  (#eq? @_key "value")
  (#eq? @_native_key "nativeQuery")
  (#eq? @_native_value "true")
  (#set! injection.language "sql")
)

(
  (annotation
    (constructor_invocation
      (user_type
        (type_identifier) @_annotation)
      (value_arguments
        (value_argument
          (simple_identifier) @_native_key
          (boolean_literal) @_native_value)
        (value_argument
          (simple_identifier) @_key
          (string_literal
            (string_content) @injection.content)))))
  (#eq? @_annotation "Query")
  (#eq? @_key "value")
  (#eq? @_native_key "nativeQuery")
  (#eq? @_native_value "true")
  (#set! injection.language "sql")
)

; SQL assignment like `val userSql = """...""".trimIndent()` or `"..." + "..."`
(
  (property_declaration
    (variable_declaration
      (simple_identifier) @_name)
    (string_literal
      (string_content) @injection.content))
  (#lua-match? @_name "^[%u][%u%d_]*_SQL$")
  (#set! injection.language "sql")
)

(
  (property_declaration
    (variable_declaration
      (simple_identifier) @_name)
    (string_literal
      (string_content) @injection.content))
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#set! injection.language "sql")
)

(
  (property_declaration
    (variable_declaration
      (simple_identifier) @_name)
    (call_expression
      (navigation_expression
        (string_literal
          (string_content) @injection.content)
        (navigation_suffix
          (simple_identifier) @_trim))
      (call_suffix
        (value_arguments))))
  (#any-of? @_trim "trimIndent" "trimMargin")
  (#lua-match? @_name "^[%u][%u%d_]*_SQL$")
  (#set! injection.language "sql")
)

(
  (property_declaration
    (variable_declaration
      (simple_identifier) @_name)
    (call_expression
      (navigation_expression
        (string_literal
          (string_content) @injection.content)
        (navigation_suffix
          (simple_identifier) @_trim))
      (call_suffix
        (value_arguments))))
  (#any-of? @_trim "trimIndent" "trimMargin")
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#set! injection.language "sql")
)

(
  (property_declaration
    (variable_declaration
      (simple_identifier) @_name)
    (additive_expression
      (string_literal
        (string_content) @injection.content)
      (string_literal
        (string_content) @injection.content)))
  (#lua-match? @_name "^[%u][%u%d_]*_SQL$")
  (#set! injection.language "sql")
)

(
  (property_declaration
    (variable_declaration
      (simple_identifier) @_name)
    (additive_expression
      (string_literal
        (string_content) @injection.content)
      (string_literal
        (string_content) @injection.content)))
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#set! injection.language "sql")
)

(
  (property_declaration
    (variable_declaration
      (simple_identifier) @_name)
    (additive_expression
      (additive_expression
        (string_literal
          (string_content) @injection.content)
        (string_literal
          (string_content) @injection.content))
      (string_literal
        (string_content) @injection.content)))
  (#lua-match? @_name "^[%u][%u%d_]*_SQL$")
  (#set! injection.language "sql")
)

(
  (property_declaration
    (variable_declaration
      (simple_identifier) @_name)
    (additive_expression
      (additive_expression
        (string_literal
          (string_content) @injection.content)
        (string_literal
          (string_content) @injection.content))
      (string_literal
        (string_content) @injection.content)))
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#set! injection.language "sql")
)

(
  (property_declaration
    (variable_declaration
      (simple_identifier) @_name)
    (additive_expression
      (additive_expression
        (additive_expression
          (string_literal
            (string_content) @injection.content)
          (string_literal
            (string_content) @injection.content))
        (string_literal
          (string_content) @injection.content))
      (string_literal
        (string_content) @injection.content)))
  (#lua-match? @_name "^[%u][%u%d_]*_SQL$")
  (#set! injection.language "sql")
)

(
  (property_declaration
    (variable_declaration
      (simple_identifier) @_name)
    (additive_expression
      (additive_expression
        (additive_expression
          (string_literal
            (string_content) @injection.content)
          (string_literal
            (string_content) @injection.content))
        (string_literal
          (string_content) @injection.content))
      (string_literal
        (string_content) @injection.content)))
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#set! injection.language "sql")
)

; SQL passed to Kotlin DB helpers.
(
  (call_expression
    (navigation_expression
      (simple_identifier)
      (navigation_suffix
        (simple_identifier) @_fn))
    (call_suffix
      (value_arguments
        (value_argument
          (string_literal
            (string_content) @injection.content)))))
  (#any-of? @_fn "execute" "query" "prepareStatement")
  (#set! injection.language "sql")
)

(
  (call_expression
    (navigation_expression
      (simple_identifier)
      (navigation_suffix
        (simple_identifier) @_fn))
    (call_suffix
      (value_arguments
        (value_argument
          (additive_expression
            (additive_expression
              (additive_expression
                (additive_expression
                  (string_literal
                    (string_content) @injection.content)
                  (string_literal
                    (string_content) @injection.content))
                (string_literal
                  (string_content) @injection.content))
              (string_literal
                (string_content) @injection.content))
            (string_literal
              (string_content) @injection.content))))))
  (#any-of? @_fn "execute" "query" "prepareStatement")
  (#set! injection.language "sql")
)

(
  (call_expression
    (navigation_expression
      (simple_identifier)
      (navigation_suffix
        (simple_identifier) @_fn))
    (call_suffix
      (value_arguments
        (value_argument
          (call_expression
            (navigation_expression
              (string_literal
                (string_content) @injection.content)
              (navigation_suffix
                (simple_identifier) @_trim))
            (call_suffix
              (value_arguments)))))))
  (#any-of? @_fn "execute" "query" "prepareStatement")
  (#any-of? @_trim "trimIndent" "trimMargin")
  (#set! injection.language "sql")
)

(
  (call_expression
    (navigation_expression
      (simple_identifier)
      (navigation_suffix
        (simple_identifier) @_fn))
    (call_suffix
      (value_arguments
        (value_argument
          (additive_expression
            (string_literal
              (string_content) @injection.content)
            (string_literal
              (string_content) @injection.content))))))
  (#any-of? @_fn "execute" "query" "prepareStatement")
  (#set! injection.language "sql")
)

(
  (call_expression
    (navigation_expression
      (simple_identifier)
      (navigation_suffix
        (simple_identifier) @_fn))
    (call_suffix
      (value_arguments
        (value_argument
          (additive_expression
            (additive_expression
              (string_literal
                (string_content) @injection.content)
              (string_literal
                (string_content) @injection.content))
            (string_literal
              (string_content) @injection.content))))))
  (#any-of? @_fn "execute" "query" "prepareStatement")
  (#set! injection.language "sql")
)

(
  (call_expression
    (navigation_expression
      (simple_identifier)
      (navigation_suffix
        (simple_identifier) @_fn))
    (call_suffix
      (value_arguments
        (value_argument
          (additive_expression
            (additive_expression
              (additive_expression
                (string_literal
                  (string_content) @injection.content)
                (string_literal
                  (string_content) @injection.content))
              (string_literal
                (string_content) @injection.content))
            (string_literal
              (string_content) @injection.content))))))
  (#any-of? @_fn "execute" "query" "prepareStatement")
  (#set! injection.language "sql")
)

; === GraphQL ===

; GQL suffix
(
  (property_declaration
    (variable_declaration
      (simple_identifier) @_name)
    (string_literal
      (string_content) @injection.content))
  (#lua-match? @_name "^[%u][%u%d_]*_GQL$")
  (#set! injection.language "graphql")
)

(
  (property_declaration
    (variable_declaration
      (simple_identifier) @_name)
    (string_literal
      (string_content) @injection.content))
  (#lua-match? @_name "^[%l][%w]*Gql$")
  (#set! injection.language "graphql")
)

; GQL suffix with trimIndent / trimMargin
(
  (property_declaration
    (variable_declaration
      (simple_identifier) @_name)
    (call_expression
      (navigation_expression
        (string_literal
          (string_content) @injection.content)
        (navigation_suffix
          (simple_identifier) @_trim))
      (call_suffix
        (value_arguments))))
  (#any-of? @_trim "trimIndent" "trimMargin")
  (#lua-match? @_name "^[%u][%u%d_]*_GQL$")
  (#set! injection.language "graphql")
)

(
  (property_declaration
    (variable_declaration
      (simple_identifier) @_name)
    (call_expression
      (navigation_expression
        (string_literal
          (string_content) @injection.content)
        (navigation_suffix
          (simple_identifier) @_trim))
      (call_suffix
        (value_arguments))))
  (#any-of? @_trim "trimIndent" "trimMargin")
  (#lua-match? @_name "^[%l][%w]*Gql$")
  (#set! injection.language "graphql")
)
