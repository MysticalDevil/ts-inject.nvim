local M = {}

local util = require("ts_inject.host._util")

local MAX_CONCAT_DEPTH = 5

local function add(blocks, text)
  blocks[#blocks + 1] = text
end

local static_preamble = [[
(
  (_
    [
      (line_comment) @_marker
      (block_comment) @_marker
    ]
    .
    (local_variable_declaration
      declarator: (variable_declarator
        value: [
          (string_literal
            (string_fragment) @injection.content)
          (string_literal
            (multiline_string_fragment) @injection.content)
          (binary_expression
            left: (string_literal
              (string_fragment) @injection.content)
            right: (string_literal
              (string_fragment) @injection.content))
          (binary_expression
            left: (binary_expression
              left: (string_literal
                (string_fragment) @injection.content)
              right: (string_literal
                (string_fragment) @injection.content))
            right: (string_literal
              (string_fragment) @injection.content))
        ])))
  (#lua-match? @_marker "[Ss][Qq][Ll]")
  (#set! injection.language "sql"))

(
  (local_variable_declaration
    declarator: (variable_declarator
      [
        (line_comment) @_marker
        (block_comment) @_marker
      ]
      value: [
        (string_literal
          (string_fragment) @injection.content)
        (string_literal
          (multiline_string_fragment) @injection.content)
        (binary_expression
          left: (string_literal
            (string_fragment) @injection.content)
          right: (string_literal
            (string_fragment) @injection.content))
        (binary_expression
          left: (binary_expression
            left: (string_literal
              (string_fragment) @injection.content)
            right: (string_literal
              (string_fragment) @injection.content))
          right: (string_literal
            (string_fragment) @injection.content))
      ]))
  (#lua-match? @_marker "[Ss][Qq][Ll]")
  (#set! injection.language "sql"))

(
  (annotation
    name: (identifier) @_annotation
    arguments: (annotation_argument_list
      (string_literal
        (string_fragment) @injection.content)))
  (#any-of? @_annotation "Select" "Insert" "Update" "Delete")
  (#set! injection.language "sql"))

(
  (annotation
    name: (identifier) @_annotation
    arguments: (annotation_argument_list
      (element_value_array_initializer
        (string_literal
          (string_fragment) @injection.content)+)))
  (#any-of? @_annotation "Select" "Insert" "Update" "Delete")
  (#set! injection.language "sql"))

(
  (annotation
    name: (identifier) @_annotation
    arguments: (annotation_argument_list
      (element_value_pair
        key: (identifier) @_key
        value: (string_literal
          (string_fragment) @injection.content))
      (element_value_pair
        key: (identifier) @_native_key
        value: (true))))
  (#eq? @_annotation "Query")
  (#eq? @_key "value")
  (#eq? @_native_key "nativeQuery")
  (#set! injection.language "sql"))

(
  (annotation
    name: (identifier) @_annotation
    arguments: (annotation_argument_list
      (element_value_pair
        key: (identifier) @_native_key
        value: (true))
      (element_value_pair
        key: (identifier) @_key
        value: (string_literal
          (string_fragment) @injection.content))))
  (#eq? @_annotation "Query")
  (#eq? @_key "value")
  (#eq? @_native_key "nativeQuery")
  (#set! injection.language "sql"))

(
  (annotation
    name: (identifier) @_annotation
    arguments: (annotation_argument_list
      (string_literal
        (string_fragment) @injection.content)))
  (#any-of? @_annotation "Subselect")
  (#set! injection.language "sql"))

(
  (annotation
    name: (identifier) @_annotation
    arguments: (annotation_argument_list
      (element_value_pair
        key: (identifier) @_key
        value: (string_literal
          (string_fragment) @injection.content))))
  (#any-of? @_annotation "NamedNativeQuery" "Subselect")
  (#any-of? @_key "query" "value")
  (#set! injection.language "sql"))

(
  (annotation
    name: (identifier) @_annotation
    arguments: (annotation_argument_list
      (element_value_pair
        key: (identifier) @_key
        value: (string_literal
          (string_fragment) @injection.content))))
  (#any-of? @_annotation "SQLDelete" "SQLInsert" "SQLSelect" "SQLUpdate" "Where")
  (#any-of? @_key "sql" "clause")
  (#set! injection.language "sql"))

(
  (method_invocation
    (identifier) @_class
    (identifier) @_method
    (argument_list
      .
      (string_literal
        (string_fragment) @injection.content)))
  (#eq? @_class "Pattern")
  (#eq? @_method "compile")
  (#set! injection.language "regex"))

(
  (method_invocation
    (string_literal)
    (identifier) @_method
    (argument_list
      .
      (string_literal
        (string_fragment) @injection.content)))
  (#eq? @_method "matches")
  (#set! injection.language "regex"))
]]

local function leaf_multiline()
  return [[(string_literal
    (multiline_string_fragment) @injection.content)]]
end

local concat = require("ts_inject.host._concat")

local function leaf_string()
  return [[(string_literal
    (string_fragment) @injection.content)]]
end

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
  (local_variable_declaration
    type: (type_identifier)
    declarator: (variable_declarator
      name: (identifier) @_name
      value: %s))
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(leaf_multiline(), util.q(rule.pattern), util.q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (local_variable_declaration
    type: (type_identifier)
    declarator: (variable_declarator
      name: (identifier) @_name
      value: %s))
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(leaf_string(), util.q(rule.pattern), util.q(rule.lang))

  for depth = 2, MAX_CONCAT_DEPTH do
    add(
      blocks,
      ([[
(
  (local_variable_declaration
    type: (type_identifier)
    declarator: (variable_declarator
      name: (identifier) @_name
      value: %s))
  (#lua-match? @_name %s)
  (#set! injection.combined)
  (#set! injection.language %s))
]]):format(concat_expr(depth), util.q(rule.pattern), util.q(rule.lang))
    )
  end

  return blocks
end

local function render_call(rule)
  local fn = util.join_fn_list(rule.fn)
  local blocks = {}

  blocks[#blocks + 1] = ([[
(
  (method_invocation
    object: (identifier)
    name: (identifier) @_fn
    arguments: (argument_list
      %s))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(leaf_multiline(), fn, util.q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (method_invocation
    name: (identifier) @_fn
    arguments: (argument_list
      .
      %s))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(leaf_multiline(), fn, util.q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (method_invocation
    object: (identifier)
    name: (identifier) @_fn
    arguments: (argument_list
      %s))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(leaf_string(), fn, util.q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (method_invocation
    name: (identifier) @_fn
    arguments: (argument_list
      .
      %s))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(leaf_string(), fn, util.q(rule.lang))

  for depth = 2, MAX_CONCAT_DEPTH do
    add(
      blocks,
      ([[
(
  (method_invocation
    object: (identifier)
    name: (identifier) @_fn
    arguments: (argument_list
      %s))
  (#any-of? @_fn %s)
  (#set! injection.combined)
  (#set! injection.language %s))
]]):format(concat_expr(depth), fn, util.q(rule.lang))
    )
    add(
      blocks,
      ([[
(
  (method_invocation
    name: (identifier) @_fn
    arguments: (argument_list
      .
      %s))
  (#any-of? @_fn %s)
  (#set! injection.combined)
  (#set! injection.language %s))
]]):format(concat_expr(depth), fn, util.q(rule.lang))
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
      return nil, ("unsupported java rule kind: %s"):format(rule.kind)
    end

    vim.list_extend(blocks, rendered)
  end

  return "; extends\n" .. static_preamble .. "\n" .. table.concat(blocks, "\n")
end

return M
