local M = {}

local mode_resolver = require("ts_inject.mode_resolver")
local rule_resolver = require("ts_inject.rule_resolver")

local defaults = {
  debug_command = "TSInjectDebug",
  enable = {},
  query_mode = {},
  rules = {},
}

---@param opts? TSInjectOpts
---@return TSInjectResolvedOpts
function M.normalize(opts)
  local normalized = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
  local warnings = {}

  normalized.enable = mode_resolver.normalize_enable(normalized.enable)
  normalized.query_mode = normalized.query_mode or {}
  normalized.rules = normalized.rules or {}
  normalized.host_modes = mode_resolver.resolve_host_modes(normalized.query_mode, warnings)
  normalized.host_rules, normalized.rule_configs =
    rule_resolver.resolve_rules(normalized.rules, normalized.host_modes, warnings)

  -- Alias deprecated top-level keys to internal resolved keys for backward compatibility.
  normalized.rules = normalized.rule_configs
  normalized.query_mode = normalized.host_modes
  normalized.warnings = warnings
  return normalized
end

return M
