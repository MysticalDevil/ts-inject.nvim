const std = @import("std");

const usersSql =
    \\  SELECT id, email
    \\  FROM users
    \\  WHERE status = 'active'
;

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

    std.debug.print("{s}\\n{s}\\n", .{ usersSql, schemaSql });
}
