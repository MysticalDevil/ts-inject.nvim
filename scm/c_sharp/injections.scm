; extends

; SQL assignment like `var summarySql = "..." + "..."`
(
  (local_declaration_statement
    (modifier)
    (variable_declaration
      (_)
      (variable_declarator
        (identifier) @_name
        (verbatim_string_literal) @injection.content)))
  (#lua-match? @_name "^[%u][%u%d_]*_SQL$")
  (#offset! @injection.content 0 2 0 -1)
  (#set! injection.language "sql")
)

(
  (local_declaration_statement
    (variable_declaration
      (_)
      (variable_declarator
        (identifier) @_name
        (verbatim_string_literal) @injection.content)))
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#offset! @injection.content 0 2 0 -1)
  (#set! injection.language "sql")
)

(
  (local_declaration_statement
    (variable_declaration
      (_)
      (variable_declarator
        (identifier) @_name
        (string_literal
          (string_literal_content) @injection.content))))
  (#lua-match? @_name "^[%u][%u%d_]*_SQL$")
  (#set! injection.language "sql")
)

(
  (local_declaration_statement
    (variable_declaration
      (_)
      (variable_declarator
        (identifier) @_name
        (string_literal
          (string_literal_content) @injection.content))))
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#set! injection.language "sql")
)

(
  (local_declaration_statement
    (variable_declaration
      (_)
      (variable_declarator
        (identifier) @_name
        (binary_expression
          left: (string_literal
            (string_literal_content) @injection.content)
          right: (string_literal
            (string_literal_content) @injection.content)))))
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#set! injection.language "sql")
)

(
  (local_declaration_statement
    (variable_declaration
      (_)
      (variable_declarator
        (identifier) @_name
        (binary_expression
          left: (binary_expression
            left: (string_literal
              (string_literal_content) @injection.content)
            right: (string_literal
              (string_literal_content) @injection.content))
          right: (string_literal
            (string_literal_content) @injection.content)))))
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#set! injection.language "sql")
)

(
  (local_declaration_statement
    (variable_declaration
      (_)
      (variable_declarator
        (identifier) @_name
        (binary_expression
          left: (binary_expression
            left: (binary_expression
              left: (string_literal
                (string_literal_content) @injection.content)
              right: (string_literal
                (string_literal_content) @injection.content))
            right: (string_literal
              (string_literal_content) @injection.content))
          right: (string_literal
            (string_literal_content) @injection.content)))))
  (#lua-match? @_name "^[%l][%w]*Sql$")
  (#set! injection.language "sql")
)

; SQL passed to C# DB helpers.
(
  (invocation_expression
    (member_access_expression
      (identifier)
      .
      (identifier) @_fn)
    (argument_list
      "("
      .
      (argument
        (verbatim_string_literal) @injection.content)
      . [
        ","
        ")"
      ]))
  (#any-of? @_fn "Query" "Execute" "Prepare")
  (#offset! @injection.content 0 2 0 -1)
  (#set! injection.language "sql")
)

(
  (invocation_expression
    (member_access_expression
      (identifier)
      .
      (identifier) @_fn)
    (argument_list
      "("
      .
      (argument
        (string_literal
          (string_literal_content) @injection.content))
      . [
        ","
        ")"
      ]))
  (#any-of? @_fn "Query" "Execute" "Prepare")
  (#set! injection.language "sql")
)

(
  (invocation_expression
    (member_access_expression
      (identifier)
      .
      (identifier) @_fn)
    (argument_list
      "("
      .
      (argument
        (binary_expression
          left: (string_literal
            (string_literal_content) @injection.content)
          right: (string_literal
            (string_literal_content) @injection.content)))
      . [
        ","
        ")"
      ]))
  (#any-of? @_fn "Query" "Execute" "Prepare")
  (#set! injection.language "sql")
)

(
  (invocation_expression
    (member_access_expression
      (identifier)
      .
      (identifier) @_fn)
    (argument_list
      "("
      .
      (argument
        (binary_expression
          left: (binary_expression
            left: (string_literal
              (string_literal_content) @injection.content)
            right: (string_literal
              (string_literal_content) @injection.content))
          right: (string_literal
            (string_literal_content) @injection.content)))
      . [
        ","
        ")"
      ]))
  (#any-of? @_fn "Query" "Execute" "Prepare")
  (#set! injection.language "sql")
)

(
  (invocation_expression
    (member_access_expression
      (identifier)
      .
      (identifier) @_fn)
    (argument_list
      "("
      .
      (argument
        (binary_expression
          left: (binary_expression
            left: (binary_expression
              left: (string_literal
                (string_literal_content) @injection.content)
              right: (string_literal
                (string_literal_content) @injection.content))
            right: (string_literal
              (string_literal_content) @injection.content))
          right: (string_literal
            (string_literal_content) @injection.content)))
      . [
        ","
        ")"
      ]))
  (#any-of? @_fn "Query" "Execute" "Prepare")
  (#set! injection.language "sql")
)

(
  (invocation_expression
    (member_access_expression
      (identifier)
      .
      (identifier) @_fn)
    (argument_list
      "("
      .
      (argument
        (binary_expression
          left: (binary_expression
            left: (binary_expression
              left: (binary_expression
                left: (string_literal
                  (string_literal_content) @injection.content)
                right: (string_literal
                  (string_literal_content) @injection.content))
              right: (string_literal
                (string_literal_content) @injection.content))
            right: (string_literal
              (string_literal_content) @injection.content))
          right: (string_literal
            (string_literal_content) @injection.content)))
      . [
        ","
        ")"
      ]))
  (#any-of? @_fn "Query" "Execute" "Prepare")
  (#set! injection.language "sql")
)

; === GraphQL ===

; GQL suffix with verbatim strings
(
  (local_declaration_statement
    (modifier)
    (variable_declaration
      (_)
      (variable_declarator
        (identifier) @_name
        (verbatim_string_literal) @injection.content)))
  (#lua-match? @_name "^[%u][%u%d_]*_GQL$")
  (#offset! @injection.content 0 2 0 -1)
  (#set! injection.language "graphql")
)

(
  (local_declaration_statement
    (variable_declaration
      (_)
      (variable_declarator
        (identifier) @_name
        (verbatim_string_literal) @injection.content)))
  (#lua-match? @_name "^[%l][%w]*Gql$")
  (#offset! @injection.content 0 2 0 -1)
  (#set! injection.language "graphql")
)

; GQL suffix with regular strings
(
  (local_declaration_statement
    (variable_declaration
      (_)
      (variable_declarator
        (identifier) @_name
        (string_literal
          (string_literal_content) @injection.content))))
  (#lua-match? @_name "^[%u][%u%d_]*_GQL$")
  (#set! injection.language "graphql")
)

(
  (local_declaration_statement
    (variable_declaration
      (_)
      (variable_declarator
        (identifier) @_name
        (string_literal
          (string_literal_content) @injection.content))))
  (#lua-match? @_name "^[%l][%w]*Gql$")
  (#set! injection.language "graphql")
)

; === Regex ===

; Regex.Match("input", "pattern") — second argument
(
  (invocation_expression
    (member_access_expression
      (identifier) @_class
      .
      (identifier) @_method)
    (argument_list
      "("
      (argument)
      ","
      (argument
        (string_literal
          (string_literal_content) @injection.content))))
  (#eq? @_class "Regex")
  (#any-of? @_method "Match" "Replace" "IsMatch" "Split" "Matches")
  (#set! injection.language "regex")
)

; new Regex("pattern")
(
  (object_creation_expression
    (identifier) @_class
    (argument_list
      "("
      .
      (argument
        (string_literal
          (string_literal_content) @injection.content))))
  (#eq? @_class "Regex")
  (#set! injection.language "regex")
)
