local M = {}

local util = require("ts_inject.host._util")

local MAX_CONCAT_DEPTH = 6

local concat = require("ts_inject.host._concat")

local function leaf_string()
  return [[(string
        (string_content) @injection.content)]]
end

local concat_expr = concat.binary({
  node_name = "binary_expression",
  left_field = "left: ",
  right_field = "right: ",
  direction = "right",
  leaf_fn = leaf_string,
  max_depth = MAX_CONCAT_DEPTH,
})

local function render_name_pattern(rule)
  local blocks = {
    ([[
(
  (assignment_statement
    (variable_list
      (identifier) @_name)
    (expression_list
      (string
        (string_content) @injection.content)))
  (#lua-match? @_name %s)
  (#set! injection.language %s)
)
]]):format(util.q(rule.pattern), util.q(rule.lang)),
  }

  vim.list_extend(
    blocks,
    concat.expand(concat_expr, MAX_CONCAT_DEPTH, function(expr)
      return ([[
(
  (assignment_statement
    (variable_list
      (identifier) @_name)
    (expression_list
      %s))
  (#lua-match? @_name %s)
  (#set! injection.language %s)
)
]]):format(expr, util.q(rule.pattern), util.q(rule.lang))
    end)
  )

  return blocks
end

local function render_name_format(rule)
  return {
    ([[
(
  (assignment_statement
    (variable_list
      (identifier) @_name)
    (expression_list
      (function_call
        name: (method_index_expression
          table: (parenthesized_expression
            (string
              (string_content) @injection.content))
          method: (identifier) @_format)
        arguments: (arguments))))
  (#lua-match? @_name %s)
  (#eq? @_format "format")
  (#set! injection.language %s)
)
]]):format(util.q(rule.pattern), util.q(rule.lang)),
  }
end

local function call_name_pattern()
  return [[
[
  (identifier) @_fn
  (method_index_expression
    method: (identifier) @_fn)
  (dot_index_expression
    field: (identifier) @_fn)
]
]]
end

local function render_call(rule)
  local blocks = {
    ([[
(
  (function_call
    name: %s
    arguments: (arguments
      "("
      .
      (string
        (string_content) @injection.content)
      . [
        ","
        ")"
      ]))
  (#any-of? @_fn %s)
  (#set! injection.language %s)
)
]]):format(call_name_pattern(), util.join_fn_list(rule.fn), util.q(rule.lang)),
  }

  vim.list_extend(
    blocks,
    concat.expand(concat_expr, MAX_CONCAT_DEPTH, function(expr)
      return ([[
(
  (function_call
    name: %s
    arguments: (arguments
      "("
      .
      %s
      . [
        ","
        ")"
      ]))
  (#any-of? @_fn %s)
  (#set! injection.language %s)
)
]]):format(call_name_pattern(), expr, util.join_fn_list(rule.fn), util.q(rule.lang))
    end)
  )

  return blocks
end

local function render_call_format(rule)
  return {
    ([[
(
  (function_call
    name: %s
    arguments: (arguments
      "("
      .
      (function_call
        name: (method_index_expression
          table: (parenthesized_expression
            (string
              (string_content) @injection.content))
          method: (identifier) @_format)
        arguments: (arguments))
      . [
        ","
        ")"
      ]))
  (#any-of? @_fn %s)
  (#eq? @_format "format")
  (#set! injection.language %s)
)
]]):format(call_name_pattern(), util.join_fn_list(rule.fn), util.q(rule.lang)),
  }
end

local function render_content_prefix(rule)
  local blocks = {}

  for _, pattern in ipairs(rule.patterns or {}) do
    blocks[#blocks + 1] = ([[
(
  (assignment_statement
    (variable_list
      (_))
    (expression_list
      (string
        (string_content) @injection.content)))
  (#lua-match? @injection.content %s)
  (#set! injection.language %s)
)
]]):format(util.q(pattern), util.q(rule.lang))

    blocks[#blocks + 1] = ([[
(
  (assignment_statement
    (variable_list
      (_))
    (expression_list
      (binary_expression
        left: (string
          (string_content) @injection.content)
        right: (string
          (string_content) @injection.content))))
  ; #any-lua-match? is required because binary_expression has two string captures.
  (#any-lua-match? @injection.content %s)
  (#set! injection.combined)
  (#set! injection.language %s)
)
]]):format(util.q(pattern), util.q(rule.lang))

    blocks[#blocks + 1] = ([[
(
  (function_call
    name: %s
    arguments: (arguments
      "("
      .
      (string
        (string_content) @injection.content)
      . [
        ","
        ")"
      ]))
  (#lua-match? @injection.content %s)
  (#set! injection.language %s)
)
]]):format(call_name_pattern(), util.q(pattern), util.q(rule.lang))

    blocks[#blocks + 1] = ([[
(
  (function_call
    name: %s
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
  ; #any-lua-match? is required because binary_expression has two string captures.
  (#any-lua-match? @injection.content %s)
  (#set! injection.combined)
  (#set! injection.language %s)
)
]]):format(call_name_pattern(), util.q(pattern), util.q(rule.lang))
  end

  return blocks
end

M.build = util.build_dispatcher({
  header = "; extends",
  renderers = {
    name_pattern = render_name_pattern,
    name_format = render_name_format,
    call = render_call,
    call_format = render_call_format,
    content_prefix = render_content_prefix,
  },
})

return M
