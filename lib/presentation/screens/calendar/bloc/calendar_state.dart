part of 'calendar_bloc.dart';

@freezed
class CalendarState with _$CalendarState {
  const factory CalendarState({
    required StateType type,
    required StateType saveType,
    required CalendarArgument argument,
    required List<Event> events,
    required DateTime focusedDay,
    required DateTime selectedDay,
  }) = _CalendarState;

  const CalendarState._();

  factory CalendarState.initial({required CalendarArgument argument}) {
    final today = DateTime.now();

    return CalendarState(
      type: StateType.loading,
      saveType: StateType.initial,
      argument: argument,
      events: const [],
      focusedDay: today,
      selectedDay: today,
    );
  }

  List<Event> eventsOf(DateTime day) =>
      events.where((event) => _isSameDay(event.startAt, day)).toList();

  List<Event> get selectedDayEvents => eventsOf(selectedDay);
}
