const USERS_SQL = `
  SELECT id, email
  FROM users
  WHERE status = 'active'
`;

const aggregateSql = "SELECT status, count(*) AS total " +
  "FROM users " +
  "GROUP BY status " +
  "HAVING count(*) > 0";

const db = {
  query(sql) {
    return sql;
  },
};

const prisma = {
  $queryRaw(strings, ...values) {
    return [strings, values];
  },
};

db.query(`
  INSERT INTO users (email, status)
  VALUES ('alice@example.com', 'active')
  RETURNING id, email
`);

db.execute(
  "UPDATE users " +
    "SET status = 'active' " +
    "WHERE email = ?",
  "alice@example.com",
);

db.execute(
  "INSERT INTO users (email, status) " +
    "VALUES (?, ?) " +
    "ON CONFLICT (email) DO UPDATE SET status = excluded.status " +
    "RETURNING id, email, status",
  "alice@example.com",
  "active",
);

prisma.$queryRaw`
  DELETE FROM users
  WHERE status = ${"disabled"}
`;

const joinSql = `SELECT u.id, u.email, p.name
  FROM users u
  LEFT JOIN projects p ON u.id = p.user_id
  WHERE u.id IN (SELECT user_id FROM audit_logs GROUP BY user_id HAVING COUNT(*) > 1)
  ORDER BY u.created_at`;

const windowSql = `WITH ranked AS (
    SELECT id, email, row_number() OVER (PARTITION BY status ORDER BY created_at) AS rn
    FROM users
  )
  SELECT id, email FROM ranked WHERE rn <= 5`;

void USERS_SQL;
void aggregateSql;
const GET_USER_GQL = gql`
  query GetUser($id: ID!) {
    user(id: $id) {
      id
      name
      email
    }
  }
`;

const CREATE_USER_GQL = gql`
  mutation CreateUser($input: CreateUserInput!) {
    createUser(input: $input) {
      id
      name
      email
      createdAt
    }
  }
`;

const USER_UPDATED_GQL = gql`
  subscription OnUserUpdated($userId: ID!) {
    userUpdated(userId: $userId) {
      id
      name
      status
    }
  }
`;

const USER_FIELDS_FRAGMENT = gql`
  fragment UserFields on User {
    id
    name
    email
    avatar {
      url
      thumbnail
    }
  }
`;

const SEARCH_USERS_GQL = gql`
  query SearchUsers($query: String!, $includeInactive: Boolean!) {
    activeUsers: users(query: $query, status: ACTIVE) {
      ...UserFields
    }
    inactiveUsers: users(query: $query, status: INACTIVE) @include(if: $includeInactive) {
      ...UserFields
    }
  }
`;

const GET_ENTITY_GQL = gql`
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
`;

const client = {
  graphql(strings, ...values) {
    return [strings, values];
  },
};

client.graphql`
  mutation DeleteUser($id: ID!) {
    deleteUser(id: $id) {
      success
    }
  }
`;

void joinSql;
void windowSql;
void GET_USER_GQL;
void CREATE_USER_GQL;
void USER_UPDATED_GQL;
void USER_FIELDS_FRAGMENT;
void SEARCH_USERS_GQL;
void GET_ENTITY_GQL;
