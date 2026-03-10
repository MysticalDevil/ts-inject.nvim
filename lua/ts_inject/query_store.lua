local M = {}

local cache = {}

local function root_dir()
  local source = debug.getinfo(1, "S").source:sub(2)
  return vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(source)))
end

function M.supported_languages()
  return {
    go = true,
    javascript = true,
    python = true,
    rust = true,
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
