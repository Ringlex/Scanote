import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/data/model/backup/backup_result.dart';
import 'package:note/data/model/sync/sync_result.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:note/presentation/common/app_message.dart';
import 'package:note/presentation/screens/settings/widgets/backup_passphrase_dialog.dart';
import 'package:note/presentation/injector_container.dart';
import 'package:note/presentation/common/protection_message.dart';
import 'package:note/data/protection/note_protection_service.dart';
import 'package:note/presentation/common/dimen.dart';
import 'package:note/presentation/common/state_type.dart';
import 'package:note/presentation/screens/settings/bloc/settings_bloc.dart';
import 'package:note/presentation/components/auth/bloc/auth_bloc.dart';
import 'package:note/presentation/screens/account/account_screen.dart';
import 'package:note/presentation/screens/bin/bin_argument.dart';
import 'package:note/presentation/screens/bin/bin_screen.dart';
import 'package:note/presentation/screens/categories/categories_argument.dart';
import 'package:note/presentation/screens/categories/categories_screen.dart';
import 'package:note/presentation/screens/dashboard/widgets/dashboard_sliver_app_bar.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';
import 'package:note/presentation/components/locale/bloc/locale_bloc.dart';
import 'package:note/presentation/screens/settings/widgets/language_picker.dart';
import 'package:note/presentation/screens/settings/widgets/theme_picker.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  static const _bottomPadding = 96.0;

  String _appVersion = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    unawaited(_readAppVersion());
  }

  Future<void> _readAppVersion() async {
    final info = await PackageInfo.fromPlatform();

    if (mounted) {
      setState(() => _appVersion = '${info.version} (${info.buildNumber})');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<SettingsBloc>().add(const SettingsEvent.onNotificationsChecked());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.primaryColor,
      body: BlocListener<SettingsBloc, SettingsState>(
        listenWhen: (previous, current) =>
            previous.backupType != current.backupType ||
            previous.syncType != current.syncType ||
            (!previous.isNotificationsDenied && current.isNotificationsDenied),
        listener: _onSettingsChanged,
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              const DashboardSliverAppBar(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(Insets.xLarge, Insets.large, Insets.xLarge, _bottomPadding),
                sliver: SliverList.list(
                  children: [
                    Text(
                      context.translations.settingsTitle,
                      style: context.textTheme.displaySmall!.copyWith(color: context.palette.textOnPrimaryColor),
                    ),
                    Gap.large,
                    _SettingsSection(
                      title: context.translations.settingsAppearance,
                      children: [
                        ValueListenableBuilder<AdaptiveThemeMode>(
                          valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
                          builder: (context, mode, _) => _SettingsTile(
                            icon: themeIcon(mode),
                            title: context.translations.settingsTheme,
                            subtitle: themeLabel(context, mode),
                            onTap: () => showThemePicker(context),
                          ),
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
                          onTap: () => context.push(
                            CategoriesScreen.routeName,
                            extra: CategoriesArgument(homeBloc: context.read<HomeBloc>()),
                          ),
                        ),
                        BlocBuilder<HomeBloc, HomeState>(
                          buildWhen: (previous, current) => previous.deletedNotes.length != current.deletedNotes.length,
                          builder: (context, state) => _SettingsTile(
                            icon: Icons.delete_outline,
                            title: context.translations.binTitle,
                            subtitle: state.deletedNotes.isEmpty
                                ? context.translations.binEmpty
                                : context.translations.binRetentionHint,
                            onTap: () => context.push(
                              BinScreen.routeName,
                              extra: BinArgument(homeBloc: context.read<HomeBloc>()),
                            ),
                          ),
                        ),
                        BlocBuilder<SettingsBloc, SettingsState>(
                          buildWhen: (previous, current) =>
                              previous.isNotificationsEnabled != current.isNotificationsEnabled ||
                              previous.isExactRemindersEnabled != current.isExactRemindersEnabled,
                          builder: (context, state) => Column(
                            children: [
                              _SettingsTile(
                                icon: state.isNotificationsEnabled
                                    ? Icons.notifications_active_outlined
                                    : Icons.notifications_off_outlined,
                                title: context.translations.settingsReminders,
                                subtitle: state.isNotificationsEnabled
                                    ? context.translations.settingsRemindersOn
                                    : context.translations.settingsRemindersOff,
                                onTap: () =>
                                    context.read<SettingsBloc>().add(const SettingsEvent.onNotificationsRequested()),
                              ),
                              if (state.isNotificationsEnabled && !state.isExactRemindersEnabled)
                                _SettingsTile(
                                  icon: Icons.timer_outlined,
                                  title: context.translations.settingsExactReminders,
                                  subtitle: context.translations.settingsExactRemindersOff,
                                  onTap: () =>
                                      context.read<SettingsBloc>().add(const SettingsEvent.onExactRemindersRequested()),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Gap.large,
                    BlocBuilder<SettingsBloc, SettingsState>(
                      buildWhen: (previous, current) =>
                          previous.isSyncEnabled != current.isSyncEnabled ||
                          previous.syncType != current.syncType ||
                          previous.lastSyncedAt != current.lastSyncedAt,
                      builder: (context, state) => _SettingsSection(
                        title: context.translations.settingsSync,
                        children: [
                          _SettingsSwitchTile(
                            icon: state.isSyncEnabled ? Icons.sync : Icons.sync_disabled,
                            title: context.translations.settingsSyncEnabled,
                            subtitle: context.translations.settingsSyncDescription,
                            value: state.isSyncEnabled,
                            isBusy: state.isSyncRunning,
                            onChanged: (isEnabled) =>
                                context.read<SettingsBloc>().add(SettingsEvent.onSyncToggled(isEnabled: isEnabled)),
                          ),
                          if (state.isSyncEnabled)
                            _SettingsTile(
                              icon: Icons.cloud_sync_outlined,
                              title: context.translations.settingsSyncNow,
                              subtitle: _lastSyncedLabel(context, state.lastSyncedAt),
                              isBusy: state.isSyncRunning,
                              onTap: () => context.read<SettingsBloc>().add(const SettingsEvent.onSyncRequested()),
                            ),
                        ],
                      ),
                    ),
                    Gap.large,
                    BlocBuilder<SettingsBloc, SettingsState>(
                      buildWhen: (previous, current) =>
                          previous.backupType != current.backupType || previous.backupTask != current.backupTask,
                      builder: (context, state) => _SettingsSection(
                        title: context.translations.settingsBackup,
                        children: [
                          _SettingsTile(
                            icon: Icons.backup_outlined,
                            title: context.translations.settingsBackupExport,
                            subtitle: context.translations.settingsBackupExportDescription,
                            isBusy: state.isRunning(BackupTask.export),
                            onTap: () => context.read<SettingsBloc>().add(const SettingsEvent.onExportRequested()),
                          ),
                          _SettingsTile(
                            icon: Icons.cloud_download_outlined,
                            title: context.translations.settingsBackupImport,
                            subtitle: context.translations.settingsBackupImportDescription,
                            isBusy: state.isRunning(BackupTask.import),
                            onTap: () => context.read<SettingsBloc>().add(const SettingsEvent.onImportRequested()),
                          ),
                        ],
                      ),
                    ),
                    Gap.large,
                    BlocBuilder<AuthBloc, AuthState>(
                      buildWhen: (previous, current) =>
                          previous.user != current.user || previous.isGuest != current.isGuest,
                      builder: (context, state) => _SettingsSection(
                        title: context.translations.settingsAccount,
                        children: [
                          if (state.isLoggedIn)
                            _SettingsTile(
                              icon: Icons.manage_accounts_outlined,
                              title: context.translations.settingsManageAccount,
                              subtitle: state.user!.email,
                              onTap: () => context.push(AccountScreen.routeName),
                            ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSettingsChanged(BuildContext context, SettingsState state) {
    if (state.isNotificationsDenied) {
      showAppMessage(context, message: context.translations.settingsRemindersDenied);

      return;
    }

    _onSyncChanged(context, state);
    _onBackupChanged(context, state);
  }

  String _lastSyncedLabel(BuildContext context, DateTime? syncedAt) {
    if (syncedAt == null) {
      return context.translations.settingsSyncNever;
    }

    final elapsed = DateTime.now().difference(syncedAt);

    if (elapsed.inMinutes < 1) {
      return context.translations.settingsSyncJustNow;
    }

    if (elapsed.inHours < 1) {
      return context.translations.settingsSyncMinutesAgo(elapsed.inMinutes);
    }

    if (elapsed.inDays < 1) {
      return context.translations.settingsSyncHoursAgo(elapsed.inHours);
    }

    return DateFormat.yMMMd(context.translations.localeName).add_Hm().format(syncedAt);
  }

  void _onSyncChanged(BuildContext context, SettingsState state) {
    if (state.syncType == StateType.error) {
      showAppMessage(context, message: context.translations.settingsSyncError);

      return;
    }

    final result = state.syncResult;

    if (state.syncType != StateType.success || result == null) {
      return;
    }

    switch (result.status) {
      case SyncStatus.cancelled:
      case SyncStatus.disabled:
      case SyncStatus.skipped:
        return;
      case SyncStatus.done:
        if (result.received > 0) {
          context.read<HomeBloc>().add(const HomeEvent.onInitiated());
        }

        showAppMessage(
          context,
          message: result.received > 0
              ? context.translations.settingsSyncReceived(result.received)
              : context.translations.settingsSyncUpToDate,
          isError: false,
        );
    }
  }

  Future<void> _askForPassphrase(BuildContext context, {required BackupTask? task}) async {
    final isExport = task == BackupTask.export;
    final settingsBloc = context.read<SettingsBloc>();

    final passphrase = await showBackupPassphraseDialog(context, isConfirming: isExport);

    if (passphrase == null || !context.mounted) {
      return;
    }

    try {
      final dataKey = await injector<NoteProtectionService>().unlockKey(
        title: context.translations.noteProtectPromptTitle,
        subtitle: context.translations.noteProtectOpenSubtitle,
        cancel: context.translations.commonCancel,
      );

      settingsBloc.add(
        isExport
            ? SettingsEvent.onExportRequested(passphrase: passphrase, dataKey: dataKey)
            : SettingsEvent.onImportRequested(passphrase: passphrase, dataKey: dataKey),
      );
    } on ProtectionException catch (error) {
      if (!context.mounted || error.failure == ProtectionFailure.cancelled) {
        return;
      }

      showAppMessage(context, message: protectionMessage(context, error.failure));
    }
  }

  void _onBackupChanged(BuildContext context, SettingsState state) {
    if (state.backupType == StateType.error) {
      showAppMessage(context, message: context.translations.backupError);

      return;
    }

    final result = state.backupResult;

    if (state.backupType != StateType.success || result == null) {
      return;
    }

    switch (result.status) {
      case BackupStatus.cancelled:
        return;
      case BackupStatus.nothingFound:
        showAppMessage(context, message: context.translations.backupNothingFound);
      case BackupStatus.wrongPassphrase:
        showAppMessage(context, message: context.translations.backupWrongPassphrase);
      case BackupStatus.passphraseNeeded:
        unawaited(_askForPassphrase(context, task: state.backupTask));
      case BackupStatus.done:
        final isImport = state.backupTask == BackupTask.import;

        if (isImport) {
          context.read<HomeBloc>().add(const HomeEvent.onInitiated());
        }

        showAppMessage(
          context,
          message: isImport
              ? context.translations.backupImportDone(result.noteCount)
              : context.translations.backupExportDone(result.noteCount),
          isError: false,
        );
    }
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isBusy = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  final bool isBusy;

  static const _iconSize = 24.0;
  static const _progressSize = 20.0;
  static const _progressWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: isBusy ? null : onChanged,
      activeThumbColor: context.palette.accentColor,
      secondary: isBusy
          ? SizedBox(
              width: _progressSize,
              height: _progressSize,
              child: CircularProgressIndicator(strokeWidth: _progressWidth, color: context.palette.accentColor),
            )
          : Icon(icon, size: _iconSize, color: context.palette.accentColor),
      title: Text(title, style: context.textTheme.bodyLarge!.copyWith(color: context.palette.textOnPrimaryColor)),
      subtitle: Text(subtitle, style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor)),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

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
          child: Text(title, style: context.textTheme.titleSmall!.copyWith(color: context.palette.inactiveColor)),
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
    this.isBusy = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  final bool isBusy;

  static const _iconSize = 24.0;
  static const _progressSize = 20.0;
  static const _progressWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: isBusy ? null : onTap,
      leading: Icon(icon, size: _iconSize, color: context.palette.accentColor),
      title: Text(title, style: context.textTheme.bodyLarge!.copyWith(color: context.palette.textOnPrimaryColor)),
      subtitle: Text(subtitle, style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor)),
      trailing: isBusy
          ? SizedBox(
              width: _progressSize,
              height: _progressSize,
              child: CircularProgressIndicator(strokeWidth: _progressWidth, color: context.palette.accentColor),
            )
          : Icon(Icons.chevron_right, color: context.palette.inactiveColor),
    );
  }
}
