vim.opt.runtimepath:append(vim.fn.getcwd())

local ts_inject = require("ts_inject")
local query_builder = require("ts_inject.query_builder")

-- Language list: all 19 hosts + injection targets
local hosts = {
  "bash", "c", "cpp", "c_sharp", "elixir", "go", "java", "javascript",
  "kotlin", "lua", "perl", "php", "python", "ruby", "rust", "scala",
  "typescript", "xml", "zig",
}

local inject_targets = { "sql", "graphql", "regex", "json", "python", "lua", "javascript", "typescript", "ruby", "perl" }

local all_enable = {}
for _, host in ipairs(hosts) do
  all_enable[host] = true
end

local results = {
  passed = 0,
  failed = 0,
  errors = {},
}

local function ok(msg)
  results.passed = results.passed + 1
  print("  [PASS] " .. msg)
end

local function fail(msg)
  results.failed = results.failed + 1
  table.insert(results.errors, msg)
  print("  [FAIL] " .. msg)
end

local function section(title)
  print("\n=== " .. title .. " ===")
end

-- Setup BEFORE any buffer / vim.treesitter.start() calls
section("Setup")
ts_inject.setup({ enable = all_enable })
ok("ts_inject.setup() with all hosts enabled")

-- Ensure all parsers exist
section("Parser Availability")
for _, lang in ipairs(vim.list_extend(vim.deepcopy(hosts), inject_targets)) do
  local parser_ok, parser_err = pcall(function()
    vim.treesitter.language.add(lang)
    vim.treesitter.get_string_parser("", lang)
  end)
  if parser_ok then
    ok("parser: " .. lang)
  else
    fail("parser missing: " .. lang .. " -> " .. tostring(parser_err))
  end
end

-- Section 1: Query generation for all hosts
section("Query Generation (All 19 Hosts)")
for _, host in ipairs(hosts) do
  local gen_ok, gen_err = pcall(function()
    local query = query_builder.build(host)
    if not query or query == "" then
      error("empty query")
    end
    return query
  end)
  if gen_ok then
    ok("generate: " .. host)
  else
    fail("generate: " .. host .. " -> " .. tostring(gen_err))
  end
end

-- Section 2: Query parseability
section("Query Parseability (All 19 Hosts)")
for _, host in ipairs(hosts) do
  local parse_ok, parse_err = pcall(function()
    local query = query_builder.build(host)
    if not query or query == "" then
      error("empty query")
    end
    vim.treesitter.query.parse(host, query)
  end)
  if parse_ok then
    ok("parseable: " .. host)
  else
    fail("parseable: " .. host .. " -> " .. tostring(parse_err))
  end
end

-- Section 3: Actual injection matching on fixtures
section("Injection Matching (All Fixture Files)")

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

local function load_fixture(file, filetype)
  local path = vim.fn.fnamemodify(file, ":p")
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(buf) == path then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
  local bufnr = vim.fn.bufadd(path)
  vim.fn.bufload(bufnr)
  vim.api.nvim_set_current_buf(bufnr)
  vim.bo[bufnr].filetype = filetype
  return bufnr
end

local function test_fixture(file, filetype, expected_langs, test_cases)
  local bufnr = load_fixture(file, filetype)

  vim.treesitter.language.add(filetype)
  for _, lang in ipairs(expected_langs) do
    vim.treesitter.language.add(lang)
  end

  local parser = vim.treesitter.get_parser(bufnr, filetype)
  vim.treesitter.start(bufnr, filetype)
  parser:parse(true)
  parser:parse(true)
  parser:parse(true)

  local langs = collect_langs(parser)
  for _, lang in ipairs(expected_langs) do
    local found = false
    for _, l in ipairs(langs) do
      if l == lang then
        found = true
        break
      end
    end
    if found then
      ok(filetype .. " injects " .. lang)
    else
      fail(filetype .. " missing injection: " .. lang)
    end
  end

  if test_cases then
    for _, tc in ipairs(test_cases) do
      local text, expected_type, target_lang = tc[1], tc[2], tc[3] or "sql"
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
      if row == nil then
        fail(filetype .. " text not found: " .. text)
      else
        local node = vim.treesitter.get_node({
          bufnr = bufnr,
          pos = { row, col },
          ignore_injections = false,
        })
        if node and node:type() == expected_type then
          ok(filetype .. " node " .. expected_type .. " at '" .. text .. "'")
        else
          local actual = node and node:type() or "nil"
          fail(filetype .. " expected " .. expected_type .. " got " .. actual .. " at '" .. text .. "'")
        end
      end
    end
  end

  vim.cmd("silent! %bwipeout!")
