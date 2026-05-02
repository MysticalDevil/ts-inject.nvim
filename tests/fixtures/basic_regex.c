#include <regex.h>

void test_regex() {
  regex_t regex;
  regcomp(&regex, "[a-zA-Z]+", REG_EXTENDED);
}
