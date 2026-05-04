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

    let _query_as = sqlx::query_as::<_, User>("SELECT id FROM sqlx_query_as_users WHERE id = $1");
    let _query_scalar = sqlx::query_scalar("SELECT count(*) FROM sqlx_scalar_users");
    let _diesel = diesel::sql_query("SELECT id FROM diesel_users WHERE active = true");
    let _sea = Statement::from_string(
        DbBackend::Postgres,
        "SELECT id FROM sea_orm_users WHERE active = true",
    );
    let _sea_values = Statement::from_sql_and_values(
        DbBackend::Postgres,
        "UPDATE sea_orm_users SET active = true WHERE id = $1",
        [],
    );

    let manager = Manager;
    let _manager_rows = manager.fetch_all("SELECT id FROM manager_users WHERE active = true");
    let _manager_delete = manager.exec_stmt("DELETE FROM manager_users WHERE active = false");

    let join_sql = r#"
  SELECT u.id, u.email, p.name
  FROM users u
  LEFT JOIN projects p ON u.id = p.user_id
  WHERE u.id IN (SELECT user_id FROM audit_logs GROUP BY user_id HAVING COUNT(*) > 1)
  ORDER BY u.created_at
"#;

    let window_sql = r#"
  WITH ranked AS (
    SELECT id, email, row_number() OVER (PARTITION BY status ORDER BY created_at) AS rn
    FROM users
  )
  SELECT id, email FROM ranked WHERE rn <= 5
"#;

    let truncate_sql = r#"TRUNCATE TABLE audit_logs"#;

    let drop_sql = r#"DROP TABLE IF EXISTS temp_projects"#;

    let union_sql = r#"
  SELECT id, email FROM users WHERE status = 'active'
  UNION
  SELECT id, email FROM archived_users WHERE status = 'active'
  "#;

    let exists_sql = r#"
  SELECT id, email FROM users u
  WHERE EXISTS (SELECT 1 FROM projects p WHERE p.user_id = u.id)
  "#;

    let transaction_sql = r#"
  BEGIN;
  UPDATE accounts SET balance = balance - 100 WHERE id = 1;
  UPDATE accounts SET balance = balance + 100 WHERE id = 2;
  COMMIT;
  "#;

    let upsert_sql = r#"
  INSERT INTO users (email, status)
  VALUES ($1, $2)
  ON CONFLICT (email) DO UPDATE SET status = excluded.status
  "#;

    let _ = (
        schema_sql,
        query,
        _rows,
        _insert,
        _query_as,
        _query_scalar,
        _diesel,
        _sea,
        _sea_values,
        _manager_rows,
        _manager_delete,
        join_sql,
        window_sql,
        truncate_sql,
        drop_sql,
        union_sql,
        exists_sql,
        transaction_sql,
        upsert_sql,
    );
}

struct User;
struct Statement;
struct Manager;
enum DbBackend {
    Postgres,
}
