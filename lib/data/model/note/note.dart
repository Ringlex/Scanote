import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note/data/model/bool_int_converter.dart';
import 'package:note/data/model/note/checklist_item.dart';
import 'package:note/data/model/note/note_images.dart';

part 'note.freezed.dart';
part 'note.g.dart';

@freezed
abstract class Note with _$Note {
  factory Note({
    int? id,
    required String title,
    String? todoList,
    String? noteContents,
    @BoolIntConverter() @Default(false) bool isProtected,
    int? categoryId,
    @BoolIntConverter() @Default(false) bool isFavorite,
    DateTime? date,
    DateTime? deletedAt,
    String? imagePaths,
    String? uuid,
    DateTime? updatedAt,
  }) = _Note;

  Note._();

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  bool get isDeleted => deletedAt != null;

  bool get isChecklist => todoList != null;

  bool get isLocked => isProtected;

  List<String> get imageNames => NoteImages.decode(imagePaths);

  bool get hasImages => imageNames.isNotEmpty;

  List<ChecklistItem> get checklistItems => Checklist.decode(todoList);

  int get checklistDoneCount => checklistItems.where((item) => item.isDone).length;

  bool get isChecklistCompleted {
    final items = checklistItems;

    return items.isNotEmpty && items.every((item) => item.isDone);
  }

  String get searchableText =>
      [title, if (!isProtected) noteContents ?? '', for (final item in checklistItems) item.label].join('\n');
}
