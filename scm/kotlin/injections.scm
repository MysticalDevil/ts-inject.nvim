; extends

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
