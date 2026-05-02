local smoke = require("tests.smoke.init")

-- GraphQL suffix rules: *_GQL / *Gql
smoke.assert_injected_node("tests/fixtures/basic_graphql.php", "php", "query GetUser", "operation_type", "graphql")
smoke.assert_injected_node("tests/fixtures/basic_graphql.php", "php", "user {", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.php",
  "php",
  "mutation CreateUser",
  "operation_type",
  "graphql"
)
smoke.assert_injected_node("tests/fixtures/basic_graphql.php", "php", "createUser {", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.php",
  "php",
  "subscription OnUserUpdated",
  "operation_type",
  "graphql"
)
smoke.assert_injected_node("tests/fixtures/basic_graphql.php", "php", "userUpdated {", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.php",
  "php",
  "fragment UserFields",
  "fragment_definition",
  "graphql"
)

-- aliases + directives + fragment spread
smoke.assert_injected_node("tests/fixtures/basic_graphql.php", "php", "activeUsers: users", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.php",
  "php",
  "inactiveUsers: users(status: INACTIVE)",
  "name",
  "graphql"
)
smoke.assert_injected_node("tests/fixtures/basic_graphql.php", "php", "@include(if: true)", "directive", "graphql")

-- meta field + inline fragments
smoke.assert_injected_node("tests/fixtures/basic_graphql.php", "php", "__typename", "name", "graphql")
smoke.assert_injected_node("tests/fixtures/basic_graphql.php", "php", "... on User", "inline_fragment", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.php",
  "php",
  "... on Organization",
  "inline_fragment",
  "graphql"
)
