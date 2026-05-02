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

local function render_name_pattern(rule)
  return {
    ([[
(
  (variable_declaration
    (identifier) @_name
    (multiline_string) @injection.content)
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(q(rule.pattern), q(rule.lang)),
    ([[
(
  (variable_declaration
    (identifier) @_name
    (string
      (string_content) @injection.content))
  (#lua-match? @_name %s)
  (#set! injection.language %s))
]]):format(q(rule.pattern), q(rule.lang)),
  }
end

local function call_function_pattern()
  return [[
(field_expression
  object: (identifier)
  member: (identifier) @_fn)
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
      (multiline_string) @injection.content
      . (_)*))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(call_function_pattern(), table.concat(args_prefix, "\n"), fn, q(rule.lang)),
    ([[
(
  (call_expression
    function: %s
    arguments: (arguments
%s
      (string
        (string_content) @injection.content)
      . (_)*))
  (#any-of? @_fn %s)
  (#set! injection.language %s))
]]):format(call_function_pattern(), table.concat(args_prefix, "\n"), fn, q(rule.lang)),
  }
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
      return nil, ("unsupported zig rule kind: %s"):format(rule.kind)
    end

    vim.list_extend(blocks, rendered)
  end

  return table.concat(blocks, "\n")
end

return M
