import 'package:flutter/foundation.dart';
import 'package:note/data/model/note/checklist_item.dart';

enum ScannedTextKind { text, checklist }

@immutable
class ScannedText {
  const ScannedText({required this.kind, required this.text, required this.items});

  final ScannedTextKind kind;

  final String text;

  final List<ChecklistItem> items;

  bool get isEmpty => text.isEmpty;
}

abstract class TextScan {
  const TextScan._();

  static final _markerPattern = RegExp(r'^\s*(\[\s*[xX✓]?\s*\]|[-*•·‣▪–—]|\d+[.)]|☐|☑|✔|✓)\s*');

  static final _donePattern = RegExp(r'^\s*(\[\s*[xX✓]\s*\]|☑|✔|✓)');

  static const _maximumEntryWords = 3;
  static const _minimumListLines = 3;
  static const _minimumMarkedLines = 2;

  static ScannedText classify(List<String> lines) {
    final cleaned = [
      for (final line in lines)
        if (line.trim().isNotEmpty) line.trim(),
    ];

    if (cleaned.isEmpty) {
      return const ScannedText(kind: ScannedTextKind.text, text: '', items: []);
    }

    return _looksLikeList(cleaned)
        ? ScannedText(
            kind: ScannedTextKind.checklist,
            text: cleaned.join('\n'),
            items: [
              for (final line in cleaned)
                ChecklistItem(label: line.replaceFirst(_markerPattern, '').trim(), isDone: _donePattern.hasMatch(line)),
            ].where((item) => item.label.isNotEmpty).toList(),
          )
        : ScannedText(kind: ScannedTextKind.text, text: cleaned.join('\n'), items: const []);
  }

  static bool _looksLikeList(List<String> lines) {
    final markedCount = lines.where(_markerPattern.hasMatch).length;

    if (markedCount >= _minimumMarkedLines && markedCount * 2 >= lines.length) {
      return true;
    }

    return lines.length >= _minimumListLines && lines.every(_looksLikeEntry);
  }

  static bool _looksLikeEntry(String line) {
    final words = line.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);

    return words.length <= _maximumEntryWords && !line.endsWith('.') && !line.endsWith(',');
  }
}
