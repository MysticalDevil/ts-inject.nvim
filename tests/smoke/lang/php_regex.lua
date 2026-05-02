local smoke = require("tests.smoke.init")

-- Regex injections via preg_* first argument
smoke.assert_injected_node("tests/fixtures/basic_regex.php", "php", "a-z", "class_character", "regex")
smoke.assert_injected_node("tests/fixtures/basic_regex.php", "php", "\\d", "character_class_escape", "regex")
