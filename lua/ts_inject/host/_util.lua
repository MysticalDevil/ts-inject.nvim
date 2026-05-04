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

---Generate Tree-sitter query sibling-anchoring prefix for the Nth argument.
---For arg_index=1: returns "." (first sibling anchor)
---For arg_index=2: returns "(_)
---  ." (skip one, then anchor)
---For arg_index=3: returns "(_)
---  .
---  (_)
---  ." etc.
function M.arg_prefix(arg_index)
  local args_prefix = {}
  if arg_index == 1 then
    args_prefix[#args_prefix + 1] = "      ."
  else
    for _ = 1, arg_index - 1 do
      args_prefix[#args_prefix + 1] = "      (_)"
      args_prefix[#args_prefix + 1] = "      ."
    end
  end
  return table.concat(args_prefix, "\n")
end

---Append a line to a list (debug/health output builder).
function M.add(lines, line)
  lines[#lines + 1] = line
end

---Append a "key: value" pair, left-aligned.
function M.add_kv(lines, key, value)
  M.add(lines, ("%-18s %s"):format(key .. ":", value))
end

---Return a list with "(none)" if empty, otherwise prefix each item with two spaces.
function M.list_or_none(items)
  if not items or vim.tbl_isempty(items) then
    return { "  (none)" }
  end
  local out = {}
  for _, item in ipairs(items) do
    out[#out + 1] = "  " .. item
  end
  return out
end

---Append a titled section to a line list.
function M.append_section(lines, title, items)
  M.add(lines, "")
  M.add(lines, title .. ":")
  for _, item in ipairs(M.list_or_none(items)) do
    M.add(lines, item)
  end
end

---Open a centered floating window with the given lines and title.
---Returns (bufnr, win). Window can be closed with `q` or `<Esc>`.
function M.open_float(lines, title)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].filetype = "markdown"
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
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

function M.build_dispatcher(opts)
  opts = opts or {}
  local header = opts.header or ""
  local renderers = opts.renderers or {}
  local static_preamble = opts.static_preamble
  return function(rules, render_opts)
    local blocks = {}
    for _, rule in ipairs(rules or {}) do
      local rendered = {}
      local renderer = renderers[rule.kind]
      if renderer then
        rendered = renderer(rule, render_opts)
      else
        return nil, ("unsupported rule kind: %s"):format(rule.kind)
      end
      vim.list_extend(blocks, rendered)
    end
    local body = table.concat(blocks, "\n")
    local parts = {}
    if header ~= "" then
      parts[#parts + 1] = header
    end
    if static_preamble then
      parts[#parts + 1] = static_preamble
    end
    if body ~= "" then
      parts[#parts + 1] = body
    end
    return table.concat(parts, "\n")
  end
end

return M
