import 'package:flutter/foundation.dart';
import 'package:note/data/model/event/event.dart';
import 'package:note/presentation/screens/calendar/bloc/calendar_bloc.dart';

@immutable
class EventEditorArgument {
  const EventEditorArgument({
    required this.calendarBloc,
    this.event,
  });

  final CalendarBloc calendarBloc;

  final Event? event;
}
