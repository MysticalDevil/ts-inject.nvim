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

  get_user_gql = """
  query GetUser($id: ID!) {
    user(id: $id) {
      id
      name
    }
  }
  """

  create_user_gql = """
  mutation CreateUser($input: CreateUserInput!) {
    createUser(input: $input) {
      id
      name
    }
  }
  """

  return query_sql, join_sql, window_sql, get_user_gql, create_user_gql
