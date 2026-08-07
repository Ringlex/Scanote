abstract class NoteTitle {
  const NoteTitle._();

  static const limit = 60;

  static String fromText(String text) {
    final firstLine = text.trim().split('\n').first.trim();

    return firstLine.length <= limit ? firstLine : '${firstLine.substring(0, limit).trimRight()}…';
  }
}
