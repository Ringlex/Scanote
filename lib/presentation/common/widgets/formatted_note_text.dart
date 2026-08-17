import 'package:flutter/material.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/data/model/note/note_markup.dart';

class FormattedNoteText extends StatelessWidget {
  const FormattedNoteText({required this.text, super.key});

  final String text;

  static const _monospace = ['monospace', 'Courier'];

  static const _codeFontScale = 0.92;
  static const _bulletGlyph = '•  ';
  static const _taskIconSize = 18.0;
  static const _taskGap = 6.0;

  @override
  Widget build(BuildContext context) {
    final base = context.textTheme.bodyLarge!.copyWith(color: context.palette.textOnPrimaryColor);
    final blocks = NoteMarkup.parse(text);

    return SelectableText.rich(
      TextSpan(
        style: base,
        children: [
          for (final (index, block) in blocks.indexed) ...[
            if (index > 0) const TextSpan(text: '\n'),
            ..._blockSpans(context, block: block, base: base),
          ],
        ],
      ),
    );
  }

  List<InlineSpan> _blockSpans(BuildContext context, {required NoteBlock block, required TextStyle base}) {
    return switch (block.kind) {
      NoteBlockKind.heading => [
        TextSpan(
          children: _inlineSpans(context, block: block, base: _headingStyle(context, block.headingLevel)),
        ),
      ],
      NoteBlockKind.bullet => [
        TextSpan(
          text: _bulletGlyph,
          style: base.copyWith(color: context.palette.accentColor),
        ),
        ..._inlineSpans(context, block: block, base: base),
      ],
      NoteBlockKind.task => [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.only(right: _taskGap),
            child: Icon(
              block.isDone ? Icons.check_box : Icons.check_box_outline_blank,
              size: _taskIconSize,
              color: block.isDone ? context.palette.accentColor : context.palette.inactiveColor,
            ),
          ),
        ),
        ..._inlineSpans(
          context,
          block: block,
          base: block.isDone
              ? base.copyWith(color: context.palette.inactiveColor, decoration: TextDecoration.lineThrough)
              : base,
        ),
      ],
      NoteBlockKind.paragraph => _inlineSpans(context, block: block, base: base),
    };
  }

  List<InlineSpan> _inlineSpans(BuildContext context, {required NoteBlock block, required TextStyle base}) {
    return [
      for (final span in block.spans)
        TextSpan(
          text: span.text,
          style: _styleFor(context, span: span, base: base),
        ),
    ];
  }

  TextStyle _styleFor(BuildContext context, {required NoteMarkupSpan span, required TextStyle base}) {
    var style = base;

    if (span.isBold) {
      style = style.copyWith(fontWeight: FontWeight.bold);
    }

    if (span.isItalic) {
      style = style.copyWith(fontStyle: FontStyle.italic);
    }

    if (span.isStruckThrough) {
      style = style.copyWith(
        decoration: TextDecoration.combine([
          if (style.decoration != null && style.decoration != TextDecoration.none) style.decoration!,
          TextDecoration.lineThrough,
        ]),
      );
    }

    if (span.isCode) {
      style = style.copyWith(
        fontFamily: _monospace.first,
        fontFamilyFallback: _monospace,
        fontSize: (style.fontSize ?? base.fontSize ?? 16) * _codeFontScale,
        backgroundColor: context.palette.cardColor,
      );
    }

    return style;
  }

  TextStyle _headingStyle(BuildContext context, int level) {
    final theme = context.textTheme;
    final style = switch (level) {
      1 => theme.displaySmall!,
      2 => theme.headlineSmall!,
      _ => theme.titleMedium!,
    };

    return style.copyWith(color: context.palette.textOnPrimaryColor);
  }
}
