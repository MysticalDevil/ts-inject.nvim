local smoke = require("tests.smoke.init")
local function assert_debug_command(file, filetype)
  smoke.assert_buffer_loaded(file, filetype)
  smoke.assert_debug_header()
end

assert_debug_command("tests/fixtures/basic.go", "go")
