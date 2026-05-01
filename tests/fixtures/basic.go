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

  _, _, _, _, _, _, _ = rawQuery, inlineQuery, plainText, joinQuery, windowQuery, getUserGQL, createUserGQL
}
