local M = {}

local builtin = require("ts_inject.builtin")
local query_store = require("ts_inject.query_store")
local rules = require("ts_inject.rules")

local function expand_host_rule(host, rule)
  local out = { rule }

  if host == "lua" then
    if rule.kind == "name_pattern" then
      local format_rule = vim.deepcopy(rule)
      format_rule.kind = "name_format"
      out[#out + 1] = format_rule
    elseif rule.kind == "call" then
      local format_rule = vim.deepcopy(rule)
      format_rule.kind = "call_format"
      out[#out + 1] = format_rule
    end
  end

  return out
end

function M.resolve_rules(raw_host_rules, host_modes, warnings)
  local generated = query_store.generated_languages()
  local configurable = query_store.generated_languages()
  local host_rules = {}
  local rule_configs = {}

  for lang in pairs(generated) do
    local builtin_rules = builtin.rules_for(lang)
    local rule_config = {
      builtin = true,
      items = {},
      configurable = configurable[lang] == true,
      builtin_rule_count = #builtin_rules,
      user_rule_count = 0,
    }
    local user_warnings = {}

    if configurable[lang] then
      rule_config, user_warnings = rules.normalize_user_config(lang, raw_host_rules and raw_host_rules[lang])
      rule_config.configurable = true
      rule_config.builtin_rule_count = #builtin_rules
      rule_config.user_rule_count = #(rule_config.items or {})
    elseif raw_host_rules and raw_host_rules[lang] and not vim.tbl_isempty(raw_host_rules[lang]) then
      user_warnings = {
        "experimental rules are not supported for this generated host yet",
      }
      rule_config.user_rule_count = 0
    end

    local merged_rules = {}
    if rule_config.builtin then
      vim.list_extend(merged_rules, builtin_rules)
    end
    for _, rule in ipairs(rule_config.items or {}) do
      vim.list_extend(merged_rules, expand_host_rule(lang, rule))
    end
    host_rules[lang] = merged_rules
    rule_configs[lang] = rule_config

    if host_modes[lang] == "static" and rule_config.user_rule_count > 0 then
      warnings[#warnings + 1] = ("%s: rules are ignored in static mode"):format(lang)
    end

    for _, warning in ipairs(user_warnings) do
      warnings[#warnings + 1] = ("%s: %s"):format(lang, warning)
    end
  end

  return host_rules, rule_configs
end

return M
