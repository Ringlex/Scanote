import 'package:flutter/foundation.dart';

@immutable
class NoteDateMatch {
  const NoteDateMatch({required this.date, required this.text});

  final DateTime date;
  final String text;

  @override
  bool operator ==(Object other) => other is NoteDateMatch && other.date == date && other.text == text;

  @override
  int get hashCode => Object.hash(date, text);
}

abstract class NoteDates {
  const NoteDates._();

  static const defaultHour = 9;

  static final _isoPattern = RegExp(r'(\d{4})-(\d{1,2})-(\d{1,2})(?:[ T]+(\d{1,2}):(\d{2}))?');

  static final _dayFirstPattern = RegExp(
    r'(?<![\d.:/-])(\d{1,2})[./](\d{1,2})(?:[./](\d{2,4}))?(?:\s+(\d{1,2}):(\d{2}))?(?![\d/.-])',
  );

  static List<NoteDateMatch> parse(String source, {DateTime? today}) {
    final now = today ?? DateTime.now();
    final matches = <NoteDateMatch>[];

    for (final match in _isoPattern.allMatches(source)) {
      final date = _build(
        year: int.parse(match.group(1)!),
        month: int.parse(match.group(2)!),
        day: int.parse(match.group(3)!),
        hour: match.group(4),
        minute: match.group(5),
      );

      if (date != null) {
        matches.add(NoteDateMatch(date: date, text: match.group(0)!.trim()));
      }
    }

    final consumed = _isoPattern.allMatches(source).map((match) => match.start).toSet();

    for (final match in _dayFirstPattern.allMatches(source)) {
      if (consumed.any((start) => match.start >= start && match.start < start + 10)) {
        continue;
      }

      final date = _build(
        year: _resolveYear(match.group(3), now),
        month: int.parse(match.group(2)!),
        day: int.parse(match.group(1)!),
        hour: match.group(4),
        minute: match.group(5),
      );

      if (date != null) {
        matches.add(NoteDateMatch(date: date, text: match.group(0)!.trim()));
      }
    }

    matches.sort((first, second) => first.date.compareTo(second.date));

    return matches.toSet().toList();
  }

  static int _resolveYear(String? group, DateTime now) {
    if (group == null) {
      return now.year;
    }

    final year = int.parse(group);

    return year < 100 ? 2000 + year : year;
  }

  static DateTime? _build({required int year, required int month, required int day, String? hour, String? minute}) {
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return null;
    }

    var parsedHour = hour == null ? defaultHour : int.parse(hour);
    var parsedMinute = minute == null ? 0 : int.parse(minute);

    if (parsedHour > 23 || parsedMinute > 59) {
      parsedHour = defaultHour;
      parsedMinute = 0;
    }

    final date = DateTime(year, month, day, parsedHour, parsedMinute);

    return date.month == month && date.day == day ? date : null;
  }
}
