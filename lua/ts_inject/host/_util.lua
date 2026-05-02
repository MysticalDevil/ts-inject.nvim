local M = {}

function M.q(text)
  return string.format("%q", text)
end

function M.add(blocks, text)
  blocks[#blocks + 1] = text
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

function M.build_dispatcher(opts)
  opts = opts or {}
  local header = opts.header or ""
  local renderers = opts.renderers or {}
  local static_preamble = opts.static_preamble
  local preamble_first = opts.preamble_first or false
  return function(rules, _opts)
    local blocks = {}
    if header ~= "" then
      blocks[#blocks + 1] = header
    end
    for _, rule in ipairs(rules or {}) do
      local rendered = {}
      local renderer = renderers[rule.kind]
      if renderer then
        rendered = renderer(rule, _opts)
      else
        return nil, ("unsupported rule kind: %s"):format(rule.kind)
      end
      vim.list_extend(blocks, rendered)
    end
    local body = table.concat(blocks, "\n")
    if static_preamble then
      if preamble_first then
        return static_preamble .. "\n" .. body
      end
      return body .. "\n" .. static_preamble
    end
    return body
  end
end

return M
