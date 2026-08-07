part of 'auth_bloc.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    required StateType userStateType,
    required StateType signInType,
    AuthUser? user,
    @Default(false) bool isGuest,
  }) = _AuthState;

  const AuthState._();

  factory AuthState.initial() => const AuthState(
        userStateType: StateType.loading,
        signInType: StateType.initial,
      );

  bool get isLoggedIn => user != null;

  bool get hasAccess => isLoggedIn || isGuest;

  bool get isBootstrapped => userStateType == StateType.loaded;
}
