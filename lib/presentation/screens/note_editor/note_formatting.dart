import 'package:flutter/widgets.dart';

extension NoteFormatting on TextEditingController {
  void wrapSelection(String marker) {
    final selection = _effectiveSelection;
    final selected = selection.textInside(text);

    final updatedText = text.replaceRange(
      selection.start,
      selection.end,
      '$marker$selected$marker',
    );

    value = value.copyWith(
      text: updatedText,
      selection: TextSelection(
        baseOffset: selection.start + marker.length,
        extentOffset: selection.start + marker.length + selected.length,
      ),
      composing: TextRange.empty,
    );
  }

  void toggleLinePrefix(String prefix) {
    final selection = _effectiveSelection;
    final lineStart = text.lastIndexOf('\n', selection.start == 0 ? 0 : selection.start - 1) + 1;
    final hasPrefix = text.startsWith(prefix, lineStart);

    final updatedText = hasPrefix
        ? text.replaceRange(lineStart, lineStart + prefix.length, '')
        : text.replaceRange(lineStart, lineStart, prefix);
    final offset = hasPrefix ? -prefix.length : prefix.length;

    value = value.copyWith(
      text: updatedText,
      selection: TextSelection.collapsed(
        offset: (selection.end + offset).clamp(lineStart, updatedText.length),
      ),
      composing: TextRange.empty,
    );
  }

  TextSelection get _effectiveSelection => selection.isValid ? selection : TextSelection.collapsed(offset: text.length);
}
