import 'package:flutter/material.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';

Future<String?> showCategoryNameDialog(BuildContext context, {required String title, String? initialName}) {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => _CategoryNameDialog(title: title, initialName: initialName),
  );
}

class _CategoryNameDialog extends StatefulWidget {
  const _CategoryNameDialog({required this.title, this.initialName});

  final String title;
  final String? initialName;

  @override
  State<_CategoryNameDialog> createState() => _CategoryNameDialogState();
}

class _CategoryNameDialogState extends State<_CategoryNameDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _onSubmitted(),
        style: context.textTheme.bodyLarge!.copyWith(color: context.palette.textOnPrimaryColor),
        cursorColor: context.palette.accentColor,
        decoration: InputDecoration(
          hintText: context.translations.categoriesNameHint,
          hintStyle: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.palette.inactiveColor)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.palette.accentColor)),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.translations.commonCancel)),
        TextButton(onPressed: _onSubmitted, child: Text(context.translations.commonSave)),
      ],
    );
  }

  void _onSubmitted() {
    final name = _controller.text.trim();

    Navigator.of(context).pop(name.isEmpty ? null : name);
  }
}
