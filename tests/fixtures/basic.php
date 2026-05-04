<?php

const USERS_SQL = <<<'SQL'
      SELECT id, email
      FROM users
      WHERE status = 'active'
    SQL;

$summarySql = 'SELECT status, count(*) AS total ' . 'FROM users ' . 'GROUP BY status ' . 'HAVING count(*) > 0';

$deleteSql = 'DELETE FROM users ' . "WHERE status = 'inactive'";

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
    'INSERT INTO users (email, status) ' . 'VALUES (?, ?) ' . 'RETURNING id, email, status',
    'alice@example.com',
    'active',
);

$cte = $db->query(
    'WITH recent_users AS ( '
    . "SELECT id, email FROM users WHERE created_at >= NOW() - INTERVAL '7 days' "
    . ') '
    . 'SELECT id, email FROM recent_users '
    . 'ORDER BY email ASC',
);

$stmt = $db->prepare('CREATE TABLE audit_logs (id BIGINT PRIMARY KEY)');
$alter = $db->prepare(<<<'SQL'
      ALTER TABLE audit_logs
      ADD COLUMN created_at TIMESTAMP
    SQL);

$joinSql = <<<'SQL'
      SELECT u.id, u.email, p.name
      FROM users u
      LEFT JOIN projects p ON u.id = p.user_id
      WHERE u.id IN (SELECT user_id FROM audit_logs GROUP BY user_id HAVING COUNT(*) > 1)
      ORDER BY u.created_at
    SQL;

$windowSql = <<<'SQL'
      WITH ranked AS (
        SELECT id, email, row_number() OVER (PARTITION BY status ORDER BY created_at) AS rn
        FROM users
      )
      SELECT id, email FROM ranked WHERE rn <= 5
    SQL;

$truncateSql = <<<'SQL'
      TRUNCATE TABLE audit_logs
    SQL;

$dropSql = <<<'SQL'
      DROP TABLE IF EXISTS temp_projects
    SQL;

$unionSql = <<<'SQL'
      SELECT id, email FROM users WHERE status = 'active'
      UNION
      SELECT id, email FROM archived_users WHERE status = 'active'
    SQL;

$existsSql = <<<'SQL'
      SELECT id, email FROM users u
      WHERE EXISTS (SELECT 1 FROM projects p WHERE p.user_id = u.id)
    SQL;

$transactionSql = <<<'SQL'
      BEGIN;
      UPDATE accounts SET balance = balance - 100 WHERE id = 1;
      UPDATE accounts SET balance = balance + 100 WHERE id = 2;
      COMMIT;
    SQL;

$upsertSql = $db->query(
    'INSERT INTO users (email, status) '
    . 'VALUES (?, ?) '
    . 'ON CONFLICT (email) DO UPDATE SET status = excluded.status',
    'bob@example.com',
    'active',
);
