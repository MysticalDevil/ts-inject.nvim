local smoke = require("tests.smoke.init")
-- GraphQL template_tag injections (gql, graphql, client.graphql)

-- query + variables
smoke.assert_injected_node("tests/fixtures/basic.js", "javascript", "query GetUser", "operation_type", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.js", "javascript", "user(id: $id)", "name", "graphql")

-- mutation + input
smoke.assert_injected_node("tests/fixtures/basic.js", "javascript", "mutation CreateUser", "operation_type", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.js", "javascript", "createUser(input: $input)", "name", "graphql")

-- subscription
smoke.assert_injected_node(
  "tests/fixtures/basic.js",
  "javascript",
  "subscription OnUserUpdated",
  "operation_type",
  "graphql"
)
smoke.assert_injected_node("tests/fixtures/basic.js", "javascript", "userUpdated(userId: $userId)", "name", "graphql")

-- fragment definition + nested selection
smoke.assert_injected_node(
  "tests/fixtures/basic.js",
  "javascript",
  "fragment UserFields",
  "fragment_definition",
  "graphql"
)
smoke.assert_injected_node("tests/fixtures/basic.js", "javascript", "avatar {", "name", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.js", "javascript", "url", "name", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.js", "javascript", "thumbnail", "name", "graphql")

-- aliases + directives + fragment spread
smoke.assert_injected_node("tests/fixtures/basic.js", "javascript", "activeUsers: users", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic.js",
  "javascript",
  "inactiveUsers: users(query: $query, status: INACTIVE)",
  "name",
  "graphql"
)
smoke.assert_injected_node(
  "tests/fixtures/basic.js",
  "javascript",
  "@include(if: $includeInactive)",
  "directive",
  "graphql"
)

-- meta field + inline fragments
smoke.assert_injected_node("tests/fixtures/basic.js", "javascript", "__typename", "name", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.js", "javascript", "... on User", "inline_fragment", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.js", "javascript", "... on Organization", "inline_fragment", "graphql")

-- member_expression template tag (client.graphql)
smoke.assert_injected_node("tests/fixtures/basic.js", "javascript", "mutation DeleteUser", "operation_type", "graphql")
