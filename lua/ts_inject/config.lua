local M = {}

local builtin = require("ts_inject.builtin")
local query_store = require("ts_inject.query_store")
local rules = require("ts_inject.rules")

local defaults = {
  debug_command = "TSInjectDebug",
  enable = {},
  rules = {},
}

local function generated_hosts()
  return query_store.generated_languages()
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

  local generated = generated_hosts()
  for host in pairs(generated) do
    local host_rules = builtin.rules_for(host)
    local user_rules, user_warnings = rules.normalize_user_rules(host, normalized.rules[host] or {})

    vim.list_extend(host_rules, user_rules)
    normalized.host_rules[host] = host_rules

    for _, warning in ipairs(user_warnings) do
      warnings[#warnings + 1] = ("%s: %s"):format(host, warning)
    end
  end

  normalized.warnings = warnings
  return normalized
end

return M
