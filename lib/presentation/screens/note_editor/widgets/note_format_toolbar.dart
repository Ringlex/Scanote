import 'package:flutter/material.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/presentation/common/dimen.dart';
import 'package:note/presentation/screens/note_editor/note_formatting.dart';

class NoteFormatToolbar extends StatelessWidget {
  const NoteFormatToolbar({
    required this.controller,
    required this.focusNode,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  static const _cornerRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.palette.cardColor,
        borderRadius: BorderRadius.circular(_cornerRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: Insets.xSmall),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FormatButton(
              icon: Icons.format_bold,
              tooltip: context.translations.noteFormatBold,
              onPressed: () => _apply(() => controller.wrapSelection('**')),
            ),
            _FormatButton(
              icon: Icons.format_italic,
              tooltip: context.translations.noteFormatItalic,
              onPressed: () => _apply(() => controller.wrapSelection('_')),
            ),
            _FormatButton(
              icon: Icons.format_strikethrough,
              tooltip: context.translations.noteFormatStrikethrough,
              onPressed: () => _apply(() => controller.wrapSelection('~~')),
            ),
            _FormatButton(
              icon: Icons.code,
              tooltip: context.translations.noteFormatCode,
              onPressed: () => _apply(() => controller.wrapSelection('`')),
            ),
            _FormatButton(
              icon: Icons.title,
              tooltip: context.translations.noteFormatHeading,
              onPressed: () => _apply(() => controller.toggleLinePrefix('# ')),
            ),
            _FormatButton(
              icon: Icons.format_list_bulleted,
              tooltip: context.translations.noteFormatBulletList,
              onPressed: () => _apply(() => controller.toggleLinePrefix('- ')),
            ),
            _FormatButton(
              icon: Icons.checklist,
              tooltip: context.translations.noteFormatChecklist,
              onPressed: () => _apply(() => controller.toggleLinePrefix('- [ ] ')),
            ),
          ],
        ),
      ),
    );
  }

  void _apply(VoidCallback format) {
    format();
    focusNode.requestFocus();
  }
}

class _FormatButton extends StatelessWidget {
  const _FormatButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  static const _iconSize = 22.0;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      icon: Icon(
        icon,
        size: _iconSize,
        color: context.palette.textOnPrimaryColor,
      ),
    );
  }
}
