import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'checklist_item.freezed.dart';
part 'checklist_item.g.dart';

@freezed
abstract class ChecklistItem with _$ChecklistItem {
  const factory ChecklistItem({
    required String label,
    @Default(false) bool isDone,
  }) = _ChecklistItem;

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => _$ChecklistItemFromJson(json);
}

abstract class Checklist {
  const Checklist._();

  static List<ChecklistItem> decode(String? source) {
    if (source == null || source.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(source);

      return decoded is List
          ? decoded.whereType<Map<String, dynamic>>().map(ChecklistItem.fromJson).toList()
          : const [];
    } catch (_) {
      return const [];
    }
  }

  static String encode(List<ChecklistItem> items) => jsonEncode(items.map((item) => item.toJson()).toList());
}
