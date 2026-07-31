import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';

@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
  }) = _AuthUser;

  const AuthUser._();

  String get name => displayName ?? email;
}
