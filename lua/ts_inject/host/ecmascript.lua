local M = {}

local util = require("ts_inject.host._util")

local MAX_CONCAT_DEPTH = 5

local function leaf_string()
  return [[(string
  (string_fragment) @injection.content)]]
end

local concat = require("ts_inject.host._concat")

local concat_expr = concat.binary({
  node_name = "binary_expression",
  left_field = "left: ",
  right_field = "right: ",
  direction = "left",
  leaf_fn = leaf_string,
  max_depth = MAX_CONCAT_DEPTH,
})

local function render_concat(depth)
  return concat_expr(depth)
end

local function add(blocks, text)
  blocks[#blocks + 1] = text
end

local function render_name_pattern(rule, max_concat_depth)
  max_concat_depth = max_concat_depth or MAX_CONCAT_DEPTH
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
]]):format(util.q(rule.pattern), util.q(rule.lang)),
    ([[
(
  (variable_declarator
    name: (identifier) @_name
    value: (string
      (string_fragment) @injection.content))
  (#lua-match? @_name %s)
  (#set! injection.language %s)
)
]]):format(util.q(rule.pattern), util.q(rule.lang)),
  }

  for depth = 2, max_concat_depth do
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
]]):format(render_concat(depth), util.q(rule.pattern), util.q(rule.lang))
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

local function render_call(rule, max_concat_depth)
  max_concat_depth = max_concat_depth or MAX_CONCAT_DEPTH
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
]]):format(call_function_pattern(), util.join_fn_list(rule.fn), util.q(rule.lang)),
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
]]):format(call_function_pattern(), util.join_fn_list(rule.fn), util.q(rule.lang)),
  }

  for depth = 2, max_concat_depth do
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
]]):format(call_function_pattern(), render_concat(depth), util.join_fn_list(rule.fn), util.q(rule.lang))
    )
  end

  return blocks
end

local function render_template_tag(rule)
  return {
    ([[
(
  (call_expression
    function: [
      (identifier) @_fn
      (member_expression
        property: (property_identifier) @_fn)
    ]
    arguments: (template_string) @injection.content)
  (#any-of? @_fn %s)
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language %s)
)
]]):format(util.join_fn_list(rule.fn), util.q(rule.lang)),
  }
end

function M.build(rules, opts)
  local max_concat_depth = opts and opts.max_concat_depth or MAX_CONCAT_DEPTH
  local blocks = { "; extends" }

  for _, rule in ipairs(rules or {}) do
    local rendered = {}

    if rule.kind == "name_pattern" then
      rendered = render_name_pattern(rule, max_concat_depth)
    elseif rule.kind == "call" then
      rendered = render_call(rule, max_concat_depth)
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
