local M = {}

local util = require("ts_inject.host._util")

local MAX_CONCAT_DEPTH = 5

local static_preamble = [[
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
  (#set! injection.language "sql"))

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
  (#set! injection.language "sql"))

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
  (#set! injection.language "sql"))

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
  (#set! injection.language "sql"))
]]

local concat = require("ts_inject.host._concat")

local function leaf_string()
  return [[(string_literal
    (string_content) @injection.content)]]
end

local concat_expr = concat.binary({
  node_name = "additive_expression",
  left_field = "",
  right_field = "",
  direction = "left",
  leaf_fn = leaf_string,
  max_depth = MAX_CONCAT_DEPTH,
})

local function render_name_pattern(rule)
  local blocks = {}

  blocks[#blocks + 1] = ([[
(
  (property_declaration
    (variable_declaration
      (simple_identifier) @_name)
    %s)
  (#lua-match? @_name %s)
  (#set! injection.language %s)
)
]]):format(leaf_string(), util.q(rule.pattern), util.q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (property_declaration
    (variable_declaration
      (simple_identifier) @_name)
    (call_expression
      (navigation_expression
        %s
        (navigation_suffix
          (simple_identifier) @_trim))
      (call_suffix
        (value_arguments))))
  (#any-of? @_trim "trimIndent" "trimMargin")
  (#lua-match? @_name %s)
  (#set! injection.language %s)
)
]]):format(leaf_string(), util.q(rule.pattern), util.q(rule.lang))

  vim.list_extend(
    blocks,
    concat.expand(concat_expr, MAX_CONCAT_DEPTH, function(expr)
      return ([[
(
  (property_declaration
    (variable_declaration
      (simple_identifier) @_name)
    %s)
  (#lua-match? @_name %s)
  (#set! injection.combined)
  (#set! injection.language %s)
)
]]):format(expr, util.q(rule.pattern), util.q(rule.lang))
    end)
  )

  return blocks
end

local function render_call(rule)
  local fn = util.join_fn_list(rule.fn)
  local blocks = {}

  blocks[#blocks + 1] = ([[
(
  (call_expression
    (navigation_expression
      (simple_identifier)
      (navigation_suffix
        (simple_identifier) @_fn))
    (call_suffix
      (value_arguments
        (value_argument
          %s))))
  (#any-of? @_fn %s)
  (#set! injection.language %s)
)
]]):format(leaf_string(), fn, util.q(rule.lang))

  blocks[#blocks + 1] = ([[
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
              %s
              (navigation_suffix
                (simple_identifier) @_trim))
            (call_suffix
              (value_arguments)))))))
  (#any-of? @_fn %s)
  (#any-of? @_trim "trimIndent" "trimMargin")
  (#set! injection.language %s)
)
]]):format(leaf_string(), fn, util.q(rule.lang))

  vim.list_extend(
    blocks,
    concat.expand(concat_expr, MAX_CONCAT_DEPTH, function(expr)
      return ([[
(
  (call_expression
    (navigation_expression
      (simple_identifier)
      (navigation_suffix
        (simple_identifier) @_fn))
    (call_suffix
      (value_arguments
        (value_argument
          %s))))
  (#any-of? @_fn %s)
  (#set! injection.combined)
  (#set! injection.language %s)
)
]]):format(expr, fn, util.q(rule.lang))
    end)
  )

  return blocks
end

M.build = util.build_dispatcher({
  header = "; extends",
  renderers = {
    name_pattern = render_name_pattern,
    call = render_call,
  },
  static_preamble = static_preamble,
})

return M
