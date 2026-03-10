local M = {}

local root_dir = vim.fn.stdpath("data") .. "/ts-inject"

local function ensure_dir(path)
  vim.fn.mkdir(path, "p")
end

function M.root_dir()
  return root_dir
end

function M.query_path(lang)
  return root_dir .. "/queries/" .. lang .. "/injections.scm"
end

function M.install(lang, query)
  local dir = root_dir .. "/queries/" .. lang
  ensure_dir(dir)
  vim.fn.writefile(vim.split(query, "\n", { plain = true }), M.query_path(lang))
end

function M.remove(lang)
  local path = M.query_path(lang)
  if vim.uv.fs_stat(path) then
    vim.fn.delete(path)
  end
end

function M.enable_on_runtimepath()
  local rtp = vim.opt.runtimepath:get()
  if vim.tbl_contains(rtp, root_dir) then
    return
  end
  vim.opt.runtimepath:prepend(root_dir)
end

return M
