import 'package:fpdart/fpdart.dart';
import 'package:note/core/fpdarts.dart';
import 'package:note/data/local/adapter/storage_adapter.dart';
import 'package:note/data/model/error_detail.dart';

class SettingsRepository {
  SettingsRepository({required StorageAdapter storageAdapter}) : _storageAdapter = storageAdapter;

  static const _languageCodeKey = 'settings.languageCode';
  static const _syncEnabledKey = 'settings.syncEnabled';
  static const _lastSyncedAtKey = 'settings.lastSyncedAt';

  static const _systemValue = 'system';
  static const _onValue = 'on';

  final StorageAdapter _storageAdapter;

  TaskEither<ErrorDetail, String?> readLanguageCode() {
    return tryCatchE(() async {
      final value = await _storageAdapter.read(key: _languageCodeKey);

      return right(value == _systemValue ? null : value);
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, Unit> writeLanguageCode(String? languageCode) {
    return tryCatchE(() async {
      await _storageAdapter.write(key: _languageCodeKey, value: languageCode ?? _systemValue);

      return right(unit);
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, bool> readSyncEnabled() {
    return tryCatchE(
      () async => right(await _storageAdapter.read(key: _syncEnabledKey) == _onValue),
      (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace),
    );
  }

  TaskEither<ErrorDetail, Unit> writeSyncEnabled({required bool isEnabled}) {
    return tryCatchE(() async {
      if (isEnabled) {
        await _storageAdapter.write(key: _syncEnabledKey, value: _onValue);
      } else {
        await _storageAdapter.delete(key: _syncEnabledKey);
        await _storageAdapter.delete(key: _lastSyncedAtKey);
      }

      return right(unit);
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, DateTime?> readLastSyncedAt() {
    return tryCatchE(() async {
      final value = await _storageAdapter.read(key: _lastSyncedAtKey);

      return right(value == null ? null : DateTime.tryParse(value));
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, Unit> writeLastSyncedAt(DateTime syncedAt) {
    return tryCatchE(() async {
      await _storageAdapter.write(key: _lastSyncedAtKey, value: syncedAt.toIso8601String());

      return right(unit);
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }
}
