fun main() {
  val USERS_SQL = """
    SELECT id, email
    FROM users
    WHERE status = 'active'
  """.trimIndent()

  val summarySql = "SELECT status, count(*) AS total " +
    "FROM users " +
    "GROUP BY status " +
    "HAVING count(*) > 0"

  val db = Db()

  val rows = db.execute(
    """
      UPDATE users
      SET status = ?
      WHERE email = ?
    """.trimIndent(),
    "active",
    "alice@example.com",
  )

  val insertRows = db.query(
    "INSERT INTO users (email, status) " +
      "VALUES (?, ?) " +
      "RETURNING id, email, status",
    "alice@example.com",
    "active",
  )

  val statements = db.query(
    "WITH recent_users AS ( " +
      "SELECT id, email FROM users WHERE created_at >= NOW() - INTERVAL '7 days' " +
      ") " +
      "SELECT id, email FROM recent_users " +
      "ORDER BY email ASC",
  )

  val schemaSql = """
    CREATE TABLE audit_logs (
      id BIGINT PRIMARY KEY,
      message TEXT NOT NULL
    )
  """.trimIndent()

  println(USERS_SQL)
  println(summarySql)
  println(rows)
  println(insertRows)
  println(statements)
  println(schemaSql)
}

class Db {
  fun query(sql: String, vararg params: Any?): String = sql

  fun execute(sql: String, vararg params: Any?): String = sql
}
