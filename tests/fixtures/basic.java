import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLInsert;
import org.hibernate.annotations.Subselect;
import org.springframework.data.jpa.repository.Query;

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

interface UserMapper {
  @Select("SELECT id FROM annotated_users WHERE id = #{id}")
  Object findById(long id);

  @Select({
    "SELECT active_id, email",
    "FROM annotated_active_users",
    "WHERE active = true",
  })
  Object findActive();

  @Insert("INSERT INTO annotated_users (email, status) VALUES (#{email}, #{status})")
  int insert(Object user);

  @Update("UPDATE annotated_users SET status = ? WHERE id = ?")
  int update(Object user);

  @Delete("DELETE FROM annotated_users WHERE active = false")
  int deleteInactive();
}

interface SpringUserRepository {
  @Query(value = "SELECT id FROM spring_users WHERE active = true", nativeQuery = true)
  Object findNativeUsers();

  @Query(nativeQuery = true, value = "SELECT id FROM spring_reversed_users WHERE active = true")
  Object findNativeUsersReversed();
}

@Subselect("SELECT id, email FROM hibernate_subselect_users WHERE active = true")
@SQLInsert(sql = "INSERT INTO hibernate_users (email, status) VALUES (?, ?)")
@SQLDelete(sql = "DELETE FROM hibernate_users WHERE id = ?")
class UserView {
}

class Main {
  void run(Db db, Object entityManager, Object jdbcTemplate, Object handle, Object dsl) {
    String USERS_SQL = """
      SELECT id, email
      FROM users
      WHERE status = 'active'
      """;

    String summarySql = "SELECT status, count(*) AS total " +
      "FROM users " +
      "GROUP BY status " +
      "HAVING count(*) > 0";

    String deleteSql = "DELETE FROM users " +
      "WHERE status = 'inactive'";

    // sql
    String markedQuery = "SELECT id "
      + "FROM comment_marked_users "
      + "WHERE active = true";

    String inlineMarked = /* sql */ """
      DELETE FROM comment_marked_users
      WHERE active = false
      """;

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
    var alter = db.prepareStatement("""
      ALTER TABLE audit_logs
      ADD COLUMN created_at TIMESTAMP
      """);

    entityManager.createNativeQuery("SELECT id FROM jpa_native_users WHERE active = true");
    entityManager.createQuery("SELECT u FROM User u WHERE u.active = true");
    jdbcTemplate.queryForList("SELECT id FROM jdbc_template_users WHERE active = ?", true);
    jdbcTemplate.queryForObject("SELECT count(*) FROM jdbc_template_users", Integer.class);
    jdbcTemplate.update("UPDATE jdbc_template_users SET status = ? WHERE id = ?", "active", 1);
    handle.createQuery("SELECT id FROM jdbi_users WHERE active = :active");
    handle.createUpdate("UPDATE jdbi_users SET status = :status WHERE id = :id");
    dsl.fetch("SELECT id FROM jooq_users WHERE active = ?", true);
    dsl.resultQuery("SELECT id FROM jooq_result_users WHERE active = ?", true);

    System.out.println(USERS_SQL);
    System.out.println(summarySql);
    System.out.println(rows);
    System.out.println(inserts);
    System.out.println(cte);
    System.out.println(stmt);
    System.out.println(deleteSql);
    System.out.println(alter);
    System.out.println(markedQuery);
    System.out.println(inlineMarked);

    String joinSql = """
      SELECT u.id, u.email, p.name
      FROM users u
      LEFT JOIN projects p ON u.id = p.user_id
      WHERE u.id IN (SELECT user_id FROM audit_logs GROUP BY user_id HAVING COUNT(*) > 1)
      ORDER BY u.created_at
      """;

    String windowSql = """
      WITH ranked AS (
        SELECT id, email, row_number() OVER (PARTITION BY status ORDER BY created_at) AS rn
        FROM users
      )
      SELECT id, email FROM ranked WHERE rn <= 5
      """;

    System.out.println(joinSql);
    System.out.println(windowSql);
  }
}
