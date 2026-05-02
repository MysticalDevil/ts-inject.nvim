local smoke = require("tests.smoke.init")
-- GraphQL injections in Rust (suffix, content prefix, macros)

-- suffix rules: *_gql / *Graphql
smoke.assert_injected_node("tests/fixtures/basic_graphql.rs", "rust", "query GetUser", "operation_type", "graphql")
smoke.assert_injected_node("tests/fixtures/basic_graphql.rs", "rust", "user(id: $id)", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.rs",
  "rust",
  "mutation CreateUser",
  "operation_type",
  "graphql"
)
smoke.assert_injected_node("tests/fixtures/basic_graphql.rs", "rust", "createUser(input: $input)", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.rs",
  "rust",
  "subscription OnUserUpdated",
  "operation_type",
  "graphql"
)
smoke.assert_injected_node("tests/fixtures/basic_graphql.rs", "rust", "userUpdated(userId: $userId)", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.rs",
  "rust",
  "fragment UserFields",
  "fragment_definition",
  "graphql"
)

-- aliases + directives + fragment spread
smoke.assert_injected_node("tests/fixtures/basic_graphql.rs", "rust", "activeUsers: users", "name", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.rs",
  "rust",
  "inactiveUsers: users(query: $query, status: INACTIVE)",
  "name",
  "graphql"
)
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.rs",
  "rust",
  "@include(if: $includeInactive)",
  "directive",
  "graphql"
)

-- meta field + inline fragments
smoke.assert_injected_node("tests/fixtures/basic_graphql.rs", "rust", "__typename", "name", "graphql")
smoke.assert_injected_node("tests/fixtures/basic_graphql.rs", "rust", "... on User", "inline_fragment", "graphql")
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.rs",
  "rust",
  "... on Organization",
  "inline_fragment",
  "graphql"
)

-- content prefix rules (no GraphQL suffix)
smoke.assert_injected_node("tests/fixtures/basic_graphql.rs", "rust", "query GetUsers", "operation_type", "graphql")
smoke.assert_injected_node("tests/fixtures/basic_graphql.rs", "rust", "users {", "name", "graphql")

-- macro rules: graphql! / gql!
smoke.assert_injected_node(
  "tests/fixtures/basic_graphql.rs",
  "rust",
  "mutation DeleteUser",
  "operation_type",
  "graphql"
)
smoke.assert_injected_node("tests/fixtures/basic_graphql.rs", "rust", "deleteUser(id: $id)", "name", "graphql")
smoke.assert_injected_node("tests/fixtures/basic_graphql.rs", "rust", "query SimpleQuery", "operation_type", "graphql")
