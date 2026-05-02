local smoke = require("tests.smoke.init")
smoke.assert_language_trees(
  "tests/fixtures/basic.sh",
  "bash",
  { "sql", "python", "lua", "javascript", "typescript", "ruby", "perl", "graphql", "json", "regex" }
)
smoke.assert_injected_node("tests/fixtures/basic.sh", "bash", "SELECT id, email", "keyword_select")
smoke.assert_injected_node("tests/fixtures/basic.sh", "bash", "SELECT id, email, status", "keyword_select")
smoke.assert_injected_node("tests/fixtures/basic.sh", "bash", "DELETE FROM users", "keyword_delete")
smoke.assert_injected_node("tests/fixtures/basic.sh", "bash", "SELECT id FROM logs", "keyword_select")
smoke.assert_injected_node("tests/fixtures/basic.sh", "bash", "SELECT id, email FROM users", "keyword_select")
smoke.assert_injected_node("tests/fixtures/basic.sh", "bash", "UPDATE users SET status", "keyword_update")
smoke.assert_injected_node("tests/fixtures/basic.sh", "bash", "SELECT count(*) FROM users", "keyword_select")
smoke.assert_injected_node("tests/fixtures/basic.sh", "bash", "INSERT INTO users", "keyword_insert")
smoke.assert_injected_node("tests/fixtures/basic.sh", "bash", "LEFT JOIN projects", "keyword_left")
smoke.assert_injected_node("tests/fixtures/basic.sh", "bash", "HAVING COUNT(*) > 1", "keyword_having")
smoke.assert_injected_node("tests/fixtures/basic.sh", "bash", "WITH ranked AS", "keyword_with")
smoke.assert_injected_node("tests/fixtures/basic.sh", "bash", "row_number() OVER", "identifier")
