local script_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")
dofile(script_dir .. "/smoke/init.lua")

-- Integration tests
dofile(script_dir .. "/smoke/integration/debug.lua")
dofile(script_dir .. "/smoke/integration/health.lua")
dofile(script_dir .. "/smoke/integration/reload.lua")
dofile(script_dir .. "/smoke/integration/custom_rules.lua")
dofile(script_dir .. "/smoke/integration/legacy.lua")

-- Language-specific fixture tests
local lang_dir = script_dir .. "/smoke/lang"
for _, file in ipairs(vim.fn.readdir(lang_dir)) do
  if file:match("%.lua$") then
    dofile(lang_dir .. "/" .. file)
  end
end

print("smoke test passed")
