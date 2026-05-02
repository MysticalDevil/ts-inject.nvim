using System.Text.RegularExpressions;

class RegexProgram {
    static void Main() {
        var match = Regex.Match("hello", "[a-zA-Z]+");
        var replaced = Regex.Replace("hello", "[a-z]+", "X");
        var pattern = new Regex("[0-9]+");
    }
}
