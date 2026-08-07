import 'package:flutter_test/flutter_test.dart';
import 'package:note/data/model/search_match.dart';

void main() {
  group('SearchMatch.matches', () {
    test('finds a word typed without Polish letters', () {
      expect(
        SearchMatch.matches(text: 'Zażółć gęślą jaźń', query: 'zazolc'),
        isTrue,
      );
      expect(
        SearchMatch.matches(text: 'Faktura za śmieci', query: 'smieci'),
        isTrue,
      );
    });

    test('finds a word typed with them, in text that has them', () {
      expect(
        SearchMatch.matches(text: 'Umowa najmu — część druga', query: 'część'),
        isTrue,
      );
    });

    test('ignores letter case on both sides', () {
      expect(SearchMatch.matches(text: 'PARAGON', query: 'paragon'), isTrue);
      expect(SearchMatch.matches(text: 'paragon', query: 'PARAGON'), isTrue);
    });

    test('takes the words in any order, which is how a scan is remembered', () {
      const text = 'Faktura VAT nr 12/2026 z dnia 3 marca, sprzedawca Kowalski';

      expect(SearchMatch.matches(text: text, query: 'faktura marca'), isTrue);
      expect(SearchMatch.matches(text: text, query: 'kowalski faktura'), isTrue);
    });

    test('wants every word, not just one of them', () {
      const text = 'Paragon z piekarni';

      expect(SearchMatch.matches(text: text, query: 'paragon piekarni'), isTrue);
      expect(SearchMatch.matches(text: text, query: 'paragon apteka'), isFalse);
    });

    test('matches partial words, so a half-remembered one still finds it', () {
      expect(SearchMatch.matches(text: 'ubezpieczenie', query: 'ubezp'), isTrue);
    });

    test('an empty query matches everything, nothing having been asked yet', () {
      expect(SearchMatch.matches(text: 'cokolwiek', query: ''), isTrue);
      expect(SearchMatch.matches(text: 'cokolwiek', query: '   '), isTrue);
    });

    test('extra spaces between words change nothing', () {
      expect(
        SearchMatch.matches(text: 'faktura marzec', query: '  faktura    marzec  '),
        isTrue,
      );
    });

    test('says no when the text holds nothing of the query', () {
      expect(SearchMatch.matches(text: 'lista zakupów', query: 'faktura'), isFalse);
    });
  });

  group('SearchMatch.fold', () {
    test('takes the accents off and lowers the case', () {
      expect(SearchMatch.fold('ŻÓŁW'), 'zolw');
      expect(SearchMatch.fold('Zażółć'), 'zazolc');
    });

    test('leaves plain letters, digits and punctuation alone', () {
      expect(SearchMatch.fold('Nr 12/2026'), 'nr 12/2026');
    });

    test('handles letters from beyond Polish that turn up in scans', () {
      expect(SearchMatch.fold('Müller'), 'muller');
      expect(SearchMatch.fold('Straße'), 'strasse');
    });
  });

  group('SearchMatch.tokenise', () {
    test('splits on whitespace and drops the gaps', () {
      expect(SearchMatch.tokenise('  faktura   marzec '), ['faktura', 'marzec']);
    });

    test('gives nothing back for a query of only spaces', () {
      expect(SearchMatch.tokenise('    '), isEmpty);
    });
  });
}
