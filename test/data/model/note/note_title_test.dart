import 'package:flutter_test/flutter_test.dart';
import 'package:note/data/model/note/note_title.dart';

void main() {
  group('NoteTitle.fromText', () {
    test('takes the opening line, which is what a document calls itself', () {
      expect(NoteTitle.fromText('Umowa najmu\nStrony umowy\n...'), 'Umowa najmu');
    });

    test('ignores blank lines above the heading, as a photograph often has', () {
      expect(NoteTitle.fromText('\n\n  Paragon 12/2026  \nRazem: 49,90'), 'Paragon 12/2026');
    });

    test('cuts an overlong line rather than handing the whole paragraph over', () {
      final title = NoteTitle.fromText('a' * 200);

      expect(title.length, lessThanOrEqualTo(NoteTitle.limit + 1));
      expect(title, endsWith('…'));
    });

    test('leaves a line that already fits alone', () {
      expect(NoteTitle.fromText('Lista zakupów'), 'Lista zakupów');
      expect(NoteTitle.fromText('Lista zakupów'), isNot(endsWith('…')));
    });

    test('answers with nothing for text that is nothing but whitespace', () {
      expect(NoteTitle.fromText('   \n  \n'), isEmpty);
    });
  });
}
