local M = {}

local util = require("ts_inject.host._util")

local MAX_CONCAT_DEPTH = 5

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

local concat = require("ts_inject.host._concat")

local concat_expr = concat.binary({
  node_name = "binary_expression",
  left_field = "left: ",
  right_field = "right: ",
  direction = "left",
  leaf_fn = leaf_encapsed_string,
  max_depth = MAX_CONCAT_DEPTH,
})

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
]]):format(nowdoc_string(), util.q(rule.pattern), util.q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (expression_statement
    (assignment_expression
      left: (variable_name
        (name) @_name)
      right: %s))
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(nowdoc_string(), util.q(rule.pattern), util.q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (expression_statement
    (assignment_expression
      left: (variable_name
        (name) @_name)
      right: %s))
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(leaf_encapsed_string(), util.q(rule.pattern), util.q(rule.lang))

  vim.list_extend(
    blocks,
    concat.expand(concat_expr, MAX_CONCAT_DEPTH, function(expr)
      return ([[
(
  (expression_statement
    (assignment_expression
      left: (variable_name
        (name) @_name)
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
  (member_call_expression
    object: (variable_name)
    name: (name) @_fn
    arguments: (arguments
      .
      (argument
        %s)))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(nowdoc_string(), fn, util.q(rule.lang))

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
]]):format(fn, util.q(rule.lang))

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
]]):format(leaf_encapsed_string(), fn, util.q(rule.lang))

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
]]):format(leaf_string_or_encapsed(), fn, util.q(rule.lang))

  vim.list_extend(
    blocks,
    concat.expand(concat_expr, MAX_CONCAT_DEPTH, function(expr)
      return ([[
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
]]):format(expr, fn, util.q(rule.lang))
    end)
  )

  return blocks
end

M.build = util.build_dispatcher({
  header = "; extends",
  renderers = {
    name_pattern = render_name_pattern,
    call = render_call,
  },
})

return M
