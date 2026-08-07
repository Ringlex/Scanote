import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:note/core/app_logger/app_logger.dart';
import 'package:note/data/local/adapter/storage_adapter.dart';
import 'package:note/data/protection/note_cipher.dart';

enum ProtectionFailure { unavailable, cancelled, keyLost, failed }

class ProtectionException implements Exception {
  const ProtectionException(this.failure);

  final ProtectionFailure failure;

  @override
  String toString() => 'ProtectionException($failure)';
}

class NoteProtectionService {
  NoteProtectionService({required StorageAdapter storage}) : _storage = storage;

  final StorageAdapter _storage;

  static const _wrappedKeyKey = 'note_protection_wrapped_key';

  static const _channel = MethodChannel('io.robert.note/crypto');

  static const _isAvailableMethod = 'isProtectionAvailable';
  static const _encryptMethod = 'encrypt';
  static const _decryptMethod = 'decrypt';

  Future<bool> isAvailable() async {
    try {
      return await _channel.invokeMethod<bool>(_isAvailableMethod) ?? false;
    } on PlatformException catch (error, stackTrace) {
      logSevere('Asking about note protection failed', error, stackTrace);

      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<List<int>> unlockKey({required String title, required String subtitle, required String cancel}) async {
    final wrapped = await _storage.read(key: _wrappedKeyKey);

    if (wrapped != null) {
      final plain = await _invoke(_decryptMethod, wrapped, title, subtitle, cancel);

      return base64Decode(plain);
    }

    final key = await NoteCipher.newKey();
    final sealed = await _invoke(_encryptMethod, base64Encode(key), title, subtitle, cancel);

    await _storage.write(key: _wrappedKeyKey, value: sealed);

    return key;
  }

  Future<bool> hasKey() async => await _storage.read(key: _wrappedKeyKey) != null;

  Future<String> _invoke(String method, String value, String title, String subtitle, String cancel) async {
    try {
      final result = await _channel.invokeMethod<String>(method, {
        'value': value,
        'title': title,
        'subtitle': subtitle,
        'cancel': cancel,
      });

      if (result == null) {
        throw const ProtectionException(ProtectionFailure.failed);
      }

      return result;
    } on PlatformException catch (error, stackTrace) {
      logSevere('Note protection failed: ${error.code}', error, stackTrace);

      throw ProtectionException(_failureOf(error.code));
    } on MissingPluginException catch (error, stackTrace) {
      logSevere('The platform does not answer $method', error, stackTrace);

      throw const ProtectionException(ProtectionFailure.unavailable);
    }
  }

  ProtectionFailure _failureOf(String code) => switch (code) {
    'unavailable' => ProtectionFailure.unavailable,
    'cancelled' => ProtectionFailure.cancelled,
    'key_lost' => ProtectionFailure.keyLost,
    _ => ProtectionFailure.failed,
  };
}
