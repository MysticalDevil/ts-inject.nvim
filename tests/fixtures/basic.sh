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

perl <<'PERL'
print "hello again\n";
PERL
