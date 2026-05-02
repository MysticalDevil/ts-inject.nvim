local M = {}

local cache = {}

local function root_dir()
  -- Resolve plugin root from this file's location (lua/ts_inject/query_store.lua).
  -- :p:h:h:h goes from .../lua/ts_inject/ → .../lua/ → .../ → plugin root.
  local source = debug.getinfo(1, "S").source:sub(2)
  return vim.fn.fnamemodify(source, ":p:h:h:h")
end

---All languages with built-in injection support (static scm or generated).
function M.supported_languages()
  return {
    bash = true,
    c = true,
    cpp = true,
    elixir = true,
    go = true,
    c_sharp = true,
    java = true,
    javascript = true,
    kotlin = true,
    lua = true,
    perl = true,
    php = true,
    python = true,
    ruby = true,
    scala = true,
    rust = true,
    typescript = true,
    xml = true,
    zig = true,
  }
end

---Alias for supported_languages (all supported hosts are generated-capable).
function M.generated_languages()
  return M.supported_languages()
end

function M.path(lang)
  return vim.fs.joinpath(root_dir(), "scm", lang, "injections.scm")
end

function M.archive_path(lang)
  return vim.fs.joinpath(root_dir(), "archive", "scm-generated", ("%s.injections.scm"):format(lang))
end

function M.static_path(lang)
  local path = M.path(lang)
  if vim.uv.fs_stat(path) then
    return path
  end

  local archived = M.archive_path(lang)
  if vim.uv.fs_stat(archived) then
    return archived
  end

  return path
end

function M.load(lang)
  if cache[lang] then
    return cache[lang]
  end

  local path = M.static_path(lang)
  local lines = vim.fn.readfile(path)
  local query = table.concat(lines, "\n")
  cache[lang] = query
  return query
end

return M
