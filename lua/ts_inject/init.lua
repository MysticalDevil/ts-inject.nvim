local M = {}

local defaults = {
  enabled = true,
  debug_command = "TSInjectDebug",
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

function M.setup(opts)
  if state.configured then
    return state.opts
  end

  state.opts = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
  state.configured = true

  if state.opts.enabled then
    register_commands()
  end

  return state.opts
end

function M.get_opts()
  return state.opts
end

return M
