class Db {
  String query(String sql, Object... params) {
    return sql;
  }

  String execute(String sql, Object... params) {
    return sql;
  }

  java.sql.PreparedStatement prepareStatement(String sql) {
    return null;
  }
}

class Main {
  void run(Db db) {
    String USERS_SQL = """
      SELECT id, email
      FROM users
      WHERE status = 'active'
      """;

    String summarySql = "SELECT status, count(*) AS total " +
      "FROM users " +
      "GROUP BY status " +
      "HAVING count(*) > 0";

    var rows = db.execute("""
      UPDATE users
      SET status = ?
      WHERE email = ?
      """, "active", "alice@example.com");

    var inserts = db.query(
      "INSERT INTO users (email, status) " +
      "VALUES (?, ?) " +
      "RETURNING id, email, status",
      "alice@example.com",
      "active"
    );

    var cte = db.query(
      "WITH recent_users AS ( " +
      "SELECT id, email FROM users WHERE created_at >= NOW() - INTERVAL '7 days' " +
      ") " +
      "SELECT id, email FROM recent_users " +
      "ORDER BY email ASC"
    );

    var stmt = db.prepareStatement("CREATE TABLE audit_logs (id BIGINT PRIMARY KEY)");

    System.out.println(USERS_SQL);
    System.out.println(summarySql);
    System.out.println(rows);
    System.out.println(inserts);
    System.out.println(cte);
    System.out.println(stmt);
  }
}
