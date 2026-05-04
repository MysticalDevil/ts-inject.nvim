local c_family = require("ts_inject.host._c_family")

local M = c_family.new({
  leaf_strings = {
    "(string_literal\n    (string_content) @injection.content\n    ((escape_sequence)\n    (string_content) @injection.content)*)",
    "(concatenated_string\n    (string_literal\n      (string_content) @injection.content)+)",
  },
  parenthesized = {
    "(parenthesized_expression\n    (string_literal\n      (string_content) @injection.content\n      ((escape_sequence)\n      (string_content) @injection.content)*))",
    "(parenthesized_expression\n    (concatenated_string\n      (string_literal\n        (string_content) @injection.content)+))",
  },
  cast = {
    "(cast_expression\n    value: (string_literal\n      (string_content) @injection.content\n      ((escape_sequence)\n      (string_content) @injection.content)*))",
    "(cast_expression\n    value: (concatenated_string\n      (string_literal\n        (string_content) @injection.content)+))",
  },
  static_preamble = [[
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
  (call_expression
    function: (identifier) @_fn
    arguments: (argument_list
      .
      (_)
      .
      (string_literal
        (string_content) @injection.content)))
  (#eq? @_fn "regcomp")
  (#set! injection.language "regex"))
]],
})

return M
