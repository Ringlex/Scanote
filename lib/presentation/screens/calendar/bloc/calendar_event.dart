part of 'calendar_bloc.dart';

@freezed
class CalendarEvent with _$CalendarEvent {
  const factory CalendarEvent.onInitiated() = _OnInitiated;

  const factory CalendarEvent.onDaySelected({
    required DateTime selectedDay,
    required DateTime focusedDay,
  }) = _OnDaySelected;

  const factory CalendarEvent.onFocusedDayChanged({required DateTime focusedDay}) = _OnFocusedDayChanged;

  const factory CalendarEvent.onEventSubmitted({
    required String title,
    required DateTime startAt,
    int? id,
    String? description,
    DateTime? remindAt,
  }) = _OnEventSubmitted;

  const factory CalendarEvent.onEventDeleted({required int id}) = _OnEventDeleted;
}
