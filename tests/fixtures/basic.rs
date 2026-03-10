fn main() {
  let schema_sql = r#"
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  email TEXT NOT NULL
)
"#;

  let query = r#"
SELECT id, email
FROM users
WHERE email = $1
"#;

  let _rows = sqlx::query(
    r#"
SELECT id, email
FROM users
WHERE email = $1
"#,
  );

  let _insert = sqlx::query!(
    r#"
INSERT INTO users (email)
VALUES ($1)
"#,
    "alice@example.com",
  );

  let _ = (schema_sql, query, _rows, _insert);
}
