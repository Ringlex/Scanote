import 'package:flutter/foundation.dart';
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
  static const _emailScope = 'email';

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

  /// Picks the session back up without showing anything, when the platform can
  /// do so. Null means nobody is signed in and the user has to be asked.
  TaskEither<ErrorDetail, AuthUser?> restoreSession() {
    return tryCatchE(
      () async {
        final account = await _googleSignIn.attemptLightweightAuthentication();

        return right(_toUser(account));
      },
      (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace),
    );
  }

  TaskEither<ErrorDetail, AuthUser?> signIn() {
    return tryCatchE(
      () async {
        GoogleSignInAccount? account;

        try {
          account = await _googleSignIn.authenticate(scopeHint: const [_emailScope]);
        } on GoogleSignInException catch (error) {
          // Google says why it turned the sign in down, and that reason is the
          // only thing that tells a misconfigured OAuth client apart from a
          // network fault. It goes to the console, where the logger's own
          // output cannot be read from outside the debugger.
          if (kDebugMode) {
            debugPrint(
              'SIGNIN_DIAGNOSTIC code=${error.code} '
              'description=${error.description} details=${error.details}',
            );
          }

          // Backing out of the prompt is an answer, not a failure: it just
          // leaves nobody signed in.
          if (error.code != GoogleSignInExceptionCode.canceled) {
            rethrow;
          }
        }

        return right(_toUser(account));
      },
      (error, stackTrace) {
        logSevere('Google sign-in failed', error, stackTrace);

        return ErrorDetail.fatal(throwable: error, stackTrace: stackTrace);
      },
    );
  }

  /// Hands the granted access back to Google, so the next sign in asks for
  /// permission again. Signing out only ends the session on this device.
  TaskEither<ErrorDetail, Unit> disconnect() {
    return tryCatchE(
      () async {
        await _googleSignIn.disconnect();

        return right(unit);
      },
      (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace),
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
