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

local function render_name_pattern(rule, opts)
  local max_concat_depth = opts and opts.max_concat_depth or MAX_CONCAT_DEPTH
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

  vim.list_extend(
    blocks,
    concat.expand(concat_expr, max_concat_depth, function(expr)
      return ([[
(
  (variable_declarator
    name: (identifier) @_name
    value: %s)
  (#lua-match? @_name %s)
  (#set! injection.combined)
  (#set! injection.language %s)
)
]]):format(expr, util.q(rule.pattern), util.q(rule.lang))
    end)
  )

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

local function render_call(rule, opts)
  local max_concat_depth = opts and opts.max_concat_depth or MAX_CONCAT_DEPTH
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

  vim.list_extend(
    blocks,
    concat.expand(concat_expr, max_concat_depth, function(expr)
      return ([[
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
]]):format(call_function_pattern(), expr, util.join_fn_list(rule.fn), util.q(rule.lang))
    end)
  )

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

M.build = util.build_dispatcher({
  header = "; extends",
  renderers = {
    name_pattern = render_name_pattern,
    call = render_call,
    template_tag = render_template_tag,
  },
})

return M
