local M = {}

local util = require("ts_inject.host._util")

local HEREDOC_BODY = [[
    .
    (heredoc_body
      (heredoc_content) @injection.content)]]

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
%s)
  (#lua-match? @_name %s)
  (#set! injection.language %s)
)
]]):format(HEREDOC_BODY, util.q(rule.pattern), util.q(rule.lang)),
    ([[
(
  (_
    (assignment
      left: (constant) @_name
      right: (heredoc_beginning))
%s)
  (#lua-match? @_name %s)
  (#set! injection.language %s)
)
]]):format(HEREDOC_BODY, util.q(rule.pattern), util.q(rule.lang)),
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
%s)
  (#any-of? @_method %s)
  (#set! injection.language %s)
)
]]):format(HEREDOC_BODY, fn, util.q(rule.lang)),
    ([[
(
  (_
    (call
      receiver: (_)
      method: (identifier) @_method
      arguments: (argument_list
        (heredoc_beginning)))
%s)
  (#any-of? @_method %s)
  (#set! injection.language %s)
)
]]):format(HEREDOC_BODY, fn, util.q(rule.lang)),
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
%s)
  (#lua-match? @injection.content %s)
  (#set! injection.language %s)
)
]]):format(HEREDOC_BODY, util.q(pattern), util.q(rule.lang))

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
        (heredoc_beginning))
%s)
  (#lua-match? @injection.content %s)
  (#set! injection.language %s)
)
]]):format(HEREDOC_BODY, util.q(pattern), util.q(rule.lang))

    blocks[#blocks + 1] = ([[
(
  (_
    (call
      receiver: (_)
      method: (identifier)
      arguments: (argument_list
        (heredoc_beginning))
%s)
  (#lua-match? @injection.content %s)
  (#set! injection.language %s)
)
]]):format(HEREDOC_BODY, util.q(pattern), util.q(rule.lang))
  end

  return blocks
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
