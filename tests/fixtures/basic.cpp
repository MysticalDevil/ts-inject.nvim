#include <libpq-fe.h>
#include <sqlite3.h>

void run(PGconn *conn, sqlite3 *db) {
  const char *users_sql = R"sql(  SELECT id, email
      FROM users
      WHERE active = true)sql";

  const char *schema_sql = R"sql(  CREATE TABLE audit_logs (
      id INTEGER PRIMARY KEY,
      message TEXT NOT NULL
    ))sql";

  sqlite3_exec(db,
    R"sql(  UPDATE users
      SET status = 'active'
      WHERE email = 'alice@example.com')sql",
    0, 0, 0);

  PQexec(conn,
    R"sql(  INSERT INTO users (email, status)
      VALUES ('alice@example.com', 'active')
      RETURNING id, email, status)sql");

  PQprepare(conn,
    "lookup_user",
    R"sql(  WITH recent_users AS (
      SELECT id, email FROM users WHERE created_at >= '2024-01-01'
    )
    SELECT id, email FROM recent_users ORDER BY email ASC)sql",
    0,
    0);

  sqlite3_prepare_v2(db,
    R"sql(  ALTER TABLE audit_logs ADD COLUMN created_at TEXT)sql",
    -1,
    0,
    0);

  (void) users_sql;
  (void) schema_sql;
}
