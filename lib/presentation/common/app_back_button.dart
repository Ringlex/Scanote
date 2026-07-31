import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:note/core/theme/theme.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  static const _iconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _onPressed(context),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      icon: Icon(
        Icons.arrow_back_ios_new,
        size: _iconSize,
        color: context.palette.textOnPrimaryColor,
      ),
    );
  }

  void _onPressed(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }
}
