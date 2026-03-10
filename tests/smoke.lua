vim.opt.runtimepath:append(vim.fn.getcwd())

require("ts_inject").setup()

local fixture = vim.fn.fnamemodify("tests/fixtures/basic.go", ":p")
vim.cmd.edit(fixture)
vim.bo.filetype = "go"

vim.cmd("TSInjectDebug")

local debug_buf = vim.api.nvim_get_current_buf()
local debug_lines = vim.api.nvim_buf_get_lines(debug_buf, 0, -1, false)
local debug_text = table.concat(debug_lines, "\n")

assert(debug_text:find("TSInject Debug", 1, true), "debug header missing")
assert(debug_text:find("injection query files", 1, true), "debug query section missing")

vim.cmd.bprevious()

local source_buf = vim.api.nvim_get_current_buf()
local source_lines = vim.api.nvim_buf_get_lines(source_buf, 0, -1, false)
local row, col

for i, line in ipairs(source_lines) do
  local start_col = line:find("SELECT id, name", 1, true)
  if start_col then
    row = i - 1
    col = start_col - 1
    break
  end
end

assert(row ~= nil, "fixture SQL not found")

local parser = vim.treesitter.get_parser(source_buf, "go")
parser:parse(true)
parser:parse(true)

local langtree_text = {}
local function collect(langtree)
  langtree_text[#langtree_text + 1] = langtree:lang()
  for _, child in pairs(langtree:children() or {}) do
    collect(child)
  end
end
collect(parser)

assert(vim.tbl_contains(langtree_text, "sql"), "sql language tree missing")

local query_files = vim.treesitter.query.get_files("go", "injections")
local found_plugin_query = false
for _, path in ipairs(query_files) do
  if path == "./queries/go/injections.scm" or path:match("ts%-inject%.nvim/queries/go/injections%.scm$") then
    found_plugin_query = true
    break
  end
end
assert(found_plugin_query, "plugin go injection query not active")

local node = vim.treesitter.get_node({
  bufnr = source_buf,
  pos = { row, col },
  ignore_injections = false,
})
assert(node ~= nil, "no node found at injected SQL position")
assert(node:type() == "keyword_select", "expected SQL node at injected position")

print("smoke test passed")
