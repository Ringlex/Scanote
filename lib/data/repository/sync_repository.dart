import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';
import 'package:note/core/app_logger/app_logger.dart';
import 'package:note/core/fpdarts.dart';
import 'package:note/data/drive/drive_service.dart';
import 'package:note/data/model/categories/category.dart';
import 'package:note/data/model/error_detail.dart';
import 'package:note/data/model/note/checklist_item.dart';
import 'package:note/data/model/note/note.dart';
import 'package:note/data/model/sync/note_sync_document.dart';
import 'package:note/data/model/sync/sync_result.dart';
import 'package:note/data/repository/note_repository.dart';
import 'package:note/data/repository/settings_repository.dart';

class SyncRepository {
  SyncRepository({
    required NoteRepository noteRepository,
    required DriveService driveService,
    required SettingsRepository settingsRepository,
  }) : _noteRepository = noteRepository,
       _driveService = driveService,
       _settingsRepository = settingsRepository;

  final NoteRepository _noteRepository;
  final DriveService _driveService;
  final SettingsRepository _settingsRepository;

  static const _fileName = 'note-sync.json';
  static const _namePrefix = 'note-sync';

  TaskEither<ErrorDetail, SyncResult> sync({bool force = false}) {
    return tryCatchE(() async {
      if (!force && !await _unwrap(_settingsRepository.readSyncEnabled())) {
        return right(const SyncResult.disabled());
      }

      if (!await _unwrap(_driveService.ensureAccess())) {
        return right(const SyncResult.cancelled());
      }

      final file = await _unwrap(_driveService.findLatest(namePrefix: _namePrefix));
      final remote = file == null
          ? NoteSyncDocument.empty
          : NoteSyncDocument.decode(await _unwrap(_driveService.download(fileId: file.id))) ?? NoteSyncDocument.empty;

      final received = await _pull(remote);
      final document = await _localDocument();

      await _unwrap(
        file == null
            ? _driveService.upload(name: _fileName, contents: document.encode()).map((_) => unit)
            : _driveService.update(fileId: file.id, contents: document.encode()),
      );

      await _unwrap(_settingsRepository.writeLastSyncedAt(document.syncedAt));

      logInfo('Sync took $received notes in and left ${document.notes.length} on Drive');

      return right(SyncResult.done(received: received, sent: document.notes.length));
    }, _toErrorDetail);
  }

  Future<int> _pull(NoteSyncDocument remote) async {
    if (remote.notes.isEmpty) {
      return 0;
    }

    final local = await _unwrap(_noteRepository.getAllNotes());
    final byUuid = {
      for (final note in local)
        if (note.uuid != null) note.uuid!: note,
    };

    for (final name in remote.categoryNames) {
      await _unwrap(_noteRepository.resolveCategory(name: name));
    }

    var received = 0;

    for (final incoming in remote.notes) {
      final stored = byUuid[incoming.uuid];

      if (stored == null && incoming.isDeleted) {
        continue;
      }

      if (stored != null && stored.isProtected) {
        continue;
      }

      if (stored != null && !_isNewer(incoming, than: stored)) {
        continue;
      }

      await _unwrap(_noteRepository.saveSyncedNote(note: await _merge(incoming, into: stored)));

      received++;
    }

    return received;
  }

  bool _isNewer(SyncNote incoming, {required Note than}) {
    final storedAt = than.updatedAt;

    return storedAt == null || incoming.updatedAt.isAfter(storedAt);
  }

  Future<Note> _merge(SyncNote incoming, {required Note? into}) async {
    final category = await _resolveCategory(incoming.categoryName);

    return Note(
      id: into?.id,
      uuid: incoming.uuid,
      title: incoming.title,
      todoList: incoming.isChecklist ? Checklist.encode(incoming.items) : null,
      noteContents: incoming.isChecklist ? null : incoming.contents,
      categoryId: category?.id,
      isFavorite: incoming.isFavorite,
      date: incoming.date,
      deletedAt: incoming.deletedAt,
      updatedAt: incoming.updatedAt,
      imagePaths: into?.imagePaths,
    );
  }

  Future<Category?> _resolveCategory(String? name) async {
    if (name == null || name.trim().isEmpty) {
      return null;
    }

    return _unwrap(_noteRepository.resolveCategory(name: name));
  }

  Future<NoteSyncDocument> _localDocument() async {
    final notes = await _unwrap(_noteRepository.getAllNotes());
    final categories = await _unwrap(_noteRepository.getCategories());

    return NoteSyncDocument(
      syncedAt: DateTime.now(),
      categoryNames: [for (final category in categories) category.name],
      notes: [
        for (final note in notes)
          if (!note.isProtected && note.uuid != null && note.updatedAt != null)
            SyncNote(
              uuid: note.uuid!,
              title: note.title,
              updatedAt: note.updatedAt!,
              contents: note.isChecklist ? null : note.noteContents,
              items: note.checklistItems,
              categoryName: categories.firstWhereOrNull((category) => category.id == note.categoryId)?.name,
              isFavorite: note.isFavorite,
              date: note.date,
              deletedAt: note.deletedAt,
            ),
      ],
    );
  }

  Future<T> _unwrap<T>(TaskEither<ErrorDetail, T> task) async {
    final result = await task.run();

    return result.getOrElse((error) => throw _SyncFailure(error));
  }

  ErrorDetail _toErrorDetail(Object error, StackTrace stackTrace) {
    return error is _SyncFailure ? error.detail : ErrorDetail.fatal(throwable: error, stackTrace: stackTrace);
  }
}

class _SyncFailure implements Exception {
  const _SyncFailure(this.detail);

  final ErrorDetail detail;
}
