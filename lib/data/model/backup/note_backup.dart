import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:note/data/model/note/checklist_item.dart';

@immutable
class BackupNote {
  const BackupNote({
    required this.title,
    this.contents,
    this.items = const [],
    this.categoryName,
    this.isFavorite = false,
    this.date,
    this.isProtected = false,
  });

  final String title;
  final String? contents;
  final List<ChecklistItem> items;
  final String? categoryName;
  final bool isFavorite;
  final DateTime? date;

  final bool isProtected;

  bool get isChecklist => items.isNotEmpty;

  String get signature => [
    title.trim(),

    if (!isProtected) contents?.trim() ?? '',
    for (final item in items) item.label.trim(),
    date?.toIso8601String() ?? '',
  ].join(' ');
}

@immutable
class NoteBackup {
  const NoteBackup({required this.exportedAt, required this.notes, required this.categoryNames, this.salt});

  final DateTime exportedAt;
  final List<BackupNote> notes;

  final List<String> categoryNames;

  final List<int>? salt;

  bool get hasProtectedNotes => notes.any((note) => note.isProtected);

  static const _kind = 'note-backup';

  static const _version = 2;
  static const _readableVersions = [1, 2];

  String encode() {
    return jsonEncode({
      'kind': _kind,
      'version': _version,
      'exportedAt': exportedAt.toIso8601String(),
      if (salt != null) 'salt': base64Encode(salt!),
      'categories': categoryNames,
      'notes': [
        for (final note in notes)
          {
            'title': note.title,
            if (note.contents != null) 'contents': note.contents,
            if (note.isChecklist)
              'items': [
                for (final item in note.items) {'label': item.label, 'isDone': item.isDone},
              ],
            if (note.categoryName != null) 'category': note.categoryName,
            if (note.isFavorite) 'isFavorite': true,
            if (note.isProtected) 'isProtected': true,
            if (note.date != null) 'date': note.date!.toIso8601String(),
          },
      ],
    });
  }

  static NoteBackup? decode(String payload) {
    try {
      final decoded = jsonDecode(payload);

      if (decoded is! Map<String, dynamic> ||
          decoded['kind'] != _kind ||
          !_readableVersions.contains(decoded['version'])) {
        return null;
      }

      final rawSalt = decoded['salt'] as String?;

      return NoteBackup(
        exportedAt: DateTime.tryParse(decoded['exportedAt'] as String? ?? '') ?? DateTime.now(),
        notes: _decodeNotes(decoded['notes']),
        categoryNames: _decodeCategories(decoded['categories']),
        salt: rawSalt == null ? null : base64Decode(rawSalt),
      );
    } catch (_) {
      return null;
    }
  }

  static List<BackupNote> _decodeNotes(Object? raw) {
    if (raw is! List) {
      return const [];
    }

    return [
      for (final entry in raw)
        if (entry is Map && entry['title'] is String && (entry['title'] as String).trim().isNotEmpty)
          BackupNote(
            title: entry['title'] as String,
            contents: entry['contents'] is String ? entry['contents'] as String : null,
            items: _decodeItems(entry['items']),
            categoryName: entry['category'] is String ? entry['category'] as String : null,
            isFavorite: entry['isFavorite'] == true,
            isProtected: entry['isProtected'] == true,
            date: entry['date'] is String ? DateTime.tryParse(entry['date'] as String) : null,
          ),
    ];
  }

  static List<ChecklistItem> _decodeItems(Object? raw) {
    if (raw is! List) {
      return const [];
    }

    return [
      for (final entry in raw)
        if (entry is Map && entry['label'] is String)
          ChecklistItem(label: entry['label'] as String, isDone: entry['isDone'] == true),
    ];
  }

  static List<String> _decodeCategories(Object? raw) {
    if (raw is! List) {
      return const [];
    }

    return [
      for (final entry in raw)
        if (entry is String && entry.trim().isNotEmpty) entry,
    ];
  }
}