end

-- bash: SQL + other language heredocs + regex + json + graphql
test_fixture("tests/fixtures/basic.sh", "bash",
  { "sql", "python", "lua", "javascript", "typescript", "ruby", "perl", "graphql", "json", "regex" },
  {
    { "SELECT id, email", "keyword_select" },
    { "UPDATE users SET status", "keyword_update" },
    { "LEFT JOIN projects", "keyword_left" },
    { "WITH ranked AS", "keyword_with" },
  }
)

-- c: SQL + asm (regex in separate fixture)
test_fixture("tests/fixtures/basic.c", "c", { "sql", "asm" },
  {
    { "UPDATE users", "keyword_update" },
    { "CREATE TABLE audit_logs", "keyword_create" },
    { "WITH ranked AS", "keyword_with" },
  }
)
test_fixture("tests/fixtures/basic_regex.c", "c", { "regex" },
  {
    { "a-z", "class_character", "regex" },
  }
)

-- cpp: SQL (regex in separate fixture)
test_fixture("tests/fixtures/basic.cpp", "cpp", { "sql" },
  {
    { "SELECT id, email", "keyword_select" },
    { "ALTER TABLE audit_logs", "keyword_alter" },
    { "LEFT JOIN projects", "keyword_left" },
  }
)
test_fixture("tests/fixtures/basic_regex.cpp", "cpp", { "regex" },
  {
    { "a-z", "class_character", "regex" },
  }
)

-- c_sharp: SQL (graphql + regex in separate fixtures)
test_fixture("tests/fixtures/basic.cs", "c_sharp", { "sql" },
  {
    { "SELECT Id, Email", "keyword_select" },
    { "UPDATE Users", "keyword_update" },
    { "LEFT JOIN projects", "keyword_left" },
  }
)
test_fixture("tests/fixtures/basic_graphql.cs", "c_sharp", { "graphql" },
  {
    { "query GetUser", "operation_type", "graphql" },
    { "fragment UserFields", "fragment_definition", "graphql" },
  }
)
test_fixture("tests/fixtures/basic_regex.cs", "c_sharp", { "regex" },
  {
    { "a-z", "class_character", "regex" },
  }
)

-- elixir: SQL
test_fixture("tests/fixtures/basic.ex", "elixir", { "sql" },
  {
    { "SELECT id, email", "keyword_select" },
    { "UPDATE users SET status", "keyword_update" },
    { "LEFT JOIN projects", "keyword_left" },
  }
)

-- go: SQL (graphql in separate fixture)
test_fixture("tests/fixtures/basic.go", "go", { "sql" },
  {
    { "SELECT id, name", "keyword_select" },
    { "LEFT JOIN projects", "keyword_left" },
    { "row_number() OVER", "identifier" },
  }
)
test_fixture("tests/fixtures/basic_graphql.go", "go", { "graphql" },
  {
    { "query GetUser", "operation_type", "graphql" },
    { "fragment UserFields", "fragment_definition", "graphql" },
  }
)

-- java: SQL (graphql + regex in separate fixtures)
test_fixture("tests/fixtures/basic.java", "java", { "sql" },
  {
    { "SELECT id, email", "keyword_select" },
    { "UPDATE users", "keyword_update" },
    { "LEFT JOIN projects", "keyword_left" },
  }
)
test_fixture("tests/fixtures/basic_graphql.java", "java", { "graphql" },
  {
    { "query GetUser", "operation_type", "graphql" },
    { "fragment UserFields", "fragment_definition", "graphql" },
  }
)
test_fixture("tests/fixtures/basic_regex.java", "java", { "regex" },
  {
    { "a-z", "class_character", "regex" },
  }
)

