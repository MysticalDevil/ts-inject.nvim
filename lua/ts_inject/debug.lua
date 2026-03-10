local M = {}

local function buf_line_count(bufnr)
  return vim.api.nvim_buf_line_count(bufnr)
end

local function add(lines, line)
  lines[#lines + 1] = line
end

local function add_kv(lines, key, value)
  add(lines, ("%-18s %s"):format(key .. ":", value))
end

local function list_or_none(items)
  if not items or vim.tbl_isempty(items) then
    return { "  (none)" }
  end

  local out = {}
  for _, item in ipairs(items) do
    out[#out + 1] = "  " .. item
  end
  return out
end

local function append_section(lines, title, items)
  add(lines, "")
  add(lines, title .. ":")
  for _, item in ipairs(list_or_none(items)) do
    add(lines, item)
  end
end

local function collect_langtrees(langtree, indent, acc)
  acc[#acc + 1] = ("%s%s"):format(indent, langtree:lang())
  for _, child in pairs(langtree:children() or {}) do
    collect_langtrees(child, indent .. "  ", acc)
  end
end

function M.collect(opts)
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = math.max(cursor[1] - 1, 0)
  local max_row = math.max(buf_line_count(bufnr) - 1, 0)
  if row > max_row then
    row = max_row
  end
  local col = cursor[2]
  local filetype = vim.bo[bufnr].filetype
  local target_lang = opts.target_lang or "sql"
  local lines = {}

  add(lines, "TSInject Debug")
  add(lines, ("time: %s"):format(os.date("%Y-%m-%d %H:%M:%S")))
  add(lines, "")
  add_kv(lines, "buffer", tostring(bufnr))
  add_kv(lines, "filetype", filetype)
  add_kv(lines, "target_lang", target_lang)
  add_kv(lines, "cursor", ("%d:%d"):format(cursor[1], col))

  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local client_lines = {}
  for _, client in ipairs(clients) do
    local semantic = client.server_capabilities and client.server_capabilities.semanticTokensProvider and "on" or "off"
    client_lines[#client_lines + 1] = ("%s (id=%d, semantic_tokens=%s)"):format(client.name, client.id, semantic)
  end
  append_section(lines, "lsp clients", client_lines)

  local semantic_active = "unknown"
  if vim.lsp.semantic_tokens then
    local active_ok, active = pcall(vim.lsp.semantic_tokens.is_enabled, { bufnr = bufnr })
    if active_ok then
      semantic_active = active and "enabled" or "stopped"
    end
  end
  add(lines, "")
  add_kv(lines, "semantic_tokens", semantic_active)

  local parser_ok, parser = pcall(vim.treesitter.get_parser, bufnr, filetype)
  add_kv(lines, "host_parser", parser_ok and "ok" or "missing")

  local parser_files = vim.api.nvim_get_runtime_file(("parser/%s.*"):format(filetype), true)
  append_section(lines, "host parser files", parser_files)

  local target_parser_files = vim.api.nvim_get_runtime_file(("parser/%s.*"):format(target_lang), true)
  append_section(lines, "target parser files", target_parser_files)

  local query_files = {}
  local query_ok, query_err = pcall(function()
    query_files = vim.treesitter.query.get_files(filetype, "injections")
  end)
  add(lines, "")
  add_kv(lines, "injection_query", query_ok and "ok" or ("error: " .. query_err))
  append_section(lines, "injection query files", query_files)

  local captures = {}
  local captures_ok, captures_err = pcall(function()
    captures = vim.treesitter.get_captures_at_pos(bufnr, row, col)
  end)
  add(lines, "")
  add_kv(lines, "captures", captures_ok and "ok" or ("error: " .. captures_err))
  if captures_ok then
    local capture_lines = {}
    for _, cap in ipairs(captures) do
      capture_lines[#capture_lines + 1] = ("%s [%s]"):format(cap.capture or "?", cap.lang or "?")
    end
    append_section(lines, "captures at cursor", capture_lines)
  end

  local node_ok, node = pcall(vim.treesitter.get_node, {
    bufnr = bufnr,
    pos = { row, col },
    ignore_injections = false,
  })
  add(lines, "")
  if node_ok and node then
    add_kv(lines, "node:type", node:type())

    local node_lang = "unknown"
    if type(node.lang) == "function" then
      local ok_lang, lang = pcall(node.lang, node)
      if ok_lang and lang then
        node_lang = lang
      end
    end

    add_kv(lines, "node:lang", node_lang)
    local sr, sc, er, ec = node:range()
    add_kv(lines, "node:range", ("%d:%d - %d:%d"):format(sr + 1, sc, er + 1, ec))
  else
    add_kv(lines, "node", node_ok and "nil" or ("error: " .. tostring(node)))
  end

  local langtrees = {}
  if parser_ok and parser then
    collect_langtrees(parser, "", langtrees)
  end
  append_section(lines, "language trees", langtrees)

  return lines
end

function M.show(opts)
  local lines = M.collect(opts or {})
  local out = vim.api.nvim_create_buf(false, true)
  vim.bo[out].bufhidden = "wipe"
  vim.bo[out].buftype = "nofile"
  vim.bo[out].swapfile = false
  vim.bo[out].filetype = "markdown"
  vim.api.nvim_buf_set_lines(out, 0, -1, false, lines)
  vim.api.nvim_set_current_buf(out)
  return out
end

return M
