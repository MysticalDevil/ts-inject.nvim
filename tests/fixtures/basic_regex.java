import java.util.regex.Pattern;

class RegexMain {
  void run() {
    var pattern = Pattern.compile("[a-zA-Z]+");
    var matches = "hello".matches("[a-z]+");
  }
}
