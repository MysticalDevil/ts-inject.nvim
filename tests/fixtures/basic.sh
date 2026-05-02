#!/bin/bash

# === Heredoc SQL ===
cat <<'SQL' | sqlite3
SELECT id, email
FROM users
WHERE active = true
SQL

# === Variable naming ===
users_sql="SELECT id, email FROM users WHERE active = true"
USERS_SQL="SELECT id, email, status FROM users ORDER BY created_at DESC"
query_sql="DELETE FROM users WHERE id = 1"

# === Command calls ===
sqlite3 db "SELECT id FROM logs"
psql -c "SELECT id, email FROM users"
mysql -e "UPDATE users SET status = 'active'"

# === Function calls ===
run_query "SELECT id FROM logs"
execute_sql "INSERT INTO users (email) VALUES ('test@example.com')"

# === Here-string ===
sqlite3 db <<< "SELECT count(*) FROM users"

# === String concatenation ===
dynamic_sql="SELECT id, email"" FROM users"" WHERE active = true"

# === Other language heredocs ===
python <<'PY'
print("hello")
PY

cat <<'LUA' | nvim --headless
vim.print("hello")
LUA

node <<'JS'
console.log("hello")
JS

deno <<'TS'
const message: string = "hello"
console.log(message)
TS

ruby <<'RB'
puts "hello"
RB

ruby <<'RUBY'
puts "hello again"
RUBY

perl <<'PL'
print "hello\n";
PL

cat <<'SQL' | sqlite3
SELECT u.id, u.email, p.name
FROM users u
LEFT JOIN projects p ON u.id = p.user_id
WHERE u.id IN (SELECT user_id FROM audit_logs GROUP BY user_id HAVING COUNT(*) > 1)
ORDER BY u.created_at
SQL

cat <<'SQL' | sqlite3
WITH ranked AS (
  SELECT id, email, row_number() OVER (PARTITION BY status ORDER BY created_at) AS rn
  FROM users
)
SELECT id, email FROM ranked WHERE rn <= 5
SQL

perl <<'PERL'
print "hello again\n";
PERL

# === GraphQL heredoc ===
cat <<'GRAPHQL' | curl -X POST https://api.example.com/graphql
type Query {
  users: [User]
}
GRAPHQL

# === JSON heredoc ===
cat <<'JSON' | curl -X POST https://api.example.com/data -H "Content-Type: application/json"
{
  "users": [
    { "id": 1, "email": "a@example.com" }
  ]
}
JSON

# === Regex heredoc ===
cat <<'REGEX'
^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$
REGEX
