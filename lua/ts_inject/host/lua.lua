local M = {}

local util = require("ts_inject.host._util")

local MAX_CONCAT_DEPTH = 6

local function add(blocks, text)
  blocks[#blocks + 1] = text
end

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

  for depth = 2, MAX_CONCAT_DEPTH do
    add(
      blocks,
      ([[
(
  (assignment_statement
    (variable_list
      (identifier) @_name)
    (expression_list
      %s))
  (#lua-match? @_name %s)
  (#set! injection.language %s)
)
]]):format(concat_expr(depth), util.q(rule.pattern), util.q(rule.lang))
    )
  end

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

  for depth = 2, MAX_CONCAT_DEPTH do
    add(
      blocks,
      ([[
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
]]):format(call_name_pattern(), concat_expr(depth), util.join_fn_list(rule.fn), util.q(rule.lang))
    )
  end

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
  (#any-lua-match? @injection.content %s)
  (#set! injection.combined)
  (#set! injection.language %s)
)
]]):format(call_name_pattern(), util.q(pattern), util.q(rule.lang))
  end

  return blocks
end

function M.build(rules, _opts)
  local blocks = { "; extends" }

  for _, rule in ipairs(rules or {}) do
    local rendered = {}

    if rule.kind == "name_pattern" then
      rendered = render_name_pattern(rule)
    elseif rule.kind == "name_format" then
      rendered = render_name_format(rule)
    elseif rule.kind == "call" then
      rendered = render_call(rule)
    elseif rule.kind == "call_format" then
      rendered = render_call_format(rule)
    elseif rule.kind == "content_prefix" then
      rendered = render_content_prefix(rule)
    else
      return nil, ("unsupported lua rule kind: %s"):format(rule.kind)
    end

    vim.list_extend(blocks, rendered)
  end

  return table.concat(blocks, "\n")
end

return M
