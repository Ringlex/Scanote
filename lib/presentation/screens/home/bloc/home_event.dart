part of 'home_bloc.dart';

@freezed
class HomeEvent with _$HomeEvent {
  const factory HomeEvent.onInitiated() = _OnInitiated;

  const factory HomeEvent.onNoteSubmitted({
    required String title,
    required String contents,
    int? id,
    String? categoryName,
    List<ChecklistItem>? checklistItems,
  }) = _OnNoteSubmitted;

  const factory HomeEvent.onFavoriteToggled({required int noteId}) = _OnFavoriteToggled;

  const factory HomeEvent.onChecklistItemToggled({
    required int noteId,
    required int itemIndex,
  }) = _OnChecklistItemToggled;
}
