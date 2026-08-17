import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:note/data/model/note/checklist_item.dart';

/// One note as it travels between devices.
///
/// Unlike a backup entry this carries a [uuid] and an [updatedAt], which is
/// what lets the other side tell an edit from a note it has never seen, and a
/// deletion from an absence.
@immutable
class SyncNote {
  const SyncNote({
    required this.uuid,
    required this.title,
    required this.updatedAt,
    this.contents,
    this.items = const [],
    this.categoryName,
    this.isFavorite = false,
    this.date,
    this.deletedAt,
  });

  final String uuid;
  final String title;
  final DateTime updatedAt;

  final String? contents;
  final List<ChecklistItem> items;
  final String? categoryName;
  final bool isFavorite;
  final DateTime? date;

  /// Set on a note that was thrown away. It still travels, or the phone that
  /// has not heard about the deletion would hand the note straight back.
  final DateTime? deletedAt;

  bool get isChecklist => items.isNotEmpty;

  bool get isDeleted => deletedAt != null;
}

/// The single file on Drive that both phones read and rewrite.
@immutable
class NoteSyncDocument {
  const NoteSyncDocument({required this.syncedAt, required this.notes, required this.categoryNames});

  final DateTime syncedAt;
  final List<SyncNote> notes;
  final List<String> categoryNames;

  /// What the other side looks like before it has ever been written to.
  static final empty = NoteSyncDocument(syncedAt: _epoch, notes: const [], categoryNames: const []);

  static final _epoch = DateTime.fromMillisecondsSinceEpoch(0);

  static const _kind = 'note-sync';
  static const _version = 1;

  String encode() {
    return jsonEncode({
      'kind': _kind,
      'version': _version,
      'syncedAt': syncedAt.toIso8601String(),
      'categories': categoryNames,
      'notes': [
        for (final note in notes)
          {
            'uuid': note.uuid,
            'title': note.title,
            'updatedAt': note.updatedAt.toIso8601String(),
            if (note.contents != null) 'contents': note.contents,
            if (note.isChecklist)
              'items': [
                for (final item in note.items) {'label': item.label, 'isDone': item.isDone},
              ],
            if (note.categoryName != null) 'category': note.categoryName,
            if (note.isFavorite) 'isFavorite': true,
            if (note.date != null) 'date': note.date!.toIso8601String(),
            if (note.deletedAt != null) 'deletedAt': note.deletedAt!.toIso8601String(),
          },
      ],
    });
  }

  /// Null when the file is not one of ours or cannot be read. The caller treats
  /// that as "nothing on the other side yet" rather than as a failure, so a
  /// half-written file cannot stop syncing for good.
  static NoteSyncDocument? decode(String payload) {
    try {
      final decoded = jsonDecode(payload);

      if (decoded is! Map<String, dynamic> || decoded['kind'] != _kind || decoded['version'] != _version) {
        return null;
      }

      return NoteSyncDocument(
        syncedAt: DateTime.tryParse(decoded['syncedAt'] as String? ?? '') ?? _epoch,
        notes: _decodeNotes(decoded['notes']),
        categoryNames: _decodeCategories(decoded['categories']),
      );
    } catch (_) {
      return null;
    }
  }

  static List<SyncNote> _decodeNotes(Object? raw) {
    if (raw is! List) {
      return const [];
    }

    return [
      for (final entry in raw)
        if (entry is Map && entry['uuid'] is String && entry['title'] is String)
          SyncNote(
            uuid: entry['uuid'] as String,
            title: entry['title'] as String,
            // A note with no readable clock would win or lose at random, so it
            // is treated as the oldest possible and only fills a gap.
            updatedAt: DateTime.tryParse(entry['updatedAt'] as String? ?? '') ?? _epoch,
            contents: entry['contents'] is String ? entry['contents'] as String : null,
            items: _decodeItems(entry['items']),
            categoryName: entry['category'] is String ? entry['category'] as String : null,
            isFavorite: entry['isFavorite'] == true,
            date: entry['date'] is String ? DateTime.tryParse(entry['date'] as String) : null,
            deletedAt: entry['deletedAt'] is String ? DateTime.tryParse(entry['deletedAt'] as String) : null,
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
