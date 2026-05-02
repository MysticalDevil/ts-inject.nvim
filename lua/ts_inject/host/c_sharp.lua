local M = {}

local util = require("ts_inject.host._util")

local MAX_CONCAT_DEPTH = 5

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

local concat = require("ts_inject.host._concat")

local concat_expr = concat.binary({
  node_name = "binary_expression",
  left_field = "left: ",
  right_field = "right: ",
  direction = "left",
  leaf_fn = leaf_string,
  max_depth = MAX_CONCAT_DEPTH,
})

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
]]):format(verbatim_string(), util.q(rule.pattern), util.q(rule.lang))

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
]]):format(verbatim_string(), util.q(rule.pattern), util.q(rule.lang))

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
]]):format(leaf_string(), util.q(rule.pattern), util.q(rule.lang))

  vim.list_extend(
    blocks,
    concat.expand(concat_expr, MAX_CONCAT_DEPTH, function(expr)
      return ([[
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
]]):format(expr, util.q(rule.pattern), util.q(rule.lang))
    end)
  )

  return blocks
end

local function render_call(rule)
  local fn = util.join_fn_list(rule.fn)
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
]]):format(verbatim_string(), fn, util.q(rule.lang))

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
]]):format(leaf_string(), fn, util.q(rule.lang))

  vim.list_extend(
    blocks,
    concat.expand(concat_expr, MAX_CONCAT_DEPTH, function(expr)
      return ([[
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
]]):format(expr, fn, util.q(rule.lang))
    end)
  )

  return blocks
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
