local smoke = require("tests.smoke.init")

-- Regex injections via Regex.Match/Replace and new Regex
smoke.assert_injected_node("tests/fixtures/basic_regex.cs", "c_sharp", "a-z", "class_character", "regex")
smoke.assert_injected_node("tests/fixtures/basic_regex.cs", "c_sharp", "0-9", "class_character", "regex")
