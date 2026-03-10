local function append_if_dir(path)
  if vim.fn.isdirectory(path) == 1 then
    vim.opt.runtimepath:append(path)
  end
end

append_if_dir(vim.fn.expand("~/.local/share/nvim-mini/site"))
append_if_dir(vim.fn.expand("~/.local/share/nvim/site"))
vim.opt.runtimepath:append(vim.fn.getcwd())

require("ts_inject").setup({
  enable = {
    c = true,
    c_sharp = true,
    go = true,
    java = true,
    javascript = true,
    kotlin = true,
    lua = true,
    php = true,
    python = true,
    rust = true,
    typescript = true,
    zig = true,
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
  pcall(vim.treesitter.language.add, filetype)
  pcall(vim.treesitter.language.add, "sql")
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
  vim.treesitter.start(bufnr, filetype)
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

assert_injected_node("tests/fixtures/basic.c", "c", "SELECT id, email", "keyword_select")
assert_injected_node("tests/fixtures/basic.c", "c", "UPDATE users", "keyword_update")
assert_injected_node("tests/fixtures/basic.c", "c", "INSERT INTO users (email, status)", "keyword_insert")
assert_injected_node("tests/fixtures/basic.c", "c", "WITH recent_users AS (", "keyword_with")
assert_injected_node("tests/fixtures/basic.c", "c", "CREATE TABLE audit_logs (", "keyword_create")
assert_injected_node("tests/fixtures/basic.c", "c", "ORDER BY created_at DESC", "keyword_order")
assert_injected_node("tests/fixtures/basic.c", "c", "GROUP BY status", "keyword_group")
assert_injected_node("tests/fixtures/basic.c", "c", "ORDER BY created_at DESC", "keyword_order")
assert_injected_node("tests/fixtures/basic.c", "c", "DELETE FROM users", "keyword_delete")
assert_injected_node("tests/fixtures/basic.c", "c", "ALTER TABLE audit_logs", "keyword_alter")
assert_injected_node("tests/fixtures/basic.go", "go", "SELECT id, name", "keyword_select")
assert_injected_node("tests/fixtures/basic.cs", "c_sharp", "SELECT Id, Email", "keyword_select")
assert_injected_node("tests/fixtures/basic.cs", "c_sharp", "UPDATE Users", "keyword_update")
assert_injected_node("tests/fixtures/basic.cs", "c_sharp", "INSERT INTO Users (Email, Status)", "keyword_insert")
assert_injected_node("tests/fixtures/basic.cs", "c_sharp", "WITH recent_users AS (", "keyword_with")
assert_injected_node("tests/fixtures/basic.cs", "c_sharp", "CREATE TABLE AuditLogs (", "keyword_create")
assert_injected_node("tests/fixtures/basic.cs", "c_sharp", "GROUP BY Status", "keyword_group")
assert_injected_node("tests/fixtures/basic.cs", "c_sharp", "DELETE FROM Users", "keyword_delete")
assert_injected_node("tests/fixtures/basic.cs", "c_sharp", "ALTER TABLE AuditLogs", "keyword_alter")
assert_injected_node("tests/fixtures/basic.java", "java", "SELECT id, email", "keyword_select")
assert_injected_node("tests/fixtures/basic.java", "java", "UPDATE users", "keyword_update")
assert_injected_node("tests/fixtures/basic.java", "java", "INSERT INTO users (email, status)", "keyword_insert")
assert_injected_node("tests/fixtures/basic.java", "java", "WITH recent_users AS (", "keyword_with")
assert_injected_node("tests/fixtures/basic.java", "java", "CREATE TABLE audit_logs (", "keyword_create")
assert_injected_node("tests/fixtures/basic.java", "java", "GROUP BY status", "keyword_group")
assert_injected_node("tests/fixtures/basic.java", "java", "DELETE FROM users", "keyword_delete")
assert_injected_node("tests/fixtures/basic.java", "java", "ALTER TABLE audit_logs", "keyword_alter")
assert_injected_node("tests/fixtures/basic.js", "javascript", "SELECT id, email", "keyword_select")
assert_injected_node("tests/fixtures/basic.js", "javascript", "GROUP BY status", "keyword_group")
assert_injected_node("tests/fixtures/basic.js", "javascript", "UPDATE users", "keyword_update")
assert_injected_node("tests/fixtures/basic.js", "javascript", "ON CONFLICT (email)", "keyword_on")
assert_injected_node("tests/fixtures/basic.js", "javascript", "DELETE FROM users", "keyword_delete")
assert_injected_node("tests/fixtures/basic.kt", "kotlin", "SELECT id, email", "keyword_select")
assert_injected_node("tests/fixtures/basic.kt", "kotlin", "UPDATE users", "keyword_update")
assert_injected_node("tests/fixtures/basic.kt", "kotlin", "INSERT INTO users (email, status)", "keyword_insert")
assert_injected_node("tests/fixtures/basic.kt", "kotlin", "CREATE TABLE audit_logs (", "keyword_create")
assert_injected_node("tests/fixtures/basic.kt", "kotlin", "WITH recent_users AS (", "keyword_with")
assert_injected_node("tests/fixtures/basic.kt", "kotlin", "GROUP BY status", "keyword_group")
assert_injected_node("tests/fixtures/basic.kt", "kotlin", "DELETE FROM users", "keyword_delete")
assert_injected_node("tests/fixtures/basic.kt", "kotlin", "ALTER TABLE users", "keyword_alter")
assert_injected_node("tests/fixtures/basic.lua", "lua", "SELECT id, email", "keyword_select")
assert_injected_node("tests/fixtures/basic.lua", "lua", "CREATE TABLE users (", "keyword_create")
assert_injected_node("tests/fixtures/basic.lua", "lua", "WITH recent_users AS (", "keyword_with")
assert_injected_node("tests/fixtures/basic.lua", "lua", "INSERT INTO users (email, status)", "keyword_insert")
assert_injected_node("tests/fixtures/basic.php", "php", "SELECT id, email", "keyword_select")
assert_injected_node("tests/fixtures/basic.php", "php", "UPDATE users", "keyword_update")
assert_injected_node("tests/fixtures/basic.php", "php", "INSERT INTO users (email, status)", "keyword_insert")
assert_injected_node("tests/fixtures/basic.php", "php", "WITH recent_users AS (", "keyword_with")
assert_injected_node("tests/fixtures/basic.php", "php", "CREATE TABLE audit_logs (", "keyword_create")
assert_injected_node("tests/fixtures/basic.php", "php", "GROUP BY status", "keyword_group")
assert_injected_node("tests/fixtures/basic.php", "php", "DELETE FROM users", "keyword_delete")
assert_injected_node("tests/fixtures/basic.php", "php", "ALTER TABLE audit_logs", "keyword_alter")
assert_injected_node("tests/fixtures/basic.py", "python", "CREATE TABLE users (", "keyword_create")
assert_injected_node("tests/fixtures/basic.py", "python", "DELETE FROM users", "keyword_delete")
assert_injected_node("tests/fixtures/basic.rs", "rust", "CREATE TABLE users (", "keyword_create")
assert_injected_node("tests/fixtures/basic.rs", "rust", "INSERT INTO users (email)", "keyword_insert")
assert_injected_node("tests/fixtures/basic.ts", "typescript", "UPDATE users", "keyword_update")
assert_injected_node("tests/fixtures/basic.ts", "typescript", "CREATE TABLE IF NOT EXISTS audit_logs (", "keyword_create")
assert_injected_node("tests/fixtures/basic.ts", "typescript", "WITH recent_users AS (", "keyword_with")
assert_injected_node("tests/fixtures/basic.zig", "zig", "SELECT id, email", "keyword_select")
assert_injected_node("tests/fixtures/basic.zig", "zig", "CREATE TABLE audit_logs (", "keyword_create")
assert_injected_node("tests/fixtures/basic.zig", "zig", "WITH recent_users AS (", "keyword_with")
assert_injected_node("tests/fixtures/basic.zig", "zig", "UPDATE users", "keyword_update")
assert_injected_node("tests/fixtures/basic.zig", "zig", "INSERT INTO users (email)", "keyword_insert")

print("smoke test passed")
