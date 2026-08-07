import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:note/data/model/note/checklist_item.dart';
import 'package:note/data/model/note/note.dart';

@immutable
class SharedNote {
  const SharedNote({required this.title, this.contents, this.items = const [], this.categoryName});

  final String title;
  final String? contents;
  final List<ChecklistItem> items;
  final String? categoryName;

  bool get isChecklist => items.isNotEmpty;
}

abstract class NoteShare {
  const NoteShare._();

  static const _kind = 'note';
  static const _version = 1;

  static const maxPayloadLength = 1200;

  static String encode({required Note note, String? categoryName}) {
    return jsonEncode({
      'k': _kind,
      'v': _version,
      't': note.title,
      if (!note.isChecklist && (note.noteContents ?? '').isNotEmpty) 'c': note.noteContents,
      if (note.isChecklist)
        'i': [
          for (final item in note.checklistItems) {'l': item.label, if (item.isDone) 'd': 1},
        ],
      if (categoryName != null && categoryName.isNotEmpty) 'g': categoryName,
    });
  }

  static SharedNote? decode(String payload) {
    try {
      final decoded = jsonDecode(payload);

      if (decoded is! Map<String, dynamic> || decoded['k'] != _kind || decoded['v'] != _version) {
        return null;
      }

      final title = decoded['t'];

      if (title is! String || title.trim().isEmpty) {
        return null;
      }

      return SharedNote(
        title: title,
        contents: decoded['c'] is String ? decoded['c'] as String : null,
        items: _decodeItems(decoded['i']),
        categoryName: decoded['g'] is String ? decoded['g'] as String : null,
      );
    } catch (_) {
      return null;
    }
  }

  static List<ChecklistItem> _decodeItems(Object? raw) {
    if (raw is! List) {
      return const [];
    }

    return [
      for (final entry in raw)
        if (entry is Map && entry['l'] is String) ChecklistItem(label: entry['l'] as String, isDone: entry['d'] == 1),
    ];
  }
}
