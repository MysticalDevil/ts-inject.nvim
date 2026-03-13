local M = {}

local function add(lines, line)
  lines[#lines + 1] = line
end

local function add_kv(lines, key, value)
  add(lines, ("%-18s %s"):format(key .. ":", value))
end

local function append_section(lines, title, items)
  add(lines, "")
  add(lines, title .. ":")
  if not items or vim.tbl_isempty(items) then
    add(lines, "  (none)")
    return
  end

  for _, item in ipairs(items) do
    add(lines, "  " .. item)
  end
end

function M.collect()
  local state = require("ts_inject").get_runtime_state()
  local lines = {}

  add(lines, "TSInject Health")
  add(lines, ("time: %s"):format(os.date("%Y-%m-%d %H:%M:%S")))
  add(lines, "")
  add_kv(lines, "runtime_root", require("ts_inject.runtime").root_dir())

  local enabled = {}
  local generated = {}
  local static = {}
  local host_status = {}

  for host, status in pairs(state.hosts or {}) do
    enabled[#enabled + 1] = host
    host_status[#host_status + 1] = ("%s (%s, %s)"):format(
      host,
      status.mode,
      status.error and ("error: " .. status.error) or "ok"
    )
    if status.mode == "generated" then
      generated[#generated + 1] = host
    else
      static[#static + 1] = host
    end
  end

  table.sort(enabled)
  table.sort(generated)
  table.sort(static)
  table.sort(host_status)

  append_section(lines, "enabled hosts", enabled)
  append_section(lines, "generated hosts", generated)
  append_section(lines, "static hosts", static)
  append_section(lines, "host status", host_status)

  local parser_lines = {}
  for _, host in ipairs(enabled) do
    local files = vim.api.nvim_get_runtime_file(("parser/%s.*"):format(host), true)
    parser_lines[#parser_lines + 1] = ("%s: %s"):format(host, (#files > 0) and "ok" or "missing")
  end
  local sql_files = vim.api.nvim_get_runtime_file("parser/sql.*", true)
  parser_lines[#parser_lines + 1] = ("sql: %s"):format((#sql_files > 0) and "ok" or "missing")
  append_section(lines, "parser availability", parser_lines)

  append_section(lines, "warnings", state.warnings)
  return lines
end

function M.show()
  local lines = M.collect()
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
