local M = {}

local util = require("ts_inject.host._util")

local MAX_CONCAT_DEPTH = 3

local function add(blocks, text)
  blocks[#blocks + 1] = text
end

local static_preamble = [[
(
  (comment) @_comment
  (binary_operator
    left: [(identifier) (alias)]
    operator: "="
    right: (string
      (quoted_content) @injection.content))
  (#lua-match? @_comment "^[ ]*#+[ ]*[Ss][Qq][Ll][ ]*$")
  (#set! injection.language "sql"))

(
  (comment) @_comment
  (binary_operator
    left: [(identifier) (alias)]
    operator: "="
    right: (binary_operator
      left: (string (quoted_content) @injection.content)
      operator: "<\>"
      right: (string (quoted_content) @injection.content)))
  (#lua-match? @_comment "^[ ]*#+[ ]*[Ss][Qq][Ll][ ]*$")
  (#set! injection.combined)
  (#set! injection.language "sql"))
]]

local function leaf_string()
  return [[(string
    (quoted_content) @injection.content)]]
end

local function leaf_sigil()
  return [[(sigil
    (quoted_content) @injection.content)]]
end

local concat = require("ts_inject.host._concat")

local concat_expr_left = concat.binary({
  node_name = "binary_operator",
  left_field = "left: ",
  right_field = "right: ",
  operator = "<\\>",
  direction = "left",
  leaf_fn = leaf_string,
  max_depth = MAX_CONCAT_DEPTH,
})

local concat_expr_right = concat.binary({
  node_name = "binary_operator",
  left_field = "left: ",
  right_field = "right: ",
  operator = "<\\>",
  direction = "right",
  leaf_fn = leaf_string,
  max_depth = MAX_CONCAT_DEPTH,
})

local function render_name_pattern(rule)
  local blocks = {}

  blocks[#blocks + 1] = ([[
(
  (binary_operator
    left: [(identifier) (alias)] @_name
    operator: "="
    right: %s)
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(leaf_string(), util.q(rule.pattern), util.q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (binary_operator
    left: [(identifier) (alias)] @_name
    operator: "="
    right: %s)
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(leaf_sigil(), util.q(rule.pattern), util.q(rule.lang))

  for depth = 2, MAX_CONCAT_DEPTH do
    add(
      blocks,
      ([[
(
  (binary_operator
    left: [(identifier) (alias)] @_name
    operator: "="
    right: %s)
  (#lua-match? @_name %s)
  (#set! injection.combined)
  (#set! injection.language %s))
]]):format(concat_expr_left(depth), util.q(rule.pattern), util.q(rule.lang))
    )
    add(
      blocks,
      ([[
(
  (binary_operator
    left: [(identifier) (alias)] @_name
    operator: "="
    right: %s)
  (#lua-match? @_name %s)
  (#set! injection.combined)
  (#set! injection.language %s))
]]):format(concat_expr_right(depth), util.q(rule.pattern), util.q(rule.lang))
    )
  end

  return blocks
end

local function render_call(rule)
  local fn = util.join_fn_list(rule.fn)
  local blocks = {}

  blocks[#blocks + 1] = ([[
(
  (call
    (dot
      (identifier)
      "."
      (identifier) @_fn)
    (arguments
      %s))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(leaf_string(), fn, util.q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (call
    (dot
      (identifier)
      "."
      (identifier) @_fn)
    (arguments
      %s))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(leaf_sigil(), fn, util.q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (call
    (dot
      (alias)
      "."
      (identifier) @_fn)
    (arguments
      (_)
      %s))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(leaf_string(), fn, util.q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (call
    (dot
      (alias)
      "."
      (identifier) @_fn)
    (arguments
      (_)
      %s))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(leaf_sigil(), fn, util.q(rule.lang))

  for depth = 2, MAX_CONCAT_DEPTH do
    add(
      blocks,
      ([[
(
  (call
    (dot
      (identifier)
      "."
      (identifier) @_fn)
    (arguments
      %s))
  (#any-of? @_fn %s)
  (#set! injection.combined)
  (#set! injection.language %s))
]]):format(concat_expr_left(depth), fn, util.q(rule.lang))
    )
    add(
      blocks,
      ([[
(
  (call
    (dot
      (identifier)
      "."
      (identifier) @_fn)
    (arguments
      %s))
  (#any-of? @_fn %s)
  (#set! injection.combined)
  (#set! injection.language %s))
]]):format(concat_expr_right(depth), fn, util.q(rule.lang))
    )
  end

  return blocks
end

function M.build(rules, _opts)
  local blocks = {}

  for _, rule in ipairs(rules or {}) do
    local rendered = {}

    if rule.kind == "name_pattern" then
      rendered = render_name_pattern(rule)
    elseif rule.kind == "call" then
      rendered = render_call(rule)
    else
      return nil, ("unsupported elixir rule kind: %s"):format(rule.kind)
    end

    vim.list_extend(blocks, rendered)
  end

  return "; extends\n" .. static_preamble .. "\n" .. table.concat(blocks, "\n")
end

return M
