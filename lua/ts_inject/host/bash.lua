local M = {}

local util = require("ts_inject.host._util")

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
]]):format(util.q(rule.pattern), util.q(rule.lang)),
    ([[
(
  (variable_assignment
    name: (variable_name) @_name
    value: (concatenation
      (string
        (string_content) @injection.content)+))
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(util.q(rule.pattern), util.q(rule.lang)),
  }
end

local function render_call(rule)
  local fn = util.join_fn_list(rule.fn)
  return {
    ([[
(
  (command
    name: (command_name (word) @_cmd)
    argument: (string
      (string_content) @injection.content))
  (#any-of? @_cmd %s)
  (#set! injection.language %s))
]]):format(fn, util.q(rule.lang)),
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
]]):format(fn, util.q(rule.lang)),
  }
end

M.build = util.build_dispatcher({
  header = "; extends",
  renderers = {
    name_pattern = render_name_pattern,
    call = render_call,
  },
  static_preamble = static_preamble,
  preamble_first = true,
})

return M
