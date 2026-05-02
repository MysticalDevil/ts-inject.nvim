local smoke = require("tests.smoke.init")

-- GraphQL suffix rules: *_GQL / *Gql
smoke.assert_injected_node("tests/fixtures/basic_graphql.java", "java", "query GetUser", "operation_type", "graphql")
smoke.assert_injected_node("tests/fixtures/basic_graphql.java", "java", "user(id: $id)", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.java",
  "java",
  "mutation CreateUser",
  "operation_type",
  "graphql"
)
smoke.assert_injected_node("tests/fixtures/basic_graphql.java", "java", "createUser(input: $input)", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.java",
  "java",
  "subscription OnUserUpdated",
  "operation_type",
  "graphql"
)
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.java",
  "java",
  "userUpdated(userId: $userId)",
  "name",
  "graphql"
)
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.java",
  "java",
  "fragment UserFields",
  "fragment_definition",
  "graphql"
)

-- aliases + directives + fragment spread
smoke.assert_injected_node("tests/fixtures/basic_graphql.java", "java", "activeUsers: users", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.java",
  "java",
  "inactiveUsers: users(query: $query, status: INACTIVE)",
  "name",
  "graphql"
)
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.java",
  "java",
  "@include(if: $includeInactive)",
  "directive",
  "graphql"
)

-- meta field + inline fragments
smoke.assert_injected_node("tests/fixtures/basic_graphql.java", "java", "__typename", "name", "graphql")
smoke.assert_injected_node("tests/fixtures/basic_graphql.java", "java", "... on User", "inline_fragment", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.java",
  "java",
  "... on Organization",
  "inline_fragment",
  "graphql"
)
