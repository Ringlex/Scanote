import 'package:flutter/foundation.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';

@immutable
class NoteDetailsArgument {
  const NoteDetailsArgument({
    required this.homeBloc,
    required this.noteId,
  });

  final HomeBloc homeBloc;
  final int noteId;
}
