import 'package:flutter/material.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';

Future<String?> showBackupPassphraseDialog(BuildContext context, {required bool isConfirming}) {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => _BackupPassphraseDialog(isConfirming: isConfirming),
  );
}

class _BackupPassphraseDialog extends StatefulWidget {
  const _BackupPassphraseDialog({required this.isConfirming});

  final bool isConfirming;

  @override
  State<_BackupPassphraseDialog> createState() => _BackupPassphraseDialogState();
}

class _BackupPassphraseDialogState extends State<_BackupPassphraseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final _repeatController = TextEditingController();

  static const _minimumLength = 8;

  @override
  void dispose() {
    _controller.dispose();
    _repeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.translations.backupPassphraseTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.isConfirming
                    ? context.translations.backupPassphraseExportHint
                    : context.translations.backupPassphraseImportHint,
                style: context.textTheme.bodySmall?.copyWith(color: context.palette.inactiveColor),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controller,
                obscureText: true,
                autofocus: true,
                decoration: InputDecoration(hintText: context.translations.backupPassphraseHint),
                validator: (value) => (value ?? '').length < _minimumLength
                    ? context.translations.backupPassphraseTooShort(_minimumLength)
                    : null,
              ),
              if (widget.isConfirming) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _repeatController,
                  obscureText: true,
                  decoration: InputDecoration(hintText: context.translations.backupPassphraseRepeatHint),
                  validator: (value) =>
                      value == _controller.text ? null : context.translations.backupPassphraseMismatch,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.translations.commonCancel)),
        TextButton(onPressed: _onConfirmed, child: Text(context.translations.commonSave)),
      ],
    );
  }

  void _onConfirmed() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    Navigator.of(context).pop(_controller.text);
  }
}
