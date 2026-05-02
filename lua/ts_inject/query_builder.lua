local M = {}

local builders = {
  python = require("ts_inject.host.python"),
  ruby = require("ts_inject.host.ruby"),
  javascript = require("ts_inject.host.ecmascript"),
  lua = require("ts_inject.host.lua"),
  typescript = require("ts_inject.host.ecmascript"),
  go = require("ts_inject.host.go"),
  rust = require("ts_inject.host.rust"),
  zig = require("ts_inject.host.zig"),
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
    else
      table.insert(filtered_rules, rule)
    end
  end

  return builder.build(filtered_rules, opts)
end

return M
