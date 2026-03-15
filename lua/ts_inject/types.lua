---@meta

---@alias TSInjectQueryMode "generated"|"static"

---@class TSInjectRuleVarSuffix
---@field kind "var_suffix"
---@field suffix string
---@field lang? string

---@class TSInjectRuleCall
---@field kind "call"
---@field fn string|string[]
---@field lang? string

---@class TSInjectRuleTemplateTag
---@field kind "template_tag"
---@field fn string|string[]
---@field lang? string

---@class TSInjectRuleContentPrefix
---@field kind "content_prefix"
---@field patterns string[]
---@field lang? string

---@alias TSInjectRuleItem TSInjectRuleVarSuffix|TSInjectRuleCall|TSInjectRuleTemplateTag|TSInjectRuleContentPrefix

---@class TSInjectRuleConfig
---@field builtin? boolean
---@field items? TSInjectRuleItem[]

---@alias TSInjectHostRules table<string, TSInjectRuleConfig|TSInjectRuleItem[]>

---@alias TSInjectEnableMap table<string, boolean>
---@alias TSInjectQueryModeMap table<string, TSInjectQueryMode>

---@class TSInjectOpts
---@field debug_command? string
---@field enable? TSInjectEnableMap
---@field query_mode? TSInjectQueryModeMap
---@field rules? TSInjectHostRules

---@class TSInjectInternalRule
---@field kind string
---@field lang string
---@field source? string
---@field pattern? string
---@field patterns? string[]
---@field fn? string[]

---@class TSInjectNormalizedHostRuleConfig
---@field builtin boolean
---@field items TSInjectInternalRule[]
---@field configurable boolean
---@field builtin_rule_count integer
---@field user_rule_count integer

---@class TSInjectResolvedOpts
---@field debug_command string
---@field enable TSInjectEnableMap
---@field query_mode TSInjectQueryModeMap
---@field rules table<string, TSInjectNormalizedHostRuleConfig>
---@field host_rules table<string, TSInjectInternalRule[]>
---@field rule_configs table<string, TSInjectNormalizedHostRuleConfig>
---@field host_modes TSInjectQueryModeMap
---@field warnings string[]

---@class TSInjectRuntimeHostStatus
---@field mode TSInjectQueryMode
---@field generated_capable boolean
---@field error? string
---@field path string
---@field configurable_rules boolean
---@field builtin_enabled boolean
---@field builtin_rule_count integer
---@field user_rule_count integer

---@class TSInjectRuntimeState
---@field hosts table<string, TSInjectRuntimeHostStatus>
---@field warnings string[]

return {}
