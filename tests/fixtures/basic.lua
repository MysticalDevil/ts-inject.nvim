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

local delete_sql = [[
  DELETE FROM users
  WHERE status = 'inactive'
]]

local truncate_sql = "TRUNCATE TABLE audit_logs"

local drop_sql = "DROP TABLE IF EXISTS temp_projects"

local union_sql = [[
  SELECT id, email FROM users WHERE status = 'active'
  UNION
  SELECT id, email FROM archived_users WHERE status = 'active'
]]

local exists_sql = [[
  SELECT id, email FROM users u
  WHERE EXISTS (SELECT 1 FROM projects p WHERE p.user_id = u.id)
]]

local transaction_sql = [[
  BEGIN;
  UPDATE accounts SET balance = balance - 100 WHERE id = 1;
  UPDATE accounts SET balance = balance + 100 WHERE id = 2;
  COMMIT;
]]

return USERS_SQL,
  summary_sql,
  lookup_sql,
  join_sql,
  window_sql,
  delete_sql,
  truncate_sql,
  drop_sql,
  union_sql,
  exists_sql,
  transaction_sql
