package fixtures

func sample() {
  rawQuery := `
  SELECT id, name
  FROM users
  WHERE active = true
`

  inlineQuery := "SELECT count(*) FROM users WHERE active = true"
  plainText := "hello world"

  joinQuery := `
  SELECT u.id, u.email, p.name
  FROM users u
  LEFT JOIN projects p ON u.id = p.user_id
  WHERE u.id IN (SELECT user_id FROM audit_logs GROUP BY user_id HAVING COUNT(*) > 1)
  ORDER BY u.created_at
  `

  windowQuery := `
  SELECT id, email, row_number() OVER (PARTITION BY status ORDER BY created_at) AS rn
  FROM users
  `

  getUserGQL := `
  query GetUser($id: ID!) {
    user(id: $id) {
      id
      name
    }
  }
  `

  createUserGQL := `
  mutation CreateUser($input: CreateUserInput!) {
    createUser(input: $input) {
      id
      name
    }
  }
  `

  userFieldsFragment := `
  fragment UserFields on User {
    id
    name
    email
  }
  `

  searchUsersGQL := `
  query SearchUsers($query: String!, $includeInactive: Boolean!) {
    activeUsers: users(query: $query, status: ACTIVE) {
      ...UserFields
    }
    inactiveUsers: users(query: $query, status: INACTIVE) @include(if: $includeInactive) {
      ...UserFields
    }
  }
  `

  getEntityGQL := `
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
  `

  _, _, _, _, _, _, _, _, _, _ = rawQuery, inlineQuery, plainText, joinQuery, windowQuery,
    getUserGQL, createUserGQL, userFieldsFragment, searchUsersGQL, getEntityGQL
}
