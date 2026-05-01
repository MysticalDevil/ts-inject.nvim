-- GraphQL template_tag injections (gql, graphql, client.graphql)

-- query + variables
assert_injected_node("tests/fixtures/basic.js", "javascript", "query GetUser", "operation_type", "graphql")
assert_injected_node("tests/fixtures/basic.js", "javascript", "user(id: $id)", "name", "graphql")

-- mutation + input
assert_injected_node("tests/fixtures/basic.js", "javascript", "mutation CreateUser", "operation_type", "graphql")
assert_injected_node("tests/fixtures/basic.js", "javascript", "createUser(input: $input)", "name", "graphql")

-- subscription
assert_injected_node("tests/fixtures/basic.js", "javascript", "subscription OnUserUpdated", "operation_type", "graphql")
assert_injected_node("tests/fixtures/basic.js", "javascript", "userUpdated(userId: $userId)", "name", "graphql")

-- fragment definition + nested selection
assert_injected_node("tests/fixtures/basic.js", "javascript", "fragment UserFields", "fragment_definition", "graphql")
assert_injected_node("tests/fixtures/basic.js", "javascript", "avatar {", "name", "graphql")
assert_injected_node("tests/fixtures/basic.js", "javascript", "url", "name", "graphql")
assert_injected_node("tests/fixtures/basic.js", "javascript", "thumbnail", "name", "graphql")

-- aliases + directives + fragment spread
assert_injected_node("tests/fixtures/basic.js", "javascript", "activeUsers: users", "name", "graphql")
assert_injected_node("tests/fixtures/basic.js", "javascript", "inactiveUsers: users(query: $query, status: INACTIVE)", "name", "graphql")
assert_injected_node("tests/fixtures/basic.js", "javascript", "@include(if: $includeInactive)", "directive", "graphql")

-- meta field + inline fragments
assert_injected_node("tests/fixtures/basic.js", "javascript", "__typename", "name", "graphql")
assert_injected_node("tests/fixtures/basic.js", "javascript", "... on User", "inline_fragment", "graphql")
assert_injected_node("tests/fixtures/basic.js", "javascript", "... on Organization", "inline_fragment", "graphql")

-- member_expression template tag (client.graphql)
assert_injected_node("tests/fixtures/basic.js", "javascript", "mutation DeleteUser", "operation_type", "graphql")
