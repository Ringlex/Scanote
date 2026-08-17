import 'package:fpdart/fpdart.dart';
import 'package:note/core/uuid.dart';
import 'package:note/data/database/db_helper.dart';
import 'package:note/data/model/categories/category.dart';
import 'package:note/data/model/error_detail.dart';
import 'package:note/data/model/note/note.dart';
import 'package:note/data/scan/scan_image_store.dart';

class NoteRepository {
  NoteRepository({required DBHelper dbHelper, required ScanImageStore imageStore})
    : _dbHelper = dbHelper,
      _imageStore = imageStore;

  final DBHelper _dbHelper;
  final ScanImageStore _imageStore;

  TaskEither<ErrorDetail, List<Note>> getNotes() => _dbHelper.getNotes();

  TaskEither<ErrorDetail, List<Category>> getCategories() => _dbHelper.getCategories();

  TaskEither<ErrorDetail, Note> saveNote({required Note note}) {
    return _write(note.copyWith(uuid: note.uuid ?? Uuid.v4(), updatedAt: DateTime.now()));
  }

  TaskEither<ErrorDetail, Note> saveSyncedNote({required Note note}) => _write(note);

  TaskEither<ErrorDetail, Note> _write(Note note) {
    final id = note.id;

    return id == null
        ? _dbHelper.insertNote(note: note).map((insertedId) => note.copyWith(id: insertedId))
        : _dbHelper.updateNote(note: note).map((_) => note);
  }

  TaskEither<ErrorDetail, List<Note>> getDeletedNotes() => _dbHelper.getDeletedNotes();

  TaskEither<ErrorDetail, List<Note>> getAllNotes() => _dbHelper.getAllNotes();

  TaskEither<ErrorDetail, Note?> findNoteByUuid({required String uuid}) => _dbHelper.getNoteByUuid(uuid: uuid);

  TaskEither<ErrorDetail, int> countDroppedPins() => _dbHelper.countDroppedPins();

  TaskEither<ErrorDetail, int> clearDroppedPins() => _dbHelper.clearDroppedPins();

  TaskEither<ErrorDetail, int> deleteNote({required int id}) => _dbHelper.softDeleteNote(id: id);

  TaskEither<ErrorDetail, int> restoreNote({required int id}) => _dbHelper.restoreNote(id: id);

  TaskEither<ErrorDetail, int> purgeNote({required int id}) => _purging(_dbHelper.purgeNote(id: id));

  TaskEither<ErrorDetail, int> emptyBin() => _purging(_dbHelper.purgeBin());

  TaskEither<ErrorDetail, int> purgeExpiredBin() =>
      _purging(_dbHelper.purgeBin(deletedBefore: DateTime.now().subtract(DBHelper.binRetention)));

  TaskEither<ErrorDetail, int> _purging(TaskEither<ErrorDetail, List<String>> purge) {
    return purge.flatMap(
      (imageNames) => TaskEither.tryCatch(() async {
        await _imageStore.deleteAll(names: imageNames);

        return imageNames.length;
      }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace)),
    );
  }

  TaskEither<ErrorDetail, int> renameCategory({required Category category}) =>
      _dbHelper.updateCategory(category: category);

  TaskEither<ErrorDetail, int> deleteCategory({required int id}) => _dbHelper.deleteCategory(id: id);

  TaskEither<ErrorDetail, Category?> findCategory({required String name}) => _dbHelper.getCategoryByName(name: name);

  TaskEither<ErrorDetail, Category> resolveCategory({required String name}) {
    return _dbHelper
        .getCategoryByName(name: name)
        .flatMap(
          (category) => category != null
              ? TaskEither<ErrorDetail, Category>.of(category)
              : _dbHelper.insertCategory(category: Category(name: name)).map((id) => Category(id: id, name: name)),
        );
  }
}
