const std = @import("std");

const usersSql =
    \\  SELECT id, email
    \\  FROM users
    \\  WHERE status = 'active'
;

const users2Sql = "SELECT id, email FROM users WHERE status = 'active'";

pub fn main() !void {
    const schemaSql =
        \\  CREATE TABLE audit_logs (
        \\    id INTEGER PRIMARY KEY,
        \\    message TEXT NOT NULL
        \\  )
    ;

    const db = struct {
        fn query(sql: []const u8) void {
            _ = sql;
        }

        fn execute(sql: []const u8, email: []const u8) void {
            _ = sql;
            _ = email;
        }
    };

    db.query(
        \\  WITH recent_users AS (
        \\    SELECT id, email
        \\    FROM users
        \\  )
        \\  SELECT id, email FROM recent_users
    );

    db.execute(
        \\  UPDATE users
        \\  SET status = 'active'
        \\  WHERE email = ?
    , "alice@example.com");

    db.query("INSERT INTO users (email) VALUES ('alice@example.com') RETURNING id");

    const joinSql =
        \\  SELECT u.id, u.email, p.name
        \\  FROM users u
        \\  LEFT JOIN projects p ON u.id = p.user_id
        \\  WHERE u.id IN (SELECT user_id FROM audit_logs GROUP BY user_id HAVING COUNT(*) > 1)
        \\  ORDER BY u.created_at
    ;

    db.query(
        \\  WITH ranked AS (
        \\    SELECT id, email, row_number() OVER (PARTITION BY status ORDER BY created_at) AS rn
        \\    FROM users
        \\  )
        \\  SELECT id, email FROM ranked WHERE rn <= 5
    );

    std.debug.print("{s}\\n{s}\\n", .{ usersSql, schemaSql });
}
