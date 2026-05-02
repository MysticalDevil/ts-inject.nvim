local M = {}

local util = require("ts_inject.host._util")

local function render_name_pattern(rule)
  return {
    ([[
(
  (assignment
    left: (identifier) @_name
    right: (string
      (string_content) @injection.content))
  (#lua-match? @_name %s)
  (#set! injection.language %s)
)
]]):format(util.q(rule.pattern), util.q(rule.lang)),
    ([[
(
  (assignment
    left: (constant) @_name
    right: (string
      (string_content) @injection.content))
  (#lua-match? @_name %s)
  (#set! injection.language %s)
)
]]):format(util.q(rule.pattern), util.q(rule.lang)),
    ([[
(
  (_
    (assignment
      left: (identifier) @_name
      right: (heredoc_beginning))
    .
    (heredoc_body
      (heredoc_content) @injection.content))
  (#lua-match? @_name %s)
  (#set! injection.language %s)
)
]]):format(util.q(rule.pattern), util.q(rule.lang)),
    ([[
(
  (_
    (assignment
      left: (constant) @_name
      right: (heredoc_beginning))
    .
    (heredoc_body
      (heredoc_content) @injection.content))
  (#lua-match? @_name %s)
  (#set! injection.language %s)
)
]]):format(util.q(rule.pattern), util.q(rule.lang)),
  }
end

local function render_call(rule)
  local fn = util.join_fn_list(rule.fn)

  return {
    ([[
(
  (call
    method: (identifier) @_method
    arguments: (argument_list
      (string
        (string_content) @injection.content)))
  (#any-of? @_method %s)
  (#set! injection.language %s)
)
]]):format(fn, util.q(rule.lang)),
    ([[
(
  (call
    receiver: (_)
    method: (identifier) @_method
    arguments: (argument_list
      (string
        (string_content) @injection.content)))
  (#any-of? @_method %s)
  (#set! injection.language %s)
)
]]):format(fn, util.q(rule.lang)),
    ([[
(
  (_
    (call
      method: (identifier) @_method
      arguments: (argument_list
        (heredoc_beginning)))
    .
    (heredoc_body
      (heredoc_content) @injection.content))
  (#any-of? @_method %s)
  (#set! injection.language %s)
)
]]):format(fn, util.q(rule.lang)),
    ([[
(
  (_
    (call
      receiver: (_)
      method: (identifier) @_method
      arguments: (argument_list
        (heredoc_beginning)))
    .
    (heredoc_body
      (heredoc_content) @injection.content))
  (#any-of? @_method %s)
  (#set! injection.language %s)
)
]]):format(fn, util.q(rule.lang)),
  }
end

local function render_content_prefix(rule)
  local blocks = {}

  for _, pattern in ipairs(rule.patterns or {}) do
    blocks[#blocks + 1] = ([[
(
  (assignment
    left: (_)
    right: (string
      (string_content) @injection.content))
  (#lua-match? @injection.content %s)
  (#set! injection.language %s)
)
]]):format(util.q(pattern), util.q(rule.lang))

    blocks[#blocks + 1] = ([[
(
  (_
    (assignment
      left: (_)
      right: (heredoc_beginning))
    .
    (heredoc_body
      (heredoc_content) @injection.content))
  (#lua-match? @injection.content %s)
  (#set! injection.language %s)
)
]]):format(util.q(pattern), util.q(rule.lang))

    blocks[#blocks + 1] = ([[
(
  (call
    method: (identifier)
    arguments: (argument_list
      (string
        (string_content) @injection.content)))
  (#lua-match? @injection.content %s)
  (#set! injection.language %s)
)
]]):format(util.q(pattern), util.q(rule.lang))

    blocks[#blocks + 1] = ([[
(
  (call
    receiver: (_)
    method: (identifier)
    arguments: (argument_list
      (string
        (string_content) @injection.content)))
  (#lua-match? @injection.content %s)
  (#set! injection.language %s)
)
]]):format(util.q(pattern), util.q(rule.lang))

    blocks[#blocks + 1] = ([[
(
  (_
    (call
      method: (identifier)
      arguments: (argument_list
        (heredoc_beginning)))
    .
    (heredoc_body
      (heredoc_content) @injection.content))
  (#lua-match? @injection.content %s)
  (#set! injection.language %s)
)
]]):format(util.q(pattern), util.q(rule.lang))

    blocks[#blocks + 1] = ([[
(
  (_
    (call
      receiver: (_)
      method: (identifier)
      arguments: (argument_list
        (heredoc_beginning)))
    .
    (heredoc_body
      (heredoc_content) @injection.content))
  (#lua-match? @injection.content %s)
  (#set! injection.language %s)
)
]]):format(util.q(pattern), util.q(rule.lang))
  end

  return blocks
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
      return nil, ("unsupported ruby rule kind: %s"):format(rule.kind)
    end

    vim.list_extend(blocks, rendered)
  end

  return table.concat(blocks, "\n")
end

return M
