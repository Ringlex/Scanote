import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:note/core/app_logger/app_logger.dart';
import 'package:note/core/fpdarts.dart';
import 'package:note/data/model/error_detail.dart';

/// A file as Drive lists it back to us.
@immutable
class DriveFile {
  const DriveFile({
    required this.id,
    required this.name,
    required this.modifiedAt,
  });

  final String id;
  final String name;
  final DateTime? modifiedAt;
}

/// Talks to Google Drive over its REST API. Only the handful of calls a backup
/// needs is covered, which is why the whole googleapis package stays out.
///
/// The `drive.file` scope keeps this to files the app itself created - nothing
/// else in the user's Drive is ever visible to us.
class DriveService {
  DriveService({
    required GoogleSignIn googleSignIn,
    http.Client? httpClient,
  })  : _googleSignIn = googleSignIn,
        _httpClient = httpClient ?? http.Client();

  final GoogleSignIn _googleSignIn;
  final http.Client _httpClient;

  static const scope = 'https://www.googleapis.com/auth/drive.file';

  static const _host = 'www.googleapis.com';
  static const _filesPath = '/drive/v3/files';
  static const _uploadPath = '/upload/drive/v3/files';
  static const _mimeType = 'application/json';
  static const _boundary = 'note-backup-boundary';

  /// Whether Drive can be reached on the user's behalf. Signs in and asks for
  /// the scope when needed; false means the user backed out of the prompt.
  TaskEither<ErrorDetail, bool> ensureAccess() {
    return tryCatchE(
      () async => right(await _authHeaders() != null),
      (error, stackTrace) {
        logSevere('Drive access failed', error, stackTrace);

        return ErrorDetail.fatal(throwable: error, stackTrace: stackTrace);
      },
    );
  }

  /// Uploads [contents] as a new file and hands back its Drive id.
  TaskEither<ErrorDetail, String> upload({
    required String name,
    required String contents,
  }) {
    return tryCatchE(
      () async {
        final headers = await _requireHeaders();
        final body = '--$_boundary\r\n'
            'Content-Type: application/json; charset=UTF-8\r\n\r\n'
            '${jsonEncode({'name': name, 'mimeType': _mimeType})}\r\n'
            '--$_boundary\r\n'
            'Content-Type: $_mimeType; charset=UTF-8\r\n\r\n'
            '$contents\r\n'
            '--$_boundary--';

        final response = await _httpClient.post(
          Uri.https(_host, _uploadPath, {'uploadType': 'multipart'}),
          headers: {
            ...headers,
            'Content-Type': 'multipart/related; boundary=$_boundary',
          },
          body: utf8.encode(body),
        );

        final decoded = _decodeJson(response);

        return right(decoded['id'] as String);
      },
      (error, stackTrace) {
        logSevere('Drive upload failed', error, stackTrace);

        return ErrorDetail.fatal(throwable: error, stackTrace: stackTrace);
      },
    );
  }

  /// The most recently changed file this app wrote whose name starts with
  /// [namePrefix], or null when there is none.
  TaskEither<ErrorDetail, DriveFile?> findLatest({required String namePrefix}) {
    return tryCatchE(
      () async {
        final headers = await _requireHeaders();
        final response = await _httpClient.get(
          Uri.https(_host, _filesPath, {
            'q': "name contains '$namePrefix' and mimeType = '$_mimeType' and trashed = false",
            'orderBy': 'modifiedTime desc',
            'pageSize': '1',
            'fields': 'files(id,name,modifiedTime)',
            'spaces': 'drive',
          }),
          headers: headers,
        );

        final files = _decodeJson(response)['files'];

        if (files is! List || files.isEmpty) {
          return right(null);
        }

        final file = files.first as Map<String, dynamic>;

        return right(
          DriveFile(
            id: file['id'] as String,
            name: file['name'] as String? ?? '',
            modifiedAt: DateTime.tryParse(file['modifiedTime'] as String? ?? ''),
          ),
        );
      },
      (error, stackTrace) {
        logSevere('Drive lookup failed', error, stackTrace);

        return ErrorDetail.fatal(throwable: error, stackTrace: stackTrace);
      },
    );
  }

  TaskEither<ErrorDetail, String> download({required String fileId}) {
    return tryCatchE(
      () async {
        final headers = await _requireHeaders();
        final response = await _httpClient.get(
          Uri.https(_host, '$_filesPath/$fileId', {'alt': 'media'}),
          headers: headers,
        );

        _ensureSuccess(response);

        // The response carries JSON written by us, so it is UTF-8 regardless of
        // what the headers say.
        return right(utf8.decode(response.bodyBytes));
      },
      (error, stackTrace) {
        logSevere('Drive download failed', error, stackTrace);

        return ErrorDetail.fatal(throwable: error, stackTrace: stackTrace);
      },
    );
  }

  /// Null when the user is not signed in and does not sign in, or refuses to
  /// grant access to Drive.
  Future<Map<String, String>?> _authHeaders() async {
    var account = await _googleSignIn.attemptLightweightAuthentication();

    if (account == null) {
      try {
        account = await _googleSignIn.authenticate(scopeHint: const [scope]);
      } on GoogleSignInException catch (error) {
        if (error.code != GoogleSignInExceptionCode.canceled) {
          rethrow;
        }

        return null;
      }
    }

    // Authorisation is asked for separately from signing in, and an already
    // granted scope comes back without a second prompt.
    return account.authorizationClient.authorizationHeaders(
      const [scope],
      promptIfNecessary: true,
    );
  }

  Future<Map<String, String>> _requireHeaders() async {
    final headers = await _authHeaders();

    if (headers == null) {
      throw StateError('Google Drive access was not granted');
    }

    return headers;
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    _ensureSuccess(response);

    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'Drive answered ${response.statusCode}: ${response.body}',
        response.request?.url,
      );
    }
  }
}
