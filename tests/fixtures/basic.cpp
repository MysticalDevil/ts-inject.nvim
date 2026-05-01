#include <libpq-fe.h>
#include <sqlite3.h>
#include <string>

using namespace std::string_literals;

void run(PGconn *conn, sqlite3 *db) {
  const char *users_sql = R"sql(  SELECT id, email
      FROM users
      WHERE active = true)sql";

  const char *schema_sql = R"sql(  CREATE TABLE audit_logs (
      id INTEGER PRIMARY KEY,
      message TEXT NOT NULL
    ))sql";

  std::string activitySql = "  SELECT user_id, "
                            "count(*) AS total "
                            "FROM audit_logs "
                            "GROUP BY user_id "
                            "HAVING count(*) > 1";

  auto updateSql = u8"  UPDATE audit_logs "
                   u8"SET message = 'updated' "
                   u8"WHERE id = 1";

  auto insertSql = R"sql(  INSERT INTO audit_logs (message)
      VALUES ('created'))sql";

  auto deleteSql = "  DELETE FROM audit_logs "
                   "WHERE id = 2";

  auto suffixSql =
      "  CREATE INDEX idx_audit_logs_message ON audit_logs(message)"s;

  const char *castSql = (const char *)R"sql(  SELECT message
      FROM audit_logs
      ORDER BY id)sql";

  const char *assignedSql;
  assignedSql =
      (R"sql(  ALTER TABLE audit_logs ADD COLUMN updated_at TEXT)sql");

  // sql
  auto marked_query = "  SELECT id "
                      "FROM marked_users "
                      "WHERE active = true";

  auto inline_marked = /* sql */ R"sql(  DELETE FROM marked_users
      WHERE active = false)sql";

  sqlite3_exec(db,
               R"sql(  UPDATE users
      SET status = 'active'
      WHERE email = 'alice@example.com')sql",
               0, 0, 0);

  PQexec(conn,
         R"sql(  INSERT INTO users (email, status)
      VALUES ('alice@example.com', 'active')
      RETURNING id, email, status)sql");

  PQprepare(conn, "lookup_user",
            R"sql(  WITH recent_users AS (
      SELECT id, email FROM users WHERE created_at >= '2024-01-01'
    )
    SELECT id, email FROM recent_users ORDER BY email ASC)sql",
            0, 0);

  PQexecParams(conn,
               "  SELECT id "
               "FROM users "
               "WHERE email = $1",
               1, 0, 0, 0, 0, 0);

  PQsendPrepare(conn, "lookup_audit",
                (const char *)"  SELECT id "
                              "FROM audit_logs "
                              "WHERE message = $1",
                1, 0);

  sqlite3_prepare_v2(
      db, R"sql(  ALTER TABLE audit_logs ADD COLUMN created_at TEXT)sql", -1, 0,
      0);

  sqlite3_prepare_v3(db,
                     ("  SELECT id "
                      "FROM audit_logs "
                      "WHERE message = 'created'"),
                     -1, 0, 0, 0);

  struct Db {
    void exec(const char *);
    void prepare(const char *);
    void query(const char *);
  } wrapper;

  wrapper.exec(R"sql(  CREATE TABLE events (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL
    ))sql");
  wrapper.prepare("  SELECT id "
                  "FROM events "
                  "WHERE name = ?");
  wrapper.query("  SELECT count(*) "
                "FROM events");

  QSqlQuery qt_query("  SELECT id "
                     "FROM qt_users "
                     "WHERE active = 1");

  SQLite::Statement sqlite_statement(db, "  SELECT id "
                                         "FROM sqlite_users "
                                         "WHERE deleted = 0");

  query("  SELECT id "
        "FROM free_query_users "
        "WHERE active = true");

  sql << "  SELECT id "
         "FROM soci_users "
         "WHERE active = 1";

  soci::statement soci_statement = (sql.prepare << "  SELECT id "
                                                   "FROM soci_prepared_users "
                                                   "WHERE id = :id");

  (void)users_sql;
  (void)schema_sql;
  (void)activitySql;
  (void)updateSql;
  (void)insertSql;
  (void)deleteSql;
  (void)suffixSql;
  (void)castSql;
  (void)assignedSql;
  (void)marked_query;
  (void)inline_marked;

  const char *join_sql = R"sql(  SELECT u.id, u.email, p.name
      FROM users u
      LEFT JOIN projects p ON u.id = p.user_id
      WHERE u.id IN (SELECT user_id FROM audit_logs GROUP BY user_id HAVING COUNT(*) > 1)
      ORDER BY u.created_at)sql";

  const char *window_sql = R"sql(  WITH ranked AS (
      SELECT id, email, row_number() OVER (PARTITION BY status ORDER BY created_at) AS rn
      FROM users
    )
    SELECT id, email FROM ranked WHERE rn <= 5)sql";

  (void)join_sql;
  (void)window_sql;
}
