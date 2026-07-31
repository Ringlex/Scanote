import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/data/model/event/event.dart';
import 'package:note/presentation/common/dimen.dart';
import 'package:note/presentation/screens/calendar/bloc/calendar_bloc.dart';
import 'package:note/presentation/screens/event_editor/event_editor_argument.dart';
import 'package:note/presentation/screens/event_editor/event_editor_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatelessWidget {
  static const routeName = '/calendar';

  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.primaryColor,
      body: BlocBuilder<CalendarBloc, CalendarState>(
        builder: (context, state) => Column(
          children: [
            _Calendar(state: state),
            Gap.medium,
            _SelectedDayHeader(day: state.selectedDay),
            Expanded(child: _EventList(events: state.selectedDayEvents)),
          ],
        ),
      ),
    );
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar({required this.state});

  final CalendarState state;

  static final _firstDay = DateTime.utc(2000);
  static final _lastDay = DateTime.utc(2100, 12, 31);

  @override
  Widget build(BuildContext context) {
    return TableCalendar<Event>(
      firstDay: _firstDay,
      lastDay: _lastDay,
      focusedDay: state.focusedDay,
      currentDay: DateTime.now(),
      locale: context.translations.localeName,
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableGestures: AvailableGestures.horizontalSwipe,
      selectedDayPredicate: (day) => isSameDay(state.selectedDay, day),
      eventLoader: state.eventsOf,
      onDaySelected: (selectedDay, focusedDay) => context.read<CalendarBloc>().add(
            CalendarEvent.onDaySelected(selectedDay: selectedDay, focusedDay: focusedDay),
          ),
      onPageChanged: (focusedDay) => context.read<CalendarBloc>().add(
            CalendarEvent.onFocusedDayChanged(focusedDay: focusedDay),
          ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle:
            context.textTheme.titleMedium!.copyWith(color: context.palette.textOnPrimaryColor),
        leftChevronIcon: Icon(Icons.chevron_left, color: context.palette.textOnPrimaryColor),
        rightChevronIcon: Icon(Icons.chevron_right, color: context.palette.textOnPrimaryColor),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: context.textTheme.titleSmall!.copyWith(color: context.palette.inactiveColor),
        weekendStyle: context.textTheme.titleSmall!.copyWith(color: context.palette.inactiveColor),
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle:
            context.textTheme.bodyMedium!.copyWith(color: context.palette.textOnPrimaryColor),
        weekendTextStyle:
            context.textTheme.bodyMedium!.copyWith(color: context.palette.textOnPrimaryColor),
        outsideTextStyle:
            context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
        todayTextStyle:
            context.textTheme.bodyMedium!.copyWith(color: context.palette.textOnPrimaryColor),
        selectedTextStyle:
            context.textTheme.bodyMedium!.copyWith(color: context.palette.primaryColor),
        todayDecoration: BoxDecoration(
          color: context.palette.cardColor,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: context.palette.accentColor,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: context.palette.accentColor,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
      ),
    );
  }
}

class _SelectedDayHeader extends StatelessWidget {
  const _SelectedDayHeader({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Insets.large),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          DateFormat.yMMMMEEEEd(context.translations.localeName).format(day),
          style: context.textTheme.titleSmall!.copyWith(color: context.palette.inactiveColor),
        ),
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  const _EventList({required this.events});

  final List<Event> events;

  static const _bottomPadding = 96.0;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Insets.xLarge),
          child: Text(
            context.translations.calendarEmpty,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(Insets.large, Insets.medium, Insets.large, _bottomPadding),
      itemCount: events.length,
      separatorBuilder: (_, __) => Gap.small,
      itemBuilder: (context, index) => _EventTile(event: events[index]),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final Event event;

  static const _cornerRadius = 16.0;
  static const _iconSize = 16.0;

  @override
  Widget build(BuildContext context) {
    final description = event.description;

    return Material(
      color: context.palette.cardColor,
      borderRadius: BorderRadius.circular(_cornerRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _onEventPressed(context),
        child: Padding(
          padding: const EdgeInsets.all(Insets.large),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.Hm().format(event.startAt),
                style: context.textTheme.titleMedium!.copyWith(color: context.palette.accentColor),
              ),
              HorizontalGap.medium,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyLarge!
                          .copyWith(color: context.palette.textOnPrimaryColor),
                    ),
                    if (description != null && description.isNotEmpty) ...[
                      Gap.xSmall,
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium!
                            .copyWith(color: context.palette.inactiveColor),
                      ),
                    ],
                  ],
                ),
              ),
              if (event.hasReminder) ...[
                HorizontalGap.small,
                Icon(
                  Icons.notifications_active_outlined,
                  size: _iconSize,
                  color: context.palette.inactiveColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _onEventPressed(BuildContext context) {
    context.push(
      EventEditorScreen.routeName,
      extra: EventEditorArgument(
        calendarBloc: context.read<CalendarBloc>(),
        event: event,
      ),
    );
  }
}
