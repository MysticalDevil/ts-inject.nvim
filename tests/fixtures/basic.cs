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

        Console.WriteLine(USERS_SQL);
        Console.WriteLine(summarySql);
        Console.WriteLine(rows);
        Console.WriteLine(inserts);
        Console.WriteLine(cte);
        Console.WriteLine(stmt);
    }
}
