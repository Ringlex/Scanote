import 'dart:convert';

abstract class NoteImages {
  const NoteImages._();

  static List<String> decode(String? source) {
    if (source == null || source.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(source);

      return decoded is List ? decoded.whereType<String>().toList() : const [];
    } catch (_) {
      return const [];
    }
  }

  static String? encode(List<String> names) => names.isEmpty ? null : jsonEncode(names);
}
