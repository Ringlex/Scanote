import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:note/core/app_logger/app_logger.dart';
import 'package:note/core/fpdarts.dart';
import 'package:note/data/model/categories/category.dart';
import 'package:note/data/model/error_detail.dart';
import 'package:note/data/model/event/event.dart';
import 'package:note/data/model/note/note.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static const _databaseName = 'note.db';
  static const _databaseVersion = 4;

  static const noteTable = 'Note';
  static const categoriesTable = 'Categories';
  static const eventsTable = 'Events';

  Future<Database>? _database;

  /// Opens the database on first access, so every query is safe to call
  /// regardless of whether [initDatabase] has already completed.
  Future<Database> get database => _database ??= _openDatabase();

  Future<void> initDatabase() async {
    await database;
  }

  Future<Database> _openDatabase() async {
    final Directory dbDirectory = await getApplicationDocumentsDirectory();
    final String path = join(dbDirectory.path, _databaseName);
    logInfo('Opening database at $path');

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createNoteTables(db);
    await _createEventTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Version 1 never produced usable tables (the column list was not a valid
    // statement), so its schema is recreated from scratch.
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS $noteTable');
      await db.execute('DROP TABLE IF EXISTS $categoriesTable');
      await _createNoteTables(db);
    }

    if (oldVersion < 3) {
      await _createEventTable(db);
    }

    if (oldVersion < 4) {
      await db.execute(
        'ALTER TABLE $noteTable ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  Future<void> _createNoteTables(Database db) async {
    await db.execute('''
      CREATE TABLE $noteTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        todoList TEXT,
        noteContents TEXT,
        password TEXT,
        categoryId INTEGER,
        isFavorite INTEGER NOT NULL DEFAULT 0
      )
  ''');

    await db.execute('''
      CREATE TABLE $categoriesTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
  ''');
  }

  /// Dates are kept as ISO 8601 text, which sorts the same way it reads.
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
    return tryCatchE(
      () async {
        final db = await database;
        final rows = await db.query(noteTable, orderBy: 'id DESC');

        return right(rows.map(Note.fromJson).toList());
      },
      (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace),
    );
  }

  TaskEither<ErrorDetail, int> insertNote({required Note note}) {
    return tryCatchE(
      () async {
        final db = await database;
        final result = await db.insert(noteTable, note.toJson());

        return right(result);
      },
      (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace),
    );
  }

  TaskEither<ErrorDetail, int> updateNote({required Note note}) {
    return tryCatchE(
      () async {
        final db = await database;
        final result = await db.update(
          noteTable,
          note.toJson(),
          where: 'id = ?',
          whereArgs: [note.id],
        );

        return right(result);
      },
      (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace),
    );
  }

  TaskEither<ErrorDetail, List<Category>> getCategories() {
    return tryCatchE(
      () async {
        final db = await database;
        final rows = await db.query(categoriesTable, orderBy: 'name COLLATE NOCASE ASC');

        return right(rows.map(Category.fromJson).toList());
      },
      (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace),
    );
  }

  TaskEither<ErrorDetail, Category?> getCategoryByName({required String name}) {
    return tryCatchE(
      () async {
        final db = await database;
        final rows = await db.query(
          categoriesTable,
          where: 'name = ? COLLATE NOCASE',
          whereArgs: [name],
          limit: 1,
        );

        return right(rows.isEmpty ? null : Category.fromJson(rows.first));
      },
      (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace),
    );
  }

  TaskEither<ErrorDetail, List<Event>> getEvents() {
    return tryCatchE(
      () async {
        final db = await database;
        final rows = await db.query(eventsTable, orderBy: 'startAt ASC');

        return right(rows.map(Event.fromJson).toList());
      },
      (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace),
    );
  }

  TaskEither<ErrorDetail, int> insertEvent({required Event event}) {
    return tryCatchE(
      () async {
        final db = await database;
        final result = await db.insert(eventsTable, event.toJson());

        return right(result);
      },
      (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace),
    );
  }

  TaskEither<ErrorDetail, int> updateEvent({required Event event}) {
    return tryCatchE(
      () async {
        final db = await database;
        final result = await db.update(
          eventsTable,
          event.toJson(),
          where: 'id = ?',
          whereArgs: [event.id],
        );

        return right(result);
      },
      (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace),
    );
  }

  TaskEither<ErrorDetail, int> deleteEvent({required int id}) {
    return tryCatchE(
      () async {
        final db = await database;
        final result = await db.delete(eventsTable, where: 'id = ?', whereArgs: [id]);

        return right(result);
      },
      (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace),
    );
  }

  TaskEither<ErrorDetail, int> insertCategory({required Category category}) {
    return tryCatchE(
      () async {
        final db = await database;
        final result = await db.insert(categoriesTable, category.toJson());

        return right(result);
      },
      (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace),
    );
  }
}
