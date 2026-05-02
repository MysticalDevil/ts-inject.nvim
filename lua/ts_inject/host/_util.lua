local M = {}

function M.q(text)
  return string.format("%q", text)
end

function M.join_fn_list(items)
  local out = {}
  for _, item in ipairs(items or {}) do
    out[#out + 1] = M.q(item)
  end
  return table.concat(out, " ")
end

function M.arg_prefix(arg_index)
  local args_prefix = {}
  if arg_index == 1 then
    table.insert(args_prefix, "      .")
  else
    for _ = 1, arg_index - 1 do
      table.insert(args_prefix, "      (_)")
      table.insert(args_prefix, "      .")
    end
  end
  return table.concat(args_prefix, "\n")
end

return M
