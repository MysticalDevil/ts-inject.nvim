local M = {}

local cache = {}

local function root_dir()
  local source = debug.getinfo(1, "S").source:sub(2)
  return vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(source)))
end

function M.supported_languages()
  return {
    bash = true,
    c = true,
    cpp = true,
    go = true,
    c_sharp = true,
    java = true,
    javascript = true,
    kotlin = true,
    lua = true,
    php = true,
    python = true,
    ruby = true,
    scala = true,
    rust = true,
    typescript = true,
    zig = true,
  }
end

function M.generated_languages()
  return {
    javascript = true,
    lua = true,
    python = true,
    ruby = true,
    typescript = true,
  }
end

function M.configurable_generated_languages()
  return {
    javascript = true,
    python = true,
    typescript = true,
  }
end

function M.path(lang)
  return vim.fs.joinpath(root_dir(), "scm", lang, "injections.scm")
end

function M.load(lang)
  if cache[lang] then
    return cache[lang]
  end

  local path = M.path(lang)
  local lines = vim.fn.readfile(path)
  local query = table.concat(lines, "\n")
  cache[lang] = query
  return query
end

return M
