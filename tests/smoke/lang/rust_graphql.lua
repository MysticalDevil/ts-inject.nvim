local smoke = require("tests.smoke.init")
-- GraphQL injections in Rust (suffix, content prefix, macros)

-- suffix rules: *_gql / *Graphql
smoke.assert_injected_node("tests/fixtures/basic.rs", "rust", "query GetUser", "operation_type", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.rs", "rust", "user(id: $id)", "name", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.rs", "rust", "mutation CreateUser", "operation_type", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.rs", "rust", "createUser(input: $input)", "name", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.rs", "rust", "subscription OnUserUpdated", "operation_type", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.rs", "rust", "userUpdated(userId: $userId)", "name", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.rs", "rust", "fragment UserFields", "fragment_definition", "graphql")

-- content prefix rules (no GraphQL suffix)
smoke.assert_injected_node("tests/fixtures/basic.rs", "rust", "query GetUsers", "operation_type", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.rs", "rust", "users {", "name", "graphql")

-- macro rules: graphql! / gql!
smoke.assert_injected_node("tests/fixtures/basic.rs", "rust", "mutation DeleteUser", "operation_type", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.rs", "rust", "deleteUser(id: $id)", "name", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.rs", "rust", "query SimpleQuery", "operation_type", "graphql")
