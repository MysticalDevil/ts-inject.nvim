#!/usr/bin/perl
use strict;
use warnings;

# === Variable naming heuristics ===
my $users_sql = "SELECT id, email FROM perl_users WHERE active = true";
our $USERS_SQL =
  "SELECT id, email, status FROM perl_users ORDER BY created_at DESC";
my $updateSql = "UPDATE perl_users SET status = 'active'";
my $query_sql = "DELETE FROM perl_users WHERE id = ?";

# === DBI method calls (single argument) ===
my $dbh = DBI->connect( "dbi:SQLite:dbname=test.db", "", "" );
my $sth = $dbh->prepare("SELECT id, email FROM perl_users");
$dbh->execute("INSERT INTO perl_users (email) VALUES ('test@example.com')");
$dbh->do(
    "UPDATE perl_users SET status = 'active' WHERE email = 'test@example.com'");

# === DBI method calls (multiple arguments) ===
my $rows =
  $dbh->selectall_arrayref( "SELECT * FROM perl_users WHERE active = 1",
    { Slice => {} } );
my $row =
  $dbh->selectrow_hashref( "SELECT id, email FROM perl_users WHERE id = ?",
    undef, 1 );
my $col =
  $dbh->selectcol_arrayref( "SELECT email FROM perl_users WHERE active = true",
    undef );

# === String concatenation ===
my $dynamic_sql =
  "SELECT id, email" . " FROM perl_users" . " WHERE active = true";
my $usersSql = "UPDATE perl_users" . " SET status = 'active'";

# === Heredoc SQL ===
my $heredoc_sql = <<'SQL';
SELECT id, email
FROM perl_users
WHERE status = 'active'
ORDER BY created_at DESC
SQL

# === DDL ===
prepare("CREATE TABLE perl_audit_logs (id INTEGER PRIMARY KEY, message TEXT)");
execute("ALTER TABLE perl_users ADD COLUMN phone VARCHAR(20)");

# === CTE ===
my $cte_sql =
"WITH recent_users AS (SELECT id, email FROM perl_users) SELECT * FROM recent_users";

# === Transaction ===
my $tx_sql =
  "BEGIN; UPDATE accounts SET balance = balance - 100 WHERE id = 1; COMMIT;";

my $join_sql = <<'SQL';
SELECT u.id, u.email, p.name
FROM users u
LEFT JOIN projects p ON u.id = p.user_id
WHERE u.id IN (SELECT user_id FROM audit_logs GROUP BY user_id HAVING COUNT(*) > 1)
ORDER BY u.created_at
SQL

my $window_sql = <<'SQL';
WITH ranked AS (
  SELECT id, email, row_number() OVER (PARTITION BY status ORDER BY created_at) AS rn
  FROM users
)
SELECT id, email FROM ranked WHERE rn <= 5
SQL

# === TRUNCATE / DROP ===
my $truncate_sql = "TRUNCATE TABLE audit_logs";
my $drop_sql     = "DROP TABLE IF EXISTS temp_projects";

# === UNION ===
my $union_sql = <<'SQL';
SELECT id, email FROM users WHERE status = 'active'
UNION
SELECT id, email FROM archived_users WHERE status = 'active'
SQL

# === EXISTS subquery ===
my $exists_sql = <<'SQL';
SELECT id, email FROM users u
WHERE EXISTS (SELECT 1 FROM projects p WHERE p.user_id = u.id)
SQL

# === ON CONFLICT ===
my $upsert_sql =
"INSERT INTO users (email, status) VALUES ('bob@example.com', 'active') ON CONFLICT (email) DO UPDATE SET status = excluded.status";

print "Done\n";
