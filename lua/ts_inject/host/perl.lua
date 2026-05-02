local M = {}

local util = require("ts_inject.host._util")

local MAX_CONCAT_DEPTH = 3

local function leaf_string()
  return [=[([
    (string_literal
      (string_content) @injection.content)
    (interpolated_string_literal
      (string_content) @injection.content)
  ])]=]
end

local concat = require("ts_inject.host._concat")

local concat_expr = concat.binary({
  node_name = "binary_expression",
  left_field = "left: ",
  right_field = "right: ",
  operator = ".",
  direction = "left",
  leaf_fn = leaf_string,
  max_depth = MAX_CONCAT_DEPTH,
})

local function render_name_pattern(rule)
  local blocks = {}

  blocks[#blocks + 1] = ([[
(
  (expression_statement
    (assignment_expression
      left: (variable_declaration
        variable: (scalar
          (varname) @_name))
      right: %s))
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(leaf_string(), util.q(rule.pattern), util.q(rule.lang))

  vim.list_extend(
    blocks,
    concat.expand(concat_expr, MAX_CONCAT_DEPTH, function(expr)
      return ([[
(
  (expression_statement
    (assignment_expression
      left: (variable_declaration
        variable: (scalar
          (varname) @_name))
      right: %s))
  (#lua-match? @_name %s)
  (#set! injection.combined)
  (#set! injection.language %s))
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
  (method_call_expression
    method: (method) @_fn
    arguments: %s)
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(leaf_string(), fn, util.q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (method_call_expression
    method: (method) @_fn
    arguments: (list_expression
      .
      %s))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(leaf_string(), fn, util.q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (function_call_expression
    function: (function) @_fn
    %s)
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(leaf_string(), fn, util.q(rule.lang))

  vim.list_extend(
    blocks,
    concat.expand(concat_expr, MAX_CONCAT_DEPTH, function(expr)
      return ([[
(
  (method_call_expression
    method: (method) @_fn
    arguments: %s)
  (#any-of? @_fn %s)
  (#set! injection.combined)
  (#set! injection.language %s))
]]):format(expr, fn, util.q(rule.lang))
    end)
  )

  return blocks
end

local base_build = util.build_dispatcher({
  header = "; extends",
  renderers = {
    name_pattern = render_name_pattern,
    call = render_call,
  },
})

function M.build(rules, _opts)
  local has_sql = false
  for _, rule in ipairs(rules or {}) do
    if rule.lang == "sql" then
      has_sql = true
      break
    end
  end

  local result, err = base_build(rules, _opts)
  if not result then
    return nil, err
  end

  if has_sql then
    result = result
      .. "\n"
      .. [[
(
  (heredoc_content
    (heredoc_end) @_end)
  (#lua-match? @_end "^[Ss][Qq][Ll]$")
  (#set! injection.language "sql"))
]]
  end

  return result
end

return M
