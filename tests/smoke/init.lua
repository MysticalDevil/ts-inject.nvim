local M = {}

local function append_env_rtp(env_name)
  local value = vim.env[env_name]
  if not value or value == "" then
    return
  end

  for _, path in ipairs(vim.split(value, ":", { plain = true, trimempty = true })) do
    if vim.fn.isdirectory(path) == 1 then
      vim.opt.runtimepath:append(path)
    end
  end
end

local default_enable = {
  bash = true,
  c = true,
  cpp = true,
  c_sharp = true,
  elixir = true,
  go = true,
  java = true,
  javascript = true,
  kotlin = true,
  lua = true,
  perl = true,
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
required_parsers[#required_parsers + 1] = "graphql"
required_parsers[#required_parsers + 1] = "perl"
required_parsers[#required_parsers + 1] = "json"
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
  assert(text:find("enabled hosts", 1, true), "health enabled hosts section missing")
  assert(text:find("python", 1, true), "health missing python host")
  assert(text:find("ruby", 1, true), "health missing ruby host")
  assert(text:find("query status", 1, true), "health query status section missing")
  vim.api.nvim_set_current_buf(original_buf)
end

local function assert_buffer_loaded(file, filetype)
  vim.cmd("silent! %bwipeout!")
  local path = vim.fn.fnamemodify(file, ":p")
  -- Ensure any existing buffer for this path is deleted first
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
M.assert_injected_node = assert_injected_node

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

  assert(row ~= nil, "inline text not found: " .. text)

  local parser = vim.treesitter.get_parser(bufnr, filetype)
  vim.treesitter.start(bufnr, filetype)
  parser:parse(true)
  parser:parse(true)

  local node = vim.treesitter.get_node({
    bufnr = bufnr,
    pos = { row, col },
    ignore_injections = false,
  })
  assert(node ~= nil, "no node found at inline position")
  assert(node:type() == expected_type, ("expected %s at inline position, got %s"):format(expected_type, node:type()))
end
M.assert_injected_in_lines = assert_injected_in_lines

local function assert_language_trees(file, filetype, expected_langs)
  local bufnr = assert_buffer_loaded(file, filetype)

  for _, l in ipairs(expected_langs) do
    require_parser(l)
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
M.assert_language_trees = assert_language_trees

M.assert_buffer_loaded = assert_buffer_loaded
M.assert_debug_header = assert_debug_header
M.assert_injected_in_lines = assert_injected_in_lines
M.assert_health_command = assert_health_command
M.require_parser = require_parser
M.default_enable = default_enable

return M
