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
---Supports string items or {text, hl_group} tables.
function M.list_or_none(items)
  if not items or vim.tbl_isempty(items) then
    return { "  (none)" }
  end
  local out = {}
  for _, item in ipairs(items) do
    if type(item) == "table" then
      out[#out + 1] = { text = "  " .. item.text, hl_group = item.hl_group }
    else
      out[#out + 1] = "  " .. item
    end
  end
  return out
end

---Append a titled section to a line list.
function M.append_section(lines, title, items)
  M.add(lines, "")
  M.add(lines, title .. ":")
  for _, item in ipairs(M.list_or_none(items)) do
    if type(item) == "table" then
      M.add(lines, item.text)
    else
      M.add(lines, item)
    end
  end
end

---Add a line with optional full-line highlight.
function M.add_hl(lines, highlights, text, hl_group)
  local line_idx = #lines
  lines[#lines + 1] = text
  if hl_group then
    highlights[#highlights + 1] = {
      line = line_idx,
      col = 0,
      end_col = #text,
      hl_group = hl_group,
    }
  end
end

---Add a key-value pair with optional value highlight.
---The key is always highlighted with @keyword.
function M.add_kv_hl(lines, highlights, key, value, value_hl)
  local key_width = 22
  local line = ("%-" .. key_width .. "s %s"):format(key .. ":", value)
  local line_idx = #lines
  lines[#lines + 1] = line
  highlights[#highlights + 1] = {
    line = line_idx,
    col = 0,
    end_col = #key + 1,
    hl_group = "Keyword",
  }
  if value_hl then
    highlights[#highlights + 1] = {
      line = line_idx,
      col = key_width,
      end_col = #line,
      hl_group = value_hl,
    }
  end
end

---Append a titled section with separator and highlights.
---@param opts table|nil Optional config:
---   - title_hl: highlight group for the title (default "Function")
---   - sep_width: width of the separator line (default 58)
function M.append_section_hl(lines, highlights, title, items, opts)
  opts = opts or {}
  local title_hl = opts.title_hl or "Function"
  local sep_width = opts.sep_width or 58

  M.add_hl(lines, highlights, string.rep("─", sep_width), "NonText")
  M.add_hl(lines, highlights, title .. ":", title_hl)

  for _, item in ipairs(M.list_or_none(items)) do
    local line_idx = #lines
    if type(item) == "table" then
      lines[#lines + 1] = item.text
      if item.hl_group then
        highlights[#highlights + 1] = {
          line = line_idx,
          col = 0,
          end_col = #item.text,
          hl_group = item.hl_group,
        }
      end
    else
      lines[#lines + 1] = item
      if item == "  (none)" then
        highlights[#highlights + 1] = {
          line = line_idx,
          col = 0,
          end_col = #item,
          hl_group = "Comment",
        }
      else
        highlights[#highlights + 1] = {
          line = line_idx,
          col = 0,
          end_col = 2,
          hl_group = "Comment",
        }
      end
    end
  end
end

---Open a centered floating window with the given lines and title.
---Returns (bufnr, win). Window can be closed with `q` or `<Esc>`.
---@param opts table|nil Optional config:
---   - highlights: list of {line, col, end_col, hl_group} extmarks
function M.open_float(lines, title, opts)
  opts = opts or {}
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].filetype = "markdown"
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  local editor_width = vim.o.columns
  local editor_height = vim.o.lines
  local width = math.min(100, editor_width - 8)
  local height = math.min(math.max(10, #lines + 2), editor_height - 6)
  local row = math.floor((editor_height - height) / 2)
  local col = math.floor((editor_width - width) / 2)

  -- Adaptive separator lines: expand "─" runs to fit window content width.
  local content_width = math.max(1, width - 4)
  for i, line in ipairs(lines) do
    if line:match("^[─]+$") then
      local new_sep = string.rep("─", content_width)
      vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, { new_sep })
    end
  end

  vim.bo[bufnr].modifiable = false

  local ns_id = vim.api.nvim_create_namespace("ts_inject_float")
  for _, hl in ipairs(opts.highlights or {}) do
    local end_col = hl.end_col
    local line_text = vim.api.nvim_buf_get_lines(bufnr, hl.line, hl.line + 1, false)[1] or ""
    if line_text:match("^[─]+$") then
      end_col = #line_text
    end
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, hl.line, hl.col or 0, {
      end_col = end_col,
      hl_group = hl.hl_group,
    })
  end

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
  vim.wo[win].winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder,CursorLine:Visual"

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
