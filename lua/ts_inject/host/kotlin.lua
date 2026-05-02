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
  (annotation
    (constructor_invocation
      (user_type
        (type_identifier) @_annotation)
      (value_arguments
        (value_argument
          (string_literal
            (string_content) @injection.content)))))
  (#any-of? @_annotation "Select" "Insert" "Update" "Delete")
  (#set! injection.language "sql"))

(
  (annotation
    (constructor_invocation
      (user_type
        (type_identifier) @_annotation)
      (value_arguments
        (value_argument
          (call_expression
            (simple_identifier) @_array
            (call_suffix
              (value_arguments
                (value_argument
                  (string_literal
                    (string_content) @injection.content)))))))))
  (#any-of? @_annotation "Select" "Insert" "Update" "Delete")
  (#eq? @_array "arrayOf")
  (#set! injection.language "sql"))

(
  (annotation
    (constructor_invocation
      (user_type
        (type_identifier) @_annotation)
      (value_arguments
        (value_argument
          (simple_identifier) @_key
          (string_literal
            (string_content) @injection.content))
        (value_argument
          (simple_identifier) @_native_key
          (boolean_literal) @_native_value))))
  (#eq? @_annotation "Query")
  (#eq? @_key "value")
  (#eq? @_native_key "nativeQuery")
  (#eq? @_native_value "true")
  (#set! injection.language "sql"))

(
  (annotation
    (constructor_invocation
      (user_type
        (type_identifier) @_annotation)
      (value_arguments
        (value_argument
          (simple_identifier) @_native_key
          (boolean_literal) @_native_value)
        (value_argument
          (simple_identifier) @_key
          (string_literal
            (string_content) @injection.content)))))
  (#eq? @_annotation "Query")
  (#eq? @_key "value")
  (#eq? @_native_key "nativeQuery")
  (#eq? @_native_value "true")
  (#set! injection.language "sql"))
]]

local function leaf_string()
  return [[(string_literal
    (string_content) @injection.content)]]
end

local function concat_expr(depth)
  if depth <= 1 then
    return leaf_string()
  end
  return ([[
(additive_expression
  %s
  %s)
]]):format(concat_expr(depth - 1), leaf_string())
end

local function render_name_pattern(rule)
  local blocks = {}

  blocks[#blocks + 1] = ([[
(
  (property_declaration
    (variable_declaration
      (simple_identifier) @_name)
    %s)
  (#lua-match? @_name %s)
  (#set! injection.language %s)
)
]]):format(leaf_string(), q(rule.pattern), q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (property_declaration
    (variable_declaration
      (simple_identifier) @_name)
    (call_expression
      (navigation_expression
        %s
        (navigation_suffix
          (simple_identifier) @_trim))
      (call_suffix
        (value_arguments))))
  (#any-of? @_trim "trimIndent" "trimMargin")
  (#lua-match? @_name %s)
  (#set! injection.language %s)
)
]]):format(leaf_string(), q(rule.pattern), q(rule.lang))

  for depth = 2, MAX_CONCAT_DEPTH do
    add(
      blocks,
      ([[
(
  (property_declaration
    (variable_declaration
      (simple_identifier) @_name)
    %s)
  (#lua-match? @_name %s)
  (#set! injection.combined)
  (#set! injection.language %s)
)
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
  (call_expression
    (navigation_expression
      (simple_identifier)
      (navigation_suffix
        (simple_identifier) @_fn))
    (call_suffix
      (value_arguments
        (value_argument
          %s))))
  (#any-of? @_fn %s)
  (#set! injection.language %s)
)
]]):format(leaf_string(), fn, q(rule.lang))

  blocks[#blocks + 1] = ([[
(
  (call_expression
    (navigation_expression
      (simple_identifier)
      (navigation_suffix
        (simple_identifier) @_fn))
    (call_suffix
      (value_arguments
        (value_argument
          (call_expression
            (navigation_expression
              %s
              (navigation_suffix
                (simple_identifier) @_trim))
            (call_suffix
              (value_arguments)))))))
  (#any-of? @_fn %s)
  (#any-of? @_trim "trimIndent" "trimMargin")
  (#set! injection.language %s)
)
]]):format(leaf_string(), fn, q(rule.lang))

  for depth = 2, MAX_CONCAT_DEPTH do
    add(
      blocks,
      ([[
(
  (call_expression
    (navigation_expression
      (simple_identifier)
      (navigation_suffix
        (simple_identifier) @_fn))
    (call_suffix
      (value_arguments
        (value_argument
          %s))))
  (#any-of? @_fn %s)
  (#set! injection.combined)
  (#set! injection.language %s)
)
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
      return nil, ("unsupported kotlin rule kind: %s"):format(rule.kind)
    end

    vim.list_extend(blocks, rendered)
  end

  return "; extends\n" .. static_preamble .. "\n" .. table.concat(blocks, "\n")
end

return M
