SQL = <<~SQL
  CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    email TEXT NOT NULL
  )
SQL

report_sql = "SELECT id, email FROM users WHERE active = true"

aggregate_sql = "SELECT status, count(*) AS total FROM users GROUP BY status HAVING count(*) > 0"

DB.execute("UPDATE users SET status = 'active' WHERE email = 'alice@example.com'")

DB.execute(<<~SQL)
  INSERT INTO users (email, status)
  VALUES ('alice@example.com', 'active')
  RETURNING id, email, status
SQL

DB.prepare("ALTER TABLE users ADD COLUMN created_at timestamp")

User.find_by_sql(<<~SQL)
  WITH recent_users AS (
    SELECT id, email FROM users
  )
  SELECT id, email FROM recent_users
SQL

join_sql = <<~SQL
  SELECT u.id, u.email, p.name
  FROM users u
  LEFT JOIN projects p ON u.id = p.user_id
  WHERE u.id IN (SELECT user_id FROM audit_logs GROUP BY user_id HAVING COUNT(*) > 1)
  ORDER BY u.created_at
SQL

window_sql = <<~SQL
  WITH ranked AS (
    SELECT id, email, row_number() OVER (PARTITION BY status ORDER BY created_at) AS rn
    FROM users
  )
  SELECT id, email FROM ranked WHERE rn <= 5
SQL

delete_sql = <<~SQL
  DELETE FROM users
  WHERE status = 'inactive'
SQL

truncate_sql = "TRUNCATE TABLE audit_logs"

drop_sql = "DROP TABLE IF EXISTS temp_projects"

union_sql = <<~SQL
  SELECT id, email FROM users WHERE status = 'active'
  UNION
  SELECT id, email FROM archived_users WHERE status = 'active'
SQL

exists_sql = <<~SQL
  SELECT id, email FROM users u
  WHERE EXISTS (SELECT 1 FROM projects p WHERE p.user_id = u.id)
SQL

transaction_sql = <<~SQL
  BEGIN;
  UPDATE accounts SET balance = balance - 100 WHERE id = 1;
  UPDATE accounts SET balance = balance + 100 WHERE id = 2;
  COMMIT;
SQL

upsert_sql = <<~SQL
  INSERT INTO users (email, status)
  VALUES ('bob@example.com', 'active')
  ON CONFLICT (email) DO UPDATE SET status = excluded.status
SQL
