local smoke = require("tests.smoke.init")
local function assert_reload_command()
  local opts = require("ts_inject").setup({
    enable = {
      python = true,
    },
    rules = {
      python = {
        builtin = false,
        items = {
          { kind = "call", fn = { "run_sql" }, lang = "sql" },
        },
      },
    },
  })
  assert(opts.rules ~= nil, "custom rules were not stored")

  vim.cmd("TSInjectReload")

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(bufnr)
  vim.bo[bufnr].filetype = "python"
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
    "def run(cursor):",
    '  cursor.run_sql("SELECT id FROM users")',
  })

  smoke.require_parser("python")
  smoke.require_parser("sql")

  local parser = vim.treesitter.get_parser(bufnr, "python")
  vim.treesitter.start(bufnr, "python")
  parser:parse(true)
  parser:parse(true)

  local node = vim.treesitter.get_node({
    bufnr = bufnr,
    pos = { 1, 18 },
    ignore_injections = false,
  })
  assert(node ~= nil, "reload test found no node")
  assert(node:type() == "keyword_select", ("reload rule did not inject custom SQL, got %s"):format(node:type()))

  local plain_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(plain_buf)
  vim.bo[plain_buf].filetype = "python"
  vim.api.nvim_buf_set_lines(plain_buf, 0, -1, false, {
    "def run(cursor):",
    '  cursor.execute("SELECT id FROM users")',
  })

  local plain_parser = vim.treesitter.get_parser(plain_buf, "python")
  vim.treesitter.start(plain_buf, "python")
  plain_parser:parse(true)
  plain_parser:parse(true)

  local plain_node = vim.treesitter.get_node({
    bufnr = plain_buf,
    pos = { 1, 18 },
    ignore_injections = false,
  })
  assert(plain_node ~= nil, "reload override test found no plain node")
  assert(
    plain_node:type() == "string_content",
    ("builtin=false did not disable builtin execute injection, got %s"):format(plain_node:type())
  )

  local health_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(health_buf)
  vim.cmd("TSInjectHealth")
  local report = table.concat(vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), 0, -1, false), "\n")
  assert(report:find("python %(generated, builtin=off", 1) ~= nil, "health missing builtin=off status for python")
  assert(report:find("user_rules=1", 1, true) ~= nil, "health missing user rule count")

  require("ts_inject").setup({
    enable = smoke.default_enable,
  })
end

assert_reload_command()
