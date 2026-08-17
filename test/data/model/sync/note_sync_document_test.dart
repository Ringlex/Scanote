import 'package:flutter_test/flutter_test.dart';
import 'package:note/data/model/note/checklist_item.dart';
import 'package:note/data/model/sync/note_sync_document.dart';

void main() {
  final syncedAt = DateTime.utc(2026, 8, 17, 10, 30);
  final updatedAt = DateTime.utc(2026, 8, 17, 9);

  NoteSyncDocument roundTrip(NoteSyncDocument document) {
    final decoded = NoteSyncDocument.decode(document.encode());

    expect(decoded, isNotNull);

    return decoded!;
  }

  group('NoteSyncDocument', () {
    test('carries a plain note there and back', () {
      final decoded = roundTrip(
        NoteSyncDocument(
          syncedAt: syncedAt,
          categoryNames: const ['praca'],
          notes: [
            SyncNote(
              uuid: 'abc',
              title: 'Zakupy',
              updatedAt: updatedAt,
              contents: 'mleko',
              categoryName: 'praca',
              isFavorite: true,
              date: syncedAt,
            ),
          ],
        ),
      );

      final note = decoded.notes.single;

      expect(decoded.categoryNames, ['praca']);
      expect(note.uuid, 'abc');
      expect(note.title, 'Zakupy');
      expect(note.contents, 'mleko');
      expect(note.categoryName, 'praca');
      expect(note.isFavorite, isTrue);
      expect(note.updatedAt, updatedAt);
      expect(note.date, syncedAt);
    });

    test('carries a checklist there and back', () {
      final decoded = roundTrip(
        NoteSyncDocument(
          syncedAt: syncedAt,
          categoryNames: const [],
          notes: [
            SyncNote(
              uuid: 'abc',
              title: 'Lista',
              updatedAt: updatedAt,
              items: const [ChecklistItem(label: 'mleko', isDone: true), ChecklistItem(label: 'chleb')],
            ),
          ],
        ),
      );

      final note = decoded.notes.single;

      expect(note.isChecklist, isTrue);
      expect(note.items.map((item) => item.label).toList(), ['mleko', 'chleb']);
      expect(note.items.map((item) => item.isDone).toList(), [true, false]);
    });

    test('keeps a deletion, which is the whole point of a tombstone', () {
      final decoded = roundTrip(
        NoteSyncDocument(
          syncedAt: syncedAt,
          categoryNames: const [],
          notes: [SyncNote(uuid: 'abc', title: 'Stara', updatedAt: updatedAt, deletedAt: updatedAt)],
        ),
      );

      expect(decoded.notes.single.isDeleted, isTrue);
      expect(decoded.notes.single.deletedAt, updatedAt);
    });

    test('turns down a file that is not one of ours', () {
      expect(NoteSyncDocument.decode('{"kind":"something-else","version":1}'), isNull);
      expect(NoteSyncDocument.decode('not json at all'), isNull);
      expect(NoteSyncDocument.decode(''), isNull);
    });

    test('skips an entry with no identity rather than dropping the file', () {
      final decoded = NoteSyncDocument.decode(
        '{"kind":"note-sync","version":1,"syncedAt":"2026-08-17T10:30:00.000Z","categories":[],'
        '"notes":[{"title":"no uuid"},{"uuid":"abc","title":"fine","updatedAt":"2026-08-17T09:00:00.000Z"}]}',
      );

      expect(decoded, isNotNull);
      expect(decoded!.notes.single.uuid, 'abc');
    });

    test('treats a note with no readable clock as the oldest there is', () {
      final decoded = NoteSyncDocument.decode(
        '{"kind":"note-sync","version":1,"syncedAt":"2026-08-17T10:30:00.000Z","categories":[],'
        '"notes":[{"uuid":"abc","title":"fine"}]}',
      );

      expect(decoded!.notes.single.updatedAt.isBefore(updatedAt), isTrue);
    });
  });
}
