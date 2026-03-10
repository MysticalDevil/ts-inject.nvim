package fixtures

func sample() {
  rawQuery := `
SELECT id, name
FROM users
WHERE active = true
`

  inlineQuery := "SELECT count(*) FROM users WHERE active = true"
  plainText := "hello world"

  _, _, _ = rawQuery, inlineQuery, plainText
}
