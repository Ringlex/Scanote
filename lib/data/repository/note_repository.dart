import 'package:fpdart/fpdart.dart';
import 'package:note/data/database/db_helper.dart';
import 'package:note/data/model/categories/category.dart';
import 'package:note/data/model/error_detail.dart';
import 'package:note/data/model/note/note.dart';

class NoteRepository {
  NoteRepository({
    required DBHelper dbHelper,
  }) : _dbHelper = dbHelper;

  final DBHelper _dbHelper;

  TaskEither<ErrorDetail, List<Note>> getNotes() => _dbHelper.getNotes();

  TaskEither<ErrorDetail, List<Category>> getCategories() => _dbHelper.getCategories();

  TaskEither<ErrorDetail, Note> saveNote({required Note note}) {
    final id = note.id;

    return id == null
        ? _dbHelper.insertNote(note: note).map((insertedId) => note.copyWith(id: insertedId))
        : _dbHelper.updateNote(note: note).map((_) => note);
  }

  TaskEither<ErrorDetail, Category> resolveCategory({required String name}) {
    return _dbHelper.getCategoryByName(name: name).flatMap(
          (category) => category != null
              ? TaskEither<ErrorDetail, Category>.of(category)
              : _dbHelper.insertCategory(category: Category(name: name)).map((id) => Category(id: id, name: name)),
        );
  }
}
