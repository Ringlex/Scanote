part of 'home_bloc.dart';

@freezed
sealed class HomeEvent with _$HomeEvent {
  const factory HomeEvent.onInitiated() = _OnInitiated;

  const factory HomeEvent.onNoteSubmitted({
    required String title,
    required String contents,
    int? id,
    String? categoryName,
    List<ChecklistItem>? checklistItems,
    DateTime? date,
    @Default(false) bool isProtected,
    @Default(<String>[]) List<String> imageNames,
  }) = _OnNoteSubmitted;

  const factory HomeEvent.onNoteDeleted({required int noteId}) = _OnNoteDeleted;

  const factory HomeEvent.onNoteRestored({required int noteId}) = _OnNoteRestored;

  const factory HomeEvent.onNotePurged({required int noteId}) = _OnNotePurged;

  const factory HomeEvent.onBinEmptied() = _OnBinEmptied;

  const factory HomeEvent.onFavoriteToggled({required int noteId}) = _OnFavoriteToggled;

  const factory HomeEvent.onSearchChanged({required String query}) = _OnSearchChanged;

  const factory HomeEvent.onCategoryCreated({required String name}) = _OnCategoryCreated;

  const factory HomeEvent.onCategoryRenamed({required int id, required String name}) = _OnCategoryRenamed;

  const factory HomeEvent.onCategoryDeleted({required int id}) = _OnCategoryDeleted;

  const factory HomeEvent.onChecklistItemToggled({required int noteId, required int itemIndex}) =
      _OnChecklistItemToggled;
}
