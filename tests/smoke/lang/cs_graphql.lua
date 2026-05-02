local smoke = require("tests.smoke.init")

-- GraphQL suffix rules: *_GQL / *Gql
smoke.assert_injected_node("tests/fixtures/basic_graphql.cs", "c_sharp", "query GetUser", "operation_type", "graphql")
smoke.assert_injected_node("tests/fixtures/basic_graphql.cs", "c_sharp", "user(id: $id)", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.cs",
  "c_sharp",
  "mutation CreateUser",
  "operation_type",
  "graphql"
)
smoke.assert_injected_node("tests/fixtures/basic_graphql.cs", "c_sharp", "createUser(input: $input)", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.cs",
  "c_sharp",
  "subscription OnUserUpdated",
  "operation_type",
  "graphql"
)
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.cs",
  "c_sharp",
  "userUpdated(userId: $userId)",
  "name",
  "graphql"
)
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.cs",
  "c_sharp",
  "fragment UserFields",
  "fragment_definition",
  "graphql"
)

-- aliases + directives + fragment spread
smoke.assert_injected_node("tests/fixtures/basic_graphql.cs", "c_sharp", "activeUsers: users", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.cs",
  "c_sharp",
  "inactiveUsers: users(query: $query, status: INACTIVE)",
  "name",
  "graphql"
)
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.cs",
  "c_sharp",
  "@include(if: $includeInactive)",
  "directive",
  "graphql"
)

-- meta field + inline fragments
smoke.assert_injected_node("tests/fixtures/basic_graphql.cs", "c_sharp", "__typename", "name", "graphql")
smoke.assert_injected_node("tests/fixtures/basic_graphql.cs", "c_sharp", "... on User", "inline_fragment", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.cs",
  "c_sharp",
  "... on Organization",
  "inline_fragment",
  "graphql"
)
