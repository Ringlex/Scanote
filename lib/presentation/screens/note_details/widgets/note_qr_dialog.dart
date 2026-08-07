import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:note/core/app_logger/app_logger.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/data/model/note/note.dart';
import 'package:note/data/model/note/note_share.dart';
import 'package:note/presentation/common/app_message.dart';
import 'package:note/presentation/common/dimen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

Future<void> showNoteQrDialog(BuildContext context, {required Note note, String? categoryName}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => _NoteQrDialog(
      payload: NoteShare.encode(note: note, categoryName: categoryName),
      title: note.title,
    ),
  );
}

class _NoteQrDialog extends StatefulWidget {
  const _NoteQrDialog({required this.payload, required this.title});

  final String payload;
  final String title;

  @override
  State<_NoteQrDialog> createState() => _NoteQrDialogState();
}

class _NoteQrDialogState extends State<_NoteQrDialog> {
  final _codeKey = GlobalKey();

  bool _isSharing = false;

  static const _codeSize = 240.0;
  static const _codePadding = 12.0;
  static const _cornerRadius = 12.0;
  static const _progressSize = 16.0;
  static const _progressWidth = 2.0;

  static const _exportScale = 3.0;

  @override
  Widget build(BuildContext context) {
    final isTooLong = widget.payload.length > NoteShare.maxPayloadLength;

    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isTooLong)
            Text(
              context.translations.noteQrTooLong,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium!.copyWith(color: context.palette.errorColor),
            )
          else ...[
            RepaintBoundary(
              key: _codeKey,
              child: Container(
                padding: const EdgeInsets.all(_codePadding),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(_cornerRadius)),
                child: QrImageView(data: widget.payload, size: _codeSize, backgroundColor: Colors.white),
              ),
            ),
            Gap.medium,
            Text(
              context.translations.noteQrHint,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.translations.commonClose)),
        if (!isTooLong)
          TextButton.icon(
            onPressed: _isSharing ? null : _onSharePressed,
            icon: _isSharing
                ? const SizedBox(
                    width: _progressSize,
                    height: _progressSize,
                    child: CircularProgressIndicator(strokeWidth: _progressWidth),
                  )
                : const Icon(Icons.ios_share),
            label: Text(context.translations.commonShare),
          ),
      ],
    );
  }

  Future<void> _onSharePressed() async {
    final message = '${widget.title}\n${context.translations.noteQrHint}';

    final origin = _dialogBounds();

    setState(() => _isSharing = true);

    try {
      final file = await _writeCodeToFile();

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: message,
          subject: widget.title,
          sharePositionOrigin: origin,
        ),
      );
    } catch (error, stackTrace) {
      logSevere('Sharing the QR code failed', error, stackTrace);

      if (mounted) {
        showAppMessage(context, message: context.translations.noteQrShareFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<File> _writeCodeToFile() async {
    final boundary = _codeKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: _exportScale);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;

    image.dispose();

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${_fileName()}');

    return file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
  }

  String _fileName() {
    final slug = widget.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');

    return 'note-${slug.isEmpty ? 'qr' : slug}.png';
  }

  Rect? _dialogBounds() {
    final box = context.findRenderObject() as RenderBox?;

    return box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  }
}
