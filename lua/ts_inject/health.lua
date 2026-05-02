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

      local present = vim.fn.filereadable(status.path or "") == 1 and "present" or "missing"
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
  add(lines, ("%-18s %d enabled, %d generated, %d static"):format("summary:", total, #generated, #static))
  if #legacy_static > 0 then
    add(lines, ("%-18s %d host(s) forced to static mode"):format("", #legacy_static))
  end
  if #error_hosts > 0 then
    add(lines, ("%-18s %d host(s) with errors"):format("", #error_hosts))
  end

  append_section(lines, "enabled hosts", enabled)
  append_section(lines, "generated hosts", generated)
  append_section(lines, "static hosts", static)
  append_section(lines, "legacy static hosts", legacy_static)
  append_section(lines, "host status", host_status)
  append_section(lines, "generated query status", generated_paths)
  append_section(lines, "errors", error_hosts)

  local parser_lines = {}
  for _, host in ipairs(enabled) do
    local files = vim.api.nvim_get_runtime_file(("parser/%s.*"):format(host), true)
    parser_lines[#parser_lines + 1] = ("%s: %s"):format(host, (#files > 0) and "ok" or "missing")
  end
  local sql_files = vim.api.nvim_get_runtime_file("parser/sql.*", true)
  parser_lines[#parser_lines + 1] = ("sql: %s"):format((#sql_files > 0) and "ok" or "missing")
  local gql_files = vim.api.nvim_get_runtime_file("parser/graphql.*", true)
  parser_lines[#parser_lines + 1] = ("graphql: %s"):format((#gql_files > 0) and "ok" or "missing")
  append_section(lines, "parser availability", parser_lines)

  append_section(lines, "warnings", state.warnings)
  return lines
end

local function open_float(lines, title)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].filetype = "markdown"
  local sanitized = {}
  for _, line in ipairs(lines) do
    sanitized[#sanitized + 1] = (line:gsub("\n", " "))
  end
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, sanitized)
  vim.bo[bufnr].modifiable = false

  local editor_width = vim.o.columns
  local editor_height = vim.o.lines
  local width = math.min(80, editor_width - 8)
  local height = math.min(math.max(10, #lines + 2), editor_height - 6)
  local row = math.floor((editor_height - height) / 2)
  local col = math.floor((editor_width - width) / 2)

  local win = vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " " .. title .. " ",
    title_pos = "center",
  })

  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true

  local close = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  vim.keymap.set("n", "q", close, { buffer = bufnr, silent = true, nowait = true })
  vim.keymap.set("n", "<Esc>", close, { buffer = bufnr, silent = true, nowait = true })

  return bufnr, win
end

function M.show()
  local lines = M.collect()
  return open_float(lines, "TSInject Health")
end

return M
