local smoke = require("tests.smoke.init")

-- GraphQL content_prefix injections

-- query + variables
smoke.assert_injected_node("tests/fixtures/basic_graphql.py", "python", "query GetUser", "operation_type", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.py",
  "python",
  "mutation CreateUser",
  "operation_type",
  "graphql"
)

-- fragment definition
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.py",
  "python",
  "fragment UserFields",
  "fragment_definition",
  "graphql"
)

-- aliases + directives + fragment spread
smoke.assert_injected_node("tests/fixtures/basic_graphql.py", "python", "activeUsers: users", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.py",
  "python",
  "inactiveUsers: users(query: $query, status: INACTIVE)",
  "name",
  "graphql"
)
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.py",
  "python",
  "@include(if: $includeInactive)",
  "directive",
  "graphql"
)

-- meta field + inline fragments
smoke.assert_injected_node("tests/fixtures/basic_graphql.py", "python", "__typename", "name", "graphql")
smoke.assert_injected_node("tests/fixtures/basic_graphql.py", "python", "... on User", "inline_fragment", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.py",
  "python",
  "... on Organization",
  "inline_fragment",
  "graphql"
)
