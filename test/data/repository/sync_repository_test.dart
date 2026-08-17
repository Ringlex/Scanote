import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:note/data/drive/drive_service.dart';
import 'package:note/data/model/categories/category.dart';
import 'package:note/data/model/error_detail.dart';
import 'package:note/data/model/note/note.dart';
import 'package:note/data/model/sync/note_sync_document.dart';
import 'package:note/data/model/sync/sync_result.dart';
import 'package:note/data/repository/note_repository.dart';
import 'package:note/data/repository/settings_repository.dart';
import 'package:note/data/repository/sync_repository.dart';

class _MockNoteRepository extends Mock implements NoteRepository {}

class _MockDriveService extends Mock implements DriveService {}

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockNoteRepository noteRepository;
  late _MockDriveService driveService;
  late _MockSettingsRepository settingsRepository;
  late SyncRepository repository;

  final earlier = DateTime.utc(2026, 8, 17, 9);
  final later = DateTime.utc(2026, 8, 17, 11);

  late List<Note> stored;
  late String uploaded;

  setUpAll(() {
    registerFallbackValue(Note(title: ''));
  });

  void given({required List<Note> local, NoteSyncDocument? remote}) {
    stored = [];

    when(() => settingsRepository.readSyncEnabled()).thenAnswer((_) => TaskEither<ErrorDetail, bool>.of(true));
    when(() => settingsRepository.writeLastSyncedAt(any())).thenAnswer((_) => TaskEither<ErrorDetail, Unit>.of(unit));

    when(driveService.ensureAccess).thenAnswer((_) => TaskEither<ErrorDetail, bool>.of(true));
    when(() => driveService.findLatest(namePrefix: any(named: 'namePrefix'))).thenAnswer(
      (_) => TaskEither<ErrorDetail, DriveFile?>.of(
        remote == null ? null : const DriveFile(id: 'file-1', name: 'note-sync.json', modifiedAt: null),
      ),
    );
    when(
      () => driveService.download(fileId: any(named: 'fileId')),
    ).thenAnswer((_) => TaskEither<ErrorDetail, String>.of(remote?.encode() ?? ''));

    when(
      () => driveService.update(
        fileId: any(named: 'fileId'),
        contents: any(named: 'contents'),
      ),
    ).thenAnswer((invocation) {
      uploaded = invocation.namedArguments[#contents] as String;

      return TaskEither<ErrorDetail, Unit>.of(unit);
    });
    when(
      () => driveService.upload(
        name: any(named: 'name'),
        contents: any(named: 'contents'),
      ),
    ).thenAnswer((invocation) {
      uploaded = invocation.namedArguments[#contents] as String;

      return TaskEither<ErrorDetail, String>.of('file-1');
    });

    when(noteRepository.getAllNotes).thenAnswer((_) => TaskEither<ErrorDetail, List<Note>>.of(local));
    when(noteRepository.getCategories).thenAnswer((_) => TaskEither<ErrorDetail, List<Category>>.of(const []));
    when(() => noteRepository.resolveCategory(name: any(named: 'name'))).thenAnswer(
      (invocation) =>
          TaskEither<ErrorDetail, Category>.of(Category(id: 1, name: invocation.namedArguments[#name] as String)),
    );
    when(() => noteRepository.saveSyncedNote(note: any(named: 'note'))).thenAnswer((invocation) {
      final note = invocation.namedArguments[#note] as Note;

      stored.add(note);

      return TaskEither<ErrorDetail, Note>.of(note);
    });
  }

  setUp(() {
    noteRepository = _MockNoteRepository();
    driveService = _MockDriveService();
    settingsRepository = _MockSettingsRepository();

    repository = SyncRepository(
      noteRepository: noteRepository,
      driveService: driveService,
      settingsRepository: settingsRepository,
    );

    uploaded = '';
  });

  Future<SyncResult> sync() async {
    final result = await repository.sync().run();

    return result.getOrElse((error) => fail('sync failed: ${error.throwable}'));
  }

  group('SyncRepository pulling', () {
    test('takes in a note this phone has never seen', () async {
      given(
        local: const [],
        remote: NoteSyncDocument(
          syncedAt: later,
          categoryNames: const [],
          notes: [SyncNote(uuid: 'abc', title: 'Z drugiego telefonu', updatedAt: later, contents: 'treść')],
        ),
      );

      final result = await sync();

      expect(result.received, 1);
      expect(stored.single.uuid, 'abc');
      expect(stored.single.title, 'Z drugiego telefonu');
      expect(stored.single.id, isNull, reason: 'a note new to this phone gets an id from the database');
    });

    test('lets the later copy win over the one already here', () async {
      given(
        local: [Note(id: 7, uuid: 'abc', title: 'Stara', noteContents: 'stare', updatedAt: earlier)],
        remote: NoteSyncDocument(
          syncedAt: later,
          categoryNames: const [],
          notes: [SyncNote(uuid: 'abc', title: 'Nowa', updatedAt: later, contents: 'nowe')],
        ),
      );

      final result = await sync();

      expect(result.received, 1);
      expect(stored.single.title, 'Nowa');
      expect(stored.single.id, 7, reason: 'the row keeps its own id');
    });

    test('leaves the copy here alone when it is the later one', () async {
      given(
        local: [Note(id: 7, uuid: 'abc', title: 'Nowsza tutaj', updatedAt: later)],
        remote: NoteSyncDocument(
          syncedAt: later,
          categoryNames: const [],
          notes: [SyncNote(uuid: 'abc', title: 'Starsza tam', updatedAt: earlier)],
        ),
      );

      final result = await sync();

      expect(result.received, 0);
      expect(stored, isEmpty);
    });

    test('keeps the pictures, which never left this phone', () async {
      given(
        local: [Note(id: 7, uuid: 'abc', title: 'Skan', imagePaths: '["a.jpg"]', updatedAt: earlier)],
        remote: NoteSyncDocument(
          syncedAt: later,
          categoryNames: const [],
          notes: [SyncNote(uuid: 'abc', title: 'Skan poprawiony', updatedAt: later)],
        ),
      );

      await sync();

      expect(stored.single.imageNames, ['a.jpg']);
    });

    test('applies a deletion to a note it holds', () async {
      given(
        local: [Note(id: 7, uuid: 'abc', title: 'Do kosza', updatedAt: earlier)],
        remote: NoteSyncDocument(
          syncedAt: later,
          categoryNames: const [],
          notes: [SyncNote(uuid: 'abc', title: 'Do kosza', updatedAt: later, deletedAt: later)],
        ),
      );

      await sync();

      expect(stored.single.deletedAt, later);
    });

    test('ignores a tombstone for a note it has never held', () async {
      given(
        local: const [],
        remote: NoteSyncDocument(
          syncedAt: later,
          categoryNames: const [],
          notes: [SyncNote(uuid: 'gone', title: 'Dawno usunięta', updatedAt: later, deletedAt: later)],
        ),
      );

      final result = await sync();

      expect(result.received, 0);
      expect(stored, isEmpty, reason: 'storing it would put the note back in the bin on every sync');
    });

    test('will not overwrite a note that is protected here', () async {
      given(
        local: [Note(id: 7, uuid: 'abc', title: 'Chroniona', isProtected: true, updatedAt: earlier)],
        remote: NoteSyncDocument(
          syncedAt: later,
          categoryNames: const [],
          notes: [SyncNote(uuid: 'abc', title: 'Z czasów przed ochroną', updatedAt: later, contents: 'jawne')],
        ),
      );

      final result = await sync();

      expect(result.received, 0);
      expect(stored, isEmpty);
    });
  });

  group('SyncRepository pushing', () {
    test('leaves protected notes out of the document', () async {
      given(
        local: [
          Note(id: 1, uuid: 'plain', title: 'Zwykła', updatedAt: earlier),
          Note(id: 2, uuid: 'secret', title: 'Chroniona', isProtected: true, updatedAt: earlier),
        ],
      );

      final result = await sync();
      final document = NoteSyncDocument.decode(uploaded)!;

      expect(result.sent, 1);
      expect(document.notes.map((note) => note.uuid).toList(), ['plain']);
    });

    test('sends its own tombstones, so a deletion reaches the other phone', () async {
      given(
        local: [Note(id: 1, uuid: 'abc', title: 'Usunięta', deletedAt: earlier, updatedAt: earlier)],
      );

      await sync();

      final document = NoteSyncDocument.decode(uploaded)!;

      expect(document.notes.single.isDeleted, isTrue);
    });

    test('skips a note with no identity rather than sending a nameless one', () async {
      given(
        local: [Note(id: 1, title: 'Bez uuid', updatedAt: earlier)],
      );

      final result = await sync();

      expect(result.sent, 0);
      expect(NoteSyncDocument.decode(uploaded)!.notes, isEmpty);
    });

    test('creates the document when Drive has none yet', () async {
      given(
        local: [Note(id: 1, uuid: 'abc', title: 'Pierwsza', updatedAt: earlier)],
      );

      await sync();

      verify(
        () => driveService.upload(
          name: any(named: 'name'),
          contents: any(named: 'contents'),
        ),
      ).called(1);
      verifyNever(
        () => driveService.update(
          fileId: any(named: 'fileId'),
          contents: any(named: 'contents'),
        ),
      );
    });

    test('rewrites the same file rather than leaving a trail of them', () async {
      given(
        local: [Note(id: 1, uuid: 'abc', title: 'Pierwsza', updatedAt: earlier)],
        remote: NoteSyncDocument(syncedAt: earlier, categoryNames: const [], notes: const []),
      );

      await sync();

      verify(
        () => driveService.update(
          fileId: 'file-1',
          contents: any(named: 'contents'),
        ),
      ).called(1);
      verifyNever(
        () => driveService.upload(
          name: any(named: 'name'),
          contents: any(named: 'contents'),
        ),
      );
    });
  });

  group('SyncRepository gates', () {
    test('does nothing while the setting is off', () async {
      given(local: const []);
      when(() => settingsRepository.readSyncEnabled()).thenAnswer((_) => TaskEither<ErrorDetail, bool>.of(false));

      final result = await sync();

      expect(result.status, SyncStatus.disabled);
      verifyNever(driveService.ensureAccess);
    });

    test('stops without writing when Drive access is refused', () async {
      given(local: const []);
      when(driveService.ensureAccess).thenAnswer((_) => TaskEither<ErrorDetail, bool>.of(false));

      final result = await sync();

      expect(result.status, SyncStatus.cancelled);
      verifyNever(
        () => driveService.upload(
          name: any(named: 'name'),
          contents: any(named: 'contents'),
        ),
      );
    });
  });
}
