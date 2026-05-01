local smoke = require("tests.smoke.init")
smoke.assert_injected_node("tests/fixtures/basic.pl", "perl", "SELECT id, email FROM perl_users", "keyword_select")
smoke.assert_injected_node("tests/fixtures/basic.pl", "perl", "SELECT id, email, status", "keyword_select")
smoke.assert_injected_node("tests/fixtures/basic.pl", "perl", "UPDATE perl_users SET status", "keyword_update")
smoke.assert_injected_node("tests/fixtures/basic.pl", "perl", "INSERT INTO perl_users", "keyword_insert")
smoke.assert_injected_node("tests/fixtures/basic.pl", "perl", "DELETE FROM perl_users", "keyword_delete")
smoke.assert_injected_node("tests/fixtures/basic.pl", "perl", "SELECT * FROM perl_users", "keyword_select")
smoke.assert_injected_node(
  "tests/fixtures/basic.pl",
  "perl",
  "SELECT id, email FROM perl_users WHERE id",
  "keyword_select"
)
smoke.assert_injected_node("tests/fixtures/basic.pl", "perl", "CREATE TABLE perl_audit_logs", "keyword_create")
smoke.assert_injected_node("tests/fixtures/basic.pl", "perl", "ALTER TABLE perl_users", "keyword_alter")
smoke.assert_injected_node("tests/fixtures/basic.pl", "perl", "LEFT JOIN projects", "keyword_left")
smoke.assert_injected_node("tests/fixtures/basic.pl", "perl", "HAVING COUNT(*) > 1", "keyword_having")
smoke.assert_injected_node("tests/fixtures/basic.pl", "perl", "WITH ranked AS", "keyword_with")
smoke.assert_injected_node("tests/fixtures/basic.pl", "perl", "row_number() OVER", "identifier")
