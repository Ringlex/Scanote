import 'dart:async';

import 'package:flutter/material.dart';
import 'package:note/core/constants/app_const.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/presentation/common/dimen.dart';

void showAppMessage(
  BuildContext context, {
  required String message,
  bool isError = true,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  var isRemoved = false;

  void remove() {
    if (isRemoved) {
      return;
    }

    isRemoved = true;
    entry.remove();
  }

  entry = OverlayEntry(
    builder: (_) => _AppMessage(
      message: message,
      isError: isError,
      onDismissed: remove,
    ),
  );

  overlay.insert(entry);
}

class _AppMessage extends StatefulWidget {
  const _AppMessage({
    required this.message,
    required this.isError,
    required this.onDismissed,
  });

  final String message;
  final bool isError;
  final VoidCallback onDismissed;

  @override
  State<_AppMessage> createState() => _AppMessageState();
}

class _AppMessageState extends State<_AppMessage> with SingleTickerProviderStateMixin {
  static const _visibleDuration = Duration(seconds: 3);
  static const _cornerRadius = 16.0;
  static const _iconSize = 20.0;
  static const _shadowBlur = 16.0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.duration,
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.curve,
  );

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller.forward();
    _timer = Timer(_visibleDuration, _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(_animation),
        child: FadeTransition(
          opacity: _animation,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(Insets.medium),
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: _dismiss,
                  onVerticalDragEnd: (details) => _onDragEnd(details),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Insets.large,
                      vertical: Insets.medium,
                    ),
                    decoration: BoxDecoration(
                      color: context.palette.cardColor,
                      borderRadius: BorderRadius.circular(_cornerRadius),
                      boxShadow: [
                        BoxShadow(
                          color: context.palette.shadowColor,
                          blurRadius: _shadowBlur,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.isError ? Icons.error_outline : Icons.info_outline,
                          size: _iconSize,
                          color: widget.isError ? context.palette.errorColor : context.palette.accentColor,
                        ),
                        HorizontalGap.medium,
                        Expanded(
                          child: Text(
                            widget.message,
                            style: context.textTheme.bodyMedium!.copyWith(
                              color: context.palette.textOnPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onDragEnd(DragEndDetails details) {
    if ((details.primaryVelocity ?? 0) < 0) {
      _dismiss();
    }
  }

  Future<void> _dismiss() async {
    _timer?.cancel();

    if (!mounted) {
      return;
    }

    await _controller.reverse();
    widget.onDismissed();
  }
}
