import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';
import 'package:note/presentation/screens/note_editor/note_editor_argument.dart';
import 'package:note/presentation/screens/note_editor/note_editor_screen.dart';

Widget noteEditorRoute(GoRouterState state) {
  final argument = state.extra! as NoteEditorArgument;

  return BlocProvider<HomeBloc>.value(
    value: argument.homeBloc,
    child: NoteEditorScreen(note: argument.note),
  );
}
