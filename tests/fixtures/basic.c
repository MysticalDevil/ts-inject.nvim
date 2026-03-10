#include <libpq-fe.h>
#include <sqlite3.h>

void run(PGconn *conn, sqlite3 *db) {
  const char *summary_sql = "  SELECT status \
      FROM users \
      ORDER BY status";

  sqlite3_exec(db,
    "  UPDATE users \
      SET status = 'active' \
      WHERE email = 'alice@example.com'",
    0, 0, 0);

  PQexec(conn,
    "  INSERT INTO users (email, status) \
      VALUES ('alice@example.com', 'active') \
      RETURNING id, email, status");

  PQprepare(conn,
    "lookup_user",
    "  WITH recent_users AS ( SELECT id, email FROM users WHERE created_at >= '2024-01-01' ) SELECT id, email FROM recent_users ORDER BY email ASC",
    0,
    0);

  sqlite3_prepare_v2(db,
    "  CREATE TABLE audit_logs (id INTEGER PRIMARY KEY, message TEXT NOT NULL)",
    -1,
    0,
    0);

  sqlite3_prepare_v2(db,
    "  ALTER TABLE audit_logs ADD COLUMN created_at TEXT",
    -1,
    0,
    0);

  (void) summary_sql;
}
