local util = require("ts_inject.host._util")

local M = {}

function M.new(config)
  config = config or {}

  local leaf_strings = config.leaf_strings or {}
  local raw_string = config.raw_string
  local user_defined = config.user_defined
  local parenthesized = config.parenthesized or {}
  local cast = config.cast or {}
  local backslash_value_str = config.backslash_value
  local field_calls = config.field_calls
  local static_preamble = config.static_preamble

  local function string_value()
    local parts = {}
    vim.list_extend(parts, leaf_strings)
    if raw_string then
      parts[#parts + 1] = raw_string
    end
    if user_defined then
      parts[#parts + 1] = user_defined
    end
    vim.list_extend(parts, parenthesized)
    vim.list_extend(parts, cast)
    return "([\n  " .. table.concat(parts, "\n  ") .. "\n])"
  end

  local function backslash_value()
    return backslash_value_str
  end

  local mod = {}

  function mod.render_name_pattern(rule)
    local blocks = {}

    blocks[#blocks + 1] = ([[
(
  (declaration
    declarator: (init_declarator
      declarator: (_) @_decl
      value: %s))
  (#lua-match? @_decl %s)
  (#set! injection.language %s))
]]):format(string_value(), util.q(rule.pattern), util.q(rule.lang))

    if backslash_value_str then
      blocks[#blocks + 1] = ([[
(
  (declaration
    declarator: (init_declarator
      declarator: (_) @_decl
      value: %s))
  (#lua-match? @_decl %s)
  (#set! injection.combined)
  (#set! injection.language %s))
]]):format(backslash_value(), util.q(rule.pattern), util.q(rule.lang))
    end

    blocks[#blocks + 1] = ([[
(
  (assignment_expression
    left: (identifier) @_name
    right: %s)
  (#lua-match? @_name %s)
  (#set! injection.language %s)
)
]]):format(string_value(), util.q(rule.pattern), util.q(rule.lang))

    if backslash_value_str then
      blocks[#blocks + 1] = ([[
(
  (assignment_expression
    left: (identifier) @_name
    right: %s)
  (#lua-match? @_name %s)
  (#set! injection.combined)
  (#set! injection.language %s)
)
]]):format(backslash_value(), util.q(rule.pattern), util.q(rule.lang))
    end

    return blocks
  end

  function mod.render_call(rule)
    local fn = util.join_fn_list(rule.fn)
    local arg_index = rule.arg_index or 2
    local args_prefix = util.arg_prefix(arg_index)
    local blocks = {}

    blocks[#blocks + 1] = ([[
(
  (call_expression
    function: (identifier) @_fn
    arguments: (argument_list
%s
      %s))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(args_prefix, string_value(), fn, util.q(rule.lang))

    if backslash_value_str then
      blocks[#blocks + 1] = ([[
(
  (call_expression
    function: (identifier) @_fn
    arguments: (argument_list
%s
      %s))
  (#any-of? @_fn %s)
  (#set! injection.combined)
  (#set! injection.language %s))
]]):format(args_prefix, backslash_value(), fn, util.q(rule.lang))
    end

    if field_calls then
      blocks[#blocks + 1] = ([[
(
  (call_expression
    function: (field_expression
      field: (field_identifier) @_method)
    arguments: (argument_list
%s
      %s))
  (#any-of? @_method %s)
  (#set! injection.language %s))
]]):format(args_prefix, string_value(), fn, util.q(rule.lang))
    end

    return blocks
  end

  mod.build = util.build_dispatcher({
    header = "; extends",
    renderers = {
      name_pattern = mod.render_name_pattern,
      call = mod.render_call,
    },
    static_preamble = static_preamble,
  })

  return mod
end

return M
