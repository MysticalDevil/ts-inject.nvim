local M = {}

local MAX_CONCAT_DEPTH = 5

local function q(text)
  return string.format("%q", text)
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
  (string_fragment) @injection.content)]]
end

local function concat_expr(depth)
  if depth <= 1 then
    return leaf_string()
  end

  return ([[
(binary_expression
  left: %s
  right: %s)
]]):format(concat_expr(depth - 1), leaf_string())
end

local function render_concat(depth)
  return concat_expr(depth)
end

local function add(blocks, text)
  blocks[#blocks + 1] = text
end

local function render_name_pattern(rule)
  local blocks = {
    ([[
(
  (variable_declarator
    name: (identifier) @_name
    value: (template_string) @injection.content)
  (#lua-match? @_name %s)
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language %s)
)
]]):format(q(rule.pattern), q(rule.lang)),
    ([[
(
  (variable_declarator
    name: (identifier) @_name
    value: (string
      (string_fragment) @injection.content))
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
  (variable_declarator
    name: (identifier) @_name
    value: %s)
  (#lua-match? @_name %s)
  (#set! injection.combined)
  (#set! injection.language %s)
)
]]):format(render_concat(depth), q(rule.pattern), q(rule.lang))
    )
  end

  return blocks
end

local function call_function_pattern()
  return [[
[
  (identifier) @_fn
  (member_expression
    property: (property_identifier) @_fn)
]
]]
end

local function render_call(rule)
  local blocks = {
    ([[
(
  (call_expression
    function: %s
    arguments: (arguments
      (template_string) @injection.content
      . (_)*))
  (#any-of? @_fn %s)
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language %s)
)
]]):format(call_function_pattern(), join_fn_list(rule.fn), q(rule.lang)),
    ([[
(
  (call_expression
    function: %s
    arguments: (arguments
      (string
        (string_fragment) @injection.content)
      . (_)*))
  (#any-of? @_fn %s)
  (#set! injection.language %s)
)
]]):format(call_function_pattern(), join_fn_list(rule.fn), q(rule.lang)),
  }

  for depth = 2, MAX_CONCAT_DEPTH do
    add(
      blocks,
      ([[
(
  (call_expression
    function: %s
    arguments: (arguments
      %s
      . (_)*))
  (#any-of? @_fn %s)
  (#set! injection.combined)
  (#set! injection.language %s)
)
]]):format(call_function_pattern(), render_concat(depth), join_fn_list(rule.fn), q(rule.lang))
    )
  end

  return blocks
end

local function render_template_tag(rule)
  return {
    ([[
(
  (call_expression
    function: (member_expression
      property: (property_identifier) @_fn)
    arguments: (template_string) @injection.content)
  (#any-of? @_fn %s)
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language %s)
)
]]):format(join_fn_list(rule.fn), q(rule.lang)),
  }
end

function M.build(rules)
  local blocks = { "; extends" }

  for _, rule in ipairs(rules or {}) do
    local rendered = {}

    if rule.kind == "name_pattern" then
      rendered = render_name_pattern(rule)
    elseif rule.kind == "call" then
      rendered = render_call(rule)
    elseif rule.kind == "template_tag" then
      rendered = render_template_tag(rule)
    else
      return nil, ("unsupported ecmascript rule kind: %s"):format(rule.kind)
    end

    vim.list_extend(blocks, rendered)
  end

  return table.concat(blocks, "\n")
end

return M
