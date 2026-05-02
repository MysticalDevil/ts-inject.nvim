local c_family = require("ts_inject.host._c_family")

local M = c_family.new({
  leaf_strings = {
    "(string_literal\n    (string_content) @injection.content)+",
    "(concatenated_string\n    (string_literal\n      (string_content) @injection.content)+)",
  },
  raw_string = "(raw_string_literal\n    (raw_string_content) @injection.content)",
  user_defined = "(user_defined_literal\n    (string_literal\n      (string_content) @injection.content))",
  parenthesized = {
    "(parenthesized_expression\n    (string_literal\n      (string_content) @injection.content)+)",
    "(parenthesized_expression\n    (concatenated_string\n      (string_literal\n        (string_content) @injection.content)+))",
    "(parenthesized_expression\n    (raw_string_literal\n      (raw_string_content) @injection.content))",
  },
  cast = {
    "(cast_expression\n    value: (string_literal\n      (string_content) @injection.content)+)",
    "(cast_expression\n    value: (concatenated_string\n      (string_literal\n        (string_content) @injection.content)+))",
    "(cast_expression\n    value: (raw_string_literal\n      (raw_string_content) @injection.content))",
  },
  field_calls = true,
  static_preamble = [[
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
  (#set! injection.language "sql"))

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
  (#set! injection.language "sql"))

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
  (#any-of? @_type "QSqlQuery" "query" "statement")
  (#set! injection.language "sql"))

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
  (#set! injection.language "sql"))

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
  (#any-of? @_stream "sql" "prepare")
  (#set! injection.language "sql"))

(
  (gnu_asm_expression
    [
      (string_literal
        (string_content) @injection.content)+
      (concatenated_string
        (string_literal
          (string_content) @injection.content)+)
    ])
  (#set! injection.language "asm"))

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
  (#set! injection.language "regex"))

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
  (#set! injection.language "regex"))
]],
})

return M
