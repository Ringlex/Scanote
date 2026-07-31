import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note/presentation/components/auth/bloc/auth_bloc.dart';
import 'package:note/presentation/screens/home/home_screen.dart';
import 'package:note/presentation/screens/login/login_screen.dart';

class NavigationHub extends StatelessWidget {
  const NavigationHub({
    required this.rootNavigatorKey,
    required this.child,
    super.key,
  });

  final GlobalKey<NavigatorState> rootNavigatorKey;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              previous.isBootstrapped != current.isBootstrapped || previous.hasAccess != current.hasAccess,
          listener: _onAuthStateChanged,
        ),
      ],
      child: child ?? const SizedBox.shrink(),
    );
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (!state.isBootstrapped) {
      return;
    }

    rootNavigatorKey.currentContext?.go(
      state.hasAccess ? HomeScreen.routeName : LoginScreen.routeName,
    );
  }
}
