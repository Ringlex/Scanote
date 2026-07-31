import 'package:fpdart/fpdart.dart';
import 'package:note/core/fpdarts.dart';
import 'package:note/data/local/adapter/storage_adapter.dart';
import 'package:note/data/model/error_detail.dart';

class SettingsRepository {
  SettingsRepository({
    required StorageAdapter storageAdapter,
  }) : _storageAdapter = storageAdapter;

  static const _languageCodeKey = 'settings.languageCode';

  static const _systemValue = 'system';

  final StorageAdapter _storageAdapter;

  TaskEither<ErrorDetail, String?> readLanguageCode() {
    return tryCatchE(
      () async {
        final value = await _storageAdapter.read(key: _languageCodeKey);

        return right(value == _systemValue ? null : value);
      },
      (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace),
    );
  }

  TaskEither<ErrorDetail, Unit> writeLanguageCode(String? languageCode) {
    return tryCatchE(
      () async {
        await _storageAdapter.write(
          key: _languageCodeKey,
          value: languageCode ?? _systemValue,
        );

        return right(unit);
      },
      (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace),
    );
  }
}
