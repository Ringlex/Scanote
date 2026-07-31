import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';
import 'package:note/presentation/screens/note_details/note_details_argument.dart';
import 'package:note/presentation/screens/note_details/note_details_screen.dart';

Widget noteDetailsRoute(GoRouterState state) {
  final argument = state.extra! as NoteDetailsArgument;

  return BlocProvider<HomeBloc>.value(
    value: argument.homeBloc,
    child: NoteDetailsScreen(noteId: argument.noteId),
  );
}
