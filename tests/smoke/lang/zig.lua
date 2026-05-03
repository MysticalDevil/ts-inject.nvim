local smoke = require("tests.smoke.init")

-- name_pattern: multiline strings (first-line keywords)
smoke.assert_injected_node("tests/fixtures/basic.zig", "zig", "SELECT id, email", "keyword_select")
smoke.assert_injected_node("tests/fixtures/basic.zig", "zig", "CREATE TABLE audit_logs (", "keyword_create")

-- name_pattern: multiline strings (non-first-line keywords — would fail if \\\\ not stripped)
smoke.assert_injected_node("tests/fixtures/basic.zig", "zig", "FROM users", "keyword_from")
smoke.assert_injected_node("tests/fixtures/basic.zig", "zig", "WHERE status", "keyword_where")
smoke.assert_injected_node("tests/fixtures/basic.zig", "zig", "FROM users u", "keyword_from")
smoke.assert_injected_node("tests/fixtures/basic.zig", "zig", "WHERE u.id", "keyword_where")
smoke.assert_injected_node("tests/fixtures/basic.zig", "zig", "ORDER BY u.created_at", "keyword_order")

-- call: multiline string arguments (first-line keywords)
smoke.assert_injected_node("tests/fixtures/basic.zig", "zig", "WITH recent_users AS (", "keyword_with")
smoke.assert_injected_node("tests/fixtures/basic.zig", "zig", "UPDATE users", "keyword_update")

-- call: multiline string arguments (non-first-line keywords)
smoke.assert_injected_node("tests/fixtures/basic.zig", "zig", "SET status = 'active'", "keyword_set")
smoke.assert_injected_node("tests/fixtures/basic.zig", "zig", "WITH ranked AS", "keyword_with")
smoke.assert_injected_node("tests/fixtures/basic.zig", "zig", "row_number() OVER", "identifier")

-- call: regular (single-line) string arguments
smoke.assert_injected_node("tests/fixtures/basic.zig", "zig", "INSERT INTO users (email)", "keyword_insert")

-- complex clauses on non-first lines
smoke.assert_injected_node("tests/fixtures/basic.zig", "zig", "LEFT JOIN projects", "keyword_left")
smoke.assert_injected_node("tests/fixtures/basic.zig", "zig", "HAVING COUNT(*) > 1", "keyword_having")
