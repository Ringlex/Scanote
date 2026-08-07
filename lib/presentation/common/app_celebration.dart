import 'package:flutter/material.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/presentation/common/dimen.dart';

bool _isShowing = false;

void showChecklistCelebration(BuildContext context, {required String message}) {
  if (_isShowing) {
    return;
  }

  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;

  void remove() {
    if (!_isShowing) {
      return;
    }

    _isShowing = false;
    entry.remove();
  }

  entry = OverlayEntry(
    builder: (_) => _Celebration(message: message, onDismissed: remove),
  );

  _isShowing = true;
  overlay.insert(entry);
}

class _Celebration extends StatefulWidget {
  const _Celebration({required this.message, required this.onDismissed});

  final String message;
  final VoidCallback onDismissed;

  @override
  State<_Celebration> createState() => _CelebrationState();
}

class _CelebrationState extends State<_Celebration> with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1600);
  static const _badgeSize = 96.0;
  static const _iconSize = 56.0;
  static const _ringWidth = 3.0;
  static const _ringScale = 1.8;
  static const _shadowBlur = 24.0;

  late final AnimationController _controller = AnimationController(vsync: this, duration: _duration);

  late final Animation<double> _badge = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.35, curve: Curves.elasticOut),
  );

  late final Animation<double> _ring = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.1, 0.55, curve: Curves.easeOut),
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.15, curve: Curves.easeOut),
  );

  late final Animation<double> _exit = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.8, 1, curve: Curves.easeIn),
  );

  @override
  void initState() {
    super.initState();

    _controller.forward().whenComplete(widget.onDismissed);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) =>
                Opacity(opacity: (_fade.value * (1 - _exit.value)).clamp(0.0, 1.0), child: child),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBadge(context),
                Gap.large,
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleMedium!.copyWith(color: context.palette.textOnPrimaryColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context) {
    return SizedBox(
      width: _badgeSize * _ringScale,
      height: _badgeSize * _ringScale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ring,
            builder: (context, child) => Transform.scale(
              scale: 1 + (_ringScale - 1) * _ring.value,
              child: Opacity(opacity: (1 - _ring.value).clamp(0.0, 1.0), child: child),
            ),
            child: Container(
              width: _badgeSize,
              height: _badgeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: context.palette.accentColor, width: _ringWidth),
              ),
            ),
          ),
          ScaleTransition(
            scale: _badge,
            child: Container(
              width: _badgeSize,
              height: _badgeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.palette.accentColor,
                boxShadow: [BoxShadow(color: context.palette.shadowColor, blurRadius: _shadowBlur)],
              ),
              child: Icon(Icons.check_rounded, size: _iconSize, color: context.palette.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
