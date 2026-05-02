local M = {}

local function copy_list(items)
  local out = {}
  for _, item in ipairs(items or {}) do
    out[#out + 1] = item
  end
  return out
end

local function escape_lua_pattern(text)
  return (text:gsub("([^%w])", "%%%1"))
end

local function normalize_fn_list(fn)
  if type(fn) == "string" then
    return { fn }
  end

  if type(fn) == "table" and not vim.tbl_isempty(fn) then
    local out = {}
    for _, item in ipairs(fn) do
      if type(item) == "string" and item ~= "" then
        out[#out + 1] = item
      end
    end

    if not vim.tbl_isempty(out) then
      return out
    end
  end

  return nil
end

local function name_pattern_for(host, suffix)
  local escaped = escape_lua_pattern(suffix)

  if host == "python" then
    return ("^[%%a_][%%w_]*%s$"):format(escaped)
  end

  if host == "lua" then
    return ("^[%%a_][%%w_]*%s$"):format(escaped)
  end

  if host == "ruby" then
    return ("^[%%a_][%%w_]*%s$"):format(escaped)
  end

  if host == "javascript" or host == "typescript" then
    return ("^[%%a$][%%w_$]*%s$"):format(escaped)
  end

  if host == "go" then
    return ("^[%%a][%%w]*%s$"):format(escaped)
  end

  if host == "rust" then
    return ("^[%%a_][%%w_]*%s$"):format(escaped)
  end

  if host == "zig" then
    return ("^[%%l][%%w]*%s$"):format(escaped)
  end

  return nil
end

local function template_tag_supported(host)
  return host == "javascript" or host == "typescript"
end

local function content_prefix_supported(host)
  return host == "python" or host == "ruby" or host == "lua"
end

local function normalize_pattern_list(patterns)
  if type(patterns) ~= "table" or vim.tbl_isempty(patterns) then
    return nil
  end

  local out = {}
  for _, item in ipairs(patterns) do
    if type(item) == "string" and item ~= "" then
      out[#out + 1] = item
    end
  end

  if vim.tbl_isempty(out) then
    return nil
  end

  return out
end

function M.normalize_user_rule(host, rule)
  if type(rule) ~= "table" then
    return nil, "rule must be a table"
  end

  local lang = rule.lang or "sql"
  if type(lang) ~= "string" or lang == "" then
    return nil, "rule.lang must be a non-empty string"
  end

  if rule.kind == "var_suffix" then
    if type(rule.suffix) ~= "string" or rule.suffix == "" then
      return nil, "var_suffix rules require a non-empty suffix"
    end

    local pattern = name_pattern_for(host, rule.suffix)
    if not pattern then
      return nil, ("var_suffix rules are not supported for host %s"):format(host)
    end

    return {
      kind = "name_pattern",
      lang = lang,
      pattern = pattern,
      source = "user",
    }
  end

  if rule.kind == "call" then
    local fn = normalize_fn_list(rule.fn)
    if not fn then
      return nil, "call rules require fn as a string or non-empty list"
    end

    local arg_index = rule.arg_index or 1
    if type(arg_index) ~= "number" or arg_index < 1 then
      return nil, "call rules require arg_index as a positive integer"
    end

    return {
      kind = "call",
      lang = lang,
      fn = fn,
      arg_index = arg_index,
      source = "user",
    }
  end

  if rule.kind == "template_tag" then
    if not template_tag_supported(host) then
      return nil, ("template_tag rules are not supported for host %s"):format(host)
    end

    local fn = normalize_fn_list(rule.fn)
    if not fn then
      return nil, "template_tag rules require fn as a string or non-empty list"
    end

    return {
      kind = "template_tag",
      lang = lang,
      fn = fn,
      source = "user",
    }
  end

  if rule.kind == "content_prefix" then
    if not content_prefix_supported(host) then
      return nil, ("content_prefix rules are not supported for host %s"):format(host)
    end

    local patterns = normalize_pattern_list(rule.patterns)
    if not patterns then
      return nil, "content_prefix rules require patterns as a non-empty list"
    end

    return {
      kind = "content_prefix",
      lang = lang,
      patterns = patterns,
      source = "user",
    }
  end

  if rule.kind == "macro" then
    local fn = normalize_fn_list(rule.fn)
    if not fn then
      return nil, "macro rules require fn as a string or non-empty list"
    end

    return {
      kind = "macro",
      lang = lang,
      fn = fn,
      source = "user",
    }
  end

  if rule.kind == "config" then
    return {
      kind = "config",
      source = "user",
      max_concat_depth = rule.max_concat_depth,
    }
  end

  return nil, ("unsupported experimental rule kind: %s"):format(tostring(rule.kind))
end

function M.normalize_user_rules(host, raw_rules)
  local normalized = {}
  local warnings = {}

  for _, rule in ipairs(raw_rules or {}) do
    local normalized_rule, err = M.normalize_user_rule(host, rule)
    if normalized_rule then
      normalized[#normalized + 1] = normalized_rule
    else
      warnings[#warnings + 1] = err
    end
  end

  return normalized, warnings
end

function M.normalize_user_config(host, raw)
  local config = {
    builtin = true,
    items = {},
  }
  local warnings = {}

  if raw == nil then
    return config, warnings
  end

  if vim.islist(raw) then
    config.items = raw
  elseif type(raw) == "table" then
    if raw.builtin ~= nil then
      if type(raw.builtin) == "boolean" then
        config.builtin = raw.builtin
      else
        warnings[#warnings + 1] = "rules.builtin must be a boolean"
      end
    end

    if raw.items ~= nil then
      if vim.islist(raw.items) then
        config.items = raw.items
      else
        warnings[#warnings + 1] = "rules.items must be a list"
      end
    end
  else
    warnings[#warnings + 1] = "host rules must be a list or table"
  end

  local normalized, rule_warnings = M.normalize_user_rules(host, config.items)
  config.items = normalized
  vim.list_extend(warnings, rule_warnings)
  return config, warnings
end

function M.clone_rules(rules)
  local out = {}

  for _, rule in ipairs(rules or {}) do
    local cloned = vim.deepcopy(rule)
    if cloned.fn then
      cloned.fn = copy_list(cloned.fn)
    end
    if cloned.patterns then
      cloned.patterns = copy_list(cloned.patterns)
    end
    out[#out + 1] = cloned
  end

  return out
end

return M
