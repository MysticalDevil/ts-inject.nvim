local smoke = require("tests.smoke.init")

-- GraphQL content regex injections
smoke.assert_injected_node("tests/fixtures/basic.go", "go", "query GetUser", "operation_type", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.go", "go", "mutation CreateUser", "operation_type", "graphql")
