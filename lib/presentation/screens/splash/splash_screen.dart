import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:note/core/constants/app_const.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/presentation/common/app_assets.dart';
import 'package:note/presentation/common/dimen.dart';

class SplashScreen extends HookWidget {
  static const String routeName = '/';

  const SplashScreen({super.key});

  static const _logoSize = Size(220, 110);
  static const _indicatorSize = 24.0;
  static const _indicatorWidth = 2.0;
  static const _scaleFrom = 0.92;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: AppMotion.duration);

    useEffect(
      () {
        controller.forward();

        return null;
      },
      const [],
    );

    final animation = CurvedAnimation(parent: controller, curve: AppMotion.curve);

    return Scaffold(
      backgroundColor: context.palette.primaryColor,
      body: Center(
        child: FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: _scaleFrom, end: 1).animate(animation),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                context.svgImage(AppAssets.logoText, size: _logoSize),
                Gap.xxxLarge,
                SizedBox(
                  width: _indicatorSize,
                  height: _indicatorSize,
                  child: CircularProgressIndicator(
                    strokeWidth: _indicatorWidth,
                    color: context.palette.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
