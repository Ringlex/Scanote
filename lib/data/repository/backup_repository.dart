import 'package:collection/collection.dart';
import 'package:cryptography/cryptography.dart' show SecretBoxAuthenticationError;
import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';
import 'package:note/core/fpdarts.dart';
import 'package:note/data/drive/drive_service.dart';
import 'package:note/data/model/backup/backup_result.dart';
import 'package:note/data/model/backup/note_backup.dart';
import 'package:note/data/protection/note_cipher.dart';
import 'package:note/data/model/error_detail.dart';
import 'package:note/data/model/note/checklist_item.dart';
import 'package:note/data/model/note/note.dart';
import 'package:note/data/repository/note_repository.dart';

/// Puts every note on the user's Google Drive and reads them back.
class BackupRepository {
  BackupRepository({
    required NoteRepository noteRepository,
    required DriveService driveService,
  })  : _noteRepository = noteRepository,
        _driveService = driveService;

  final NoteRepository _noteRepository;
  final DriveService _driveService;

  /// Every export keeps its own file, so an older one is always still there to
  /// fall back on. The prefix is what the import looks for.
  static const _namePrefix = 'note-backup';
  static const _nameDateFormat = 'yyyy-MM-dd-HHmm';

  /// [passphrase] and [dataKey] are only needed when some note is protected.
  /// Without them the export stops with [BackupStatus.passphraseNeeded] rather
  /// than quietly writing the notes out in the clear.
  TaskEither<ErrorDetail, BackupResult> exportToDrive({
    String? passphrase,
    List<int>? dataKey,
  }) {
    return tryCatchE(
      () async {
        if (!await _unwrap(_driveService.ensureAccess())) {
          return right(const BackupResult.cancelled());
        }

        final notes = await _unwrap(_noteRepository.getNotes());
        final categories = await _unwrap(_noteRepository.getCategories());
        final exportedAt = DateTime.now();

        final hasProtected = notes.any((note) => note.isProtected);

        if (hasProtected && (passphrase == null || dataKey == null)) {
          return right(const BackupResult.passphraseNeeded());
        }

        // One salt for the whole backup: the passphrase is stretched once and
        // the key it makes seals every protected note in it.
        final salt = hasProtected ? NoteCipher.newSalt() : null;
        final backupKey = salt == null
            ? null
            : await NoteCipher.keyFromPassphrase(passphrase: passphrase!, salt: salt);

        final backup = NoteBackup(
          exportedAt: exportedAt,
          salt: salt,
          categoryNames: [for (final category in categories) category.name],
          notes: [
            for (final note in notes)
              BackupNote(
                title: note.title,
                contents: await _contentsForBackup(note, dataKey: dataKey, backupKey: backupKey),
                items: note.checklistItems,
                categoryName:
                    categories.firstWhereOrNull((category) => category.id == note.categoryId)?.name,
                isFavorite: note.isFavorite,
                isProtected: note.isProtected,
                date: note.date,
              ),
          ],
        );

        await _unwrap(
          _driveService.upload(
            name: '$_namePrefix-${DateFormat(_nameDateFormat).format(exportedAt)}.json',
            contents: backup.encode(),
          ),
        );

        return right(BackupResult.done(noteCount: notes.length));
      },
      _toErrorDetail,
    );
  }

  /// Reads the newest backup on the account and adds what this phone is
  /// missing. Nothing already here is touched, so importing twice is harmless.
  /// [passphrase] and [dataKey] are needed only when the backup turns out to
  /// hold protected notes, which is not known until it has been downloaded.
  TaskEither<ErrorDetail, BackupResult> importFromDrive({
    String? passphrase,
    List<int>? dataKey,
  }) {
    return tryCatchE(
      () async {
        if (!await _unwrap(_driveService.ensureAccess())) {
          return right(const BackupResult.cancelled());
        }

        final file = await _unwrap(_driveService.findLatest(namePrefix: _namePrefix));

        if (file == null) {
          return right(const BackupResult.nothingFound());
        }

        final backup = NoteBackup.decode(await _unwrap(_driveService.download(fileId: file.id)));

        if (backup == null) {
          return right(const BackupResult.nothingFound());
        }

        final salt = backup.salt;

        if (backup.hasProtectedNotes && (passphrase == null || dataKey == null || salt == null)) {
          return right(const BackupResult.passphraseNeeded());
        }

        final backupKey = salt == null
            ? null
            : await NoteCipher.keyFromPassphrase(passphrase: passphrase!, salt: salt);

        try {
          return right(
            BackupResult.done(
              noteCount: await _restore(backup, dataKey: dataKey, backupKey: backupKey),
            ),
          );
        } on SecretBoxAuthenticationError {
          // The passphrase did not open the first protected note, so it will
          // not open any of them. Nothing has been written by this point.
          return right(const BackupResult.wrongPassphrase());
        }
      },
      _toErrorDetail,
    );
  }

