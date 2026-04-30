#!/usr/bin/perl
use strict;
use warnings;

# === Variable naming heuristics ===
my $users_sql = "SELECT id, email FROM perl_users WHERE active = true";
our $USERS_SQL = "SELECT id, email, status FROM perl_users ORDER BY created_at DESC";
my $updateSql = "UPDATE perl_users SET status = 'active'";
my $query_sql = "DELETE FROM perl_users WHERE id = ?";

# === DBI method calls (single argument) ===
my $dbh = DBI->connect("dbi:SQLite:dbname=test.db", "", "");
my $sth = $dbh->prepare("SELECT id, email FROM perl_users");
$dbh->execute("INSERT INTO perl_users (email) VALUES ('test@example.com')");
$dbh->do("UPDATE perl_users SET status = 'active' WHERE email = 'test@example.com'");

# === DBI method calls (multiple arguments) ===
my $rows = $dbh->selectall_arrayref("SELECT * FROM perl_users WHERE active = 1", { Slice => {} });
my $row = $dbh->selectrow_hashref("SELECT id, email FROM perl_users WHERE id = ?", undef, 1);
my $col = $dbh->selectcol_arrayref("SELECT email FROM perl_users WHERE active = true", undef);

# === String concatenation ===
my $dynamic_sql = "SELECT id, email" . " FROM perl_users" . " WHERE active = true";
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
my $cte_sql = "WITH recent_users AS (SELECT id, email FROM perl_users) SELECT * FROM recent_users";

# === Transaction ===
my $tx_sql = "BEGIN; UPDATE accounts SET balance = balance - 100 WHERE id = 1; COMMIT;";

print "Done\n";
