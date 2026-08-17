import 'dart:io';

import 'package:note/core/app_logger/app_logger.dart';
import 'package:note/core/uuid.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ScanImageStore {
  Directory? _directory;

  static const _folderName = 'scans';
  static const _fallbackExtension = '.jpg';

  Future<void> prepare() async {
    if (_directory != null) {
      return;
    }

    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(join(documents.path, _folderName));

    await directory.create(recursive: true);

    _directory = directory;

    logInfo('Scan pictures live in ${directory.path}');
  }

  Future<String?> save({required String sourcePath}) async {
    try {
      await prepare();

      final extension = extensionOrDefault(sourcePath);
      final name = '${Uuid.v4()}$extension';

      await File(sourcePath).copy(pathFor(name));

      return name;
    } catch (error, stackTrace) {
      logSevere('Keeping the scanned picture failed', error, stackTrace);

      return null;
    }
  }

  String pathFor(String name) => join(_requireDirectory().path, name);

  File fileFor(String name) => File(pathFor(name));

  Future<void> deleteAll({required List<String> names}) async {
    if (names.isEmpty) {
      return;
    }

    try {
      await prepare();

      for (final name in names) {
        final file = fileFor(name);

        if (file.existsSync()) {
          await file.delete();
        }
      }
    } catch (error, stackTrace) {
      logSevere('Removing scanned pictures failed', error, stackTrace);
    }
  }

  static String extensionOrDefault(String path) {
    final found = extension(path);

    return found.isEmpty ? _fallbackExtension : found;
  }

  Directory _requireDirectory() {
    final directory = _directory;

    if (directory == null) {
      throw StateError('ScanImageStore.prepare() has not run yet');
    }

    return directory;
  }
}
