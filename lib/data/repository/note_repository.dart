import 'package:fpdart/fpdart.dart';
import 'package:note/data/database/db_helper.dart';
import 'package:note/data/model/categories/category.dart';
import 'package:note/data/model/error_detail.dart';
import 'package:note/data/model/note/note.dart';

class NoteRepository {
  NoteRepository({required DBHelper dbHelper}) : _dbHelper = dbHelper;

  final DBHelper _dbHelper;

  TaskEither<ErrorDetail, List<Note>> getNotes() => _dbHelper.getNotes();

  TaskEither<ErrorDetail, List<Category>> getCategories() => _dbHelper.getCategories();

  TaskEither<ErrorDetail, Note> saveNote({required Note note}) {
    final id = note.id;

    return id == null
        ? _dbHelper.insertNote(note: note).map((insertedId) => note.copyWith(id: insertedId))
        : _dbHelper.updateNote(note: note).map((_) => note);
  }

  TaskEither<ErrorDetail, List<Note>> getDeletedNotes() => _dbHelper.getDeletedNotes();

  TaskEither<ErrorDetail, int> countDroppedPins() => _dbHelper.countDroppedPins();

  TaskEither<ErrorDetail, int> clearDroppedPins() => _dbHelper.clearDroppedPins();

  TaskEither<ErrorDetail, int> deleteNote({required int id}) => _dbHelper.softDeleteNote(id: id);

  TaskEither<ErrorDetail, int> restoreNote({required int id}) => _dbHelper.restoreNote(id: id);

  TaskEither<ErrorDetail, int> purgeNote({required int id}) => _dbHelper.purgeNote(id: id);

  TaskEither<ErrorDetail, int> emptyBin() => _dbHelper.purgeBin();

  TaskEither<ErrorDetail, int> purgeExpiredBin() =>
      _dbHelper.purgeBin(deletedBefore: DateTime.now().subtract(DBHelper.binRetention));

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