-- javascript: SQL (graphql in separate fixture)
test_fixture("tests/fixtures/basic.js", "javascript", { "sql" },
  {
    { "SELECT id, email", "keyword_select" },
    { "UPDATE users", "keyword_update" },
    { "LEFT JOIN projects", "keyword_left" },
  }
)
test_fixture("tests/fixtures/basic_graphql.js", "javascript", { "graphql" },
  {
    { "query GetUser", "operation_type", "graphql" },
    { "fragment UserFields", "fragment_definition", "graphql" },
  }
)

-- kotlin: SQL (graphql in separate fixture)
test_fixture("tests/fixtures/basic.kt", "kotlin", { "sql" },
  {
    { "SELECT id, email", "keyword_select" },
    { "UPDATE users", "keyword_update" },
    { "LEFT JOIN projects", "keyword_left" },
  }
)
test_fixture("tests/fixtures/basic_graphql.kt", "kotlin", { "graphql" },
  {
    { "query GetUser", "operation_type", "graphql" },
    { "fragment UserFields", "fragment_definition", "graphql" },
  }
)

-- lua: SQL
test_fixture("tests/fixtures/basic.lua", "lua", { "sql" },
  {
    { "SELECT id, email", "keyword_select" },
    { "CREATE TABLE users", "keyword_create" },
    { "LEFT JOIN projects", "keyword_left" },
  }
)

-- perl: SQL
test_fixture("tests/fixtures/basic.pl", "perl", { "sql" },
  {
    { "SELECT id, email FROM perl_users", "keyword_select" },
    { "UPDATE perl_users SET status", "keyword_update" },
    { "LEFT JOIN projects", "keyword_left" },
  }
)

-- php: SQL (graphql + regex in separate fixtures)
test_fixture("tests/fixtures/basic.php", "php", { "sql" },
  {
    { "SELECT id, email", "keyword_select" },
    { "UPDATE users", "keyword_update" },
    { "LEFT JOIN projects", "keyword_left" },
  }
)
test_fixture("tests/fixtures/basic_graphql.php", "php", { "graphql" },
  {
    { "query GetUser", "operation_type", "graphql" },
    { "fragment UserFields", "fragment_definition", "graphql" },
  }
)
test_fixture("tests/fixtures/basic_regex.php", "php", { "regex" },
  {
    { "a-z", "class_character", "regex" },
  }
)

-- python: SQL (graphql in separate fixture)
test_fixture("tests/fixtures/basic.py", "python", { "sql" },
  {
    { "CREATE TABLE users", "keyword_create" },
    { "DELETE FROM users", "keyword_delete" },
    { "LEFT JOIN projects", "keyword_left" },
  }
)
test_fixture("tests/fixtures/basic_graphql.py", "python", { "graphql" },
  {
    { "query GetUser", "operation_type", "graphql" },
    { "fragment UserFields", "fragment_definition", "graphql" },
  }
)

-- ruby: SQL
test_fixture("tests/fixtures/basic.rb", "ruby", { "sql" },
  {
    { "CREATE TABLE users", "keyword_create" },
    { "UPDATE users", "keyword_update" },
    { "LEFT JOIN projects", "keyword_left" },
  }
)

-- rust: SQL (graphql in separate fixture)
test_fixture("tests/fixtures/basic.rs", "rust", { "sql" },
  {
    { "CREATE TABLE users", "keyword_create" },
    { "LEFT JOIN projects", "keyword_left" },
    { "row_number() OVER", "identifier" },
  }
)
test_fixture("tests/fixtures/basic_graphql.rs", "rust", { "graphql" },
  {
    { "query GetUser", "operation_type", "graphql" },
    { "fragment UserFields", "fragment_definition", "graphql" },
  }
)

-- scala: SQL (graphql + regex in separate fixtures)
test_fixture("tests/fixtures/basic.scala", "scala", { "sql" },
  {
    { "CREATE TABLE users", "keyword_create" },
    { "UPDATE users", "keyword_update" },
    { "LEFT JOIN projects", "keyword_left" },
  }
)
test_fixture("tests/fixtures/basic_graphql.scala", "scala", { "graphql" },
  {
    { "query GetUser", "operation_type", "graphql" },
    { "fragment UserFields", "fragment_definition", "graphql" },
  }
)
test_fixture("tests/fixtures/basic_regex.scala", "scala", { "regex" },
  {
    { "a-z", "class_character", "regex" },
  }
)

