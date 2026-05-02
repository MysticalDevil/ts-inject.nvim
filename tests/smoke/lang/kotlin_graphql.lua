local smoke = require("tests.smoke.init")

-- GraphQL suffix rules: *_GQL / *Gql
smoke.assert_injected_node("tests/fixtures/basic_graphql.kt", "kotlin", "query GetUser", "operation_type", "graphql")
smoke.assert_injected_node("tests/fixtures/basic_graphql.kt", "kotlin", "user {", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.kt",
  "kotlin",
  "mutation CreateUser",
  "operation_type",
  "graphql"
)
smoke.assert_injected_node("tests/fixtures/basic_graphql.kt", "kotlin", "createUser {", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.kt",
  "kotlin",
  "subscription OnUserUpdated",
  "operation_type",
  "graphql"
)
smoke.assert_injected_node("tests/fixtures/basic_graphql.kt", "kotlin", "userUpdated {", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.kt",
  "kotlin",
  "fragment UserFields",
  "fragment_definition",
  "graphql"
)

-- aliases + directives + fragment spread
smoke.assert_injected_node("tests/fixtures/basic_graphql.kt", "kotlin", "activeUsers: users", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.kt",
  "kotlin",
  "inactiveUsers: users(status: INACTIVE)",
  "name",
  "graphql"
)
smoke.assert_injected_node("tests/fixtures/basic_graphql.kt", "kotlin", "@include(if: true)", "directive", "graphql")

-- meta field + inline fragments
smoke.assert_injected_node("tests/fixtures/basic_graphql.kt", "kotlin", "__typename", "name", "graphql")
smoke.assert_injected_node("tests/fixtures/basic_graphql.kt", "kotlin", "... on User", "inline_fragment", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.kt",
  "kotlin",
  "... on Organization",
  "inline_fragment",
  "graphql"
)
