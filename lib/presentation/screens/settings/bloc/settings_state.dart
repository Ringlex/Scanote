part of 'settings_bloc.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    required StateType type,
    required SettingsArgument argument,
  }) = _SettingsState;

  factory SettingsState.initial({required SettingsArgument argument}) {
    return SettingsState(
      type: StateType.loading,
      argument: argument,
    );
  }
}
