local M = {}

local util = require("ts_inject.host._util")

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
    blocks[#blocks + 1] = ([[
(
  (expression_statement
    (assignment
      left: (identifier)
      right: (string
        (string_content) @injection.content)))
  (#lua-match? @injection.content %s)
  (#set! injection.language %s))
]]):format(util.q(pattern), util.q(rule.lang))

    blocks[#blocks + 1] = ([[
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

M.build = util.build_dispatcher({
  header = "; extends",
  renderers = {
    name_pattern = render_name_pattern,
    content_prefix = render_content_prefix,
    call = render_call,
  },
})

return M
