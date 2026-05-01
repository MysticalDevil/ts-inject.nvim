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

  user_fields_fragment = """
  fragment UserFields on User {
    id
    name
    email
  }
  """

  search_users_gql = """
  query SearchUsers($query: String!, $includeInactive: Boolean!) {
    activeUsers: users(query: $query, status: ACTIVE) {
      ...UserFields
    }
    inactiveUsers: users(query: $query, status: INACTIVE) @include(if: $includeInactive) {
      ...UserFields
    }
  }
  """

  get_entity_gql = """
  query GetEntity($id: ID!) {
    entity(id: $id) {
      __typename
      ... on User {
        id
        name
      }
      ... on Organization {
        id
        displayName
      }
    }
  }
  """

  return (
    query_sql,
    join_sql,
    window_sql,
    get_user_gql,
    create_user_gql,
    user_fields_fragment,
    search_users_gql,
    get_entity_gql,
  )
