import 'package:flutter/material.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/data/scan/scan_image_store.dart';
import 'package:note/presentation/common/dimen.dart';
import 'package:note/presentation/injector_container.dart';

class ScanImageStrip extends StatelessWidget {
  const ScanImageStrip({required this.names, this.onRemoved, super.key});

  final List<String> names;

  final ValueChanged<String>? onRemoved;

  static const _height = 96.0;
  static const _cornerRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: _height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: names.length,
        separatorBuilder: (context, index) => HorizontalGap.small,
        itemBuilder: (context, index) =>
            _ScanImageThumbnail(name: names[index], position: index + 1, total: names.length, onRemoved: onRemoved),
      ),
    );
  }

  static BorderRadius get cornerRadius => BorderRadius.circular(_cornerRadius);
}

class _ScanImageThumbnail extends StatelessWidget {
  const _ScanImageThumbnail({required this.name, required this.position, required this.total, required this.onRemoved});

  final String name;
  final int position;
  final int total;
  final ValueChanged<String>? onRemoved;

  static const _width = 76.0;
  static const _removeInset = 2.0;

  @override
  Widget build(BuildContext context) {
    final onRemoved = this.onRemoved;

    return Stack(
      children: [
        Material(
          color: context.palette.cardColor,
          borderRadius: ScanImageStrip.cornerRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _onPressed(context),
            child: SizedBox(
              width: _width,
              height: double.infinity,
              child: Image.file(
                injector<ScanImageStore>().fileFor(name),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.broken_image_outlined, color: context.palette.inactiveColor),
              ),
            ),
          ),
        ),
        if (onRemoved != null)
          Positioned(
            top: _removeInset,
            right: _removeInset,
            child: _RemoveButton(
              tooltip: context.translations.noteEditorScanImageRemove,
              onPressed: () => onRemoved(name),
            ),
          ),
      ],
    );
  }

  void _onPressed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _ScanImagePage(name: name, position: position, total: total),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  static const _size = 24.0;
  static const _iconSize = 16.0;
  static const _scrimOpacity = 0.6;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: context.palette.primaryColor.withValues(alpha: _scrimOpacity),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: _size,
            height: _size,
            child: Icon(Icons.close, size: _iconSize, color: context.palette.textOnPrimaryColor),
          ),
        ),
      ),
    );
  }
}

class _ScanImagePage extends StatelessWidget {
  const _ScanImagePage({required this.name, required this.position, required this.total});

  final String name;
  final int position;
  final int total;

  static const _minScale = 1.0;
  static const _maxScale = 5.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.primaryColor,
      appBar: AppBar(
        backgroundColor: context.palette.primaryColor,
        foregroundColor: context.palette.textOnPrimaryColor,
        title: Text(
          context.translations.noteScanImageCounter(position, total),
          style: context.textTheme.titleMedium!.copyWith(color: context.palette.textOnPrimaryColor),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: _minScale,
          maxScale: _maxScale,
          child: Image.file(
            injector<ScanImageStore>().fileFor(name),
            errorBuilder: (context, error, stackTrace) => Padding(
              padding: const EdgeInsets.all(Insets.xLarge),
              child: Text(
                context.translations.noteScanImageMissing,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
