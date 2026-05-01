local USERS_SQL = [[
  SELECT id, email
  FROM users
  WHERE status = 'active'
]]

local summary_sql = "SELECT status, count(*) AS total " .. "FROM users " .. "GROUP BY status"

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
  "WITH recent_users AS ( "
    .. "SELECT id, email FROM users "
    .. "WHERE created_at >= NOW() - INTERVAL '7 days' "
    .. ") "
    .. "SELECT id, email FROM recent_users"
)

db:execute(
  "INSERT INTO users (email, status) " .. "VALUES ($1, $2) " .. "RETURNING id, email, status",
  "alice@example.com",
  "active"
)

db:execute(("UPDATE users SET status = '%s' WHERE email = '%s'"):format("active", "alice@example.com"))

local join_sql = [[
  SELECT u.id, u.email, p.name
  FROM users u
  LEFT JOIN projects p ON u.id = p.user_id
  WHERE u.id IN (SELECT user_id FROM audit_logs GROUP BY user_id HAVING COUNT(*) > 1)
  ORDER BY u.created_at
]]

local window_sql = [[
  WITH ranked AS (
    SELECT id, email, row_number() OVER (PARTITION BY status ORDER BY created_at) AS rn
    FROM users
  )
  SELECT id, email FROM ranked WHERE rn <= 5
]]

return USERS_SQL, summary_sql, lookup_sql, join_sql, window_sql
