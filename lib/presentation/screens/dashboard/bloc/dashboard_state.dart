part of 'dashboard_bloc.dart';

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    required StateType type,
    required DashboardArgument argument,
  }) = _DashboardState;

  factory DashboardState.initial({required DashboardArgument argument}) {
    return DashboardState(
      type: StateType.loaded,
      argument: argument,
    );
  }
}
