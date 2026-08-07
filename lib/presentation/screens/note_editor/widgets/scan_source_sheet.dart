import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/presentation/common/dimen.dart';

Future<ImageSource?> showScanSourceSheet(BuildContext context, {required String title}) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: context.palette.cardColor,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(_cornerRadius))),
    builder: (sheetContext) => _ScanSourceSheet(title: title),
  );
}

const _cornerRadius = 24.0;

class _ScanSourceSheet extends StatelessWidget {
  const _ScanSourceSheet({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(Insets.large),
            child: Text(
              title,
              style: context.textTheme.titleMedium!.copyWith(color: context.palette.textOnPrimaryColor),
            ),
          ),
          _SourceTile(
            icon: Icons.photo_camera_outlined,
            label: context.translations.noteEditorScanCamera,
            source: ImageSource.camera,
          ),
          _SourceTile(
            icon: Icons.photo_library_outlined,
            label: context.translations.noteEditorScanGallery,
            source: ImageSource.gallery,
          ),
          Gap.small,
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.icon, required this.label, required this.source});

  final IconData icon;
  final String label;
  final ImageSource source;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.of(context).pop(source),
      leading: Icon(icon, color: context.palette.accentColor),
      title: Text(label, style: context.textTheme.bodyLarge!.copyWith(color: context.palette.textOnPrimaryColor)),
    );
  }
}
