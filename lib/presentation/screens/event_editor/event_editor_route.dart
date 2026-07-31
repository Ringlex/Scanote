import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note/presentation/screens/calendar/bloc/calendar_bloc.dart';
import 'package:note/presentation/screens/event_editor/event_editor_argument.dart';
import 'package:note/presentation/screens/event_editor/event_editor_screen.dart';

Widget eventEditorRoute(GoRouterState state) {
  final argument = state.extra! as EventEditorArgument;

  return BlocProvider<CalendarBloc>.value(
    value: argument.calendarBloc,
    child: EventEditorScreen(event: argument.event),
  );
}
