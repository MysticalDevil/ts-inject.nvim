local M = {}

local util = require("ts_inject.host._util")

local function render_name_pattern(rule)
  return {
    ([[
(
  (variable_declaration
    (identifier) @_name
    (multiline_string) @injection.content)
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(util.q(rule.pattern), util.q(rule.lang)),
    ([[
(
  (variable_declaration
    (identifier) @_name
    (string
      (string_content) @injection.content))
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(util.q(rule.pattern), util.q(rule.lang)),
  }
end

local function call_function_pattern()
  return [[
(field_expression
  object: (identifier)
  member: (identifier) @_fn)
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
    arguments: (arguments
%s
      (multiline_string) @injection.content
      . (_)*))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(call_function_pattern(), args_prefix, fn, util.q(rule.lang)),
    ([[
(
  (call_expression
    function: %s
    arguments: (arguments
%s
      (string
        (string_content) @injection.content)
      . (_)*))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(call_function_pattern(), args_prefix, fn, util.q(rule.lang)),
  }
end

M.build = util.build_dispatcher({
  header = "; extends",
  renderers = {
    name_pattern = render_name_pattern,
    call = render_call,
  },
})

return M
