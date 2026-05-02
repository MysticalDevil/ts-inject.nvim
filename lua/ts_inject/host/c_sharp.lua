local M = {}

local MAX_CONCAT_DEPTH = 5

local function q(text)
  return string.format("%q", text)
end

local function add(blocks, text)
  blocks[#blocks + 1] = text
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
  (invocation_expression
    (member_access_expression
      (identifier) @_class
      .
      (identifier) @_method)
    (argument_list
      "("
      (argument)
      ","
      (argument
        (string_literal
          (string_literal_content) @injection.content))))
  (#eq? @_class "Regex")
  (#any-of? @_method "Match" "Replace" "IsMatch" "Split" "Matches")
  (#set! injection.language "regex"))

(
  (object_creation_expression
    (identifier) @_class
    (argument_list
      "("
      .
      (argument
        (string_literal
          (string_literal_content) @injection.content))))
  (#eq? @_class "Regex")
  (#set! injection.language "regex"))
]]

local function leaf_string()
  return [[(string_literal
    (string_literal_content) @injection.content)]]
end

local function verbatim_string()
  return [[(verbatim_string_literal) @injection.content]]
end

local function concat_expr(depth)
  if depth <= 1 then
    return leaf_string()
  end
  return ([[
(binary_expression
  left: %s
  right: %s)
]]):format(concat_expr(depth - 1), leaf_string())
end

local function render_name_pattern(rule)
  local blocks = {}

  blocks[#blocks + 1] = ([[
(
  (local_declaration_statement
    (modifier)
    (variable_declaration
      (_)
      (variable_declarator
        (identifier) @_name
        %s)))
  (#lua-match? @_name %s)
  (#offset! @injection.content 0 2 0 -1)
  (#set! injection.language %s))
]]):format(verbatim_string(), q(rule.pattern), q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (local_declaration_statement
    (variable_declaration
      (_)
      (variable_declarator
        (identifier) @_name
        %s)))
  (#lua-match? @_name %s)
  (#offset! @injection.content 0 2 0 -1)
  (#set! injection.language %s))
]]):format(verbatim_string(), q(rule.pattern), q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (local_declaration_statement
    (variable_declaration
      (_)
      (variable_declarator
        (identifier) @_name
        %s)))
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(leaf_string(), q(rule.pattern), q(rule.lang))

  for depth = 2, MAX_CONCAT_DEPTH do
    add(
      blocks,
      ([[
(
  (local_declaration_statement
    (variable_declaration
      (_)
      (variable_declarator
        (identifier) @_name
        %s)))
  (#lua-match? @_name %s)
  (#set! injection.combined)
  (#set! injection.language %s))
]]):format(concat_expr(depth), q(rule.pattern), q(rule.lang))
    )
  end

  return blocks
end

local function render_call(rule)
  local fn = join_fn_list(rule.fn)
  local blocks = {}

  blocks[#blocks + 1] = ([[
(
  (invocation_expression
    (member_access_expression
      (identifier)
      .
      (identifier) @_fn)
    (argument_list
      "("
      .
      (argument
        %s)
      . [
        ","
        ")"
      ]))
  (#any-of? @_fn %s)
  (#offset! @injection.content 0 2 0 -1)
  (#set! injection.language %s))
]]):format(verbatim_string(), fn, q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (invocation_expression
    (member_access_expression
      (identifier)
      .
      (identifier) @_fn)
    (argument_list
      "("
      .
      (argument
        %s)
      . [
        ","
        ")"
      ]))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(leaf_string(), fn, q(rule.lang))

  for depth = 2, MAX_CONCAT_DEPTH do
    add(
      blocks,
      ([[
(
  (invocation_expression
    (member_access_expression
      (identifier)
      .
      (identifier) @_fn)
    (argument_list
      "("
      .
      (argument
        %s)
      . [
        ","
        ")"
      ]))
  (#any-of? @_fn %s)
  (#set! injection.combined)
  (#set! injection.language %s))
]]):format(concat_expr(depth), fn, q(rule.lang))
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
      return nil, ("unsupported c_sharp rule kind: %s"):format(rule.kind)
    end

    vim.list_extend(blocks, rendered)
  end

  return "; extends\n" .. static_preamble .. "\n" .. table.concat(blocks, "\n")
end

return M
