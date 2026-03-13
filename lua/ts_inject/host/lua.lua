local M = {}

local MAX_CONCAT_DEPTH = 6

local function q(text)
  return string.format("%q", text)
end

local function add(blocks, text)
  blocks[#blocks + 1] = text
end

local function join_fn_list(items)
  local out = {}
  for _, item in ipairs(items or {}) do
    out[#out + 1] = q(item)
  end
  return table.concat(out, " ")
end

local function leaf_string()
  return [[(string
        (string_content) @injection.content)]]
end

local function concat_expr(depth)
  if depth <= 1 then
    return leaf_string()
  end

  return ([[
(binary_expression
  left: %s
  right: %s)
]]):format(leaf_string(), concat_expr(depth - 1))
end

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
]]):format(q(rule.pattern), q(rule.lang)),
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
]]):format(concat_expr(depth), q(rule.pattern), q(rule.lang))
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
]]):format(q(rule.pattern), q(rule.lang)),
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
]]):format(call_name_pattern(), join_fn_list(rule.fn), q(rule.lang)),
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
]]):format(call_name_pattern(), concat_expr(depth), join_fn_list(rule.fn), q(rule.lang))
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
]]):format(call_name_pattern(), join_fn_list(rule.fn), q(rule.lang)),
  }
end

function M.build(rules)
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
    else
      return nil, ("unsupported lua rule kind: %s"):format(rule.kind)
    end

    vim.list_extend(blocks, rendered)
  end

  return table.concat(blocks, "\n")
end

return M
