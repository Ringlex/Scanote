import 'package:flutter/foundation.dart';
import 'package:note/data/model/note/note_title.dart';

@immutable
class SharedText {
  const SharedText({required this.text, this.subject});

  final String text;

  final String? subject;

  String get suggestedTitle {
    final trimmedSubject = subject?.trim() ?? '';

    if (trimmedSubject.isNotEmpty) {
      return trimmedSubject;
    }

    return NoteTitle.fromText(text);
  }
}
