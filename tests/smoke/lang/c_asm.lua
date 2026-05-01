assert_injected_node("tests/fixtures/basic.c", "c", "nop", "word", "asm")
assert_injected_node("tests/fixtures/basic.c", "c", "mov %0, %1", "word", "asm")
assert_injected_node("tests/fixtures/basic.c", "c", "cli", "word", "asm")
assert_injected_node("tests/fixtures/basic.c", "c", "push", "word", "asm")
