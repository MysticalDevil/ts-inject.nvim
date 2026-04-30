local function append_if_dir(path)
  if vim.fn.isdirectory(path) == 1 then
    vim.opt.runtimepath:append(path)
  end
end

local function append_env_rtp(env_name)
  local value = vim.env[env_name]
  if not value or value == "" then
    return
  end

  for _, path in ipairs(vim.split(value, ":", { plain = true, trimempty = true })) do
    append_if_dir(vim.fn.expand(path))
  end
end

local default_enable = {
  bash = true,
  c = true,
  c_sharp = true,
  go = true,
  java = true,
  javascript = true,
  kotlin = true,
  lua = true,
  php = true,
  python = true,
  ruby = true,
  scala = true,
  rust = true,
  typescript = true,
  xml = true,
  zig = true,
}

append_env_rtp("TS_INJECT_TEST_RUNTIMEPATH")
vim.opt.runtimepath:append(vim.fn.getcwd())

local required_parsers = vim.tbl_keys(default_enable)
required_parsers[#required_parsers + 1] = "sql"
required_parsers[#required_parsers + 1] = "perl"
table.sort(required_parsers)

local function require_parser(lang)
  local ok, err = pcall(function()
    vim.treesitter.language.add(lang)
    vim.treesitter.get_string_parser("", lang)
  end)
  assert(ok, ("missing Tree-sitter parser for %s: %s"):format(lang, tostring(err)))
end

local function assert_debug_command_reconfigure()
  local ts_inject = require("ts_inject")

  ts_inject.setup({
    debug_command = "TSInjectSmokeDebugOne",
  })
  assert(vim.fn.exists(":TSInjectSmokeDebugOne") == 2, "custom debug command was not registered")
  assert(vim.fn.exists(":TSInjectDebug") == 0, "default debug command should not be registered")

  ts_inject.setup({
    debug_command = "TSInjectSmokeDebugTwo",
  })
  assert(vim.fn.exists(":TSInjectSmokeDebugTwo") == 2, "updated custom debug command was not registered")
  assert(vim.fn.exists(":TSInjectSmokeDebugOne") == 0, "old custom debug command was not removed")
end

assert_debug_command_reconfigure()

for _, lang in ipairs(required_parsers) do
  require_parser(lang)
end

require("ts_inject").setup({
  enable = default_enable,
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
  local original_buf = vim.api.nvim_get_current_buf()
  vim.cmd("TSInjectDebug")
  local debug_buf = vim.api.nvim_get_current_buf()
  local debug_lines = vim.api.nvim_buf_get_lines(debug_buf, 0, -1, false)
  local debug_text = table.concat(debug_lines, "\n")
  assert(debug_text:find("TSInject Debug", 1, true), "debug header missing")
  assert(debug_text:find("plugin_enabled", 1, true), "debug plugin section missing")
  vim.api.nvim_set_current_buf(original_buf)
end

local function assert_health_command()
  local original_buf = vim.api.nvim_get_current_buf()
  vim.cmd("TSInjectHealth")
  local health_buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(health_buf, 0, -1, false)
  local text = table.concat(lines, "\n")
  assert(text:find("TSInject Health", 1, true), "health header missing")
  assert(text:find("generated hosts", 1, true), "health generated hosts section missing")
  assert(text:find("legacy static hosts", 1, true), "health legacy static hosts section missing")
  assert(text:find("python", 1, true), "health missing generated python host")
  assert(text:find("ruby", 1, true), "health missing generated ruby host")
  assert(text:find("generated query status", 1, true), "health generated query section missing")
  vim.api.nvim_set_current_buf(original_buf)
end

local function assert_legacy_static_mode()
  require("ts_inject").setup({
    enable = {
      python = true,
    },
    query_mode = {
      python = "static",
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

  local custom_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(custom_buf)
  vim.bo[custom_buf].filetype = "python"
  vim.api.nvim_buf_set_lines(custom_buf, 0, -1, false, {
    "def run(cursor):",
    '  cursor.run_sql("SELECT id FROM users")',
  })
  require_parser("python")
  require_parser("sql")
  local custom_parser = vim.treesitter.get_parser(custom_buf, "python")
  vim.treesitter.start(custom_buf, "python")
  custom_parser:parse(true)
  custom_parser:parse(true)
  local custom_node = vim.treesitter.get_node({
    bufnr = custom_buf,
    pos = { 1, 18 },
    ignore_injections = false,
  })
  assert(custom_node ~= nil, "legacy static test found no custom node")
  assert(
    custom_node:type() == "string_content",
    ("legacy static mode should ignore generated custom rule, got %s"):format(custom_node:type())
  )

  local builtin_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(builtin_buf)
  vim.bo[builtin_buf].filetype = "python"
  vim.api.nvim_buf_set_lines(builtin_buf, 0, -1, false, {
    "def run(cursor):",
    '  cursor.execute("SELECT id FROM users")',
  })
  local builtin_parser = vim.treesitter.get_parser(builtin_buf, "python")
  vim.treesitter.start(builtin_buf, "python")
  builtin_parser:parse(true)
  builtin_parser:parse(true)
  local builtin_node = vim.treesitter.get_node({
    bufnr = builtin_buf,
    pos = { 1, 18 },
    ignore_injections = false,
  })
  assert(builtin_node ~= nil, "legacy static test found no builtin node")
  assert(
    builtin_node:type() == "keyword_select",
    ("legacy static mode should still use static builtin execute injection, got %s"):format(builtin_node:type())
  )

  vim.cmd("TSInjectHealth")
  local report = table.concat(vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), 0, -1, false), "\n")
  assert(report:find("legacy static hosts", 1, true), "health missing legacy static section")
  assert(report:find("python", 1, true), "health missing python legacy static entry")
  assert(
    report:find("static mode is legacy and not recommended", 1, true) ~= nil,
    "health missing legacy static warning"
  )

  require("ts_inject").setup({
    enable = default_enable,
  })
end

local function assert_buffer_loaded(file, filetype)
  vim.cmd("silent! %bwipeout!")
  local path = vim.fn.fnamemodify(file, ":p")
  local bufnr = vim.fn.bufadd(path)
  vim.fn.bufload(bufnr)
  vim.api.nvim_set_current_buf(bufnr)
  vim.bo[bufnr].filetype = filetype
  return bufnr
end

local function assert_injected_node(file, filetype, text, expected_type, target_lang)
  local bufnr = assert_buffer_loaded(file, filetype)
  local lang = target_lang or "sql"

  require_parser(filetype)
  require_parser(lang)

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

  assert(row ~= nil, "fixture text not found: " .. text)

  local parser = vim.treesitter.get_parser(bufnr, filetype)
  vim.treesitter.start(bufnr, filetype)
  parser:parse(true)
  parser:parse(true)

  local langs = collect_langs(parser)
  assert(vim.tbl_contains(langs, lang), (lang .. " language tree missing for " .. filetype))

  local node = vim.treesitter.get_node({
    bufnr = bufnr,
    pos = { row, col },
    ignore_injections = false,
  })
  assert(node ~= nil, "no node found at injected position for " .. filetype)
  assert(node:type() == expected_type, ("expected %s at injected position, got %s"):format(expected_type, node:type()))
end

local function assert_injected_in_lines(filetype, lines, text, expected_type, target_lang)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(bufnr)
  vim.bo[bufnr].filetype = filetype
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  local lang = target_lang or "sql"
  require_parser(filetype)
  require_parser(lang)

  local row, col
  for i, line in ipairs(lines) do
    local start_col = line:find(text, 1, true)
    if start_col then
      row = i - 1
      col = start_col - 1
      break
    end
  end

  assert(row ~= nil, "fixture text not found: " .. text)

  local parser = vim.treesitter.get_parser(bufnr, filetype)
  vim.treesitter.start(bufnr, filetype)
  parser:parse(true)
  parser:parse(true)

  local node = vim.treesitter.get_node({
    bufnr = bufnr,
    pos = { row, col },
    ignore_injections = false,
  })

  assert(node ~= nil, "no node found at injected position for " .. filetype)
  assert(node:type() == expected_type, ("expected %s at injected position, got %s"):format(expected_type, node:type()))
end

local function assert_language_trees(file, filetype, expected_langs)
  local bufnr = assert_buffer_loaded(file, filetype)

  require_parser(filetype)
  for _, lang in ipairs(expected_langs) do
    require_parser(lang)
  end

  local parser = vim.treesitter.get_parser(bufnr, filetype)
  vim.treesitter.start(bufnr, filetype)
  parser:parse(true)
  parser:parse(true)

  local langs = collect_langs(parser)
  for _, lang in ipairs(expected_langs) do
    assert(vim.tbl_contains(langs, lang), ("language tree missing for %s in %s"):format(lang, filetype))
  end
end

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

  require_parser("python")
  require_parser("sql")

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
    enable = default_enable,
  })
end

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

local function assert_debug_command(file, filetype)
  assert_buffer_loaded(file, filetype)
  assert_debug_header()
end

assert_debug_command("tests/fixtures/basic.go", "go")
assert_health_command()
assert_reload_command()
assert_generated_lua_ruby_rules()
assert_generated_template_tag_rules()
assert_generated_script_content_prefix_rules()
assert_legacy_static_mode()

assert_language_trees(
  "tests/fixtures/basic.sh",
  "bash",
  { "sql", "python", "lua", "javascript", "typescript", "ruby", "perl" }
)
assert_injected_node("tests/fixtures/basic.c", "c", "UPDATE users", "keyword_update")
assert_injected_node("tests/fixtures/basic.c", "c", "INSERT INTO users (email, status)", "keyword_insert")
assert_injected_node("tests/fixtures/basic.c", "c", "WITH recent_users AS (", "keyword_with")
assert_injected_node("tests/fixtures/basic.c", "c", "CREATE TABLE audit_logs (", "keyword_create")
assert_injected_node("tests/fixtures/basic.c", "c", "ORDER BY status", "keyword_order")
assert_injected_node("tests/fixtures/basic.c", "c", "ALTER TABLE audit_logs", "keyword_alter")
assert_injected_node("tests/fixtures/basic.c", "c", "GROUP BY user_id", "keyword_group")
assert_injected_node("tests/fixtures/basic.c", "c", "DELETE FROM audit_logs", "keyword_delete")
assert_injected_node("tests/fixtures/basic.c", "c", "CREATE INDEX", "keyword_create")
assert_injected_node("tests/fixtures/basic.c", "c", "row_number() OVER", "identifier")
assert_injected_node("tests/fixtures/basic.c", "c", "INSERT INTO audit_logs", "keyword_insert")
assert_injected_node("tests/fixtures/basic.c", "c", "CREATE TABLE projects", "keyword_create")
assert_injected_node("tests/fixtures/basic.c", "c", "SELECT email", "keyword_select")
assert_injected_node("tests/fixtures/basic.c", "c", "UPDATE projects", "keyword_update")
assert_injected_node("tests/fixtures/basic.c", "c", "INSERT INTO projects", "keyword_insert")
assert_injected_node("tests/fixtures/basic.c", "c", "DELETE FROM projects", "keyword_delete")
assert_injected_node("tests/fixtures/basic.c", "c", "WHERE name = 'core'", "keyword_where")
assert_injected_node("tests/fixtures/basic.c", "c", "WHERE id = $1", "keyword_where")
assert_injected_node("tests/fixtures/basic.c", "c", "WHERE name = $1", "keyword_where")
assert_injected_node("tests/fixtures/basic.c", "c", "ORDER BY name", "keyword_order")
assert_injected_node("tests/fixtures/basic.c", "c", "WHERE id > 0", "keyword_where")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "SELECT id, email", "keyword_select")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "UPDATE users", "keyword_update")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "INSERT INTO users (email, status)", "keyword_insert")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "WITH recent_users AS (", "keyword_with")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "CREATE TABLE audit_logs (", "keyword_create")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "ALTER TABLE audit_logs", "keyword_alter")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "GROUP BY user_id", "keyword_group")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "UPDATE audit_logs", "keyword_update")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "INSERT INTO audit_logs", "keyword_insert")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "DELETE FROM audit_logs", "keyword_delete")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "CREATE INDEX idx_audit_logs_message", "keyword_create")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "ORDER BY id", "keyword_order")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "ALTER TABLE audit_logs ADD COLUMN updated_at", "keyword_alter")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "WHERE email = $1", "keyword_where")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "WHERE message = $1", "keyword_where")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "WHERE message = 'created'", "keyword_where")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "CREATE TABLE events (", "keyword_create")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "WHERE name = ?", "keyword_where")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "SELECT count(*)", "keyword_select")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "FROM marked_users", "keyword_from")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "DELETE FROM marked_users", "keyword_delete")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "FROM qt_users", "keyword_from")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "FROM sqlite_users", "keyword_from")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "FROM free_query_users", "keyword_from")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "FROM soci_users", "keyword_from")
assert_injected_node("tests/fixtures/basic.cpp", "cpp", "FROM soci_prepared_users", "keyword_from")
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
assert_injected_node("tests/fixtures/basic.java", "java", "FROM comment_marked_users", "keyword_from")
assert_injected_node("tests/fixtures/basic.java", "java", "DELETE FROM comment_marked_users", "keyword_delete")
assert_injected_node("tests/fixtures/basic.java", "java", "FROM annotated_users", "keyword_from")
assert_injected_node("tests/fixtures/basic.java", "java", "SELECT active_id", "keyword_select")
assert_injected_node("tests/fixtures/basic.java", "java", "INSERT INTO annotated_users", "keyword_insert")
assert_injected_node("tests/fixtures/basic.java", "java", "UPDATE annotated_users", "keyword_update")
assert_injected_node("tests/fixtures/basic.java", "java", "DELETE FROM annotated_users", "keyword_delete")
assert_injected_node("tests/fixtures/basic.java", "java", "FROM spring_users", "keyword_from")
assert_injected_node("tests/fixtures/basic.java", "java", "FROM spring_reversed_users", "keyword_from")
assert_injected_node("tests/fixtures/basic.java", "java", "FROM hibernate_subselect_users", "keyword_from")
assert_injected_node("tests/fixtures/basic.java", "java", "INSERT INTO hibernate_users", "keyword_insert")
assert_injected_node("tests/fixtures/basic.java", "java", "DELETE FROM hibernate_users", "keyword_delete")
assert_injected_node("tests/fixtures/basic.java", "java", "FROM jpa_native_users", "keyword_from")
assert_injected_node("tests/fixtures/basic.java", "java", "FROM User u", "keyword_from")
assert_injected_node("tests/fixtures/basic.java", "java", "FROM jdbc_template_users", "keyword_from")
assert_injected_node("tests/fixtures/basic.java", "java", "UPDATE jdbc_template_users", "keyword_update")
assert_injected_node("tests/fixtures/basic.java", "java", "FROM jdbi_users", "keyword_from")
assert_injected_node("tests/fixtures/basic.java", "java", "UPDATE jdbi_users", "keyword_update")
assert_injected_node("tests/fixtures/basic.java", "java", "FROM jooq_users", "keyword_from")
assert_injected_node("tests/fixtures/basic.java", "java", "FROM jooq_result_users", "keyword_from")
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
assert_injected_node("tests/fixtures/basic.lua", "lua", "UPDATE users SET status = '%s'", "keyword_update")
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
assert_injected_node(
  "tests/fixtures/basic.rb",
  "ruby",
  "SELECT id, email FROM users WHERE active = true",
  "keyword_select"
)
assert_injected_node("tests/fixtures/basic.rb", "ruby", "CREATE TABLE users (", "keyword_create")
assert_injected_node("tests/fixtures/basic.rb", "ruby", "GROUP BY status", "keyword_group")
assert_injected_node("tests/fixtures/basic.rb", "ruby", "UPDATE users", "keyword_update")
assert_injected_node("tests/fixtures/basic.rb", "ruby", "INSERT INTO users (email, status)", "keyword_insert")
assert_injected_node("tests/fixtures/basic.rb", "ruby", "WITH recent_users AS (", "keyword_with")
assert_injected_node("tests/fixtures/basic.rb", "ruby", "ALTER TABLE users", "keyword_alter")
assert_injected_node("tests/fixtures/basic.rs", "rust", "CREATE TABLE users (", "keyword_create")
assert_injected_node("tests/fixtures/basic.rs", "rust", "INSERT INTO users (email)", "keyword_insert")
assert_injected_node(
  "tests/fixtures/basic.scala",
  "scala",
  "SELECT id, email FROM users WHERE active = true",
  "keyword_select"
)
assert_injected_node("tests/fixtures/basic.scala", "scala", "CREATE TABLE users (", "keyword_create")
assert_injected_node("tests/fixtures/basic.scala", "scala", "GROUP BY status", "keyword_group")
assert_injected_node("tests/fixtures/basic.scala", "scala", "UPDATE users", "keyword_update")
assert_injected_node("tests/fixtures/basic.scala", "scala", "INSERT INTO users (email, status)", "keyword_insert")
assert_injected_node("tests/fixtures/basic.scala", "scala", "WITH recent_users AS (", "keyword_with")
assert_injected_node("tests/fixtures/basic.scala", "scala", "ALTER TABLE users", "keyword_alter")
assert_injected_node("tests/fixtures/basic.ts", "typescript", "UPDATE users", "keyword_update")
assert_injected_node(
  "tests/fixtures/basic.ts",
  "typescript",
  "CREATE TABLE IF NOT EXISTS audit_logs (",
  "keyword_create"
)
assert_injected_node("tests/fixtures/basic.ts", "typescript", "WITH recent_users AS (", "keyword_with")
assert_injected_node("tests/fixtures/basic.xml", "xml", "FROM xml_users", "keyword_from")
assert_injected_node("tests/fixtures/basic.xml", "xml", "INSERT INTO xml_users", "keyword_insert")
assert_injected_node("tests/fixtures/basic.xml", "xml", "UPDATE xml_users", "keyword_update")
assert_injected_node("tests/fixtures/basic.xml", "xml", "DELETE FROM xml_users", "keyword_delete")
assert_injected_node("tests/fixtures/basic.xml", "xml", "FROM dynamic_xml_users", "keyword_from")
assert_injected_node("tests/fixtures/basic.xml", "xml", "UPDATE dynamic_xml_users", "keyword_update")
assert_injected_node("tests/fixtures/basic.xml", "xml", "FROM conditional_xml_users", "keyword_from")
assert_injected_node("tests/fixtures/basic.zig", "zig", "SELECT id, email", "keyword_select")
assert_injected_node("tests/fixtures/basic.zig", "zig", "CREATE TABLE audit_logs (", "keyword_create")
assert_injected_node("tests/fixtures/basic.zig", "zig", "WITH recent_users AS (", "keyword_with")
assert_injected_node("tests/fixtures/basic.zig", "zig", "UPDATE users", "keyword_update")
assert_injected_node("tests/fixtures/basic.zig", "zig", "INSERT INTO users (email)", "keyword_insert")

print("smoke test passed")
