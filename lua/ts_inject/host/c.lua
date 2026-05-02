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
(
  (gnu_asm_expression
    [
      (string_literal
        (string_content) @injection.content)+
      (concatenated_string
        (string_literal
          (string_content) @injection.content)+)
    ])
  (#set! injection.language "asm"))

(
  (call_expression
    function: (identifier) @_fn
    arguments: (argument_list
      .
      (_)
      .
      (string_literal
        (string_content) @injection.content)))
  (#eq? @_fn "regcomp")
  (#set! injection.language "regex"))
]]

local function string_value()
  return [=[([
  (string_literal
    (string_content) @injection.content)+
  (concatenated_string
    (string_literal
      (string_content) @injection.content)+)
  (parenthesized_expression
    (string_literal
      (string_content) @injection.content)+)
  (parenthesized_expression
    (concatenated_string
      (string_literal
        (string_content) @injection.content)+))
  (cast_expression
    value: (string_literal
      (string_content) @injection.content)+)
  (cast_expression
    value: (concatenated_string
      (string_literal
        (string_content) @injection.content)+))
])]=]
end

local function backslash_value()
  return [[(string_literal
    (string_content) @injection.content
    (escape_sequence)
    (string_content) @injection.content
    (escape_sequence)
    (string_content) @injection.content)]]
end

local function render_name_pattern(rule)
  local blocks = {}

  blocks[#blocks + 1] = ([[
(
  (declaration
    declarator: (init_declarator
      declarator: (_) @_decl
      value: %s))
  (#lua-match? @_decl %s)
  (#set! injection.language %s))
]]):format(string_value(), q(rule.pattern), q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (declaration
    declarator: (init_declarator
      declarator: (_) @_decl
      value: %s))
  (#lua-match? @_decl %s)
  (#set! injection.combined)
  (#set! injection.language %s))
]]):format(backslash_value(), q(rule.pattern), q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (assignment_expression
    left: (identifier) @_name
    right: %s)
  (#lua-match? @_name %s)
  (#set! injection.language %s)
)
]]):format(string_value(), q(rule.pattern), q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (assignment_expression
    left: (identifier) @_name
    right: %s)
  (#lua-match? @_name %s)
  (#set! injection.combined)
  (#set! injection.language %s)
)
]]):format(backslash_value(), q(rule.pattern), q(rule.lang))

  return blocks
end

local function render_call(rule)
  local fn = join_fn_list(rule.fn)
  local arg_index = rule.arg_index or 2
  local blocks = {}

  local args_prefix = {}
  if arg_index == 1 then
    table.insert(args_prefix, "      .")
  else
    for _ = 1, arg_index - 1 do
      table.insert(args_prefix, "      (_)")
      table.insert(args_prefix, "      .")
    end
  end

  blocks[#blocks + 1] = ([[
(
  (call_expression
    function: (identifier) @_fn
    arguments: (argument_list
%s
      %s))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(table.concat(args_prefix, "\n"), string_value(), fn, q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (call_expression
    function: (identifier) @_fn
    arguments: (argument_list
%s
      %s))
  (#any-of? @_fn %s)
  (#set! injection.combined)
  (#set! injection.language %s))
]]):format(table.concat(args_prefix, "\n"), backslash_value(), fn, q(rule.lang))

  return blocks
end

function M.build(rules, _opts)
  local blocks = { "; extends" }

  for _, rule in ipairs(rules or {}) do
    local rendered = {}

    if rule.kind == "name_pattern" then
      rendered = render_name_pattern(rule)
    elseif rule.kind == "call" then
      rendered = render_call(rule)
    else
      return nil, ("unsupported c rule kind: %s"):format(rule.kind)
    end

    vim.list_extend(blocks, rendered)
  end

  return table.concat(blocks, "\n") .. "\n" .. static_preamble
end

return M
