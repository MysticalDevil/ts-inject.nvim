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

  -- Emit a normal block (string_value) and, when backslash_value is configured,
  -- a variant that uses backslash_value with injection.combined.
  -- block_fn(value, combined_line) is called once for each variant and should
  -- return a formatted query string.
  local function value_pair(block_fn)
    local blocks = {}
    blocks[#blocks + 1] = block_fn(string_value(), "")
    if backslash_value_str then
      blocks[#blocks + 1] = block_fn(backslash_value(), "\n  (#set! injection.combined)")
    end
    return blocks
  end

  local mod = {}

  function mod.render_name_pattern(rule)
    local pattern_q = util.q(rule.pattern)
    local lang_q = util.q(rule.lang)
    local blocks = {}

    vim.list_extend(
      blocks,
      value_pair(function(value, combined)
        return ([[
(
  (declaration
    declarator: (init_declarator
      declarator: [
        (identifier) @_decl
        (pointer_declarator
          declarator: (identifier) @_decl)
        (array_declarator
          declarator: (identifier) @_decl)
      ]
      value: %s))
  (#lua-match? @_decl %s)%s
  (#set! injection.language %s))
]]):format(value, pattern_q, combined, lang_q)
      end)
    )

    vim.list_extend(
      blocks,
      value_pair(function(value, combined)
        return ([[
(
  (assignment_expression
    left: (identifier) @_name
    right: %s)
  (#lua-match? @_name %s)%s
  (#set! injection.language %s)
)
]]):format(value, pattern_q, combined, lang_q)
      end)
    )

    return blocks
  end

  function mod.render_call(rule)
    local fn = util.join_fn_list(rule.fn)
    local arg_index = rule.arg_index or 2
    local args_prefix = util.arg_prefix(arg_index)
    local lang_q = util.q(rule.lang)
    local blocks = {}

    vim.list_extend(
      blocks,
      value_pair(function(value, combined)
        return ([[
(
  (call_expression
    function: (identifier) @_fn
    arguments: (argument_list
%s
      %s))%s
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(args_prefix, value, combined, fn, lang_q)
      end)
    )

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
]]):format(args_prefix, string_value(), fn, lang_q)
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
