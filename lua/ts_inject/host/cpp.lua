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

local function string_value()
  return [=[([
  (string_literal
    (string_content) @injection.content)+
  (concatenated_string
    (string_literal
      (string_content) @injection.content)+)
  (raw_string_literal
    (raw_string_content) @injection.content)
  (user_defined_literal
    (string_literal
      (string_content) @injection.content))
  (parenthesized_expression
    (string_literal
      (string_content) @injection.content)+)
  (parenthesized_expression
    (concatenated_string
      (string_literal
        (string_content) @injection.content)+))
  (parenthesized_expression
    (raw_string_literal
      (raw_string_content) @injection.content))
  (cast_expression
    value: (string_literal
      (string_content) @injection.content)+)
  (cast_expression
    value: (concatenated_string
      (string_literal
        (string_content) @injection.content)+))
  (cast_expression
    value: (raw_string_literal
      (raw_string_content) @injection.content))
])]=]
end

local static_preamble = [[
(
  (_
    (comment) @_marker
    .
    (declaration
      declarator: (init_declarator
        value: [
          (string_literal
            (string_content) @injection.content)+
          (concatenated_string
            (string_literal
              (string_content) @injection.content)+)
          (raw_string_literal
            (raw_string_content) @injection.content)
          (user_defined_literal
            (string_literal
              (string_content) @injection.content))
          (parenthesized_expression
            (string_literal
              (string_content) @injection.content)+)
          (parenthesized_expression
            (concatenated_string
              (string_literal
                (string_content) @injection.content)+))
          (parenthesized_expression
            (raw_string_literal
              (raw_string_content) @injection.content))
          (cast_expression
            value: (string_literal
              (string_content) @injection.content)+)
          (cast_expression
            value: (concatenated_string
              (string_literal
                (string_content) @injection.content)+))
          (cast_expression
            value: (raw_string_literal
              (raw_string_content) @injection.content))
        ])))
  (#lua-match? @_marker "[Ss][Qq][Ll]")
  (#set! injection.language "sql"))

(
  (declaration
    declarator: (init_declarator
      (comment) @_marker
      value: [
        (string_literal
          (string_content) @injection.content)+
        (concatenated_string
          (string_literal
            (string_content) @injection.content)+)
        (raw_string_literal
          (raw_string_content) @injection.content)
        (user_defined_literal
          (string_literal
            (string_content) @injection.content))
        (parenthesized_expression
          (string_literal
            (string_content) @injection.content)+)
        (parenthesized_expression
          (concatenated_string
            (string_literal
              (string_content) @injection.content)+))
        (parenthesized_expression
          (raw_string_literal
            (raw_string_content) @injection.content))
        (cast_expression
          value: (string_literal
            (string_content) @injection.content)+)
        (cast_expression
          value: (concatenated_string
            (string_literal
              (string_content) @injection.content)+))
        (cast_expression
          value: (raw_string_literal
            (raw_string_content) @injection.content))
      ]))
  (#lua-match? @_marker "[Ss][Qq][Ll]")
  (#set! injection.language "sql"))

(
  (declaration
    type: [
      (type_identifier) @_type
      (qualified_identifier
        name: (type_identifier) @_type)
    ]
    declarator: (init_declarator
      value: (argument_list
        .
        [
          (string_literal
            (string_content) @injection.content)+
          (concatenated_string
            (string_literal
              (string_content) @injection.content)+)
          (raw_string_literal
            (raw_string_content) @injection.content)
          (user_defined_literal
            (string_literal
              (string_content) @injection.content))
          (parenthesized_expression
            (string_literal
              (string_content) @injection.content)+)
          (parenthesized_expression
            (concatenated_string
              (string_literal
                (string_content) @injection.content)+))
          (parenthesized_expression
            (raw_string_literal
              (raw_string_content) @injection.content))
          (cast_expression
            value: (string_literal
              (string_content) @injection.content)+)
          (cast_expression
            value: (concatenated_string
              (string_literal
                (string_content) @injection.content)+))
          (cast_expression
            value: (raw_string_literal
              (raw_string_content) @injection.content))
        ])))
  (#any-of? @_type "QSqlQuery" "query" "statement")
  (#set! injection.language "sql"))

(
  (declaration
    type: (qualified_identifier
      name: (type_identifier) @_type)
    declarator: (init_declarator
      value: (argument_list
        (_)
        .
        [
          (string_literal
            (string_content) @injection.content)+
          (concatenated_string
            (string_literal
              (string_content) @injection.content)+)
          (raw_string_literal
            (raw_string_content) @injection.content)
          (user_defined_literal
            (string_literal
              (string_content) @injection.content))
          (parenthesized_expression
            (string_literal
              (string_content) @injection.content)+)
          (parenthesized_expression
            (concatenated_string
              (string_literal
                (string_content) @injection.content)+))
          (parenthesized_expression
            (raw_string_literal
              (raw_string_content) @injection.content))
          (cast_expression
            value: (string_literal
              (string_content) @injection.content)+)
          (cast_expression
            value: (concatenated_string
              (string_literal
                (string_content) @injection.content)+))
          (cast_expression
            value: (raw_string_literal
              (raw_string_content) @injection.content))
        ])))
  (#eq? @_type "Statement")
  (#set! injection.language "sql"))

(
  (binary_expression
    left: [
      (identifier) @_stream
      (field_expression
        field: (field_identifier) @_stream)
    ]
    right: [
      (string_literal
        (string_content) @injection.content)+
      (concatenated_string
        (string_literal
          (string_content) @injection.content)+)
      (raw_string_literal
        (raw_string_content) @injection.content)
      (user_defined_literal
        (string_literal
          (string_content) @injection.content))
      (parenthesized_expression
        (string_literal
          (string_content) @injection.content)+)
      (parenthesized_expression
        (concatenated_string
          (string_literal
            (string_content) @injection.content)+))
      (parenthesized_expression
        (raw_string_literal
          (raw_string_content) @injection.content))
      (cast_expression
        value: (string_literal
          (string_content) @injection.content)+)
      (cast_expression
        value: (concatenated_string
          (string_literal
            (string_content) @injection.content)+))
      (cast_expression
        value: (raw_string_literal
          (raw_string_content) @injection.content))
    ])
  (#any-of? @_stream "sql" "prepare")
  (#set! injection.language "sql"))

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
  (declaration
    type: [
      (qualified_identifier
        (type_identifier) @_class)
      (type_identifier) @_class
    ]
    declarator: (init_declarator
      declarator: (identifier)
      value: (argument_list
        .
        (string_literal
          (string_content) @injection.content))))
  (#eq? @_class "regex")
  (#set! injection.language "regex"))

(
  (call_expression
    function: [
      (qualified_identifier
        (identifier) @_class)
      (identifier) @_class
    ]
    arguments: (argument_list
      .
      (string_literal
        (string_content) @injection.content)))
  (#eq? @_class "regex")
  (#set! injection.language "regex"))
]]

local function render_name_pattern(rule)
  return {
    ([[
(
  (declaration
    declarator: (init_declarator
      declarator: (_) @_decl
      value: %s))
  (#lua-match? @_decl %s)
  (#set! injection.language %s))
]]):format(string_value(), q(rule.pattern), q(rule.lang)),
    ([[
(
  (assignment_expression
    left: (identifier) @_name
    right: %s)
  (#lua-match? @_name %s)
  (#set! injection.language %s)
)
]]):format(string_value(), q(rule.pattern), q(rule.lang)),
  }
end

local function render_call(rule)
  local fn = join_fn_list(rule.fn)
  local arg_index = rule.arg_index or 1
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
    function: (field_expression
      field: (field_identifier) @_method)
    arguments: (argument_list
%s
      %s))
  (#any-of? @_method %s)
  (#set! injection.language %s))
]]):format(table.concat(args_prefix, "\n"), string_value(), fn, q(rule.lang))

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
      return nil, ("unsupported cpp rule kind: %s"):format(rule.kind)
    end

    vim.list_extend(blocks, rendered)
  end

  return "; extends\n" .. static_preamble .. "\n" .. table.concat(blocks, "\n")
end

return M
