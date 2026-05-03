local script_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")

-- Integration tests
require("tests.smoke.integration.debug")
require("tests.smoke.integration.health")
require("tests.smoke.integration.reload")
require("tests.smoke.integration.custom_rules")

-- Language-specific fixture tests
local lang_dir = script_dir .. "/smoke/lang"
for _, file in ipairs(vim.fn.readdir(lang_dir)) do
  if file:match("%.lua$") then
    require("tests.smoke.lang." .. file:gsub("%.lua$", ""))
  end
end

print("smoke test passed")
