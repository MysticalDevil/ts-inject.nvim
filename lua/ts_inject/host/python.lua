local M = {}

local util = require("ts_inject.host._util")

local function add_block(blocks, text)
  blocks[#blocks + 1] = text
end

local function render_name_pattern(rule)
  return {
    ([[
(
  (expression_statement
    (assignment
      left: (identifier) @_name
      right: (string
        (string_content) @injection.content)))
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(util.q(rule.pattern), util.q(rule.lang)),
    ([[
(
  (expression_statement
    (assignment
      left: (identifier) @_name
      right: (parenthesized_expression
        (concatenated_string
          (string
            (string_content) @injection.content)+))))
  (#lua-match? @_name %s)
  (#set! injection.combined)
  (#set! injection.language %s))
]]):format(util.q(rule.pattern), util.q(rule.lang)),
  }
end

local function render_content_prefix(rule)
  local blocks = {}

  for _, pattern in ipairs(rule.patterns or {}) do
    add_block(
      blocks,
      ([[
(
  (expression_statement
    (assignment
      left: (identifier)
      right: (string
        (string_content) @injection.content)))
  (#lua-match? @injection.content %s)
  (#set! injection.language %s))
]]):format(util.q(pattern), util.q(rule.lang))
    )

    add_block(
      blocks,
      ([[
(
  (expression_statement
    (assignment
      left: (identifier)
      right: (parenthesized_expression
        (concatenated_string
          (string
            (string_content) @injection.content)+))))
  (#any-lua-match? @injection.content %s)
  (#set! injection.combined)
  (#set! injection.language %s))
]]):format(util.q(pattern), util.q(rule.lang))
    )
  end

  return blocks
end

local function render_call(rule)
  local fn = util.join_fn_list(rule.fn)

  return {
    ([[
(
  (expression_statement
    (call
      function: (attribute
        attribute: (identifier) @_fn)
      arguments: (argument_list
        (string
          (string_content) @injection.content)
        . (_)*)))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(fn, util.q(rule.lang)),
    ([[
(
  (expression_statement
    (call
      function: (attribute
        attribute: (identifier) @_fn)
      arguments: (argument_list
        (concatenated_string
          (string
            (string_content) @injection.content)+)
        . (_)*)))
  (#any-of? @_fn %s)
  (#set! injection.combined)
  (#set! injection.language %s))
]]):format(fn, util.q(rule.lang)),
    ([[
(
  (expression_statement
    (call
      function: (attribute
        attribute: (identifier) @_fn)
      arguments: (argument_list
        (parenthesized_expression
          (concatenated_string
            (string
              (string_content) @injection.content)+))
        . (_)*)))
  (#any-of? @_fn %s)
  (#set! injection.combined)
  (#set! injection.language %s))
]]):format(fn, util.q(rule.lang)),
  }
end

function M.build(rules, _opts)
  local blocks = { "; extends" }

  for _, rule in ipairs(rules or {}) do
    local rendered = {}

    if rule.kind == "name_pattern" then
      rendered = render_name_pattern(rule)
    elseif rule.kind == "content_prefix" then
      rendered = render_content_prefix(rule)
    elseif rule.kind == "call" then
      rendered = render_call(rule)
    else
      return nil, ("unsupported python rule kind: %s"):format(rule.kind)
    end

    vim.list_extend(blocks, rendered)
  end

  return table.concat(blocks, "\n\n")
end

return M
