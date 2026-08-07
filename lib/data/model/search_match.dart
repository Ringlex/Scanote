abstract class SearchMatch {
  const SearchMatch._();

  static const _foldings = {
    'ą': 'a',
    'ć': 'c',
    'ę': 'e',
    'ł': 'l',
    'ń': 'n',
    'ó': 'o',
    'ś': 's',
    'ź': 'z',
    'ż': 'z',

    'á': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'í': 'i',
    'ö': 'o',
    'ü': 'u',
    'ß': 'ss',
    'č': 'c',
    'š': 's',
    'ž': 'z',
  };

  static String fold(String text) {
    final buffer = StringBuffer();

    for (final rune in text.toLowerCase().runes) {
      final character = String.fromCharCode(rune);

      buffer.write(_foldings[character] ?? character);
    }

    return buffer.toString();
  }

  static bool matches({required String text, required String query}) {
    final words = tokenise(query);

    if (words.isEmpty) {
      return true;
    }

    final folded = fold(text);

    return words.every(folded.contains);
  }

  static List<String> tokenise(String query) => [
    for (final word in fold(query).split(RegExp(r'\s+')))
      if (word.isNotEmpty) word,
  ];
}
