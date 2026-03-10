local USERS_SQL = [[
  SELECT id, email
  FROM users
  WHERE status = 'active'
]]

local summary_sql = "SELECT status, count(*) AS total " ..
  "FROM users " ..
  "GROUP BY status"

local lookup_sql = ("SELECT id, email FROM users WHERE email = '%s'"):format("alice@example.com")

local db = {}

function db:query(sql)
  return sql
end

function db:execute(sql)
  return sql
end

db:query([[
  CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    email TEXT NOT NULL
  )
]])

db:execute(
  "WITH recent_users AS ( " ..
    "SELECT id, email FROM users " ..
    "WHERE created_at >= NOW() - INTERVAL '7 days' " ..
  ") " ..
  "SELECT id, email FROM recent_users"
)

db:execute(
  "INSERT INTO users (email, status) " ..
    "VALUES ($1, $2) " ..
    "RETURNING id, email, status",
  "alice@example.com",
  "active"
)

db:execute(("UPDATE users SET status = '%s' WHERE email = '%s'"):format("active", "alice@example.com"))

return USERS_SQL, summary_sql, lookup_sql
