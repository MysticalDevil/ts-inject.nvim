; extends

; SQL assignment like `const usersSql = `...`` or chained `"..." + "..."`.
(
  (variable_declarator
    name: (identifier) @_name
    value: [
      (template_string) @injection.content
      (string
        (string_fragment) @injection.content)
      (binary_expression
        left: (string
          (string_fragment) @injection.content)
        right: (string
          (string_fragment) @injection.content))
      (binary_expression
        left: (binary_expression
          left: (string
            (string_fragment) @injection.content)
          right: (string
            (string_fragment) @injection.content))
        right: (string
          (string_fragment) @injection.content))
      (binary_expression
        left: (binary_expression
          left: (binary_expression
            left: (string
              (string_fragment) @injection.content)
            right: (string
              (string_fragment) @injection.content))
          right: (string
            (string_fragment) @injection.content))
        right: (string
          (string_fragment) @injection.content))
    ])
  (#lua-match? @_name "^[%a$][%w_$]*_?[Ss][Qq][Ll]$")
  (#set! injection.combined)
  (#set! injection.language "sql")
)

(
  (variable_declarator
    name: (identifier) @_name
    value: (template_string) @injection.content)
  (#lua-match? @_name "^[%a$][%w_$]*_?[Ss][Qq][Ll]$")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "sql")
)

; SQL passed directly to DB helpers.
(
  (call_expression
    function: [
      (identifier) @_fn
      (member_expression
        property: (property_identifier) @_fn)
    ]
    arguments: (arguments
      [
        (string
          (string_fragment) @injection.content)
        (binary_expression
          left: (string
            (string_fragment) @injection.content)
          right: (string
            (string_fragment) @injection.content))
        (binary_expression
          left: (binary_expression
            left: (string
              (string_fragment) @injection.content)
            right: (string
              (string_fragment) @injection.content))
          right: (string
            (string_fragment) @injection.content))
        (binary_expression
          left: (binary_expression
            left: (binary_expression
              left: (string
                (string_fragment) @injection.content)
              right: (string
                (string_fragment) @injection.content))
            right: (string
              (string_fragment) @injection.content))
          right: (string
            (string_fragment) @injection.content))
        (binary_expression
          left: (binary_expression
            left: (binary_expression
              left: (binary_expression
                left: (string
                  (string_fragment) @injection.content)
                right: (string
                  (string_fragment) @injection.content))
              right: (string
                (string_fragment) @injection.content))
            right: (string
              (string_fragment) @injection.content))
          right: (string
            (string_fragment) @injection.content))
      ]
      . (_)*))
  (#any-of? @_fn "query" "queryRaw" "execute" "executeRaw")
  (#set! injection.combined)
  (#set! injection.language "sql")
)

(
  (call_expression
    function: [
      (identifier) @_fn
      (member_expression
        property: (property_identifier) @_fn)
    ]
    arguments: (arguments
      (template_string) @injection.content
      . (_)*))
  (#any-of? @_fn "query" "queryRaw" "execute" "executeRaw")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "sql")
)

(
  (call_expression
    function: (member_expression
      property: (property_identifier) @_fn)
    arguments: (template_string) @injection.content)
  (#any-of? @_fn "$queryRaw" "$executeRaw" "queryRaw" "executeRaw" "sql")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "sql")
)