  /// Hands back how many notes were actually new to this phone.
  Future<int> _restore(
    NoteBackup backup, {
    List<int>? dataKey,
    List<int>? backupKey,
  }) async {
    final stored = await _unwrap(_noteRepository.getNotes());
    final known = {for (final note in stored) _signatureOf(note)};
    var imported = 0;

    // Categories nothing is filed under would otherwise be lost.
    for (final name in backup.categoryNames) {
      await _unwrap(_noteRepository.resolveCategory(name: name));
    }

    for (final backupNote in backup.notes) {
      if (!known.add(backupNote.signature)) {
        continue;
      }

      final categoryName = backupNote.categoryName;
      final category = categoryName == null || categoryName.trim().isEmpty
          ? null
          : await _unwrap(_noteRepository.resolveCategory(name: categoryName));

      await _unwrap(
        _noteRepository.saveNote(
          note: Note(
            title: backupNote.title,
            todoList: backupNote.isChecklist ? Checklist.encode(backupNote.items) : null,
            noteContents: await _contentsFromBackup(
              backupNote,
              dataKey: dataKey,
              backupKey: backupKey,
            ),
            categoryId: category?.id,
            isFavorite: backupNote.isFavorite,
            isProtected: backupNote.isProtected,
            date: backupNote.date,
          ),
        ),
      );

      imported++;
    }

    return imported;
  }

  /// What goes into the backup for one note. A protected note is opened with
  /// this phone's data key and sealed again under the passphrase, because the
  /// Keystore key it was stored with cannot leave the device - and a backup
  /// only that phone can read is no backup at all.
  Future<String?> _contentsForBackup(
    Note note, {
    required List<int>? dataKey,
    required List<int>? backupKey,
  }) async {
    if (note.isChecklist) {
      return null;
    }

    if (!note.isProtected) {
      return note.noteContents;
    }

    final plainText = await NoteCipher.decrypt(
      payload: note.noteContents ?? '',
      key: dataKey!,
    );

    return NoteCipher.encrypt(plainText: plainText, key: backupKey!);
  }

  /// The mirror of [_contentsForBackup]: a protected note is opened with the
  /// passphrase it travelled under and sealed again under this phone's own key,
  /// so it goes on being protected here rather than landing in the clear.
  Future<String?> _contentsFromBackup(
    BackupNote backupNote, {
    required List<int>? dataKey,
    required List<int>? backupKey,
  }) async {
    if (backupNote.isChecklist) {
      return null;
    }

    if (!backupNote.isProtected) {
      return backupNote.contents;
    }

    final plainText = await NoteCipher.decrypt(
      payload: backupNote.contents ?? '',
      key: backupKey!,
    );

    return NoteCipher.encrypt(plainText: plainText, key: dataKey!);
  }

  /// A stored note measured by the same yardstick the backup uses.
  String _signatureOf(Note note) {
    return BackupNote(
      title: note.title,
      contents: note.isChecklist ? null : note.noteContents,
      items: note.checklistItems,
      // Has to match how the backup measures it, or every protected note would
      // look new and come back as a second copy.
      isProtected: note.isProtected,
      date: note.date,
    ).signature;
  }

  /// Lets the steps read as plain `await`s while a failure in any of them ends
  /// the whole export or import.
  Future<T> _unwrap<T>(TaskEither<ErrorDetail, T> task) async {
    final result = await task.run();

    return result.getOrElse((error) => throw _BackupFailure(error));
  }

  ErrorDetail _toErrorDetail(Object error, StackTrace stackTrace) {
    return error is _BackupFailure
        ? error.detail
        : ErrorDetail.fatal(throwable: error, stackTrace: stackTrace);
  }
}

/// Carries the detail of a failed step out of [BackupRepository._unwrap].
class _BackupFailure implements Exception {
  const _BackupFailure(this.detail);

  final ErrorDetail detail;
}
