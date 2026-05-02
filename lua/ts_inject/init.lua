local M = {}

local config = require("ts_inject.config")
local query_builder = require("ts_inject.query_builder")
local query_store = require("ts_inject.query_store")
local runtime = require("ts_inject.runtime")

local defaults = {
  debug_command = "TSInjectDebug",
  enable = {},
  query_mode = {},
  rules = {},
}

local state = {
  commands_registered = false,
  debug_command = nil,
  opts = vim.deepcopy(defaults),
  runtime_state = {
    hosts = {},
    warnings = {},
  },
}

local function clear_query_cache()
  if vim.treesitter and vim.treesitter.query then
    if vim.treesitter.query.get and vim.treesitter.query.get.clear then
      vim.treesitter.query.get:clear()
    end
    if vim.treesitter.query.parse and vim.treesitter.query.parse.clear then
      vim.treesitter.query.parse:clear()
    end
  end
end

local function validate_query(lang, query)
  if not query then
    return nil
  end
  local ok, parse_err = pcall(vim.treesitter.query.parse, lang, query)
  if not ok then
    return parse_err
  end
  return nil
end

local function install_query(lang)
  local generated_hosts = query_store.generated_languages()
  local mode = (state.opts.host_modes and state.opts.host_modes[lang]) or "static"
  local query
  local err
  local rule_config = state.opts.rule_configs and state.opts.rule_configs[lang] or nil

  if mode == "generated" then
    query, err = query_builder.build(lang, state.opts.host_rules[lang] or {})
  else
    query = query_store.load(lang)
  end

  if query then
    local parse_err = validate_query(lang, query)
    if parse_err then
      err = parse_err
      runtime.remove(lang)
    else
      runtime.install(lang, query)
    end
  else
    runtime.remove(lang)
  end

  state.runtime_state.hosts[lang] = {
    mode = mode,
    generated_capable = generated_hosts[lang] == true,
    error = err,
    path = runtime.query_path(lang),
    configurable_rules = mode == "generated" and rule_config and rule_config.configurable or false,
    builtin_enabled = mode == "generated" and rule_config and rule_config.builtin or false,
    builtin_rule_count = mode == "generated" and rule_config and rule_config.builtin_rule_count or 0,
    user_rule_count = mode == "generated" and rule_config and rule_config.user_rule_count or 0,
  }
end

local function register_queries()
  runtime.enable_on_runtimepath()
  state.runtime_state = {
    hosts = {},
    warnings = vim.deepcopy(state.opts.warnings or {}),
  }

  for lang in pairs(query_store.supported_languages()) do
    if state.opts.enable[lang] then
      install_query(lang)
    else
      runtime.remove(lang)
    end
  end

  clear_query_cache()
end

local function register_debug_command()
  if state.debug_command == state.opts.debug_command then
    return
  end

  if state.debug_command then
    pcall(vim.api.nvim_del_user_command, state.debug_command)
  end

  vim.api.nvim_create_user_command(state.opts.debug_command, function(opts)
    require("ts_inject.debug").show({
      target_lang = opts.args ~= "" and opts.args or "sql",
    })
  end, {
    nargs = "?",
    desc = "Inspect Tree-sitter injection state for the current buffer",
  })

  state.debug_command = state.opts.debug_command
end

local function register_commands()
  register_debug_command()

  if state.commands_registered then
    return
  end

  vim.api.nvim_create_user_command("TSInjectReload", function()
    local host_count = require("ts_inject").reload()
    vim.notify(("ts-inject: reloaded %d host query files"):format(host_count))
  end, {
    desc = "Regenerate and reinstall ts-inject queries",
  })

  vim.api.nvim_create_user_command("TSInjectHealth", function()
    require("ts_inject.health").show()
  end, {
    desc = "Inspect ts-inject runtime health",
  })

  state.commands_registered = true
end

---@param opts? TSInjectOpts
---@return TSInjectResolvedOpts
function M.setup(opts)
  state.opts = config.normalize(vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {}))
  register_commands()
  register_queries()
  return state.opts
end

---@return integer
function M.reload()
  register_queries()
  return vim.tbl_count(state.runtime_state.hosts)
end

---@return TSInjectResolvedOpts
function M.get_opts()
  return state.opts
end

---@return TSInjectRuntimeState
function M.get_runtime_state()
  return vim.deepcopy(state.runtime_state)
end

---@param lang string
---@return boolean
function M.is_enabled(lang)
  return state.opts.enable[lang] == true
end

return M
