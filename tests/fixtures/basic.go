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

	schemaQuery := `
  CREATE TABLE audit_logs (
    id INTEGER PRIMARY KEY,
    message TEXT NOT NULL
  )
  `

	insertQuery := `INSERT INTO users (email, status)
  VALUES ('alice@example.com', 'active')
  RETURNING id, email, status`

	updateQuery := "UPDATE users SET status = 'active' WHERE email = 'alice@example.com'"

	deleteQuery := "DELETE FROM users WHERE status = 'inactive'"

	truncateQuery := "TRUNCATE TABLE audit_logs"

	dropQuery := "DROP TABLE IF EXISTS temp_projects"

	unionQuery := `
  SELECT id, email FROM users WHERE status = 'active'
  UNION
  SELECT id, email FROM archived_users WHERE status = 'active'
  `

	existsQuery := `
  SELECT id, email FROM users u
  WHERE EXISTS (SELECT 1 FROM projects p WHERE p.user_id = u.id)
  `

	transactionQuery := `BEGIN;
  UPDATE accounts SET balance = balance - 100 WHERE id = 1;
  UPDATE accounts SET balance = balance + 100 WHERE id = 2;
  COMMIT;`

	upsertQuery := `INSERT INTO users (email, status)
  VALUES ('bob@example.com', 'active')
  ON CONFLICT (email) DO UPDATE SET status = excluded.status`

	_, _, _, _, _, _, _, _, _, _, _, _ = rawQuery, inlineQuery, plainText, joinQuery, windowQuery, schemaQuery, insertQuery, updateQuery, deleteQuery, truncateQuery, dropQuery, unionQuery, existsQuery, transactionQuery, upsertQuery
}
