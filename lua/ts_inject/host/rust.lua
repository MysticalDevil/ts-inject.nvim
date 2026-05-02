local M = {}

-- Static preamble that overrides nvim-treesitter's default macro injection
-- so sqlx macros can be injected with SQL/GraphQL instead of rust.
local static_preamble = [[
; Rust injections are defined as a full query so we can override the default
; macro token-tree injection from nvim-treesitter for sqlx SQL macros.

(macro_invocation
  macro: [
    (scoped_identifier
      name: (_) @_macro_name)
    (identifier) @_macro_name
  ]
  (token_tree) @injection.content
  (#not-any-of? @_macro_name "slint" "html" "json" "query" "query_as" "query_scalar" "graphql" "gql" "sql_query")
  (#set! injection.language "rust")
  (#set! injection.include-children))

(macro_invocation
  macro: [
    (scoped_identifier
      name: (_) @injection.language)
    (identifier) @injection.language
  ]
  (token_tree) @injection.content
  (#any-of? @injection.language "slint" "html" "json")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children))

(macro_definition
  (macro_rule
    left: (token_tree_pattern) @injection.content
    (#set! injection.language "rust")))

(macro_definition
  (macro_rule
    right: (token_tree) @injection.content
    (#set! injection.language "rust")))

([
  (line_comment)
  (block_comment)
] @injection.content
  (#set! injection.language "comment"))

(call_expression
  function: (scoped_identifier
    path: (identifier) @_regex
    (#any-of? @_regex "Regex" "RegexBuilder")
    name: (identifier) @_new
    (#eq? @_new "new"))
  arguments: (arguments
    (raw_string_literal
      (string_content) @injection.content))
  (#set! injection.language "regex"))

(call_expression
  function: (scoped_identifier
    path: (scoped_identifier
      (identifier) @_regex
      (#any-of? @_regex "Regex" "RegexBuilder") .)
    name: (identifier) @_new
    (#eq? @_new "new"))
  arguments: (arguments
    (raw_string_literal
      (string_content) @injection.content))
  (#set! injection.language "regex"))

(call_expression
  function: (scoped_identifier
    path: (identifier) @_regex
    (#any-of? @_regex "RegexSet" "RegexSetBuilder")
    name: (identifier) @_new
    (#eq? @_new "new"))
  arguments: (arguments
    (array_expression
      (raw_string_literal
        (string_content) @injection.content)))
  (#set! injection.language "regex"))

(call_expression
  function: (scoped_identifier
    path: (scoped_identifier
      (identifier) @_regex
      (#any-of? @_regex "RegexSet" "RegexSetBuilder") .)
    name: (identifier) @_new
    (#eq? @_new "new"))
  arguments: (arguments
    (array_expression
      (raw_string_literal
        (string_content) @injection.content)))
  (#set! injection.language "regex"))

((block_comment) @injection.content
  (#match? @injection.content "/\\*!([a-zA-Z]+:)?re2c")
  (#set! injection.language "re2c"))
]]

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

local function string_literal_query()
  return [[
[
  (string_literal
    (string_content) @injection.content)
  (raw_string_literal
    (string_content) @injection.content)
]
]]
end

local function render_name_pattern(rule)
  return {
    ([[
(
  (let_declaration
    pattern: (identifier) @_name
    value: %s)
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(string_literal_query(), q(rule.pattern), q(rule.lang)),
  }
end

local function call_function_pattern()
  return [[
[
  (identifier) @_fn
  (field_expression
    field: (field_identifier) @_fn)
  (scoped_identifier
    name: (identifier) @_fn)
  (generic_function
    function: [
      (identifier) @_fn
      (scoped_identifier
        name: (identifier) @_fn)
    ])
]
]]
end

local function render_call(rule)
  local fn = join_fn_list(rule.fn)
  local arg_index = rule.arg_index or 1

  local args_prefix = {}
  for _ = 1, arg_index - 1 do
    table.insert(args_prefix, "      .")
    table.insert(args_prefix, "      (_)")
  end
  table.insert(args_prefix, "      .")

  return {
    ([[
(
  (call_expression
    function: %s
    arguments: (arguments
%s
      [
        (string_literal
          (string_content) @injection.content)
        (raw_string_literal
          (string_content) @injection.content)
      ]
      . (_)*))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(call_function_pattern(), table.concat(args_prefix, "\n"), fn, q(rule.lang)),
  }
end

local function render_content_prefix(rule)
  local blocks = {}

  for _, pattern in ipairs(rule.patterns or {}) do
    blocks[#blocks + 1] = ([[
(
  (let_declaration
    pattern: (identifier)
    value: %s)
  (#lua-match? @injection.content %s)
  (#set! injection.language %s))
]]):format(string_literal_query(), q(pattern), q(rule.lang))

    blocks[#blocks + 1] = ([[
(
  (call_expression
    function: %s
    arguments: (arguments
      .
      %s
      . (_)*))
  (#lua-match? @injection.content %s)
  (#set! injection.language %s))
]]):format(call_function_pattern(), string_literal_query(), q(pattern), q(rule.lang))
  end

  return blocks
end

local function render_macro(rule)
  local fn = join_fn_list(rule.fn)

  return {
    ([[
(
  (macro_invocation
    macro: [
      (identifier) @_macro
      (scoped_identifier
        name: (identifier) @_macro)
    ]
    (token_tree
      [
        (string_literal
          (string_content) @injection.content)
        (raw_string_literal
          (string_content) @injection.content)
      ]
      . (_)*))
  (#any-of? @_macro %s)
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
    elseif rule.kind == "content_prefix" then
      rendered = render_content_prefix(rule)
    elseif rule.kind == "macro" then
      rendered = render_macro(rule)
    else
      return nil, ("unsupported rust rule kind: %s"):format(rule.kind)
    end

    vim.list_extend(blocks, rendered)
  end

  return static_preamble .. "\n" .. table.concat(blocks, "\n")
end

return M
