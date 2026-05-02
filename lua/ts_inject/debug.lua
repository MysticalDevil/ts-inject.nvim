local M = {}

local util = require("ts_inject.host._util")

local function buf_line_count(bufnr)
  return vim.api.nvim_buf_line_count(bufnr)
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

  util.add(lines, "TSInject Debug")
  util.add(lines, ("time: %s"):format(os.date("%Y-%m-%d %H:%M:%S")))
  util.add(lines, "")
  util.add_kv(lines, "buffer", tostring(bufnr))
  util.add_kv(lines, "filetype", filetype)
  util.add_kv(lines, "target_lang", target_lang)
  util.add_kv(lines, "cursor", ("%d:%d"):format(cursor[1], col))
  util.add_kv(lines, "plugin_enabled", require("ts_inject").is_enabled(filetype) and "yes" or "no")

  if require("ts_inject").is_enabled(filetype) then
    util.add_kv(lines, "plugin_query", require("ts_inject.runtime").query_path(filetype))
  end

  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local client_lines = {}
  for _, client in ipairs(clients) do
    local semantic = client.server_capabilities and client.server_capabilities.semanticTokensProvider and "on" or "off"
    client_lines[#client_lines + 1] = ("%s (id=%d, semantic_tokens=%s)"):format(client.name, client.id, semantic)
  end
  util.append_section(lines, "lsp clients", client_lines)

  local semantic_active = "unknown"
  if vim.lsp.semantic_tokens then
    local active_ok, active = pcall(vim.lsp.semantic_tokens.is_enabled, { bufnr = bufnr })
    if active_ok then
      semantic_active = active and "enabled" or "stopped"
    end
  end
  util.add(lines, "")
  util.add_kv(lines, "semantic_tokens", semantic_active)

  local parser_ok, parser = pcall(vim.treesitter.get_parser, bufnr, filetype)
  util.add_kv(lines, "host_parser", parser_ok and "ok" or "missing")

  local parser_files = vim.api.nvim_get_runtime_file(("parser/%s.*"):format(filetype), true)
  util.append_section(lines, "host parser files", parser_files)

  local target_parser_files = vim.api.nvim_get_runtime_file(("parser/%s.*"):format(target_lang), true)
  util.append_section(lines, "target parser files", target_parser_files)

  local query_files = {}
  local query_ok, query_err = pcall(function()
    query_files = vim.treesitter.query.get_files(filetype, "injections")
  end)
  util.add(lines, "")
  util.add_kv(lines, "injection_query", query_ok and "ok" or ("error: " .. query_err))
  util.append_section(lines, "injection query files", query_files)

  local captures = {}
  local captures_ok, captures_err = pcall(function()
    captures = vim.treesitter.get_captures_at_pos(bufnr, row, col)
  end)
  util.add(lines, "")
  util.add_kv(lines, "captures", captures_ok and "ok" or ("error: " .. captures_err))
  if captures_ok then
    local capture_lines = {}
    for _, cap in ipairs(captures) do
      capture_lines[#capture_lines + 1] = ("%s [%s]"):format(cap.capture or "?", cap.lang or "?")
    end
    util.append_section(lines, "captures at cursor", capture_lines)
  end

  local node_ok, node = pcall(vim.treesitter.get_node, {
    bufnr = bufnr,
    pos = { row, col },
    ignore_injections = false,
  })
  util.add(lines, "")
  if node_ok and node then
    util.add_kv(lines, "node:type", node:type())

    local node_lang = "unknown"
    if type(node.lang) == "function" then
      local ok_lang, lang = pcall(node.lang, node)
      if ok_lang and lang then
        node_lang = lang
      end
    end

    util.add_kv(lines, "node:lang", node_lang)
    local sr, sc, er, ec = node:range()
    util.add_kv(lines, "node:range", ("%d:%d - %d:%d"):format(sr + 1, sc, er + 1, ec))
  else
    util.add_kv(lines, "node", node_ok and "nil" or ("error: " .. tostring(node)))
  end

  local langtrees = {}
  if parser_ok and parser then
    collect_langtrees(parser, "", langtrees)
  end
  util.append_section(lines, "language trees", langtrees)

  return lines
end

function M.show(opts)
  local lines = M.collect(opts or {})
  return util.open_float(lines, "TSInject Debug")
end

return M
