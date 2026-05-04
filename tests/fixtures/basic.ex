defmodule SqlExamples do
  # === Comment marker SQL ===
  # sql
  query = "SELECT id, email FROM users WHERE active = true"

  # === Variable naming heuristics ===
  # UPPER_SNAKE_CASE
  USERS_SQL = "SELECT id, email, status FROM users ORDER BY created_at DESC"

  # camelCase
  userQuery = "SELECT id, email FROM users WHERE status = 'active'"

  # snake_case
  users_sql = "SELECT status, count(*) AS total FROM users GROUP BY status"

  # === Sigils ===
  # sql
  sigilSql = ~S"SELECT id FROM users WHERE active = true"

  # ~S multiline
  multilineSql = ~S'''
  SELECT id, email
  FROM users
  WHERE status = 'active'
  '''

  # === Multi-line strings ===
  complex_sql = """
  SELECT u.id, u.email, count(o.id) AS order_count
  FROM users u
  LEFT JOIN orders o ON u.id = o.user_id
  WHERE u.status = 'active'
  GROUP BY u.id, u.email
  HAVING count(o.id) > 0
  """

  # === String concatenation ===
  dynamic_sql = "SELECT id, email" <> " FROM users" <> " WHERE active = true"

  # === DB helper method calls ===
  def run_queries(conn) do
    conn.execute("SELECT id FROM logs")
    conn.query("UPDATE users SET status = 'active'")
    conn.query!("DELETE FROM users WHERE id = #{id}")
    conn.prepare("INSERT INTO audit_logs (message) VALUES (?)")
  end

  # === Ecto.Adapters.SQL ===
  def ecto_queries(repo) do
    Ecto.Adapters.SQL.query!(repo, "SELECT id FROM users", [])
    Ecto.Adapters.SQL.query(repo, ~S"SELECT * FROM users WHERE active = true", [])
    Ecto.Adapters.SQL.execute(repo, "UPDATE users SET status = 'active'")
  end

  # === CTEs and advanced SQL ===
  cte_sql = """
  WITH recent_users AS (
    SELECT id, email FROM users WHERE created_at > '2024-01-01'
  )
  SELECT id, email FROM recent_users ORDER BY id
  """

  # === DDL ===
  schema_sql = """
  CREATE TABLE audit_logs (
    id INTEGER PRIMARY KEY,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )
  """

  alter_sql = "ALTER TABLE users ADD COLUMN phone VARCHAR(20)"

  # === Transactions ===
  transaction_sql = """
  BEGIN;
  UPDATE accounts SET balance = balance - 100 WHERE id = 1;
  UPDATE accounts SET balance = balance + 100 WHERE id = 2;
  COMMIT;
  """

  # === DELETE ===
  delete_sql = "DELETE FROM users WHERE status = 'inactive'"

  # === RETURNING ===
  returning_sql = "INSERT INTO users (email) VALUES ('test@example.com') RETURNING id, email"

  # === JOIN + Subquery + Aggregate ===
  join_sql = """
  SELECT u.id, u.email, p.name
  FROM users u
  LEFT JOIN projects p ON u.id = p.user_id
  WHERE u.id IN (SELECT user_id FROM audit_logs GROUP BY user_id HAVING COUNT(*) > 1)
  ORDER BY u.created_at
  """

  # === CTE + Window function ===
  window_sql = """
  WITH ranked AS (
    SELECT id, email, row_number() OVER (PARTITION BY status ORDER BY created_at) AS rn
    FROM users
  )
  SELECT id, email FROM ranked WHERE rn <= 5
  """

  # === TRUNCATE / DROP ===
  truncate_sql = "TRUNCATE TABLE audit_logs"
  drop_sql = "DROP TABLE IF EXISTS temp_projects"

  # === UNION ===
  union_sql = """
  SELECT id, email FROM users WHERE status = 'active'
  UNION
  SELECT id, email FROM archived_users WHERE status = 'active'
  """

  # === EXISTS subquery ===
  exists_sql = """
  SELECT id, email FROM users u
  WHERE EXISTS (SELECT 1 FROM projects p WHERE p.user_id = u.id)
  """

  # === ON CONFLICT ===
  upsert_sql = """
  INSERT INTO users (email, status)
  VALUES ('bob@example.com', 'active')
  ON CONFLICT (email) DO UPDATE SET status = excluded.status
  """
end
