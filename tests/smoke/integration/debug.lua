local function assert_debug_command(file, filetype)
  assert_buffer_loaded(file, filetype)
  assert_debug_header()
end

assert_debug_command("tests/fixtures/basic.go", "go")
