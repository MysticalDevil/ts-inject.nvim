local M = {}

local builtin = {
  python = {
    {
      kind = "name_pattern",
      lang = "sql",
      pattern = "^[%a_][%w_]*[Ss][Qq][Ll]$",
      source = "builtin",
    },
    {
      kind = "call",
      lang = "sql",
      fn = { "execute", "executemany", "executescript" },
      source = "builtin",
    },
    {
      kind = "content_prefix",
      lang = "sql",
      patterns = {
        "^%s*[Ss][Ee][Ll][Ee][Cc][Tt]%s+",
        "^%s*[Ii][Nn][Ss][Ee][Rr][Tt]%s+[Ii][Nn][Tt][Oo]%s+",
        "^%s*[Uu][Pp][Dd][Aa][Tt][Ee]%s+",
        "^%s*[Dd][Ee][Ll][Ee][Tt][Ee]%s+[Ff][Rr][Oo][Mm]%s+",
        "^%s*[Cc][Rr][Ee][Aa][Tt][Ee]%s+",
        "^%s*[Aa][Ll][Tt][Ee][Rr]%s+",
        "^%s*[Ww][Ii][Tt][Hh]%s+",
        "^%s*[Bb][Ee][Gg][Ii][Nn]%s*;",
      },
      source = "builtin",
    },
  },
  javascript = {
    {
      kind = "name_pattern",
      lang = "sql",
      pattern = "^[%a$][%w_$]*_?[Ss][Qq][Ll]$",
      source = "builtin",
    },
    {
      kind = "call",
      lang = "sql",
      fn = { "query", "queryRaw", "execute", "executeRaw" },
      source = "builtin",
    },
    {
      kind = "template_tag",
      lang = "sql",
      fn = { "$queryRaw", "$executeRaw", "queryRaw", "executeRaw", "sql" },
      source = "builtin",
    },
  },
  lua = {
    {
      kind = "name_pattern",
      lang = "sql",
      pattern = "^[%a_][%w_]*_?[Ss][Qq][Ll]$",
      source = "builtin",
    },
    {
      kind = "name_format",
      lang = "sql",
      pattern = "^[%a_][%w_]*_?[Ss][Qq][Ll]$",
      source = "builtin",
    },
    {
      kind = "call",
      lang = "sql",
      fn = { "query", "execute", "exec", "prepare" },
      source = "builtin",
    },
    {
      kind = "call_format",
      lang = "sql",
      fn = { "query", "execute", "exec", "prepare" },
      source = "builtin",
    },
  },
  typescript = {
    {
      kind = "name_pattern",
      lang = "sql",
      pattern = "^[%a$][%w_$]*_?[Ss][Qq][Ll]$",
      source = "builtin",
    },
    {
      kind = "call",
      lang = "sql",
      fn = { "query", "queryRaw", "execute", "executeRaw" },
      source = "builtin",
    },
    {
      kind = "template_tag",
      lang = "sql",
      fn = { "$queryRaw", "$executeRaw", "queryRaw", "executeRaw", "sql" },
      source = "builtin",
    },
  },
}

function M.rules_for(host)
  return require("ts_inject.rules").clone_rules(builtin[host] or {})
end

return M
