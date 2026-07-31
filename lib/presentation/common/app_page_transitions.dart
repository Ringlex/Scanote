import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:note/core/constants/app_const.dart';

CustomTransitionPage<T> fadeSlidePage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    transitionDuration: AppMotion.duration,
    reverseTransitionDuration: AppMotion.duration,
    transitionsBuilder: _buildTransition,
    child: child,
  );
}

const _slideOffset = 0.04;

Widget _buildTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final curved = CurvedAnimation(parent: animation, curve: AppMotion.curve);

  return FadeTransition(
    opacity: curved,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, _slideOffset),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    ),
  );
}
