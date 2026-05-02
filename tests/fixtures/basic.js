const USERS_SQL = `
  SELECT id, email
  FROM users
  WHERE status = 'active'
`;

const aggregateSql = "SELECT status, count(*) AS total " +
  "FROM users " +
  "GROUP BY status " +
  "HAVING count(*) > 0";

const db = {
  query(sql) {
    return sql;
  },
};

const prisma = {
  $queryRaw(strings, ...values) {
    return [strings, values];
  },
};

db.query(`
  INSERT INTO users (email, status)
  VALUES ('alice@example.com', 'active')
  RETURNING id, email
`);

db.execute(
  "UPDATE users " +
    "SET status = 'active' " +
    "WHERE email = ?",
  "alice@example.com",
);

db.execute(
  "INSERT INTO users (email, status) " +
    "VALUES (?, ?) " +
    "ON CONFLICT (email) DO UPDATE SET status = excluded.status " +
    "RETURNING id, email, status",
  "alice@example.com",
  "active",
);

prisma.$queryRaw`
  DELETE FROM users
  WHERE status = ${"disabled"}
`;

const joinSql = `SELECT u.id, u.email, p.name
  FROM users u
  LEFT JOIN projects p ON u.id = p.user_id
  WHERE u.id IN (SELECT user_id FROM audit_logs GROUP BY user_id HAVING COUNT(*) > 1)
  ORDER BY u.created_at`;

const windowSql = `WITH ranked AS (
    SELECT id, email, row_number() OVER (PARTITION BY status ORDER BY created_at) AS rn
    FROM users
  )
  SELECT id, email FROM ranked WHERE rn <= 5`;

void USERS_SQL;
void aggregateSql;
void joinSql;
void windowSql;
