local smoke = require("tests.smoke.init")

-- GraphQL content_prefix injections
smoke.assert_injected_node("tests/fixtures/basic.py", "python", "query GetUser", "operation_type", "graphql")
smoke.assert_injected_node("tests/fixtures/basic.py", "python", "mutation CreateUser", "operation_type", "graphql")
