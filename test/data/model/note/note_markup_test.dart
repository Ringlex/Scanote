import 'package:flutter_test/flutter_test.dart';
import 'package:note/data/model/note/note_markup.dart';

NoteMarkupSpan onlySpanOf(NoteBlock block) {
  expect(block.spans, hasLength(1));

  return block.spans.single;
}

void main() {
  group('NoteMarkup inline marks', () {
    test('reads the four marks the toolbar writes', () {
      final cases = {
        '**loud**': (bold: true, italic: false, struck: false, code: false),
        '_leaning_': (bold: false, italic: true, struck: false, code: false),
        '~~gone~~': (bold: false, italic: false, struck: true, code: false),
        '`literal`': (bold: false, italic: false, struck: false, code: true),
      };

      for (final MapEntry(key: source, value: expected) in cases.entries) {
        final span = onlySpanOf(NoteMarkup.parse(source).single);

        expect(span.isBold, expected.bold, reason: source);
        expect(span.isItalic, expected.italic, reason: source);
        expect(span.isStruckThrough, expected.struck, reason: source);
        expect(span.isCode, expected.code, reason: source);
      }
    });

    test('takes the markers out of the text it hands back', () {
      final span = onlySpanOf(NoteMarkup.parse('**loud**').single);

      expect(span.text, 'loud');
    });

    test('marks only the part between the markers', () {
      final spans = NoteMarkup.parse('before **loud** after').single.spans;

      expect(spans.map((span) => span.text).toList(), ['before ', 'loud', ' after']);
      expect(spans.map((span) => span.isBold).toList(), [false, true, false]);
    });

    test('carries one mark inside another', () {
      final spans = NoteMarkup.parse('**loud and _leaning_**').single.spans;
      final nested = spans.last;

      expect(spans.every((span) => span.isBold), isTrue);
      expect(nested.text, 'leaning');
      expect(nested.isItalic, isTrue);
    });

    test('leaves an underscore inside a word alone', () {
      final span = onlySpanOf(NoteMarkup.parse('file_name_here.txt').single);

      expect(span.text, 'file_name_here.txt');
      expect(span.isItalic, isFalse);
    });

    test('leaves a marker that never closes as the text it is', () {
      final span = onlySpanOf(NoteMarkup.parse('2 ** 3 is not bold').single);

      expect(span.text, '2 ** 3 is not bold');
      expect(span.isBold, isFalse);
    });

    test('does not read an empty pair as a mark', () {
      final span = onlySpanOf(NoteMarkup.parse('****').single);

      expect(span.text, '****');
      expect(span.isBold, isFalse);
    });

    test('takes code literally, markers and all', () {
      final span = onlySpanOf(NoteMarkup.parse('`**not bold**`').single);

      expect(span.text, '**not bold**');
      expect(span.isCode, isTrue);
      expect(span.isBold, isFalse);
    });
  });

  group('NoteMarkup blocks', () {
    test('reads a heading and its level', () {
      final block = NoteMarkup.parse('## Shopping').single;

      expect(block.kind, NoteBlockKind.heading);
      expect(block.headingLevel, 2);
      expect(onlySpanOf(block).text, 'Shopping');
    });

    test('needs a space after the hashes to call it a heading', () {
      final block = NoteMarkup.parse('#1 in the charts').single;

      expect(block.kind, NoteBlockKind.paragraph);
      expect(onlySpanOf(block).text, '#1 in the charts');
    });

    test('reads a bullet', () {
      final block = NoteMarkup.parse('- milk').single;

      expect(block.kind, NoteBlockKind.bullet);
      expect(onlySpanOf(block).text, 'milk');
    });

    test('tells a ticked task from an unticked one', () {
      final blocks = NoteMarkup.parse('- [ ] open\n- [x] closed');

      expect(blocks.map((block) => block.kind).toList(), [NoteBlockKind.task, NoteBlockKind.task]);
      expect(blocks.map((block) => block.isDone).toList(), [false, true]);
      expect(blocks.map((block) => onlySpanOf(block).text).toList(), ['open', 'closed']);
    });

    test('keeps one block per line, blank ones included', () {
      final blocks = NoteMarkup.parse('first\n\nthird');

      expect(blocks, hasLength(3));
      expect(blocks[1].isEmpty, isTrue);
    });

    test('marks text inside a bullet as well', () {
      final spans = NoteMarkup.parse('- **milk**').single.spans;

      expect(onlySpanOf(NoteMarkup.parse('- **milk**').single).text, 'milk');
      expect(spans.single.isBold, isTrue);
    });
  });

  group('NoteMarkup.strip', () {
    test('gives back the words without any of the marks', () {
      expect(NoteMarkup.strip('# Title\n- **milk** and _eggs_'), 'Title\nmilk and eggs');
    });

    test('leaves text that has no marks exactly as it was', () {
      const plain = 'Nothing to do here.\nSecond line.';

      expect(NoteMarkup.strip(plain), plain);
    });
  });
}
