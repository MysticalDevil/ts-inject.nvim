type UserRow = {
  id: number;
  email: string;
};

const USER_LOOKUP_SQL = `
SELECT id, email
FROM users
WHERE email = $1
`;

const summarySql = "SELECT status, count(*) AS total " +
  "FROM users " +
  "GROUP BY status " +
  "HAVING count(*) > 0";

const db = {
  async execute<T>(_sql: string): Promise<T[]> {
    return [];
  },

  async query<T>(_sql: string): Promise<T[]> {
    return [];
  },
};

const prisma = {
  $executeRaw(strings: TemplateStringsArray, ...values: unknown[]) {
    return [strings, values];
  },
};

const rows = db.execute<UserRow>(`
UPDATE users
SET status = 'active'
WHERE email = 'alice@example.com'
`);

const summaries = db.query<UserRow>(
  "WITH recent_users AS ( " +
    "SELECT id, email FROM users WHERE created_at >= NOW() - INTERVAL '7 days' " +
  ") " +
  "SELECT id, email FROM recent_users " +
  "ORDER BY email ASC",
);

prisma.$executeRaw`
CREATE TABLE IF NOT EXISTS audit_logs (
  id SERIAL PRIMARY KEY,
  message TEXT NOT NULL
)
`;

void USER_LOOKUP_SQL;
void summarySql;
void rows;
void summaries;
