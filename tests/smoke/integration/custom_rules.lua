local function assert_generated_lua_ruby_rules()
  require("ts_inject").setup({
    enable = {
      lua = true,
      ruby = true,
    },
    rules = {
      lua = {
        builtin = false,
        items = {
          { kind = "var_suffix", suffix = "_qry", lang = "sql" },
          { kind = "call", fn = { "run_sql" }, lang = "sql" },
        },
      },
      ruby = {
        builtin = false,
        items = {
          { kind = "var_suffix", suffix = "_qry", lang = "sql" },
          { kind = "call", fn = { "run_sql" }, lang = "sql" },
        },
      },
    },
  })

  vim.cmd("TSInjectReload")

  assert_injected_in_lines("lua", {
    "report_qry = [[",
    "  SELECT id, email FROM users",
    "]]",
    "local db = {}",
    "function db:run_sql(sql) return sql end",
    'db:run_sql(("UPDATE users SET status = \'%s\' WHERE email = \'%s\'"):format("active", "alice@example.com"))',
  }, "SELECT id, email FROM users", "keyword_select")
  assert_injected_in_lines("lua", {
    "report_qry = [[",
    "  SELECT id, email FROM users",
    "]]",
    "local db = {}",
    "function db:run_sql(sql) return sql end",
    'db:run_sql(("UPDATE users SET status = \'%s\' WHERE email = \'%s\'"):format("active", "alice@example.com"))',
  }, "UPDATE users SET status", "keyword_update")

  assert_injected_in_lines("ruby", {
    "report_qry = <<~SQL",
    "  SELECT id, email FROM users",
    "  WHERE active = true",
    "SQL",
    "DB.run_sql(<<~SQL)",
    "  UPDATE users",
    "  SET status = 'active'",
    "  WHERE email = 'alice@example.com'",
    "SQL",
  }, "SELECT id, email FROM users", "keyword_select")
  assert_injected_in_lines("ruby", {
    "report_qry = <<~SQL",
    "  SELECT id, email FROM users",
    "  WHERE active = true",
    "SQL",
    "DB.run_sql(<<~SQL)",
    "  UPDATE users",
    "  SET status = 'active'",
    "  WHERE email = 'alice@example.com'",
    "SQL",
  }, "UPDATE users", "keyword_update")

  vim.cmd("TSInjectHealth")
  local report = table.concat(vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), 0, -1, false), "\n")
  assert(report:find("lua %(generated, builtin=off", 1) ~= nil, "health missing builtin=off status for lua")
  assert(report:find("ruby %(generated, builtin=off", 1) ~= nil, "health missing builtin=off status for ruby")
  assert(report:find("user_rules=2", 1, true) ~= nil, "health missing user rule count for lua/ruby")

  require("ts_inject").setup({
    enable = default_enable,
  })
end

local function assert_generated_template_tag_rules()
  require("ts_inject").setup({
    enable = {
      javascript = true,
      typescript = true,
      python = true,
    },
    rules = {
      javascript = {
        builtin = false,
        items = {
          { kind = "template_tag", fn = { "runSql" }, lang = "sql" },
        },
      },
      typescript = {
        builtin = false,
        items = {
          { kind = "template_tag", fn = { "runSql" }, lang = "sql" },
        },
      },
      python = {
        items = {
          { kind = "template_tag", fn = { "run_sql" }, lang = "sql" },
        },
      },
    },
  })

  vim.cmd("TSInjectReload")

  assert_injected_in_lines("javascript", {
    "const db = { runSql(strings, ...values) { return [strings, values]; } };",
    "db.runSql`",
    "  SELECT id, email FROM users",
    "  WHERE status = 'active'",
    "`;",
  }, "SELECT id, email FROM users", "keyword_select")

  assert_injected_in_lines("typescript", {
    "const db = { runSql(_strings: TemplateStringsArray, ..._values: unknown[]) { return []; } };",
    "db.runSql`",
    "  WITH recent_users AS (",
    "    SELECT id, email FROM users",
    "  )",
    "  SELECT id, email FROM recent_users",
    "`;",
  }, "WITH recent_users AS (", "keyword_with")

  vim.cmd("TSInjectHealth")
  local report = table.concat(vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), 0, -1, false), "\n")
  assert(
    report:find("python: template_tag rules are not supported for host python", 1, true) ~= nil,
    "health missing unsupported template_tag warning for python"
  )
  assert(
    report:find("javascript %(generated, builtin=off", 1) ~= nil,
    "health missing builtin=off status for javascript"
  )
  assert(
    report:find("typescript %(generated, builtin=off", 1) ~= nil,
    "health missing builtin=off status for typescript"
  )

  require("ts_inject").setup({
    enable = default_enable,
  })
end

local function assert_generated_script_content_prefix_rules()
  require("ts_inject").setup({
    enable = {
      python = true,
      ruby = true,
      lua = true,
      javascript = true,
    },
    rules = {
      python = {
        builtin = false,
        items = {
          { kind = "content_prefix", patterns = { "^%s*[Ss][Ee][Ll][Ee][Cc][Tt]%s+" }, lang = "sql" },
        },
      },
      ruby = {
        builtin = false,
        items = {
          { kind = "content_prefix", patterns = { "^%s*[Ww][Ii][Tt][Hh]%s+" }, lang = "sql" },
        },
      },
      lua = {
        builtin = false,
        items = {
          { kind = "content_prefix", patterns = { "^%s*[Uu][Pp][Dd][Aa][Tt][Ee]%s+" }, lang = "sql" },
        },
      },
      javascript = {
        items = {
          { kind = "content_prefix", patterns = { "^%s*[Ss][Ee][Ll][Ee][Cc][Tt]%s+" }, lang = "sql" },
        },
      },
    },
  })

  vim.cmd("TSInjectReload")

  assert_injected_in_lines("python", {
    "def run():",
    '  statement = "SELECT id, email FROM users"',
  }, "SELECT id, email FROM users", "keyword_select")

  assert_injected_in_lines("ruby", {
    "statement = <<~SQL",
    "  WITH recent_users AS (",
    "    SELECT id, email FROM users",
    "  )",
    "  SELECT id, email FROM recent_users",
    "SQL",
  }, "WITH recent_users AS (", "keyword_with")

  assert_injected_in_lines("lua", {
    "run_sql(",
    "  \"UPDATE users SET status = 'active' \" ..",
    "  \"WHERE email = 'alice@example.com'\"",
    ")",
  }, "UPDATE users", "keyword_update")

  vim.cmd("TSInjectHealth")
  local report = table.concat(vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), 0, -1, false), "\n")
  assert(
    report:find("javascript: content_prefix rules are not supported for host javascript", 1, true) ~= nil,
    "health missing unsupported content_prefix warning for javascript"
  )
  assert(report:find("python %(generated, builtin=off", 1) ~= nil, "health missing builtin=off status for python")
  assert(report:find("ruby %(generated, builtin=off", 1) ~= nil, "health missing builtin=off status for ruby")
  assert(report:find("lua %(generated, builtin=off", 1) ~= nil, "health missing builtin=off status for lua")

  require("ts_inject").setup({
    enable = default_enable,
  })
end

assert_generated_lua_ruby_rules()
assert_generated_template_tag_rules()
assert_generated_script_content_prefix_rules()
