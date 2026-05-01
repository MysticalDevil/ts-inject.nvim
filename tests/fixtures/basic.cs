using System;

class Db {
    public string Query(string sql, params object[] args) => sql;
    public string Execute(string sql, params object[] args) => sql;
    public string Prepare(string sql) => sql;
}

class Program {
    static void Main() {
        const string USERS_SQL = @"
SELECT Id, Email
FROM Users
WHERE Status = 'active'
";

        var summarySql = "SELECT Status, COUNT(*) AS Total " +
            "FROM Users " +
            "GROUP BY Status " +
            "HAVING COUNT(*) > 0";

        var deleteSql = "DELETE FROM Users " +
            "WHERE Status = 'inactive'";

        var db = new Db();

        var rows = db.Execute(@"
UPDATE Users
SET Status = @status
WHERE Email = @email
",
            "active",
            "alice@example.com"
        );

        var inserts = db.Query(
            "INSERT INTO Users (Email, Status) " +
            "VALUES (@email, @status) " +
            "RETURNING Id, Email, Status",
            "alice@example.com",
            "active"
        );

        var cte = db.Query(
            "WITH recent_users AS ( " +
            "SELECT Id, Email FROM Users WHERE CreatedAt >= NOW() - INTERVAL '7 days' " +
            ") " +
            "SELECT Id, Email FROM recent_users " +
            "ORDER BY Email ASC"
        );

        var stmt = db.Prepare("CREATE TABLE AuditLogs (Id BIGINT PRIMARY KEY)");
        var alter = db.Prepare(@"
ALTER TABLE AuditLogs
ADD COLUMN CreatedAt TIMESTAMP
");

        Console.WriteLine(USERS_SQL);
        Console.WriteLine(summarySql);
        Console.WriteLine(rows);
        Console.WriteLine(inserts);
        Console.WriteLine(cte);
        Console.WriteLine(stmt);
        Console.WriteLine(deleteSql);
        var joinSql = @"SELECT u.id, u.email, p.name
FROM users u
LEFT JOIN projects p ON u.id = p.user_id
WHERE u.id IN (SELECT user_id FROM audit_logs GROUP BY user_id HAVING COUNT(*) > 1)
ORDER BY u.created_at";

        var windowSql = @"WITH ranked AS (
    SELECT id, email, row_number() OVER (PARTITION BY status ORDER BY created_at) AS rn
    FROM users
)
SELECT id, email FROM ranked WHERE rn <= 5";

        Console.WriteLine(alter);
        Console.WriteLine(joinSql);
        Console.WriteLine(windowSql);
    }
}
