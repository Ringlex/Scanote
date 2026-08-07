part of 'settings_bloc.dart';

enum BackupTask { export, import }

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    required StateType type,
    required SettingsArgument argument,
    @Default(StateType.initial) StateType backupType,
    BackupTask? backupTask,
    BackupResult? backupResult,
    @Default(false) bool isNotificationsEnabled,

    @Default(false) bool isNotificationsDenied,
  }) = _SettingsState;

  const SettingsState._();

  factory SettingsState.initial({required SettingsArgument argument}) {
    return SettingsState(type: StateType.loading, argument: argument);
  }

  bool get isBackupRunning => backupType == StateType.loading;

  bool isRunning(BackupTask task) => isBackupRunning && backupTask == task;
}
