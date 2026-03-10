<?php

const USERS_SQL = <<<'SQL'
  SELECT id, email
  FROM users
  WHERE status = 'active'
SQL;

$summarySql = "SELECT status, count(*) AS total " .
  "FROM users " .
  "GROUP BY status " .
  "HAVING count(*) > 0";

$deleteSql = "DELETE FROM users " .
  "WHERE status = 'inactive'";

$db = new class {
  public function query(string $sql, mixed ...$params): string
  {
    return $sql;
  }

  public function execute(string $sql, mixed ...$params): string
  {
    return $sql;
  }

  public function prepare(string $sql): string
  {
    return $sql;
  }
};

$rows = $db->execute(<<<'SQL'
  UPDATE users
  SET status = ?
  WHERE email = ?
SQL, 'active', 'alice@example.com');

$inserts = $db->query(
  "INSERT INTO users (email, status) " .
  "VALUES (?, ?) " .
  "RETURNING id, email, status",
  'alice@example.com',
  'active',
);

$cte = $db->query(
  "WITH recent_users AS ( " .
  "SELECT id, email FROM users WHERE created_at >= NOW() - INTERVAL '7 days' " .
  ") " .
  "SELECT id, email FROM recent_users " .
  "ORDER BY email ASC",
);

$stmt = $db->prepare("CREATE TABLE audit_logs (id BIGINT PRIMARY KEY)");
$alter = $db->prepare(<<<'SQL'
  ALTER TABLE audit_logs
  ADD COLUMN created_at TIMESTAMP
SQL);
