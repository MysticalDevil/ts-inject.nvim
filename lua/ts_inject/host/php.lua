local M = {}

local MAX_CONCAT_DEPTH = 5

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

local function nowdoc_string()
  return [[(nowdoc
    (nowdoc_body
      (nowdoc_string)+ @injection.content))]]
end

local function leaf_encapsed_string()
  return [[(encapsed_string
    (string_content) @injection.content)]]
end

local function leaf_string_or_encapsed()
  return [=[([
  (string
    (string_content) @injection.content)
  (encapsed_string
    (string_content) @injection.content)
])]=]
end

local function concat_expr(depth)
  if depth <= 1 then
    return leaf_encapsed_string()
  end
  return ([[
(binary_expression
  left: %s
  right: %s)
]]):format(concat_expr(depth - 1), leaf_encapsed_string())
end

local function render_name_pattern(rule)
  local blocks = {}

  blocks[#blocks + 1] = ([[
(
  (const_declaration
    (const_element
      (name) @_name
      %s))
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(nowdoc_string(), q(rule.pattern), q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (expression_statement
    (assignment_expression
      left: (variable_name
        (name) @_name)
      right: %s))
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(nowdoc_string(), q(rule.pattern), q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (expression_statement
    (assignment_expression
      left: (variable_name
        (name) @_name)
      right: %s))
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(leaf_encapsed_string(), q(rule.pattern), q(rule.lang))

  for depth = 2, MAX_CONCAT_DEPTH do
    add(
      blocks,
      ([[
(
  (expression_statement
    (assignment_expression
      left: (variable_name
        (name) @_name)
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
  (member_call_expression
    object: (variable_name)
    name: (name) @_fn
    arguments: (arguments
      .
      (argument
        %s)))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(nowdoc_string(), fn, q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (member_call_expression
    object: (variable_name)
    name: (name) @_fn
    arguments: (arguments
      .
      (argument
        (string
          (string_content) @injection.content))))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(fn, q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (member_call_expression
    object: (variable_name)
    name: (name) @_fn
    arguments: (arguments
      .
      (argument
        %s)))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(leaf_encapsed_string(), fn, q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (function_call_expression
    (name) @_fn
    (arguments
      .
      (argument
        %s)))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(leaf_string_or_encapsed(), fn, q(rule.lang))

  for depth = 2, MAX_CONCAT_DEPTH do
    add(
      blocks,
      ([[
(
  (member_call_expression
    object: (variable_name)
    name: (name) @_fn
    arguments: (arguments
      .
      (argument
        %s)))
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

  for _, rule in ipairs(rules or {}) do
    local rendered = {}

    if rule.kind == "name_pattern" then
      rendered = render_name_pattern(rule)
    elseif rule.kind == "call" then
      rendered = render_call(rule)
    else
      return nil, ("unsupported php rule kind: %s"):format(rule.kind)
    end

    vim.list_extend(blocks, rendered)
  end

  return table.concat(blocks, "\n")
end

return M
