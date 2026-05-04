SCHEMA_SQL = """
  CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    email TEXT NOT NULL
  )
"""

query_sql = (
  "SELECT id, email "
  "FROM users "
  "WHERE email LIKE 'a%'"
)

statement = """
  DELETE FROM users
  WHERE email = 'old@example.com'
"""


def run(cursor):
  cursor.execute(
    "SELECT id, email "
    "FROM users "
    "WHERE email = ?"
  )

  cursor.execute(
    """
    INSERT INTO users (email)
    VALUES ('alice@example.com')
"""
  )

  join_sql = """
  SELECT u.id, u.email, p.name
  FROM users u
  LEFT JOIN projects p ON u.id = p.user_id
  WHERE u.id IN (SELECT user_id FROM audit_logs GROUP BY user_id HAVING COUNT(*) > 1)
  ORDER BY u.created_at
  """

  window_sql = """
  WITH ranked AS (
    SELECT id, email, row_number() OVER (PARTITION BY status ORDER BY created_at) AS rn
    FROM users
  )
  SELECT id, email FROM ranked WHERE rn <= 5
  """

  delete_sql = """
  DELETE FROM users
  WHERE status = 'inactive'
  """

  truncate_sql = "TRUNCATE TABLE audit_logs"

  drop_sql = "DROP TABLE IF EXISTS temp_projects"

  union_sql = """
  SELECT id, email FROM users WHERE status = 'active'
  UNION
  SELECT id, email FROM archived_users WHERE status = 'active'
  """

  exists_sql = """
  SELECT id, email FROM users u
  WHERE EXISTS (SELECT 1 FROM projects p WHERE p.user_id = u.id)
  """

  transaction_sql = """
  BEGIN;
  UPDATE accounts SET balance = balance - 100 WHERE id = 1;
  UPDATE accounts SET balance = balance + 100 WHERE id = 2;
  COMMIT;
  """

  upsert_sql = """
  INSERT INTO users (email, status)
  VALUES ('bob@example.com', 'active')
  ON CONFLICT (email) DO UPDATE SET status = excluded.status
  """

  return (
    query_sql,
    join_sql,
    window_sql,
    delete_sql,
    truncate_sql,
    drop_sql,
    union_sql,
    exists_sql,
    transaction_sql,
    upsert_sql,
  )
