local M = {}

local util = require("ts_inject.host._util")

function M.collect()
  local state = require("ts_inject").get_runtime_state()
  local lines = {}

  util.add(lines, "TSInject Health")
  util.add(lines, ("time: %s"):format(os.date("%Y-%m-%d %H:%M:%S")))
  util.add(lines, "")
  util.add_kv(lines, "runtime_root", require("ts_inject.runtime").root_dir())

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
  util.add(lines, ("%-18s %d enabled, %d generated, %d static"):format("summary:", total, #generated, #static))
  if #legacy_static > 0 then
    util.add(lines, ("%-18s %d host(s) forced to static mode"):format("", #legacy_static))
  end
  if #error_hosts > 0 then
    util.add(lines, ("%-18s %d host(s) with errors"):format("", #error_hosts))
  end

  util.append_section(lines, "enabled hosts", enabled)
  util.append_section(lines, "generated hosts", generated)
  util.append_section(lines, "static hosts", static)
  util.append_section(lines, "legacy static hosts", legacy_static)
  util.append_section(lines, "host status", host_status)
  util.append_section(lines, "generated query status", generated_paths)
  util.append_section(lines, "errors", error_hosts)

  local parser_lines = {}
  for _, host in ipairs(enabled) do
    local files = vim.api.nvim_get_runtime_file(("parser/%s.*"):format(host), true)
    parser_lines[#parser_lines + 1] = ("%s: %s"):format(host, (#files > 0) and "ok" or "missing")
  end
  local sql_files = vim.api.nvim_get_runtime_file("parser/sql.*", true)
  parser_lines[#parser_lines + 1] = ("sql: %s"):format((#sql_files > 0) and "ok" or "missing")
  local gql_files = vim.api.nvim_get_runtime_file("parser/graphql.*", true)
  parser_lines[#parser_lines + 1] = ("graphql: %s"):format((#gql_files > 0) and "ok" or "missing")
  util.append_section(lines, "parser availability", parser_lines)

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
  util.append_section(lines, "semantic_token risk", semantic_risk)

  util.append_section(lines, "warnings", state.warnings)
  return lines
end

function M.show()
  local lines = M.collect()
  -- Sanitize embedded newlines before writing to buffer (some status messages
  -- contain multi-line strings that would crash nvim_buf_set_lines).
  local sanitized = {}
  for _, line in ipairs(lines) do
    sanitized[#sanitized + 1] = (line:gsub("\n", " "))
  end
  return util.open_float(sanitized, "TSInject Health")
end

return M
