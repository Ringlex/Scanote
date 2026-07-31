part of 'home_bloc.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    required StateType type,
    required StateType saveType,
    required HomeArgument argument,
    required List<Note> notes,
    required List<Category> categories,
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

  List<Note> get favoriteNotes => notes.where((note) => note.isFavorite).toList();

  String? categoryNameOf(Note note) =>
      categories.firstWhereOrNull((category) => category.id == note.categoryId)?.name;
}
