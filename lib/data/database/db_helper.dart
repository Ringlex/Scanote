import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:note/core/app_logger/app_logger.dart';
import 'package:note/core/fpdarts.dart';
import 'package:note/core/uuid.dart';
import 'package:note/data/model/categories/category.dart';
import 'package:note/data/model/error_detail.dart';
import 'package:note/data/model/event/event.dart';
import 'package:note/data/model/note/note.dart';
import 'package:note/data/model/note/note_images.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static const _databaseName = 'note.db';
  static const _databaseVersion = 8;

  static const binRetention = Duration(days: 30);

  static const noteTable = 'Note';
  static const categoriesTable = 'Categories';
  static const eventsTable = 'Events';

  Future<Database>? _database;

  Future<Database> get database => _database ??= _openDatabase();

  Future<void> initDatabase() async {
    await database;
  }

  Future<Database> _openDatabase() async {
    final Directory dbDirectory = await getApplicationDocumentsDirectory();
    final String path = join(dbDirectory.path, _databaseName);
    logInfo('Opening database at $path');

    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createNoteTables(db);
    await _createEventTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS $noteTable');
      await db.execute('DROP TABLE IF EXISTS $categoriesTable');
      await _createNoteTables(db);
    }

    if (oldVersion < 3) {
      await _createEventTable(db);
    }

    if (oldVersion < 4) {
      await db.execute('ALTER TABLE $noteTable ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0');
    }

    if (oldVersion < 5) {
      await db.execute('ALTER TABLE $noteTable ADD COLUMN date TEXT');
    }

    if (oldVersion < 6) {
      await db.execute('ALTER TABLE $noteTable ADD COLUMN deletedAt TEXT');
    }

    if (oldVersion < 7) {
      await db.execute('ALTER TABLE $noteTable ADD COLUMN isProtected INTEGER NOT NULL DEFAULT 0');
    }

    if (oldVersion < 8) {
      await db.execute('ALTER TABLE $noteTable ADD COLUMN imagePaths TEXT');
      await db.execute('ALTER TABLE $noteTable ADD COLUMN uuid TEXT');
      await db.execute('ALTER TABLE $noteTable ADD COLUMN updatedAt TEXT');
      await _stampExistingNotes(db);
    }
  }

  Future<void> _stampExistingNotes(Database db) async {
    final rows = await db.query(noteTable, columns: ['id'], where: 'uuid IS NULL');
    final stampedAt = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      for (final row in rows) {
        await txn.update(
          noteTable,
          {'uuid': Uuid.v4(), 'updatedAt': stampedAt},
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      }
    });

    logInfo('Gave ${rows.length} existing notes an identity for syncing');
  }

  Future<void> _createNoteTables(Database db) async {
    await db.execute('''
      CREATE TABLE $noteTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        todoList TEXT,
        noteContents TEXT,
        isProtected INTEGER NOT NULL DEFAULT 0,
        -- Vestigial: the PIN it once held gave way to the Keystore. It stays so
        -- that a fresh database has the same shape as an upgraded one, and is
        -- always null here.
        password TEXT,
        categoryId INTEGER,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        date TEXT,
        deletedAt TEXT,
        imagePaths TEXT,
        uuid TEXT,
        updatedAt TEXT
      )
  ''');

    await db.execute('''
      CREATE TABLE $categoriesTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
  ''');
  }

  Future<void> _createEventTable(Database db) async {
    await db.execute('''
      CREATE TABLE $eventsTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        startAt TEXT NOT NULL,
        remindAt TEXT
      )
  ''');
  }

  TaskEither<ErrorDetail, List<Note>> getNotes() {
    return tryCatchE(() async {
      final db = await database;
      final rows = await db.query(noteTable, where: 'deletedAt IS NULL', orderBy: 'id DESC');

      return right(rows.map(Note.fromJson).toList());
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, int> countDroppedPins() {
    return tryCatchE(() async {
      final db = await database;
      final rows = await db.rawQuery('SELECT COUNT(*) AS total FROM $noteTable WHERE password IS NOT NULL');

      return right((rows.first['total'] as int?) ?? 0);
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, int> clearDroppedPins() {
    return tryCatchE(() async {
      final db = await database;
      final result = await db.update(noteTable, {'password': null}, where: 'password IS NOT NULL');

      return right(result);
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, List<Note>> getDeletedNotes() {
    return tryCatchE(() async {
      final db = await database;
      final rows = await db.query(noteTable, where: 'deletedAt IS NOT NULL', orderBy: 'deletedAt DESC');

      return right(rows.map(Note.fromJson).toList());
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, int> insertNote({required Note note}) {
    return tryCatchE(() async {
      final db = await database;
      final result = await db.insert(noteTable, note.toJson());

      return right(result);
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, int> updateNote({required Note note}) {
    return tryCatchE(() async {
      final db = await database;
      final result = await db.update(noteTable, note.toJson(), where: 'id = ?', whereArgs: [note.id]);

      return right(result);
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, int> softDeleteNote({required int id, DateTime? at}) {
    return tryCatchE(() async {
      final db = await database;
      final deletedAt = (at ?? DateTime.now()).toIso8601String();
      final result = await db.update(
        noteTable,
        {'deletedAt': deletedAt, 'updatedAt': deletedAt},
        where: 'id = ? AND deletedAt IS NULL',
        whereArgs: [id],
      );

      return right(result);
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, int> restoreNote({required int id}) {
    return tryCatchE(() async {
      final db = await database;
      final result = await db.update(
        noteTable,
        {'deletedAt': null, 'updatedAt': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );

      return right(result);
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, List<String>> purgeNote({required int id}) {
    return _purge(where: 'id = ?', whereArgs: [id]);
  }

  TaskEither<ErrorDetail, List<String>> purgeBin({DateTime? deletedBefore}) {
    return _purge(
      where: deletedBefore == null ? 'deletedAt IS NOT NULL' : 'deletedAt IS NOT NULL AND deletedAt < ?',
      whereArgs: deletedBefore == null ? null : [deletedBefore.toIso8601String()],
    );
  }

  TaskEither<ErrorDetail, List<String>> _purge({required String where, List<Object?>? whereArgs}) {
    return tryCatchE(() async {
      final db = await database;

      return right(
        await db.transaction((txn) async {
          final rows = await txn.query(noteTable, columns: ['imagePaths'], where: where, whereArgs: whereArgs);

          await txn.delete(noteTable, where: where, whereArgs: whereArgs);

          return [for (final row in rows) ...NoteImages.decode(row['imagePaths'] as String?)];
        }),
      );
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, List<Note>> getAllNotes() {
    return tryCatchE(() async {
      final db = await database;
      final rows = await db.query(noteTable, orderBy: 'id DESC');

      return right(rows.map(Note.fromJson).toList());
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, Note?> getNoteByUuid({required String uuid}) {
    return tryCatchE(() async {
      final db = await database;
      final rows = await db.query(noteTable, where: 'uuid = ?', whereArgs: [uuid], limit: 1);

      return right(rows.isEmpty ? null : Note.fromJson(rows.first));
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, List<Category>> getCategories() {
    return tryCatchE(() async {
      final db = await database;
      final rows = await db.query(categoriesTable, orderBy: 'name COLLATE NOCASE ASC');

      return right(rows.map(Category.fromJson).toList());
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, Category?> getCategoryByName({required String name}) {
    return tryCatchE(() async {
      final db = await database;
      final rows = await db.query(categoriesTable, where: 'name = ? COLLATE NOCASE', whereArgs: [name], limit: 1);

      return right(rows.isEmpty ? null : Category.fromJson(rows.first));
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, List<Event>> getEvents() {
    return tryCatchE(() async {
      final db = await database;
      final rows = await db.query(eventsTable, orderBy: 'startAt ASC');

      return right(rows.map(Event.fromJson).toList());
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, int> insertEvent({required Event event}) {
    return tryCatchE(() async {
      final db = await database;
      final result = await db.insert(eventsTable, event.toJson());

      return right(result);
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, int> updateEvent({required Event event}) {
    return tryCatchE(() async {
      final db = await database;
      final result = await db.update(eventsTable, event.toJson(), where: 'id = ?', whereArgs: [event.id]);

      return right(result);
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, int> deleteEvent({required int id}) {
    return tryCatchE(() async {
      final db = await database;
      final result = await db.delete(eventsTable, where: 'id = ?', whereArgs: [id]);

      return right(result);
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, int> updateCategory({required Category category}) {
    return tryCatchE(() async {
      final db = await database;
      final result = await db.update(categoriesTable, category.toJson(), where: 'id = ?', whereArgs: [category.id]);

      return right(result);
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  /// Notes keep everything they hold, they just stop pointing at the category.
  TaskEither<ErrorDetail, int> deleteCategory({required int id}) {
    return tryCatchE(() async {
      final db = await database;
      final result = await db.transaction((txn) async {
        await txn.update(noteTable, {'categoryId': null}, where: 'categoryId = ?', whereArgs: [id]);

        return txn.delete(categoriesTable, where: 'id = ?', whereArgs: [id]);
      });

      return right(result);
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  TaskEither<ErrorDetail, int> insertCategory({required Category category}) {
    return tryCatchE(() async {
      final db = await database;
      final result = await db.insert(categoriesTable, category.toJson());

      return right(result);
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }
}
