local smoke = require("tests.smoke.init")
-- GraphQL template_tag injections (gql, graphql, client.graphql)

-- query + variables
smoke.assert_injected_node("tests/fixtures/basic.ts", "typescript", "query GetUser", "operation_type", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.ts", "typescript", "user(id: $id)", "name", "graphql")

-- mutation + input
smoke.assert_injected_node("tests/fixtures/basic.ts", "typescript", "mutation CreateUser", "operation_type", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.ts", "typescript", "createUser(input: $input)", "name", "graphql")

-- subscription
smoke.assert_injected_node(
  "tests/fixtures/basic.ts",
  "typescript",
  "subscription OnUserUpdated",
  "operation_type",
  "graphql"
)
smoke.assert_injected_node("tests/fixtures/basic.ts", "typescript", "userUpdated(userId: $userId)", "name", "graphql")

-- fragment definition + nested selection
smoke.assert_injected_node(
  "tests/fixtures/basic.ts",
  "typescript",
  "fragment UserFields",
  "fragment_definition",
  "graphql"
)
smoke.assert_injected_node("tests/fixtures/basic.ts", "typescript", "avatar {", "name", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.ts", "typescript", "url", "name", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.ts", "typescript", "thumbnail", "name", "graphql")

-- aliases + directives + fragment spread
smoke.assert_injected_node("tests/fixtures/basic.ts", "typescript", "activeUsers: users", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic.ts",
  "typescript",
  "inactiveUsers: users(query: $query, status: INACTIVE)",
  "name",
  "graphql"
)
smoke.assert_injected_node(
  "tests/fixtures/basic.ts",
  "typescript",
  "@include(if: $includeInactive)",
  "directive",
  "graphql"
)

-- meta field + inline fragments
smoke.assert_injected_node("tests/fixtures/basic.ts", "typescript", "__typename", "name", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.ts", "typescript", "... on User", "inline_fragment", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.ts", "typescript", "... on Organization", "inline_fragment", "graphql")

-- member_expression template tag (client.graphql)
smoke.assert_injected_node("tests/fixtures/basic.ts", "typescript", "mutation DeleteUser", "operation_type", "graphql")
