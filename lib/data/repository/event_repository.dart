import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';
import 'package:note/core/fpdarts.dart';
import 'package:note/data/database/db_helper.dart';
import 'package:note/data/model/error_detail.dart';
import 'package:note/data/model/event/event.dart';
import 'package:note/data/notifications/notification_service.dart';

class EventRepository {
  EventRepository({required DBHelper dbHelper, required NotificationService notificationService})
    : _dbHelper = dbHelper,
      _notificationService = notificationService;

  final DBHelper _dbHelper;
  final NotificationService _notificationService;

  TaskEither<ErrorDetail, List<Event>> getEvents() => _dbHelper.getEvents();

  TaskEither<ErrorDetail, Event> saveEvent({required Event event}) {
    final id = event.id;
    final saved = id == null
        ? _dbHelper.insertEvent(event: event).map((insertedId) => event.copyWith(id: insertedId))
        : _dbHelper.updateEvent(event: event).map((_) => event);

    return saved.flatMap(_applyReminder);
  }

  TaskEither<ErrorDetail, int> deleteEvent({required int id}) {
    return _dbHelper
        .deleteEvent(id: id)
        .flatMap(
          (deletedRows) => tryCatchE(() async {
            await _notificationService.cancelReminder(id);

            return right(deletedRows);
          }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace)),
        );
  }

  TaskEither<ErrorDetail, int> rescheduleReminders() {
    return getEvents().flatMap(
      (events) => tryCatchE(() async {
        final now = DateTime.now();
        var rescheduled = 0;

        for (final event in events) {
          final remindAt = event.remindAt;

          if (event.id == null || remindAt == null || !remindAt.isAfter(now)) {
            continue;
          }

          await _notificationService.scheduleReminder(
            id: event.id!,
            title: event.title,
            body: _reminderBody(event),
            remindAt: remindAt,
          );

          rescheduled++;
        }

        return right(rescheduled);
      }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace)),
    );
  }

  TaskEither<ErrorDetail, Event> _applyReminder(Event event) {
    return tryCatchE(() async {
      final remindAt = event.remindAt;

      if (remindAt == null) {
        await _notificationService.cancelReminder(event.id!);
      } else {
        await _notificationService.scheduleReminder(
          id: event.id!,
          title: event.title,
          body: _reminderBody(event),
          remindAt: remindAt,
        );
      }

      return right(event);
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  String _reminderBody(Event event) {
    final startsAt = DateFormat.Hm().format(event.startAt);
    final description = event.description;

    return description == null || description.isEmpty ? startsAt : '$startsAt · $description';
  }
}
