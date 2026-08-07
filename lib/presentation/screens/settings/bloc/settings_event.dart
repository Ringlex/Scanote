part of 'settings_bloc.dart';

@freezed
sealed class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.onInitiated() = _OnInitiated;

  const factory SettingsEvent.onNotificationsChecked() = _OnNotificationsChecked;

  const factory SettingsEvent.onNotificationsRequested() = _OnNotificationsRequested;

  const factory SettingsEvent.onExportRequested({String? passphrase, List<int>? dataKey}) = _OnExportRequested;

  const factory SettingsEvent.onImportRequested({String? passphrase, List<int>? dataKey}) = _OnImportRequested;
}
