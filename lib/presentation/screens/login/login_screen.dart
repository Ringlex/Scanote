import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/presentation/common/app_message.dart';
import 'package:note/presentation/common/dimen.dart';
import 'package:note/presentation/common/state_type.dart';
import 'package:note/presentation/components/auth/bloc/auth_bloc.dart';
import 'package:note/presentation/common/widgets/app_wordmark.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  static const _wordmarkSize = 44.0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.signInType != current.signInType,
      listener: _onSignInStateChanged,
      child: Scaffold(
        backgroundColor: context.palette.primaryColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Insets.xLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                const Center(child: AppWordmark(fontSize: _wordmarkSize)),
                Gap.xxxLarge,
                Text(
                  context.translations.loginHeadline,
                  textAlign: TextAlign.center,
                  style: context.textTheme.displaySmall!.copyWith(
                    color: context.palette.textOnPrimaryColor,
                  ),
                ),
                Gap.medium,
                Text(
                  context.translations.loginSubtitle,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: context.palette.inactiveColor,
                  ),
                ),
                const Spacer(),
                const _GoogleSignInButton(),
                Gap.small,
                const _GuestButton(),
                Gap.large,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSignInStateChanged(BuildContext context, AuthState state) {
    if (state.signInType == StateType.error) {
      showAppMessage(context, message: context.translations.loginError);
    }
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton();

  static const _cornerRadius = 28.0;
  static const _height = 56.0;
  static const _markSize = 24.0;
  static const _googleBlue = Color(0xff4285F4);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) => previous.signInType != current.signInType,
      builder: (context, state) {
        final isSigningIn = state.signInType == StateType.loading;

        return SizedBox(
          height: _height,
          child: ElevatedButton(
            onPressed: isSigningIn ? null : () => _onPressed(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              disabledBackgroundColor: Colors.white70,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_cornerRadius),
              ),
            ),
            child: isSigningIn
                ? const _ButtonSpinner()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'G',
                        style: context.textTheme.titleMedium!.copyWith(
                          color: _googleBlue,
                          fontSize: _markSize,
                        ),
                      ),
                      HorizontalGap.medium,
                      Text(
                        context.translations.loginGoogleButton,
                        style: context.textTheme.bodyLarge!.copyWith(
                          color: context.palette.darkGrayColor,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  void _onPressed(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEvent.onSignInRequested());
  }
}

class _GuestButton extends StatelessWidget {
  const _GuestButton();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.read<AuthBloc>().add(const AuthEvent.onGuestRequested()),
      child: Text(
        context.translations.loginContinueAsGuest,
        style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
      ),
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  static const _size = 20.0;
  static const _width = 2.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: CircularProgressIndicator(
        strokeWidth: _width,
        color: context.palette.accentColor,
      ),
    );
  }
}
