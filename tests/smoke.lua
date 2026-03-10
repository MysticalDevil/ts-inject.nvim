vim.opt.runtimepath:append(vim.fn.getcwd())

require("ts_inject").setup({
  enable = {
    go = true,
    python = true,
  },
})

local function collect_langs(parser)
  local langs = {}

  local function collect(langtree)
    langs[#langs + 1] = langtree:lang()
    for _, child in pairs(langtree:children() or {}) do
      collect(child)
    end
  end

  collect(parser)
  return langs
end

local function assert_debug_header()
  vim.cmd("TSInjectDebug")
  local debug_buf = vim.api.nvim_get_current_buf()
  local debug_lines = vim.api.nvim_buf_get_lines(debug_buf, 0, -1, false)
  local debug_text = table.concat(debug_lines, "\n")
  assert(debug_text:find("TSInject Debug", 1, true), "debug header missing")
  assert(debug_text:find("plugin_enabled", 1, true), "debug plugin section missing")
  vim.cmd.bprevious()
end

local function assert_injected_node(file, filetype, text, expected_type)
  vim.cmd.edit(vim.fn.fnamemodify(file, ":p"))
  vim.bo.filetype = filetype
  assert_debug_header()

  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local row, col

  for i, line in ipairs(lines) do
    local start_col = line:find(text, 1, true)
    if start_col then
      row = i - 1
      col = start_col - 1
      break
    end
  end

  assert(row ~= nil, "fixture SQL not found: " .. text)

  local parser = vim.treesitter.get_parser(bufnr, filetype)
  parser:parse(true)
  parser:parse(true)

  local langs = collect_langs(parser)
  assert(vim.tbl_contains(langs, "sql"), "sql language tree missing for " .. filetype)

  local node = vim.treesitter.get_node({
    bufnr = bufnr,
    pos = { row, col },
    ignore_injections = false,
  })
  assert(node ~= nil, "no node found at injected SQL position for " .. filetype)
  assert(node:type() == expected_type, ("expected %s at injected position, got %s"):format(expected_type, node:type()))
end

assert_injected_node("tests/fixtures/basic.go", "go", "SELECT id, name", "keyword_select")
assert_injected_node("tests/fixtures/basic.py", "python", "CREATE TABLE users (", "keyword_create")
assert_injected_node("tests/fixtures/basic.py", "python", "DELETE FROM users", "keyword_delete")

print("smoke test passed")
