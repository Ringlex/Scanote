import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note/data/model/event/event.dart';
import 'package:note/data/repository/event_repository.dart';
import 'package:note/presentation/common/state_type.dart';
import 'package:note/presentation/screens/calendar/calendar_argument.dart';

part 'calendar_bloc.freezed.dart';
part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc({required CalendarArgument argument, required EventRepository eventRepository})
    : _eventRepository = eventRepository,
      super(CalendarState.initial(argument: argument)) {
    on<_OnInitiated>(_onInitiated);
    on<_OnDaySelected>(_onDaySelected);
    on<_OnFocusedDayChanged>(_onFocusedDayChanged);
    on<_OnEventSubmitted>(_onEventSubmitted);
    on<_OnEventDeleted>(_onEventDeleted);
  }

  final EventRepository _eventRepository;

  Future<void> _onInitiated(_OnInitiated event, Emitter<CalendarState> emit) async {
    emit(state.copyWith(type: StateType.loading));

    await _loadEvents(emit);
  }

  Future<void> _onDaySelected(_OnDaySelected event, Emitter<CalendarState> emit) async {
    emit(state.copyWith(selectedDay: event.selectedDay, focusedDay: event.focusedDay));
  }

  Future<void> _onFocusedDayChanged(_OnFocusedDayChanged event, Emitter<CalendarState> emit) async {
    emit(state.copyWith(focusedDay: event.focusedDay));
  }

  Future<void> _onEventSubmitted(_OnEventSubmitted event, Emitter<CalendarState> emit) async {
    emit(state.copyWith(saveType: StateType.loading));

    final duplicate = event.id == null ? state.duplicateOf(title: event.title, startAt: event.startAt) : null;

    if (duplicate != null) {
      emit(state.copyWith(saveType: StateType.success, selectedDay: duplicate.day));
      emit(state.copyWith(saveType: StateType.initial));

      return;
    }

    final result = await _eventRepository.saveEvent(event: _buildEvent(event)).run();

    await result.match((error) async => emit(state.copyWith(saveType: StateType.error)), (savedEvent) async {
      await _loadEvents(emit);

      emit(state.copyWith(saveType: StateType.success, selectedDay: savedEvent.day, focusedDay: savedEvent.day));
      emit(state.copyWith(saveType: StateType.initial));
    });
  }

  Future<void> _onEventDeleted(_OnEventDeleted event, Emitter<CalendarState> emit) async {
    emit(state.copyWith(saveType: StateType.loading));

    final result = await _eventRepository.deleteEvent(id: event.id).run();

    await result.match((error) async => emit(state.copyWith(saveType: StateType.error)), (_) async {
      await _loadEvents(emit);
      emit(state.copyWith(saveType: StateType.success));
      emit(state.copyWith(saveType: StateType.initial));
    });
  }

  Event _buildEvent(_OnEventSubmitted event) {
    final storedEvent = state.events.firstWhereOrNull((stored) => stored.id == event.id);
    final title = event.title.trim();
    final description = event.description?.trim();

    return (storedEvent ?? Event(title: title, startAt: event.startAt)).copyWith(
      title: title,
      description: description == null || description.isEmpty ? null : description,
      startAt: event.startAt,
      remindAt: event.remindAt,
    );
  }

  Future<void> _loadEvents(Emitter<CalendarState> emit) async {
    final result = await _eventRepository.getEvents().run();

    result.match(
      (error) => emit(state.copyWith(type: StateType.error)),
      (events) => emit(state.copyWith(type: events.isEmpty ? StateType.empty : StateType.loaded, events: events)),
    );
  }
}

bool _isSameDay(DateTime first, DateTime second) =>
    first.year == second.year && first.month == second.month && first.day == second.day;
