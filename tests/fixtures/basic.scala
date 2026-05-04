object Main {
  val reportSql = "SELECT id, email FROM users WHERE active = true"

  val USERS_SQL = """
    CREATE TABLE users (
      id INTEGER PRIMARY KEY,
      email TEXT NOT NULL
    )
  """

  val aggregateSql = """
    SELECT status, count(*) AS total
    FROM users
    GROUP BY status
    HAVING count(*) > 0
  """

  DB.execute("UPDATE users SET status = 'active' WHERE email = 'alice@example.com'")

  DB.execute("""
    INSERT INTO users (email, status)
    VALUES ('alice@example.com', 'active')
    RETURNING id, email, status
  """)

  DB.prepare("ALTER TABLE users ADD COLUMN created_at timestamp")

  DB.query("""
    WITH recent_users AS (
      SELECT id, email FROM users
    )
    SELECT id, email FROM recent_users
  """)

  val joinSql = """
    SELECT u.id, u.email, p.name
    FROM users u
    LEFT JOIN projects p ON u.id = p.user_id
    WHERE u.id IN (SELECT user_id FROM audit_logs GROUP BY user_id HAVING COUNT(*) > 1)
    ORDER BY u.created_at
  """

  val windowSql = """
    WITH ranked AS (
      SELECT id, email, row_number() OVER (PARTITION BY status ORDER BY created_at) AS rn
      FROM users
    )
    SELECT id, email FROM ranked WHERE rn <= 5
  """

  val deleteSql = "DELETE FROM users WHERE status = 'inactive'"

  val truncateSql = "TRUNCATE TABLE audit_logs"

  val dropSql = "DROP TABLE IF EXISTS temp_projects"

  val unionSql = """
    SELECT id, email FROM users WHERE status = 'active'
    UNION
    SELECT id, email FROM archived_users WHERE status = 'active'
  """

  val existsSql = """
    SELECT id, email FROM users u
    WHERE EXISTS (SELECT 1 FROM projects p WHERE p.user_id = u.id)
  """

  val transactionSql = """
    BEGIN;
    UPDATE accounts SET balance = balance - 100 WHERE id = 1;
    UPDATE accounts SET balance = balance + 100 WHERE id = 2;
    COMMIT;
  """

  val upsertSql = """
    INSERT INTO users (email, status)
    VALUES ('bob@example.com', 'active')
    ON CONFLICT (email) DO UPDATE SET status = excluded.status
  """
}
