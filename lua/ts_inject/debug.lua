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

---Return a semantic highlight group for a status value.
local function status_hl(value)
  local v = tostring(value)
  if v == "ok" or v == "yes" or v == "present" or v == "stopped" then
    return "DiagnosticOk"
  elseif v == "missing" or v == "error" or v == "no" then
    return "DiagnosticError"
  elseif v == "enabled" or v == "on" then
    return "DiagnosticWarn"
  elseif v == "unknown" or v == "warning" then
    return "DiagnosticWarn"
  elseif v == "off" then
    return "DiagnosticInfo"
  end
  return nil
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
  local highlights = {}

  -- Header
  util.add_hl(lines, highlights, "TSInject Debug", "Title")
  util.add_hl(lines, highlights, ("time: %s"):format(os.date("%Y-%m-%d %H:%M:%S")), "Comment")
  util.add(lines, "")

  -- Basic info
  util.add_kv_hl(lines, highlights, "buffer", tostring(bufnr))
  util.add_kv_hl(lines, highlights, "filetype", filetype)
  util.add_kv_hl(lines, highlights, "target_lang", target_lang)
  util.add_kv_hl(lines, highlights, "cursor", ("%d:%d"):format(cursor[1], col))

  local plugin_enabled = require("ts_inject").is_enabled(filetype)
  util.add_kv_hl(
    lines,
    highlights,
    "plugin_enabled",
    plugin_enabled and "yes" or "no",
    status_hl(plugin_enabled and "yes" or "no")
  )

  if plugin_enabled then
    util.add_kv_hl(lines, highlights, "plugin_query", require("ts_inject.runtime").query_path(filetype))
  end

  -- LSP Clients
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local client_lines = {}
  for _, client in ipairs(clients) do
    local semantic = client.server_capabilities and client.server_capabilities.semanticTokensProvider and "on" or "off"
    client_lines[#client_lines + 1] = {
      text = ("%s (id=%d, semantic_tokens=%s)"):format(client.name, client.id, semantic),
      hl_group = status_hl(semantic),
    }
  end
  util.append_section_hl(lines, highlights, "lsp clients", client_lines)

  -- Semantic tokens
  local semantic_active = "unknown"
  if vim.lsp.semantic_tokens then
    local active_ok, active = pcall(vim.lsp.semantic_tokens.is_enabled, { bufnr = bufnr })
    if active_ok then
      semantic_active = active and "enabled" or "stopped"
    end
  end
  util.add(lines, "")
  util.add_kv_hl(lines, highlights, "semantic_tokens", semantic_active, status_hl(semantic_active))

  -- Host parser
  local parser_ok, parser = pcall(vim.treesitter.get_parser, bufnr, filetype)
  util.add_kv_hl(
    lines,
    highlights,
    "host_parser",
    parser_ok and "ok" or "missing",
    status_hl(parser_ok and "ok" or "missing")
  )

  -- Parser files
  local parser_files = vim.api.nvim_get_runtime_file(("parser/%s.*"):format(filetype), true)
  util.append_section_hl(lines, highlights, "host parser files", parser_files)

  local target_parser_files = vim.api.nvim_get_runtime_file(("parser/%s.*"):format(target_lang), true)
  util.append_section_hl(lines, highlights, "target parser files", target_parser_files)

  -- Injection query
  local query_files = {}
  local query_ok, query_err = pcall(function()
    query_files = vim.treesitter.query.get_files(filetype, "injections")
  end)
  util.add(lines, "")
  util.add_kv_hl(
    lines,
    highlights,
    "injection_query",
    query_ok and "ok" or ("error: " .. query_err),
    status_hl(query_ok and "ok" or "error")
  )
  util.append_section_hl(lines, highlights, "injection query files", query_files)

  -- Captures
  local captures = {}
  local captures_ok, captures_err = pcall(function()
    captures = vim.treesitter.get_captures_at_pos(bufnr, row, col)
  end)
  util.add(lines, "")
  util.add_kv_hl(
    lines,
    highlights,
    "captures",
    captures_ok and "ok" or ("error: " .. captures_err),
    status_hl(captures_ok and "ok" or "error")
  )
  if captures_ok then
    local capture_lines = {}
    for _, cap in ipairs(captures) do
      capture_lines[#capture_lines + 1] = ("%s [%s]"):format(cap.capture or "?", cap.lang or "?")
    end
    util.append_section_hl(lines, highlights, "captures at cursor", capture_lines)
  end

  -- Node info
  local node_ok, node = pcall(vim.treesitter.get_node, {
    bufnr = bufnr,
    pos = { row, col },
    ignore_injections = false,
  })
  util.add(lines, "")
  if node_ok and node then
    util.add_kv_hl(lines, highlights, "node:type", node:type())

    local node_lang = "unknown"
    if type(node.lang) == "function" then
      local ok_lang, lang = pcall(node.lang, node)
      if ok_lang and lang then
        node_lang = lang
      end
    end

    util.add_kv_hl(lines, highlights, "node:lang", node_lang, status_hl(node_lang == "unknown" and "unknown" or "ok"))
    local sr, sc, er, ec = node:range()
    util.add_kv_hl(lines, highlights, "node:range", ("%d:%d - %d:%d"):format(sr + 1, sc, er + 1, ec))
  else
    util.add_kv_hl(lines, highlights, "node", node_ok and "nil" or ("error: " .. tostring(node)), "DiagnosticError")
  end

  -- Language trees
  local langtrees = {}
  if parser_ok and parser then
    collect_langtrees(parser, "", langtrees)
  end
  util.append_section_hl(lines, highlights, "language trees", langtrees)

  -- Diagnostics
  local diag = {}
  if semantic_active == "enabled" then
    local in_injection = false
    local has_keyword = false

    if parser_ok and parser then
      local ok_lr, lt = pcall(parser.language_for_range, parser, { row, col, row, col + 1 })
      if ok_lr and lt then
        in_injection = lt:lang() == target_lang
      end
    end

    if not in_injection and node_ok and node and type(node.lang) == "function" then
      local ok_nl, nl = pcall(node.lang, node)
      if ok_nl then
        in_injection = nl == target_lang
      end
    end

    if captures_ok then
      for _, cap in ipairs(captures) do
        if cap.lang == target_lang and cap.capture and cap.capture:match("^keyword") then
          has_keyword = true
          break
        end
      end
    end

    if in_injection and has_keyword then
      diag[#diag + 1] =
        { text = "⚠  semantic tokens may be overriding injected highlights", hl_group = "DiagnosticWarn" }
      diag[#diag + 1] = { text = "   LSP priority (125) > tree-sitter priority (100)", hl_group = "DiagnosticWarn" }
      diag[#diag + 1] = {
        text = "   Fixes: disable per-server, or :lua vim.hl.priorities.semantic_tokens = 90",
        hl_group = "DiagnosticInfo",
      }
    elseif in_injection then
      diag[#diag + 1] =
        { text = "ℹ  semantic tokens enabled, but no keyword capture found at cursor", hl_group = "DiagnosticInfo" }
    else
      diag[#diag + 1] = {
        text = "ℹ  semantic tokens enabled, but cursor is not inside an injected region",
        hl_group = "DiagnosticInfo",
      }
    end
  else
    diag[#diag + 1] = { text = "✓  semantic tokens stopped; no conflict risk", hl_group = "DiagnosticOk" }
  end
  util.append_section_hl(lines, highlights, "diagnostics", diag)

  return lines, highlights
end

function M.show(opts)
  local lines, highlights = M.collect(opts or {})
  return util.open_float(lines, "TSInject Debug", { highlights = highlights })
end

return M
