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

  return query_sql
