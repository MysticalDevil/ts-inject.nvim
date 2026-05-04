import org.apache.ibatis.annotations.Delete
import org.apache.ibatis.annotations.Insert
import org.apache.ibatis.annotations.Select
import org.apache.ibatis.annotations.Update
import org.springframework.data.jpa.repository.Query

interface UserMapper {
    @Select("SELECT id FROM kotlin_annotated_users WHERE id = #{id}")
    fun findById(id: Long): Any

    @Select(
        arrayOf(
            "SELECT active_id, email",
            "FROM kotlin_annotated_active_users",
            "WHERE active = true",
        ),
    )
    fun findActive(): List<Any>

    @Insert("INSERT INTO kotlin_annotated_users (email, status) VALUES (#{email}, #{status})")
    fun insert(user: Any): Int

    @Update("UPDATE kotlin_annotated_users SET status = ? WHERE id = ?")
    fun update(user: Any): Int

    @Delete("DELETE FROM kotlin_annotated_users WHERE active = false")
    fun deleteInactive(): Int
}

interface SpringUserRepository {
    @Query(value = "SELECT id FROM kotlin_spring_users WHERE active = true", nativeQuery = true)
    fun nativeUsers(): List<Any>

    @Query(nativeQuery = true, value = "SELECT id FROM kotlin_spring_reversed_users WHERE active = true")
    fun nativeUsersReversed(): List<Any>
}

fun main() {
    val USERS_SQL =
        """
        SELECT id, email
        FROM users
        WHERE status = 'active'
        """.trimIndent()

    val summarySql =
        "SELECT status, count(*) AS total " +
            "FROM users " +
            "GROUP BY status " +
            "HAVING count(*) > 0"

    val migrationSql =
        """
        ALTER TABLE users
        ADD COLUMN last_seen_at TIMESTAMPTZ
        """.trimIndent()

    val db = Db()

    val rows =
        db.execute(
            """
            UPDATE users
            SET status = ?
            WHERE email = ?
            """.trimIndent(),
            "active",
            "alice@example.com",
        )

    val insertRows =
        db.query(
            "INSERT INTO users (email, status) " +
                "VALUES (?, ?) " +
                "RETURNING id, email, status",
            "alice@example.com",
            "active",
        )

    val statements =
        db.query(
            "WITH recent_users AS ( " +
                "SELECT id, email FROM users WHERE created_at >= NOW() - INTERVAL '7 days' " +
                ") " +
                "SELECT id, email FROM recent_users " +
                "ORDER BY email ASC",
        )

    val schemaSql =
        """
        CREATE TABLE audit_logs (
          id BIGINT PRIMARY KEY,
          message TEXT NOT NULL
        )
        """.trimIndent()

    val stmt =
        db.prepareStatement(
            """
            DELETE FROM users
            WHERE status = 'inactive'
            """.trimIndent(),
        )

    println(USERS_SQL)
    println(summarySql)
    println(rows)
    println(insertRows)
    println(statements)
    println(schemaSql)
    println(migrationSql)
    println(stmt)

    val joinSql =
        """
        SELECT u.id, u.email, p.name
        FROM users u
        LEFT JOIN projects p ON u.id = p.user_id
        WHERE u.id IN (SELECT user_id FROM audit_logs GROUP BY user_id HAVING COUNT(*) > 1)
        ORDER BY u.created_at
        """.trimIndent()

    val windowSql =
        """
        WITH ranked AS (
          SELECT id, email, row_number() OVER (PARTITION BY status ORDER BY created_at) AS rn
          FROM users
        )
        SELECT id, email FROM ranked WHERE rn <= 5
        """.trimIndent()

    val truncateSql = "TRUNCATE TABLE audit_logs"

    val dropSql = "DROP TABLE IF EXISTS temp_projects"

    val unionSql =
        "SELECT id, email FROM users WHERE status = 'active' " +
            "UNION " +
            "SELECT id, email FROM archived_users WHERE status = 'active'"

    val existsSql =
        "SELECT id, email FROM users u " +
            "WHERE EXISTS (SELECT 1 FROM projects p WHERE p.user_id = u.id)"

    val transactionSql =
        """
        BEGIN;
        UPDATE accounts SET balance = balance - 100 WHERE id = 1;
        UPDATE accounts SET balance = balance + 100 WHERE id = 2;
        COMMIT;
        """.trimIndent()

    val upsertSql =
        db.query(
            "INSERT INTO users (email, status) " +
                "VALUES (?, ?) " +
                "ON CONFLICT (email) DO UPDATE SET status = excluded.status",
            "bob@example.com",
            "active",
        )

    println(joinSql)
    println(windowSql)
    println(truncateSql)
    println(dropSql)
    println(unionSql)
    println(existsSql)
    println(transactionSql)
    println(upsertSql)
}

class Db {
    fun query(
        sql: String,
        vararg params: Any?,
    ): String = sql

    fun execute(
        sql: String,
        vararg params: Any?,
    ): String = sql
}
