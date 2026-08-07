import 'package:flutter_test/flutter_test.dart';
import 'package:note/data/share/shared_text.dart';

void main() {
  group('SharedText.suggestedTitle', () {
    test('takes the subject when the sending app gave one', () {
      const shared = SharedText(
        text: 'https://example.com/a-long-article',
        subject: 'Jak parzyć kawę',
      );

      expect(shared.suggestedTitle, 'Jak parzyć kawę');
    });

    test('falls back to the first line when there is no subject', () {
      const shared = SharedText(text: 'Pierwsza linia\nDruga linia');

      expect(shared.suggestedTitle, 'Pierwsza linia');
    });

    test('treats a blank subject as no subject at all', () {
      const shared = SharedText(text: 'Treść notatki', subject: '   ');

      expect(shared.suggestedTitle, 'Treść notatki');
    });

    test('cuts a long first line rather than handing over the whole thing', () {
      final shared = SharedText(text: 'a' * 200);

      expect(shared.suggestedTitle.length, lessThanOrEqualTo(61));
      expect(shared.suggestedTitle, endsWith('…'));
    });

    test('leaves a first line that already fits alone', () {
      const line = 'Krótki tytuł';
      const shared = SharedText(text: line);

      expect(shared.suggestedTitle, line);
      expect(shared.suggestedTitle, isNot(endsWith('…')));
    });
  });
}
