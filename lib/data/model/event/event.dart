import 'package:freezed_annotation/freezed_annotation.dart';

part 'event.freezed.dart';
part 'event.g.dart';

@freezed
abstract class Event with _$Event {
  factory Event({
    int? id,
    required String title,
    String? description,
    required DateTime startAt,
    DateTime? remindAt,
  }) = _Event;

  Event._();

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  bool get hasReminder => remindAt != null;

  DateTime get day => DateTime(startAt.year, startAt.month, startAt.day);
}
