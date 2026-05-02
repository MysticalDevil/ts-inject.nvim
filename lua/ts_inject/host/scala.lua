local M = {}

local util = require("ts_inject.host._util")

local static_preamble = [[
; Regex: "...".r suffix
(
  (field_expression
    (string) @injection.content
    (identifier) @_suffix)
  (#eq? @_suffix "r")
  (#not-lua-match? @injection.content "^\"\"\"")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "regex"))

; Regex: new Regex("...")
(
  (instance_expression
    (type_identifier) @_class
    (arguments
      (string) @injection.content))
  (#eq? @_class "Regex")
  (#not-lua-match? @injection.content "^\"\"\"")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "regex"))
]]

local function render_name_pattern(rule)
  local blocks = {}
  local plain = "0 1 0 -1"
  local triple = "0 3 0 -3"

  blocks[#blocks + 1] = ([[
(
  (val_definition
    pattern: (identifier) @_name
    value: (string) @injection.content)
  (#lua-match? @_name %s)
  (#offset! @injection.content %s)
  (#not-lua-match? @injection.content "^\"\"\"")
  (#set! injection.language %s))
]]):format(util.q(rule.pattern), plain, util.q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (val_definition
    pattern: (identifier) @_name
    value: (string) @injection.content)
  (#lua-match? @_name %s)
  (#offset! @injection.content %s)
  (#lua-match? @injection.content "^\"\"\"")
  (#set! injection.language %s))
]]):format(util.q(rule.pattern), triple, util.q(rule.lang))

  return blocks
end

local function render_call(rule)
  local fn = util.join_fn_list(rule.fn)
  local plain = "0 1 0 -1"
  local triple = "0 3 0 -3"

  return {
    ([[
(
  (call_expression
    function: (field_expression
      field: (identifier) @_method)
    arguments: (arguments
      (string) @injection.content))
  (#any-of? @_method %s)
  (#offset! @injection.content %s)
  (#not-lua-match? @injection.content "^\"\"\"")
  (#set! injection.language %s))
]]):format(fn, plain, util.q(rule.lang)),
    ([[
(
  (call_expression
    function: (field_expression
      field: (identifier) @_method)
    arguments: (arguments
      (string) @injection.content))
  (#any-of? @_method %s)
  (#offset! @injection.content %s)
  (#lua-match? @injection.content "^\"\"\"")
  (#set! injection.language %s))
]]):format(fn, triple, util.q(rule.lang)),
  }
end

M.build = util.build_dispatcher({
  renderers = {
    name_pattern = render_name_pattern,
    call = render_call,
  },
  static_preamble = static_preamble,
  preamble_first = true,
})

return M
