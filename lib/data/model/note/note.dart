import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note/data/model/bool_int_converter.dart';
import 'package:note/data/model/note/checklist_item.dart';

part 'note.freezed.dart';
part 'note.g.dart';

@freezed
class Note with _$Note {
  factory Note({
    int? id,
    required String title,
    String? todoList,
    String? noteContents,
    String? password,
    int? categoryId,
    @BoolIntConverter() @Default(false) bool isFavorite,
  }) = _Note;

  Note._();

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  bool get isChecklist => todoList != null;

  List<ChecklistItem> get checklistItems => Checklist.decode(todoList);
}
