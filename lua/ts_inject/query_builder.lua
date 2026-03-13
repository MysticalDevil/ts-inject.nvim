local M = {}

local builders = {
  python = require("ts_inject.host.python"),
  ruby = require("ts_inject.host.ruby"),
  javascript = require("ts_inject.host.ecmascript"),
  lua = require("ts_inject.host.lua"),
  typescript = require("ts_inject.host.ecmascript"),
}

function M.build(host, rules)
  local builder = builders[host]
  if not builder then
    return nil, ("no query builder for host %s"):format(host)
  end

  return builder.build(rules or {})
end

return M
