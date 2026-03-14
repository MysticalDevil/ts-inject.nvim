local M = {}

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
]]):format(q(rule.pattern), q(rule.lang)),
    ([[
(
  (assignment
    left: (constant) @_name
    right: (string
      (string_content) @injection.content))
  (#lua-match? @_name %s)
  (#set! injection.language %s)
)
]]):format(q(rule.pattern), q(rule.lang)),
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
]]):format(q(rule.pattern), q(rule.lang)),
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
]]):format(q(rule.pattern), q(rule.lang)),
  }
end

local function render_call(rule)
  local fn = join_fn_list(rule.fn)

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
]]):format(fn, q(rule.lang)),
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
]]):format(fn, q(rule.lang)),
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
]]):format(fn, q(rule.lang)),
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
]]):format(fn, q(rule.lang)),
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
    else
      return nil, ("unsupported ruby rule kind: %s"):format(rule.kind)
    end

    vim.list_extend(blocks, rendered)
  end

  return table.concat(blocks, "\n")
end

return M
