local M = {}

local util = require("ts_inject.host._util")

local function string_literal_query()
  return [[
[
  (interpreted_string_literal
    (interpreted_string_literal_content) @injection.content)
  (raw_string_literal
    (raw_string_literal_content) @injection.content)
]
]]
end

local function render_name_pattern(rule)
  return {
    ([[
(
  (short_var_declaration
    left: (expression_list
      (identifier) @_name)
    right: (expression_list
      %s))
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(string_literal_query(), util.q(rule.pattern), util.q(rule.lang)),
    ([[
(
  (assignment_statement
    left: (expression_list
      (identifier) @_name)
    right: (expression_list
      %s))
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(string_literal_query(), util.q(rule.pattern), util.q(rule.lang)),
  }
end

local function call_function_pattern()
  return [[
[
  (identifier) @_fn
  (selector_expression
    field: (field_identifier) @_fn)
]
]]
end

local function render_call(rule)
  local fn = util.join_fn_list(rule.fn)
  local arg_index = rule.arg_index or 1

  local args_prefix = {}
  for _ = 1, arg_index - 1 do
    table.insert(args_prefix, "      .")
    table.insert(args_prefix, "      (_)")
  end
  table.insert(args_prefix, "      .")

  return {
    ([[
(
  (call_expression
    function: %s
    arguments: (argument_list
%s
      %s
      . (_)*))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(call_function_pattern(), table.concat(args_prefix, "\n"), string_literal_query(), fn, util.q(rule.lang)),
  }
end

local function render_content_prefix(rule)
  local blocks = {}

  for _, pattern in ipairs(rule.patterns or {}) do
    blocks[#blocks + 1] = ([[
(
  (assignment_statement
    left: (expression_list
      (identifier))
    right: (expression_list
      %s))
  (#lua-match? @injection.content %s)
  (#set! injection.language %s))
]]):format(string_literal_query(), util.q(pattern), util.q(rule.lang))

    blocks[#blocks + 1] = ([[
(
  (short_var_declaration
    left: (expression_list
      (identifier))
    right: (expression_list
      %s))
  (#lua-match? @injection.content %s)
  (#set! injection.language %s))
]]):format(string_literal_query(), util.q(pattern), util.q(rule.lang))

    blocks[#blocks + 1] = ([[
(
  (call_expression
    function: %s
    arguments: (argument_list
      .
      %s
      . (_)*))
  (#lua-match? @injection.content %s)
  (#set! injection.language %s))
]]):format(call_function_pattern(), string_literal_query(), util.q(pattern), util.q(rule.lang))
  end

  return blocks
end

function M.build(rules, _opts)
  local blocks = { "; extends" }

  for _, rule in ipairs(rules or {}) do
    local rendered = {}

    if rule.kind == "name_pattern" then
      rendered = render_name_pattern(rule)
    elseif rule.kind == "call" then
      rendered = render_call(rule)
    elseif rule.kind == "content_prefix" then
      rendered = render_content_prefix(rule)
    else
      return nil, ("unsupported go rule kind: %s"):format(rule.kind)
    end

    vim.list_extend(blocks, rendered)
  end

  return table.concat(blocks, "\n")
end

return M
