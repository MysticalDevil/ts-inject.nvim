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
