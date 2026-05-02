local smoke = require("tests.smoke.init")

-- Regex injections via .r suffix and new Regex
smoke.assert_injected_node("tests/fixtures/basic_regex.scala", "scala", "a-z", "class_character", "regex")
smoke.assert_injected_node("tests/fixtures/basic_regex.scala", "scala", "0-9", "class_character", "regex")
