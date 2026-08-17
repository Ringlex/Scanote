import 'package:flutter/foundation.dart';

enum NoteBlockKind { paragraph, heading, bullet, task }

@immutable
class NoteMarkupSpan {
  const NoteMarkupSpan({
    this.text = '',
    this.isBold = false,
    this.isItalic = false,
    this.isStruckThrough = false,
    this.isCode = false,
  });

  final String text;
  final bool isBold;
  final bool isItalic;
  final bool isStruckThrough;
  final bool isCode;

  NoteMarkupSpan _withText(String text) =>
      NoteMarkupSpan(text: text, isBold: isBold, isItalic: isItalic, isStruckThrough: isStruckThrough, isCode: isCode);

  NoteMarkupSpan _plus(String marker) => NoteMarkupSpan(
    isBold: isBold || marker == NoteMarkup.bold,
    isItalic: isItalic || marker == NoteMarkup.italic,
    isStruckThrough: isStruckThrough || marker == NoteMarkup.strikethrough,
    isCode: isCode || marker == NoteMarkup.code,
  );
}

@immutable
class NoteBlock {
  const NoteBlock({required this.kind, required this.spans, this.headingLevel = 1, this.isDone = false});

  final NoteBlockKind kind;
  final List<NoteMarkupSpan> spans;

  final int headingLevel;

  final bool isDone;

  bool get isEmpty => spans.every((span) => span.text.isEmpty);
}

abstract class NoteMarkup {
  const NoteMarkup._();

  static const bold = '**';
  static const italic = '_';
  static const strikethrough = '~~';
  static const code = '`';

  static const _markers = [bold, strikethrough, code, italic];

  static const _headingPrefix = '#';
  static const _bulletPrefix = '- ';
  static const _taskPrefixes = {'- [ ] ': false, '- [x] ': true, '- [X] ': true};

  static const _maxHeadingLevel = 3;

  static List<NoteBlock> parse(String text) => [for (final line in text.split('\n')) _parseLine(line)];

  static String strip(String text) {
    return [
      for (final block in parse(text)) [for (final span in block.spans) span.text].join(),
    ].join('\n');
  }

  static NoteBlock _parseLine(String line) {
    for (final MapEntry(key: prefix, value: isDone) in _taskPrefixes.entries) {
      if (line.startsWith(prefix)) {
        return NoteBlock(
          kind: NoteBlockKind.task,
          isDone: isDone,
          spans: _parseInline(line.substring(prefix.length), const NoteMarkupSpan()),
        );
      }
    }

    if (line.startsWith(_bulletPrefix)) {
      return NoteBlock(
        kind: NoteBlockKind.bullet,
        spans: _parseInline(line.substring(_bulletPrefix.length), const NoteMarkupSpan()),
      );
    }

    final level = _headingLevelOf(line);

    if (level > 0) {
      return NoteBlock(
        kind: NoteBlockKind.heading,
        headingLevel: level,
        spans: _parseInline(line.substring(level + 1), const NoteMarkupSpan()),
      );
    }

    return NoteBlock(kind: NoteBlockKind.paragraph, spans: _parseInline(line, const NoteMarkupSpan()));
  }

  static int _headingLevelOf(String line) {
    var level = 0;

    while (level < line.length && line[level] == _headingPrefix) {
      level++;
    }

    final hasSpace = level > 0 && level < line.length && line[level] == ' ';

    return hasSpace && level <= _maxHeadingLevel ? level : 0;
  }

  static List<NoteMarkupSpan> _parseInline(String text, NoteMarkupSpan style) {
    final spans = <NoteMarkupSpan>[];
    final buffer = StringBuffer();

    void flush() {
      if (buffer.isNotEmpty) {
        spans.add(style._withText(buffer.toString()));
        buffer.clear();
      }
    }

    var index = 0;

    while (index < text.length) {
      final marker = _openerAt(text, index);
      final closer = marker == null ? null : _closerFor(text, marker: marker, from: index + marker.length);

      if (marker == null || closer == null) {
        buffer.write(text[index]);
        index++;

        continue;
      }

      flush();

      final inner = text.substring(index + marker.length, closer);
      final innerStyle = style._plus(marker);

      spans.addAll(marker == code ? [innerStyle._withText(inner)] : _parseInline(inner, innerStyle));

      index = closer + marker.length;
    }

    flush();

    return spans.isEmpty ? [style] : spans;
  }

  static String? _openerAt(String text, int index) {
    for (final marker in _markers) {
      if (!text.startsWith(marker, index)) {
        continue;
      }

      if (marker == italic && !_isBoundary(index == 0 ? null : text[index - 1])) {
        continue;
      }

      return marker;
    }

    return null;
  }

  static int? _closerFor(String text, {required String marker, required int from}) {
    var index = text.indexOf(marker, from);

    while (index >= 0) {
      final isEmptyPair = index == from;
      final closesCleanly = marker != italic || _isBoundary(_charAfter(text, index + marker.length));

      if (!isEmptyPair && closesCleanly) {
        return index;
      }

      index = text.indexOf(marker, index + 1);
    }

    return null;
  }

  static String? _charAfter(String text, int index) => index < text.length ? text[index] : null;

  static bool _isBoundary(String? character) => character == null || !RegExp(r'[\w]').hasMatch(character);
}
