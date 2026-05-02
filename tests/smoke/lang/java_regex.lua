local smoke = require("tests.smoke.init")

-- Regex injections via Pattern.compile and String.matches
smoke.assert_injected_node("tests/fixtures/basic_regex.java", "java", "a-z", "class_character", "regex")
smoke.assert_injected_node("tests/fixtures/basic_regex.java", "java", "A-Z", "class_character", "regex")
