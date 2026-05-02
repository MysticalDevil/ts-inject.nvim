local smoke = require("tests.smoke.init")

-- Regex injections via std::regex constructor and std::regexMatch inner regex
smoke.assert_injected_node("tests/fixtures/basic_regex.cpp", "cpp", "a-z", "class_character", "regex")
smoke.assert_injected_node("tests/fixtures/basic_regex.cpp", "cpp", "A-Z", "class_character", "regex")
