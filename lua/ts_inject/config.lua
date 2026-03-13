local M = {}

local builtin = require("ts_inject.builtin")
local query_store = require("ts_inject.query_store")
local rules = require("ts_inject.rules")

local defaults = {
  debug_command = "TSInjectDebug",
  enable = {},
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
  normalized.rules = normalized.rules or {}
  normalized.host_rules = {}
  normalized.rule_configs = {}

  local generated = query_store.generated_languages()
  local configurable = configurable_generated_hosts()
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

    for _, warning in ipairs(user_warnings) do
      warnings[#warnings + 1] = ("%s: %s"):format(host, warning)
    end
  end

  normalized.rules = normalized.rule_configs
  normalized.warnings = warnings
  return normalized
end

return M
