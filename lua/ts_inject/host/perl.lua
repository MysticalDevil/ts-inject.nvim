local M = {}

local MAX_CONCAT_DEPTH = 3

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
  return [=[([
    (string_literal
      (string_content) @injection.content)
    (interpolated_string_literal
      (string_content) @injection.content)
  ])]=]
end

local function concat_expr(depth)
  if depth <= 1 then
    return leaf_string()
  end
  return ([[
(binary_expression
  left: %s
  operator: "."
  right: %s)
]]):format(concat_expr(depth - 1), leaf_string())
end

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
]]):format(leaf_string(), q(rule.pattern), q(rule.lang))

  for depth = 2, MAX_CONCAT_DEPTH do
    add(
      blocks,
      ([[
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
]]):format(concat_expr(depth), q(rule.pattern), q(rule.lang))
    )
  end

  return blocks
end

local function render_call(rule)
  local fn = join_fn_list(rule.fn)
  local blocks = {}

  blocks[#blocks + 1] = ([[
(
  (method_call_expression
    method: (method) @_fn
    arguments: %s)
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(leaf_string(), fn, q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (method_call_expression
    method: (method) @_fn
    arguments: (list_expression
      .
      %s))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(leaf_string(), fn, q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (function_call_expression
    function: (function) @_fn
    %s)
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(leaf_string(), fn, q(rule.lang))

  for depth = 2, MAX_CONCAT_DEPTH do
    add(
      blocks,
      ([[
(
  (method_call_expression
    method: (method) @_fn
    arguments: %s)
  (#any-of? @_fn %s)
  (#set! injection.combined)
  (#set! injection.language %s))
]]):format(concat_expr(depth), fn, q(rule.lang))
    )
  end

  return blocks
end

function M.build(rules, _opts)
  local blocks = { "; extends" }
  local has_sql = false

  for _, rule in ipairs(rules or {}) do
    local rendered = {}

    if rule.kind == "name_pattern" then
      rendered = render_name_pattern(rule)
    elseif rule.kind == "call" then
      rendered = render_call(rule)
    else
      return nil, ("unsupported perl rule kind: %s"):format(rule.kind)
    end

    if rule.lang == "sql" then
      has_sql = true
    end

    vim.list_extend(blocks, rendered)
  end

  if has_sql then
    add(
      blocks,
      [[
(
  (heredoc_content
    (heredoc_end) @_end)
  (#lua-match? @_end "^[Ss][Qq][Ll]$")
  (#set! injection.language "sql"))
]]
    )
  end

  return table.concat(blocks, "\n")
end

return M
