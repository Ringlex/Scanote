import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:note/data/model/backup/note_backup.dart';
import 'package:note/data/model/note/checklist_item.dart';

void main() {
  group('NoteBackup', () {
    final backup = NoteBackup(
      exportedAt: DateTime(2026, 8, 6, 10, 30),
      categoryNames: ['Work', 'Empty one'],
      notes: [
        BackupNote(
          title: 'Shopping',
          items: const [
            ChecklistItem(label: 'Milk', isDone: true),
            ChecklistItem(label: 'Bread'),
          ],
          categoryName: 'Work',
          isFavorite: true,
          date: DateTime(2026, 8, 7),
        ),
        const BackupNote(title: 'Plain one', contents: 'Some text'),
      ],
    );

    test('survives a round trip', () {
      final restored = NoteBackup.decode(backup.encode())!;

      expect(restored.exportedAt, backup.exportedAt);
      expect(restored.categoryNames, backup.categoryNames);
      expect(restored.notes.length, 2);

      final checklist = restored.notes.first;

      expect(checklist.title, 'Shopping');
      expect(checklist.items.map((item) => item.label), ['Milk', 'Bread']);
      expect(checklist.items.map((item) => item.isDone), [true, false]);
      expect(checklist.categoryName, 'Work');
      expect(checklist.isFavorite, isTrue);
      expect(checklist.date, DateTime(2026, 8, 7));

      final text = restored.notes.last;

      expect(text.contents, 'Some text');
      expect(text.isChecklist, isFalse);
      expect(text.isFavorite, isFalse);
    });

    test('turns down anything that is not one of our backups', () {
      expect(NoteBackup.decode('not json at all'), isNull);
      expect(NoteBackup.decode(jsonEncode({'kind': 'something-else', 'version': 1})), isNull);
      expect(NoteBackup.decode(jsonEncode({'kind': 'note-backup', 'version': 99})), isNull);
    });

    test('reads a note the same way however its list was ticked off', () {
      const before = BackupNote(
        title: 'Shopping',
        items: [ChecklistItem(label: 'Milk'), ChecklistItem(label: 'Bread')],
      );
      const after = BackupNote(
        title: 'Shopping',
        items: [
          ChecklistItem(label: 'Milk', isDone: true),
          ChecklistItem(label: 'Bread', isDone: true),
        ],
      );

      expect(before.signature, after.signature);
    });

    test('tells two different notes apart', () {
      const shopping = BackupNote(title: 'Shopping', contents: 'Milk');
      const other = BackupNote(title: 'Shopping', contents: 'Bread');

      expect(shopping.signature, isNot(other.signature));
    });
  });
}
