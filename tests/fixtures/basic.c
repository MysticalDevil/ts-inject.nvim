#include <libpq-fe.h>
#include <sqlite3.h>

void run(PGconn *conn, sqlite3 *db) {
  const char *summary_sql = "  SELECT status "
                            "FROM users "
                            "ORDER BY status";

  const char schema_sql[] = "  CREATE TABLE projects ("
                            "id INTEGER PRIMARY KEY, "
                            "name TEXT NOT NULL)";

  const char *activity_sql = "  SELECT user_id, "
                             "count(*) AS total "
                             "FROM audit_logs "
                             "GROUP BY user_id "
                             "HAVING count(*) > 1";

  const wchar_t *wide_sql = L"  SELECT email "
                            L"FROM users "
                            L"WHERE status = 'active'";

  const unsigned char utf8_sql[] = u8"  UPDATE projects "
                                   u8"SET name = 'core' "
                                   u8"WHERE id = 1";

  const char *cast_sql = (const char *)"  INSERT INTO projects (id, name) "
                                       "VALUES (1, 'core')";

  const char *assigned_sql;
  assigned_sql = ("  DELETE FROM projects "
                  "WHERE id = 2");

  sqlite3_exec(db, "  UPDATE users "
                      "SET status = 'active' "
                      "WHERE email = 'alice@example.com'",
               0, 0, 0);

  sqlite3_exec(db,
               "  DELETE FROM audit_logs "
               "WHERE created_at < '2024-01-01'",
               0, 0, 0);

  PQexec(conn, "  INSERT INTO users (email, status) "
                 "VALUES ('alice@example.com', 'active') "
                 "RETURNING id, email, status");

  PQexec(conn, "  CREATE INDEX "
               "idx_users_email "
               "ON users(email)");

  PQprepare(
      conn, "lookup_user",
      "  WITH recent_users AS ( SELECT id, email FROM users WHERE created_at "
      ">= '2024-01-01' ) SELECT id, email FROM recent_users ORDER BY email ASC",
      0, 0);

  PQprepare(conn, "windowed_users",
            "  SELECT id, "
            "row_number() OVER (ORDER BY email) AS rn "
            "FROM users",
            0, 0);

  sqlite3_prepare_v2(db,
                     "  CREATE TABLE audit_logs (id INTEGER PRIMARY KEY, "
                     "message TEXT NOT NULL)",
                     -1, 0, 0);

  sqlite3_prepare_v2(db,
                     "  INSERT INTO audit_logs (message) "
                     "VALUES ('created')",
                     -1, 0, 0);

  sqlite3_prepare_v2(db, "  ALTER TABLE audit_logs ADD COLUMN created_at TEXT",
                     -1, 0, 0);

  sqlite3_prepare_v3(db,
                     ("  SELECT id "
                      "FROM projects "
                      "WHERE name = 'core'"),
                     -1, 0, 0, 0);

  PQexecParams(conn,
               "  SELECT id "
               "FROM projects "
               "WHERE id = $1",
               1, 0, 0, 0, 0, 0);

  PQsendPrepare(conn, "project_by_name",
                (const char *)"  SELECT id "
                              "FROM projects "
                              "WHERE name = $1",
                1, 0);

  mysql_query(conn, "  SELECT id "
                    "FROM projects "
                    "ORDER BY name");

  SQLPrepare(conn,
             L"  SELECT id "
             L"FROM projects "
             L"WHERE id > 0",
             -1);

  (void)summary_sql;
  (void)schema_sql;
  (void)activity_sql;
  (void)wide_sql;
  (void)utf8_sql;
  (void)cast_sql;
  (void)assigned_sql;

  asm("nop");
  __asm__("mov %0, %1");
  __asm__ volatile ("cli");
  asm("push" " %eax");

  const char *join_sql = "  SELECT u.id, u.email, p.name "
                         "FROM users u "
                         "LEFT JOIN projects p ON u.id = p.user_id "
                         "WHERE u.id IN (SELECT user_id FROM audit_logs GROUP BY user_id HAVING COUNT(*) > 1) "
                         "ORDER BY u.created_at";

  const char *window_sql = "  WITH ranked AS ( "
                           "SELECT id, email, row_number() OVER (PARTITION BY status ORDER BY created_at) AS rn "
                           "FROM users "
                           ") "
                           "SELECT id, email FROM ranked WHERE rn <= 5";

  (void)join_sql;
  (void)window_sql;
}
