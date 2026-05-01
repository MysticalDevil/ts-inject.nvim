local smoke = require("tests.smoke.init")

-- GraphQL content regex injections

-- query + variables
smoke.assert_injected_node("tests/fixtures/basic.go", "go", "query GetUser", "operation_type", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.go", "go", "mutation CreateUser", "operation_type", "graphql")

-- fragment definition
smoke.assert_injected_node("tests/fixtures/basic.go", "go", "fragment UserFields", "fragment_definition", "graphql")

-- aliases + directives + fragment spread
smoke.assert_injected_node("tests/fixtures/basic.go", "go", "activeUsers: users", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic.go",
  "go",
  "inactiveUsers: users(query: $query, status: INACTIVE)",
  "name",
  "graphql"
)
smoke.assert_injected_node("tests/fixtures/basic.go", "go", "@include(if: $includeInactive)", "directive", "graphql")

-- meta field + inline fragments
smoke.assert_injected_node("tests/fixtures/basic.go", "go", "__typename", "name", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.go", "go", "... on User", "inline_fragment", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.go", "go", "... on Organization", "inline_fragment", "graphql")
