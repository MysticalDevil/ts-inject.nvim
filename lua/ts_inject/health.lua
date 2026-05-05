local M = {}

local util = require("ts_inject.host._util")

function M.collect()
  local state = require("ts_inject").get_runtime_state()
  local lines = {}
  local highlights = {}

  util.add_hl(lines, highlights, "TSInject Health", "Title")
  util.add_hl(lines, highlights, ("time: %s"):format(os.date("%Y-%m-%d %H:%M:%S")), "Comment")
  util.add(lines, "")

  util.add_kv_hl(lines, highlights, "runtime_root", require("ts_inject.runtime").root_dir())

  local enabled = {}
  local generated = {}
  local static = {}
  local legacy_static = {}
  local host_status = {}
  local generated_paths = {}
  local error_hosts = {}

  for host, status in pairs(state.hosts or {}) do
    enabled[#enabled + 1] = host
    local status_parts = {
      status.mode,
    }

    if status.mode == "generated" then
      status_parts[#status_parts + 1] = ("builtin=%s"):format(status.builtin_enabled and "on" or "off")
      status_parts[#status_parts + 1] = ("builtin_rules=%d"):format(status.builtin_rule_count or 0)
      status_parts[#status_parts + 1] = ("user_rules=%d"):format(status.user_rule_count or 0)
      if not status.configurable_rules then
        status_parts[#status_parts + 1] = "public_rules=locked"
      end

      local present = vim.uv.fs_stat(status.path or "") and "present" or "missing"
      generated_paths[#generated_paths + 1] = ("%s: %s (%s)"):format(host, status.path or "(none)", present)
    end

    if status.mode == "static" and status.generated_capable then
      status_parts[#status_parts + 1] = "legacy_static=on"
      legacy_static[#legacy_static + 1] = host
    end

    if status.error then
      status_parts[#status_parts + 1] = ("error: " .. status.error)
      error_hosts[#error_hosts + 1] = ("%s: %s"):format(host, status.error)
    else
      status_parts[#status_parts + 1] = "ok"
    end
    host_status[#host_status + 1] = ("%s (%s)"):format(host, table.concat(status_parts, ", "))
    if status.mode == "generated" then
      generated[#generated + 1] = host
    else
      static[#static + 1] = host
    end
  end

  table.sort(enabled)
  table.sort(generated)
  table.sort(generated_paths)
  table.sort(static)
  table.sort(legacy_static)
  table.sort(host_status)
  table.sort(error_hosts)

  local total = #enabled
  util.add_kv_hl(
    lines,
    highlights,
    "summary",
    ("%d enabled, %d generated, %d static"):format(total, #generated, #static),
    "DiagnosticInfo"
  )
  if #legacy_static > 0 then
    util.add_kv_hl(lines, highlights, "", ("%d host(s) forced to static mode"):format(#legacy_static), "DiagnosticWarn")
  end
  if #error_hosts > 0 then
    util.add_kv_hl(lines, highlights, "", ("%d host(s) with errors"):format(#error_hosts), "DiagnosticError")
  end

  util.append_section_hl(lines, highlights, "enabled hosts", enabled)
  util.append_section_hl(lines, highlights, "generated hosts", generated)
  util.append_section_hl(lines, highlights, "static hosts", static)
  util.append_section_hl(lines, highlights, "legacy static hosts", legacy_static)

  local host_status_hl = {}
  for _, status in ipairs(host_status) do
    local hl = "Normal"
    if status:find("error:", 1, true) then
      hl = "DiagnosticError"
    elseif status:find("legacy_static=on", 1, true) then
      hl = "DiagnosticWarn"
    elseif status:find("ok", 1, true) then
      hl = "DiagnosticOk"
    end
    host_status_hl[#host_status_hl + 1] = { text = status, hl_group = hl }
  end
  util.append_section_hl(lines, highlights, "host status", host_status_hl)

  local generated_paths_hl = {}
  for _, path in ipairs(generated_paths) do
    local hl = path:find("present", 1, true) and "DiagnosticOk" or "DiagnosticError"
    generated_paths_hl[#generated_paths_hl + 1] = { text = path, hl_group = hl }
  end
  util.append_section_hl(lines, highlights, "generated query status", generated_paths_hl)

  local error_hosts_hl = {}
  for _, err in ipairs(error_hosts) do
    error_hosts_hl[#error_hosts_hl + 1] = { text = err, hl_group = "DiagnosticError" }
  end
  util.append_section_hl(lines, highlights, "errors", error_hosts_hl)

  local parser_lines = {}
  for _, host in ipairs(enabled) do
    local files = vim.api.nvim_get_runtime_file(("parser/%s.*"):format(host), true)
    parser_lines[#parser_lines + 1] = ("%s: %s"):format(host, (#files > 0) and "ok" or "missing")
  end
  local sql_files = vim.api.nvim_get_runtime_file("parser/sql.*", true)
  parser_lines[#parser_lines + 1] = ("sql: %s"):format((#sql_files > 0) and "ok" or "missing")
  local gql_files = vim.api.nvim_get_runtime_file("parser/graphql.*", true)
  parser_lines[#parser_lines + 1] = ("graphql: %s"):format((#gql_files > 0) and "ok" or "missing")

  local parser_lines_hl = {}
  for _, p in ipairs(parser_lines) do
    local hl = p:find("ok", 1, true) and "DiagnosticOk" or "DiagnosticError"
    parser_lines_hl[#parser_lines_hl + 1] = { text = p, hl_group = hl }
  end
  util.append_section_hl(lines, highlights, "parser availability", parser_lines_hl)

  local semantic_risk = {}
  local semantic_active = "unknown"
  if vim.lsp.semantic_tokens then
    local active_ok, active = pcall(vim.lsp.semantic_tokens.is_enabled, { bufnr = vim.api.nvim_get_current_buf() })
    if active_ok then
      semantic_active = active and "enabled" or "stopped"
    end
  end

  if semantic_active == "enabled" then
    local risky = {}
    local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
    for _, client in ipairs(clients) do
      if client.server_capabilities and client.server_capabilities.semanticTokensProvider then
        risky[#risky + 1] = client.name
      end
    end
    if #risky > 0 then
      table.sort(risky)
      semantic_risk[#semantic_risk + 1] = "at risk: LSP semantic tokens are active"
      semantic_risk[#semantic_risk + 1] = "  servers: " .. table.concat(risky, ", ")
      semantic_risk[#semantic_risk + 1] = "  fix: :lua vim.hl.priorities.semantic_tokens = 90"
    else
      semantic_risk[#semantic_risk + 1] = "ok: no LSP semantic token providers"
    end
  elseif semantic_active == "stopped" then
    semantic_risk[#semantic_risk + 1] = "ok: semantic tokens stopped"
  else
    semantic_risk[#semantic_risk + 1] = "unknown: could not determine semantic token state"
  end

  local semantic_risk_hl = {}
  for _, r in ipairs(semantic_risk) do
    local hl = "Normal"
    if r:find("at risk", 1, true) or r:find("unknown", 1, true) then
      hl = "DiagnosticWarn"
    elseif r:find("ok:", 1, true) then
      hl = "DiagnosticOk"
    end
    semantic_risk_hl[#semantic_risk_hl + 1] = { text = r, hl_group = hl }
  end
  util.append_section_hl(lines, highlights, "semantic_token risk", semantic_risk_hl)

  local warnings_hl = {}
  for _, w in ipairs(state.warnings or {}) do
    warnings_hl[#warnings_hl + 1] = { text = w, hl_group = "DiagnosticWarn" }
  end
  util.append_section_hl(lines, highlights, "warnings", warnings_hl)

  return lines, highlights
end

function M.show()
  local lines, highlights = M.collect()
  -- Sanitize embedded newlines before writing to buffer (some status messages
  -- contain multi-line strings that would crash nvim_buf_set_lines).
  local sanitized = {}
  for _, line in ipairs(lines) do
    sanitized[#sanitized + 1] = (line:gsub("\n", " "))
  end
  return util.open_float(sanitized, "TSInject Health", { highlights = highlights })
end

return M
