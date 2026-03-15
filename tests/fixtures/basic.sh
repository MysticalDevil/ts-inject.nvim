cat <<'SQL' | sqlite3
  SELECT id, email
  FROM users
SQL

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
