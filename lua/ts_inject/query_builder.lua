local M = {}

local builders = {
  python = require("ts_inject.host.python"),
  ruby = require("ts_inject.host.ruby"),
  javascript = require("ts_inject.host.ecmascript"),
  lua = require("ts_inject.host.lua"),
  typescript = require("ts_inject.host.ecmascript"),
  go = require("ts_inject.host.go"),
  rust = require("ts_inject.host.rust"),
  scala = require("ts_inject.host.scala"),
  xml = require("ts_inject.host.xml"),
  zig = require("ts_inject.host.zig"),
  perl = require("ts_inject.host.perl"),
  php = require("ts_inject.host.php"),
  c_sharp = require("ts_inject.host.c_sharp"),
  kotlin = require("ts_inject.host.kotlin"),
  elixir = require("ts_inject.host.elixir"),
  java = require("ts_inject.host.java"),
  c = require("ts_inject.host.c"),
  cpp = require("ts_inject.host.cpp"),
  bash = require("ts_inject.host.bash"),
}

local valid_rule_kinds = {
  name_pattern = true,
  name_format = true,
  call = true,
  call_format = true,
  content_prefix = true,
  macro = true,
  template_tag = true,
  xml_tag = true,
}

function M.build(host, rules)
  local builder = builders[host]
  if not builder then
    return nil, ("no query builder for host %s"):format(host)
  end

  local opts = {}
  local filtered_rules = {}
  for _, rule in ipairs(rules or {}) do
    if rule.kind == "config" then
      if rule.max_concat_depth ~= nil then
        opts.max_concat_depth = rule.max_concat_depth
      end
    elseif valid_rule_kinds[rule.kind] then
      table.insert(filtered_rules, rule)
    else
      return nil, ("unknown rule kind %q for host %s"):format(tostring(rule.kind), host)
    end
  end

  return builder.build(filtered_rules, opts)
end

return M
