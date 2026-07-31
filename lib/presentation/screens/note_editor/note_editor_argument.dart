import 'package:flutter/foundation.dart';
import 'package:note/data/model/note/note.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';

@immutable
class NoteEditorArgument {
  const NoteEditorArgument({
    required this.homeBloc,
    this.note,
  });

  final HomeBloc homeBloc;

  final Note? note;
}
