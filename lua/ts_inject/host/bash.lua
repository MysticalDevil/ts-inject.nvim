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

local static_preamble = [[
((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
 (#eq? @_lang "SQL")
 (#set! injection.language "sql"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
 (#eq? @_lang "PY")
 (#set! injection.language "python"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
 (#eq? @_lang "LUA")
 (#set! injection.language "lua"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
 (#eq? @_lang "JS")
 (#set! injection.language "javascript"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
 (#eq? @_lang "TS")
 (#set! injection.language "typescript"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
 (#any-of? @_lang "RB" "RUBY")
 (#set! injection.language "ruby"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
 (#any-of? @_lang "PL" "PERL")
 (#set! injection.language "perl"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
 (#any-of? @_lang "GRAPHQL" "GQL")
 (#set! injection.language "graphql"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
 (#eq? @_lang "JSON")
 (#set! injection.language "json"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
 (#any-of? @_lang "REGEX" "RE")
 (#set! injection.language "regex"))

(
  (herestring_redirect
    (string
      (string_content) @injection.content))
  (#set! injection.language "sql"))
]]

local function render_name_pattern(rule)
  return {
    ([[
(
  (variable_assignment
    name: (variable_name) @_name
    value: (string
      (string_content) @injection.content))
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(q(rule.pattern), q(rule.lang)),
    ([[
(
  (variable_assignment
    name: (variable_name) @_name
    value: (concatenation
      (string
        (string_content) @injection.content)+))
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(q(rule.pattern), q(rule.lang)),
  }
end

local function render_call(rule)
  local fn = join_fn_list(rule.fn)
  return {
    ([[
(
  (command
    name: (command_name (word) @_cmd)
    argument: (string
      (string_content) @injection.content))
  (#any-of? @_cmd %s)
  (#set! injection.language %s))
]]):format(fn, q(rule.lang)),
    ([[
(
  (command
    name: (command_name (word) @_cmd)
    argument: (word) @_flag
    argument: (string
      (string_content) @injection.content))
  (#any-of? @_cmd %s)
  (#any-of? @_flag "-c" "-e" "--command" "--execute")
  (#set! injection.language %s))
]]):format(fn, q(rule.lang)),
  }
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
      return nil, ("unsupported bash rule kind: %s"):format(rule.kind)
    end

    vim.list_extend(blocks, rendered)
  end

  return "; extends\n" .. static_preamble .. "\n" .. table.concat(blocks, "\n")
end

return M
