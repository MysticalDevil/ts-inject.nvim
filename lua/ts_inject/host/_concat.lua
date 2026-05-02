local M = {}

---Generate a recursive left- or right-heavy binary concat expression.
---@param opts table
---   node_name      string   e.g. "binary_expression"
---   left_field     string   e.g. "left: " or ""
---   right_field    string   e.g. "right: " or ""
---   operator       string|nil  e.g. "." or "<\\>"
---   direction      "left"|"right"
---   leaf_fn        function returns leaf string query
---   max_depth      number
function M.binary(opts)
  local node_name = opts.node_name or "binary_expression"
  local left_field = opts.left_field or "left: "
  local right_field = opts.right_field or "right: "
  local operator = opts.operator
  local direction = opts.direction or "left"
  local leaf_fn = opts.leaf_fn
  local max_depth = opts.max_depth or 5

  local op_line = ""
  if operator then
    op_line = '\n  operator: "' .. operator .. '"'
  end

  local template = "(" .. node_name .. "\n  " .. left_field .. "%s" .. op_line .. "\n  " .. right_field .. "%s)"

  local function concat_expr(depth)
    if depth <= 1 then
      return leaf_fn()
    end
    if direction == "left" then
      return template:format(concat_expr(depth - 1), leaf_fn())
    else
      return template:format(leaf_fn(), concat_expr(depth - 1))
    end
  end

  return concat_expr, max_depth
end

---Generate a native concatenation expression (no recursion needed).
---@param opts table
---   concat_node  string   e.g. "concatenated_string"
---   leaf_fn      function
function M.native(opts)
  local concat_node = opts.concat_node or "concatenated_string"
  local leaf_fn = opts.leaf_fn

  return function()
    return "(" .. concat_node .. "\n  " .. leaf_fn() .. "+)"
  end
end

---Expand a concat expression over a range of depths, calling template_fn for each.
---@param concat_expr function(depth) -> string
---@param max_depth   number
---@param template_fn function(concat_str) -> string
---@return table      list of rendered strings
function M.expand(concat_expr, max_depth, template_fn)
  local blocks = {}
  for depth = 2, max_depth do
    blocks[#blocks + 1] = template_fn(concat_expr(depth))
  end
  return blocks
end

return M
