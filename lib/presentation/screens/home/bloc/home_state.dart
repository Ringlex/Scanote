part of 'home_bloc.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    required StateType type,
    required StateType saveType,
    required HomeArgument argument,
    required List<Note> notes,
    required List<Category> categories,

    @Default([]) List<Note> deletedNotes,
    @Default('') String query,
  }) = _HomeState;

  const HomeState._();

  factory HomeState.initial({required HomeArgument argument}) {
    return HomeState(
      type: StateType.loading,
      saveType: StateType.initial,
      argument: argument,
      notes: const [],
      categories: const [],
    );
  }

  bool get isSearching => query.trim().isNotEmpty;

  List<Note> get visibleNotes {
    if (query.trim().isEmpty) {
      return notes;
    }

    return notes.where((note) {
      final category = categoryNameOf(note) ?? '';

      return SearchMatch.matches(text: '${note.searchableText}\n$category', query: query);
    }).toList();
  }

  int noteCountOf(Category category) => notes.where((note) => note.categoryId == category.id).length;

  List<Note> notesOn(DateTime day) {
    return notes.where((note) {
      final date = note.date;

      return date != null && date.year == day.year && date.month == day.month && date.day == day.day;
    }).toList();
  }

  List<Note> get favoriteNotes => notes.where((note) => note.isFavorite).toList();

  String? categoryNameOf(Note note) => categories.firstWhereOrNull((category) => category.id == note.categoryId)?.name;
}
