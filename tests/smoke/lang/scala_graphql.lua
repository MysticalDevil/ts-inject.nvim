local smoke = require("tests.smoke.init")

-- GraphQL suffix rules: *_GQL / *Gql
smoke.assert_injected_node("tests/fixtures/basic_graphql.scala", "scala", "query GetUser", "operation_type", "graphql")
smoke.assert_injected_node("tests/fixtures/basic_graphql.scala", "scala", "user(id: $id)", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.scala",
  "scala",
  "mutation CreateUser",
  "operation_type",
  "graphql"
)
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.scala",
  "scala",
  "createUser(input: $input)",
  "name",
  "graphql"
)
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.scala",
  "scala",
  "subscription OnUserUpdated",
  "operation_type",
  "graphql"
)
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.scala",
  "scala",
  "userUpdated(userId: $userId)",
  "name",
  "graphql"
)
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.scala",
  "scala",
  "fragment UserFields",
  "fragment_definition",
  "graphql"
)

-- aliases + directives + fragment spread
smoke.assert_injected_node("tests/fixtures/basic_graphql.scala", "scala", "activeUsers: users", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.scala",
  "scala",
  "inactiveUsers: users(query: $query, status: INACTIVE)",
  "name",
  "graphql"
)
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.scala",
  "scala",
  "@include(if: $includeInactive)",
  "directive",
  "graphql"
)

-- meta field + inline fragments
smoke.assert_injected_node("tests/fixtures/basic_graphql.scala", "scala", "__typename", "name", "graphql")
smoke.assert_injected_node("tests/fixtures/basic_graphql.scala", "scala", "... on User", "inline_fragment", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.scala",
  "scala",
  "... on Organization",
  "inline_fragment",
  "graphql"
)
