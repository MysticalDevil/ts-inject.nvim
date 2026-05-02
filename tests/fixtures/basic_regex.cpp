#include <regex>

void test_regex() {
  std::regex rx("[a-zA-Z]+");
  auto m = std::regex_match("hello", std::regex("[a-z]+"));
}
