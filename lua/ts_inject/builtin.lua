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
    {
      kind = "content_prefix",
      lang = "graphql",
      patterns = {
        "^%s*[Qq][Uu][Ee][Rr][Yy]%s+",
        "^%s*[Mm][Uu][Tt][Aa][Tt][Ii][Oo][Nn]%s+",
        "^%s*[Ss][Uu][Bb][Ss][Cc][Rr][Ii][Pp][Tt][Ii][Oo][Nn]%s+",
        "^%s*[Ff][Rr][Aa][Gg][Mm][Ee][Nn][Tt]%s+",
      },
      source = "builtin",
    },
  },
  ruby = {
    {
      kind = "name_pattern",
      lang = "sql",
      pattern = "^[%l_][%w_]*_sql$",
      source = "builtin",
    },
    {
      kind = "name_pattern",
      lang = "sql",
      pattern = "^[%u][%u%d_]*_SQL$",
      source = "builtin",
    },
    {
      kind = "call",
      lang = "sql",
      fn = { "execute", "exec", "prepare", "find_by_sql" },
      source = "builtin",
    },
  },
  javascript = {
    {
      kind = "config",
      max_concat_depth = 5,
      source = "builtin",
    },
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
    {
      kind = "template_tag",
      lang = "graphql",
      fn = { "gql", "graphql", "gqlRequest" },
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
      kind = "config",
      max_concat_depth = 5,
      source = "builtin",
    },
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
    {
      kind = "template_tag",
      lang = "graphql",
      fn = { "gql", "graphql", "gqlRequest" },
      source = "builtin",
    },
  },
  go = {
    {
      kind = "name_pattern",
      lang = "sql",
      pattern = "^[%a][%w]*[Ss][Qq][Ll]$",
      source = "builtin",
    },
    {
      kind = "call",
      lang = "sql",
      fn = { "Query", "QueryRow", "QueryContext", "Exec", "ExecContext", "Prepare", "PrepareContext" },
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
    {
      kind = "content_prefix",
      lang = "graphql",
      patterns = {
        "^%s*[Qq][Uu][Ee][Rr][Yy]%s+",
        "^%s*[Mm][Uu][Tt][Aa][Tt][Ii][Oo][Nn]%s+",
        "^%s*[Ss][Uu][Bb][Ss][Cc][Rr][Ii][Pp][Tt][Ii][Oo][Nn]%s+",
        "^%s*[Ff][Rr][Aa][Gg][Mm][Ee][Nn][Tt]%s+",
      },
      source = "builtin",
    },
  },
  scala = {
    {
      kind = "name_pattern",
      lang = "sql",
      pattern = "^[%l][%w]*Sql$",
      source = "builtin",
    },
    {
      kind = "name_pattern",
      lang = "sql",
      pattern = "^[%u][%u%d_]*_SQL$",
      source = "builtin",
    },
    {
      kind = "call",
      lang = "sql",
      fn = { "execute", "exec", "prepare", "query", "queryRaw" },
      source = "builtin",
    },
    {
      kind = "name_pattern",
      lang = "graphql",
      pattern = "^[%l][%w]*Gql$",
      source = "builtin",
    },
    {
      kind = "name_pattern",
      lang = "graphql",
      pattern = "^[%u][%u%d_]*_GQL$",
      source = "builtin",
    },
  },
  rust = {
    {
      kind = "name_pattern",
      lang = "sql",
      pattern = "^[%a_][%w_]*_sql$",
      source = "builtin",
    },
    {
      kind = "name_pattern",
      lang = "sql",
      pattern = "^[%u][%u%d_]*_SQL$",
      source = "builtin",
    },
    {
      kind = "call",
      lang = "sql",
      fn = { "execute", "exec", "prepare", "query", "query_one", "query_all", "sql_query" },
      source = "builtin",
    },
    {
      kind = "call",
      lang = "sql",
      fn = { "from_string", "from_sql_and_values" },
      arg_index = 2,
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
      },
      source = "builtin",
    },
    {
      kind = "content_prefix",
      lang = "graphql",
      patterns = {
        "^%s*[Qq][Uu][Ee][Rr][Yy]%s+",
        "^%s*[Mm][Uu][Tt][Aa][Tt][Ii][Oo][Nn]%s+",
        "^%s*[Ss][Uu][Bb][Ss][Cc][Rr][Ii][Pp][Tt][Ii][Oo][Nn]%s+",
        "^%s*[Ff][Rr][Aa][Gg][Mm][Ee][Nn][Tt]%s+",
      },
      source = "builtin",
    },
    {
      kind = "macro",
      lang = "sql",
      fn = { "query", "query_as", "query_scalar", "sql_query" },
      source = "builtin",
    },
    {
      kind = "macro",
      lang = "graphql",
      fn = { "graphql", "gql" },
      source = "builtin",
    },
  },
  xml = {
    {
      kind = "xml_tag",
      lang = "sql",
      tags = {
        "select",
        "insert",
        "update",
        "delete",
        "sql",
        "where",
        "set",
        "trim",
        "foreach",
        "if",
        "choose",
        "when",
        "otherwise",
      },
      source = "builtin",
    },
  },
  zig = {
    {
      kind = "name_pattern",
      lang = "sql",
      pattern = "^[%l][%w]*Sql$",
      source = "builtin",
    },
    {
      kind = "call",
      lang = "sql",
      fn = { "query", "execute", "prepare" },
      source = "builtin",
    },
  },
}

function M.rules_for(host)
  return require("ts_inject.rules").clone_rules(builtin[host] or {})
end

return M
