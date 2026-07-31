import 'package:note/core/l10n/translations.dart';

enum ReminderOffset {
  none(null),
  atStart(Duration.zero),
  fiveMinutes(Duration(minutes: 5)),
  fifteenMinutes(Duration(minutes: 15)),
  thirtyMinutes(Duration(minutes: 30)),
  oneHour(Duration(hours: 1)),
  oneDay(Duration(days: 1));

  const ReminderOffset(this.duration);

  final Duration? duration;

  String label(Translations translations) => switch (this) {
        ReminderOffset.none => translations.reminderNone,
        ReminderOffset.atStart => translations.reminderAtStart,
        ReminderOffset.fiveMinutes => translations.reminderFiveMinutes,
        ReminderOffset.fifteenMinutes => translations.reminderFifteenMinutes,
        ReminderOffset.thirtyMinutes => translations.reminderThirtyMinutes,
        ReminderOffset.oneHour => translations.reminderOneHour,
        ReminderOffset.oneDay => translations.reminderOneDay,
      };

  DateTime? remindAtFor(DateTime startAt) {
    final duration = this.duration;

    return duration == null ? null : startAt.subtract(duration);
  }

  static ReminderOffset of({required DateTime startAt, DateTime? remindAt}) {
    if (remindAt == null) {
      return none;
    }

    final difference = startAt.difference(remindAt);

    return values.firstWhere(
      (offset) => offset.duration == difference,
      orElse: () => atStart,
    );
  }
}
