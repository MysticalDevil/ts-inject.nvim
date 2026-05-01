assert_injected_node("tests/fixtures/basic.go", "go", "SELECT id, name", "keyword_select")
assert_injected_node("tests/fixtures/basic.go", "go", "LEFT JOIN projects", "keyword_left")
assert_injected_node("tests/fixtures/basic.go", "go", "HAVING COUNT(*) > 1", "keyword_having")
assert_injected_node("tests/fixtures/basic.go", "go", "row_number() OVER", "identifier")
