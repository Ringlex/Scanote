import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/data/model/auth/auth_user.dart';
import 'package:note/presentation/common/app_back_button.dart';
import 'package:note/presentation/common/dimen.dart';
import 'package:note/presentation/components/auth/bloc/auth_bloc.dart';

class AccountScreen extends StatelessWidget {
  static const routeName = '/account';

  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.primaryColor,
      appBar: AppBar(
        backgroundColor: context.palette.primaryColor,
        foregroundColor: context.palette.textOnPrimaryColor,
        leading: const AppBackButton(),
        title: Text(
          context.translations.accountTitle,
          style: context.textTheme.titleMedium!.copyWith(color: context.palette.textOnPrimaryColor),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (previous, current) => previous.user != current.user,
        builder: (context, state) {
          final user = state.user;

          return user == null ? const SizedBox.shrink() : _AccountDetails(user: user);
        },
      ),
    );
  }
}

class _AccountDetails extends StatelessWidget {
  const _AccountDetails({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Insets.xLarge),
      children: [
        Center(child: _Avatar(user: user)),
        Gap.large,
        Text(
          user.name,
          textAlign: TextAlign.center,
          style: context.textTheme.displaySmall!.copyWith(color: context.palette.textOnPrimaryColor),
        ),
        Gap.xSmall,
        Text(
          user.email,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
        ),
        Gap.xxLarge,
        _AccountAction(
          icon: Icons.logout,
          title: context.translations.settingsSignOut,
          subtitle: context.translations.accountSignOutDescription,
          onTap: () => context.read<AuthBloc>().add(const AuthEvent.onSignOutRequested()),
        ),
        Gap.small,
        _AccountAction(
          icon: Icons.link_off,
          title: context.translations.accountDisconnect,
          subtitle: context.translations.accountDisconnectDescription,
          isDestructive: true,
          onTap: () => _onDisconnectPressed(context),
        ),
      ],
    );
  }

  Future<void> _onDisconnectPressed(BuildContext context) async {
    final authBloc = context.read<AuthBloc>();
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.translations.accountDisconnectTitle),
        content: Text(context.translations.accountDisconnectMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.translations.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: context.palette.errorColor),
            child: Text(context.translations.accountDisconnect),
          ),
        ],
      ),
    );

    if (isConfirmed ?? false) {
      authBloc.add(const AuthEvent.onDisconnectRequested());
    }
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final AuthUser user;

  static const _radius = 48.0;

  @override
  Widget build(BuildContext context) {
    final photoUrl = user.photoUrl;

    return CircleAvatar(
      radius: _radius,
      backgroundColor: context.palette.cardColor,
      backgroundImage: photoUrl == null ? null : NetworkImage(photoUrl),
      child: photoUrl != null
          ? null
          : Text(
              user.name.characters.first.toUpperCase(),
              style: context.textTheme.displayMedium!.copyWith(color: context.palette.accentColor),
            ),
    );
  }
}

class _AccountAction extends StatelessWidget {
  const _AccountAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  static const _cornerRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? context.palette.errorColor : context.palette.accentColor;

    return Material(
      color: context.palette.cardColor,
      borderRadius: BorderRadius.circular(_cornerRadius),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(title, style: context.textTheme.bodyLarge!.copyWith(color: context.palette.textOnPrimaryColor)),
        subtitle: Text(subtitle, style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor)),
      ),
    );
  }
}
