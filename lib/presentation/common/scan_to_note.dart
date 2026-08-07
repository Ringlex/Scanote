import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/data/model/note/checklist_item.dart';
import 'package:note/data/model/note/note.dart';
import 'package:note/data/model/note/note_title.dart';
import 'package:note/data/model/note/scanned_text.dart';
import 'package:note/data/ocr/ocr_service.dart';
import 'package:note/presentation/common/app_message.dart';
import 'package:note/presentation/common/dimen.dart';
import 'package:note/presentation/injector_container.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';
import 'package:note/presentation/screens/note_editor/note_editor_argument.dart';
import 'package:note/presentation/screens/note_editor/note_editor_screen.dart';
import 'package:note/presentation/screens/note_editor/widgets/scan_source_sheet.dart';

Future<void> scanIntoNewNote(BuildContext context) async {
  final source = await showScanSourceSheet(context, title: context.translations.noteEditorScanTitle);

  if (source == null || !context.mounted) {
    return;
  }

  final pages = <List<String>>[];

  while (true) {
    final picked = await ImagePicker().pickImage(source: source);

    if (picked == null || !context.mounted) {
      break;
    }

    final page = await _readLines(context, imagePath: picked.path);

    if (page == null || !context.mounted) {
      return;
    }

    pages.add(page);

    final wantsMore = await _askForAnotherPage(context, pageCount: pages.length);

    if (!wantsMore || !context.mounted) {
      break;
    }
  }

  if (pages.isEmpty || !context.mounted) {
    return;
  }

  final scanned = TextScan.classify(pages.expand((page) => page).toList());

  if (scanned.isEmpty) {
    showAppMessage(context, message: context.translations.noteEditorScanEmpty);

    return;
  }

  await context.push(
    NoteEditorScreen.routeName,
    extra: NoteEditorArgument(
      homeBloc: context.read<HomeBloc>(),
      note: _noteFrom(scanned, pages: pages),
    ),
  );
}

Future<bool> _askForAnotherPage(BuildContext context, {required int pageCount}) async {
  final answer = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: context.palette.cardColor,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(Insets.large),
            child: Text(
              sheetContext.translations.scanPagesTaken(pageCount),
              style: sheetContext.textTheme.titleMedium?.copyWith(color: sheetContext.palette.textOnPrimaryColor),
            ),
          ),
          ListTile(
            leading: Icon(Icons.add_a_photo_outlined, color: sheetContext.palette.accentColor),
            title: Text(sheetContext.translations.scanAddPage),
            onTap: () => Navigator.of(sheetContext).pop(true),
          ),
          ListTile(
            leading: Icon(Icons.check, color: sheetContext.palette.accentColor),
            title: Text(sheetContext.translations.scanFinish),
            onTap: () => Navigator.of(sheetContext).pop(false),
          ),
        ],
      ),
    ),
  );

  return answer ?? false;
}

Future<List<String>?> _readLines(BuildContext context, {required String imagePath}) async {
  unawaited(_showProgress(context));

  final result = await injector<OcrService>().readLines(imagePath: imagePath).run();

  if (context.mounted) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  if (!context.mounted) {
    return null;
  }

  return result.match((error) {
    showAppMessage(context, message: context.translations.noteEditorScanError);

    return null;
  }, (lines) => lines);
}

Future<void> _showProgress(BuildContext context) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  useRootNavigator: true,
  builder: (dialogContext) => Center(child: CircularProgressIndicator(color: dialogContext.palette.accentColor)),
);

Note _noteFrom(ScannedText scanned, {required List<List<String>> pages}) {
  if (scanned.kind == ScannedTextKind.checklist) {
    return Note(title: '', todoList: Checklist.encode(scanned.items));
  }

  final contents = pages
      .map((page) => page.map((line) => line.trim()).where((line) => line.isNotEmpty).join('\n'))
      .where((page) => page.isNotEmpty)
      .join('\n\n');

  return Note(title: NoteTitle.fromText(contents), noteContents: contents);
}
