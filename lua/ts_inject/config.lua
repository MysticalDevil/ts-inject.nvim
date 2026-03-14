local M = {}

local builtin = require("ts_inject.builtin")
local query_store = require("ts_inject.query_store")
local rules = require("ts_inject.rules")

local defaults = {
  debug_command = "TSInjectDebug",
  enable = {},
  query_mode = {},
  rules = {},
}

local function configurable_generated_hosts()
  return query_store.configurable_generated_languages()
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

function M.normalize(opts)
  local normalized = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
  local warnings = {}

  normalized.enable = normalize_enable(normalized.enable)
  normalized.query_mode = normalized.query_mode or {}
  normalized.rules = normalized.rules or {}
  normalized.host_rules = {}
  normalized.rule_configs = {}
  normalized.host_modes = {}

  local supported = query_store.supported_languages()
  for host in pairs(normalized.query_mode) do
    if not supported[host] then
      warnings[#warnings + 1] = ("%s: query_mode host is not supported"):format(host)
    end
  end

  local generated = query_store.generated_languages()
  local configurable = configurable_generated_hosts()
  for host in pairs(supported) do
    local requested_mode = normalized.query_mode[host]
    if requested_mode == nil then
      normalized.host_modes[host] = generated[host] and "generated" or "static"
    elseif requested_mode == "generated" then
      if generated[host] then
        normalized.host_modes[host] = "generated"
      else
        normalized.host_modes[host] = "static"
        warnings[#warnings + 1] = ("%s: generated mode is not supported; using static"):format(host)
      end
    elseif requested_mode == "static" then
      normalized.host_modes[host] = "static"
      if generated[host] then
        warnings[#warnings + 1] = ("%s: static mode is legacy and not recommended"):format(host)
      end
    else
      normalized.host_modes[host] = generated[host] and "generated" or "static"
      warnings[#warnings + 1] = ("%s: unsupported query_mode %q; using default"):format(host, tostring(requested_mode))
    end
  end

  for host in pairs(generated) do
    local builtin_rules = builtin.rules_for(host)
    local rule_config = {
      builtin = true,
      items = {},
      configurable = configurable[host] == true,
      builtin_rule_count = #builtin_rules,
      user_rule_count = 0,
    }
    local user_warnings = {}

    if configurable[host] then
      rule_config, user_warnings = rules.normalize_user_config(host, normalized.rules[host])
      rule_config.configurable = true
      rule_config.builtin_rule_count = #builtin_rules
      rule_config.user_rule_count = #(rule_config.items or {})
    elseif normalized.rules[host] and not vim.tbl_isempty(normalized.rules[host]) then
      user_warnings = {
        "experimental rules are not supported for this generated host yet",
      }
      rule_config.user_rule_count = 0
    end

    local host_rules = {}
    if rule_config.builtin then
      vim.list_extend(host_rules, builtin_rules)
    end
    vim.list_extend(host_rules, rule_config.items or {})
    normalized.host_rules[host] = host_rules
    normalized.rule_configs[host] = rule_config

    if normalized.host_modes[host] == "static" and rule_config.user_rule_count > 0 then
      warnings[#warnings + 1] = ("%s: rules are ignored in static mode"):format(host)
    end

    for _, warning in ipairs(user_warnings) do
      warnings[#warnings + 1] = ("%s: %s"):format(host, warning)
    end
  end

  normalized.rules = normalized.rule_configs
  normalized.query_mode = normalized.host_modes
  normalized.warnings = warnings
  return normalized
end

return M
