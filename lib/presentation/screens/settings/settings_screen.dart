import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/presentation/common/dimen.dart';
import 'package:note/presentation/components/auth/bloc/auth_bloc.dart';
import 'package:note/presentation/components/locale/bloc/locale_bloc.dart';
import 'package:note/presentation/screens/settings/widgets/language_picker.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  static const _bottomPadding = 96.0;
  static const _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.primaryColor,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Insets.xLarge, Insets.large, Insets.xLarge, _bottomPadding),
        children: [
          Text(
            context.translations.settingsTitle,
            style: context.textTheme.displaySmall!.copyWith(color: context.palette.textOnPrimaryColor),
          ),
          Gap.large,
          _SettingsSection(
            title: context.translations.settingsAppearance,
            children: [
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: context.translations.settingsTheme,
                subtitle: context.translations.settingsThemeSystem,
                onTap: () {},
              ),
              BlocBuilder<LocaleBloc, LocaleState>(
                builder: (context, state) => _SettingsTile(
                  icon: Icons.language,
                  title: context.translations.settingsLanguage,
                  subtitle: languageLabel(context, state.language),
                  onTap: () => showLanguagePicker(context),
                ),
              ),
            ],
          ),
          Gap.large,
          _SettingsSection(
            title: context.translations.settingsNotes,
            children: [
              _SettingsTile(
                icon: Icons.category_outlined,
                title: context.translations.settingsCategories,
                subtitle: context.translations.settingsCategoriesDescription,
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.notifications_none,
                title: context.translations.settingsReminders,
                subtitle: context.translations.settingsRemindersDescription,
                onTap: () {},
              ),
            ],
          ),
          Gap.large,
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (previous, current) =>
                previous.user != current.user || previous.isGuest != current.isGuest,
            builder: (context, state) => _SettingsSection(
              title: context.translations.settingsAccount,
              children: [
                _SettingsTile(
                  icon: Icons.logout,
                  title: context.translations.settingsSignOut,
                  subtitle: state.user?.name ?? context.translations.settingsGuest,
                  onTap: () => context.read<AuthBloc>().add(const AuthEvent.onSignOutRequested()),
                ),
              ],
            ),
          ),
          Gap.large,
          _SettingsSection(
            title: context.translations.settingsAbout,
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: context.translations.settingsAppVersion,
                subtitle: _appVersion,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  static const _cornerRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: Insets.small, bottom: Insets.small),
          child: Text(
            title,
            style: context.textTheme.titleSmall!.copyWith(color: context.palette.inactiveColor),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.palette.cardColor,
            borderRadius: BorderRadius.circular(_cornerRadius),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  static const _iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        size: _iconSize,
        color: context.palette.accentColor,
      ),
      title: Text(
        title,
        style: context.textTheme.bodyLarge!.copyWith(color: context.palette.textOnPrimaryColor),
      ),
      subtitle: Text(
        subtitle,
        style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: context.palette.inactiveColor,
      ),
    );
  }
}
