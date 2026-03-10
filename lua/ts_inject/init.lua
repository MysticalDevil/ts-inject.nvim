local M = {}
local query_store = require("ts_inject.query_store")
local runtime = require("ts_inject.runtime")

local defaults = {
  debug_command = "TSInjectDebug",
  enable = {},
}

local state = {
  configured = false,
  commands_registered = false,
  opts = vim.deepcopy(defaults),
}

local function register_commands()
  if state.commands_registered then
    return
  end

  vim.api.nvim_create_user_command(state.opts.debug_command, function(opts)
    require("ts_inject.debug").show({
      target_lang = opts.args ~= "" and opts.args or "sql",
    })
  end, {
    nargs = "?",
    desc = "Inspect Tree-sitter injection state for the current buffer",
  })

  state.commands_registered = true
end

local function normalize_enable(enable)
  local normalized = {}
  local supported = query_store.supported_languages()

  for lang, value in pairs(enable or {}) do
    if supported[lang] and value then
      normalized[lang] = true
    end
  end

  return normalized
end

local function register_queries()
  runtime.enable_on_runtimepath()
  for lang, enabled in pairs(state.opts.enable) do
    if enabled then
      runtime.install(lang, query_store.load(lang))
    end
  end
end

function M.setup(opts)
  if state.configured then
    return state.opts
  end

  state.opts = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
  state.opts.enable = normalize_enable(state.opts.enable)
  state.configured = true

  register_commands()
  register_queries()

  return state.opts
end

function M.get_opts()
  return state.opts
end

function M.is_enabled(lang)
  return state.opts.enable[lang] == true
end

return M
