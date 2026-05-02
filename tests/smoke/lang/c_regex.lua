local smoke = require("tests.smoke.init")

-- Regex injection via regcomp second argument
smoke.assert_injected_node("tests/fixtures/basic_regex.c", "c", "a-z", "class_character", "regex")
