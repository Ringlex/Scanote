part of 'auth_bloc.dart';

@freezed
sealed class AuthEvent with _$AuthEvent {
  const factory AuthEvent.onInitiated() = _OnInitiated;

  const factory AuthEvent.onSignInRequested() = _OnSignInRequested;

  const factory AuthEvent.onGuestRequested() = _OnGuestRequested;

  const factory AuthEvent.onSignOutRequested() = _OnSignOutRequested;

  const factory AuthEvent.onDisconnectRequested() = _OnDisconnectRequested;
}
