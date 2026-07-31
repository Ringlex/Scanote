import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:note/core/app_logger/app_logger.dart';
import 'package:note/core/fpdarts.dart';
import 'package:note/data/local/adapter/storage_adapter.dart';
import 'package:note/data/model/auth/auth_user.dart';
import 'package:note/data/model/error_detail.dart';

class AuthRepository {
  AuthRepository({
    required GoogleSignIn googleSignIn,
    required StorageAdapter storageAdapter,
  })  : _googleSignIn = googleSignIn,
        _storageAdapter = storageAdapter;

  static const _guestKey = 'auth.isGuest';
  static const _guestValue = 'true';

  final GoogleSignIn _googleSignIn;
  final StorageAdapter _storageAdapter;

  TaskEither<ErrorDetail, bool> readIsGuest() {
    return tryCatchE(
      () async {
        final value = await _storageAdapter.read(key: _guestKey);

        return right(value == _guestValue);
      },
      (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace),
    );
  }

  TaskEither<ErrorDetail, Unit> writeIsGuest({required bool isGuest}) {
    return tryCatchE(
      () async {
        if (isGuest) {
          await _storageAdapter.write(key: _guestKey, value: _guestValue);
        } else {
          await _storageAdapter.delete(key: _guestKey);
        }

        return right(unit);
      },
      (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace),
    );
  }

  TaskEither<ErrorDetail, AuthUser?> restoreSession() {
    return tryCatchE(
      () async {
        final account = await _googleSignIn.signInSilently();

        return right(_toUser(account));
      },
      (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace),
    );
  }

  TaskEither<ErrorDetail, AuthUser?> signIn() {
    return tryCatchE(
      () async {
        final account = await _googleSignIn.signIn();

        return right(_toUser(account));
      },
      (error, stackTrace) {
        logSevere('Google sign-in failed', error, stackTrace);

        return ErrorDetail.fatal(throwable: error, stackTrace: stackTrace);
      },
    );
  }

  TaskEither<ErrorDetail, Unit> signOut() {
    return tryCatchE(
      () async {
        await _googleSignIn.signOut();

        return right(unit);
      },
      (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace),
    );
  }

  AuthUser? _toUser(GoogleSignInAccount? account) {
    return account == null
        ? null
        : AuthUser(
            id: account.id,
            email: account.email,
            displayName: account.displayName,
            photoUrl: account.photoUrl,
          );
  }
}