-- typescript: SQL (graphql in separate fixture)
test_fixture("tests/fixtures/basic.ts", "typescript", { "sql" },
  {
    { "UPDATE users", "keyword_update" },
    { "LEFT JOIN projects", "keyword_left" },
    { "row_number() OVER", "identifier" },
  }
)
test_fixture("tests/fixtures/basic_graphql.ts", "typescript", { "graphql" },
  {
    { "query GetUser", "operation_type", "graphql" },
    { "fragment UserFields", "fragment_definition", "graphql" },
  }
)

-- xml: SQL
test_fixture("tests/fixtures/basic.xml", "xml", { "sql" },
  {
    { "FROM xml_users", "keyword_from" },
    { "UPDATE xml_users", "keyword_update" },
    { "LEFT JOIN projects", "keyword_left" },
  }
)

-- zig: SQL
test_fixture("tests/fixtures/basic.zig", "zig", { "sql" },
  {
    { "SELECT id, email", "keyword_select" },
    { "CREATE TABLE audit_logs", "keyword_create" },
    { "LEFT JOIN projects", "keyword_left" },
  }
)

-- Section 4: Custom rules
section("Custom Rules (Dynamic)")
local custom_ok, custom_err = pcall(function()
  ts_inject.setup({
    enable = { python = true },
    rules = {
      python = {
        builtin = false,
        items = {
          { kind = "call", fn = { "run_sql" }, lang = "sql" },
        },
      },
    },
  })
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(bufnr)
  vim.bo[bufnr].filetype = "python"
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
    "def test():",
    '  cursor.run_sql("SELECT id FROM users")',
  })
  vim.treesitter.language.add("python")
  vim.treesitter.language.add("sql")
  local parser = vim.treesitter.get_parser(bufnr, "python")
  vim.treesitter.start(bufnr, "python")
  parser:parse(true)
  parser:parse(true)
  parser:parse(true)
  local langs = collect_langs(parser)
  assert(vim.tbl_contains(langs, "sql"), "custom rule injection missing sql")
end)
if custom_ok then
  ok("custom rules: python run_sql injects sql")
else
  fail("custom rules: " .. tostring(custom_err))
end

-- Restore all hosts enabled for remaining tests
ts_inject.setup({ enable = all_enable })

-- Section 5: Debug command
section("Debug Command")
local debug_ok, debug_err = pcall(function()
  local original_buf = vim.api.nvim_get_current_buf()
  vim.cmd("TSInjectDebug")
  local debug_buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(debug_buf, 0, -1, false)
  local text = table.concat(lines, "\n")
  assert(text:find("TSInject Debug", 1, true), "debug header missing")
  assert(text:find("plugin_enabled", 1, true), "plugin_enabled section missing")
  vim.api.nvim_set_current_buf(original_buf)
end)
if debug_ok then
  ok("TSInjectDebug command works")
else
  fail("TSInjectDebug: " .. tostring(debug_err))
end

-- Section 6: Health command
section("Health Command")
local health_ok, health_err = pcall(function()
  local original_buf = vim.api.nvim_get_current_buf()
  vim.cmd("TSInjectHealth")
  local health_buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(health_buf, 0, -1, false)
  local text = table.concat(lines, "\n")
  assert(text:find("TSInject Health", 1, true), "health header missing")
  assert(text:find("generated hosts", 1, true), "generated hosts section missing")
  assert(text:find("generated query status", 1, true), "generated query section missing")
  vim.api.nvim_set_current_buf(original_buf)
end)
if health_ok then
  ok("TSInjectHealth command works")
else
  fail("TSInjectHealth: " .. tostring(health_err))
end

-- Summary
section("SUMMARY")
print("Passed: " .. results.passed)
print("Failed: " .. results.failed)
if results.failed > 0 then
  print("\nErrors:")
  for _, err in ipairs(results.errors) do
    print("  - " .. err)
  end
  os.exit(1)
else
  print("\nALL TESTS PASSED")
  os.exit(0)
end
