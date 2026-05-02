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
  local args_prefix = util.arg_prefix(rule.arg_index or 1)

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
]]):format(call_function_pattern(), args_prefix, string_literal_query(), fn, util.q(rule.lang)),
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

M.build = util.build_dispatcher({
  header = "; extends",
  renderers = {
    name_pattern = render_name_pattern,
    call = render_call,
    content_prefix = render_content_prefix,
  },
})

return M
