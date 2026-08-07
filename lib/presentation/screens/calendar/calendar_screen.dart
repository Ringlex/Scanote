import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/data/model/event/event.dart';
import 'package:note/data/model/note/note.dart';
import 'package:note/presentation/common/dimen.dart';
import 'package:note/presentation/screens/calendar/bloc/calendar_bloc.dart';
import 'package:note/presentation/screens/event_editor/event_editor_argument.dart';
import 'package:note/presentation/screens/dashboard/widgets/dashboard_sliver_app_bar.dart';
import 'package:note/presentation/screens/event_editor/event_editor_screen.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';
import 'package:note/presentation/screens/note_details/note_details_argument.dart';
import 'package:note/presentation/screens/note_details/note_details_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatelessWidget {
  static const routeName = '/calendar';

  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.primaryColor,
      body: BlocBuilder<CalendarBloc, CalendarState>(
        buildWhen: (previous, current) =>
            previous.events != current.events ||
            previous.selectedDay != current.selectedDay ||
            previous.focusedDay != current.focusedDay,
        builder: (context, calendarState) => BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) => previous.notes != current.notes,
          builder: (context, homeState) => SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                const DashboardSliverAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _Calendar(state: calendarState, homeState: homeState),
                      Gap.medium,
                      _SelectedDayHeader(day: calendarState.selectedDay),
                    ],
                  ),
                ),
                _DayContent(
                  events: calendarState.selectedDayEvents,
                  notes: homeState.notesOn(calendarState.selectedDay),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar({required this.state, required this.homeState});

  final CalendarState state;
  final HomeState homeState;

  static final _firstDay = DateTime.utc(2000);
  static final _lastDay = DateTime.utc(2100, 12, 31);

  @override
  Widget build(BuildContext context) {
    return TableCalendar<Object>(
      firstDay: _firstDay,
      lastDay: _lastDay,
      focusedDay: state.focusedDay,
      currentDay: DateTime.now(),
      locale: context.translations.localeName,
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableGestures: AvailableGestures.horizontalSwipe,
      selectedDayPredicate: (day) => isSameDay(state.selectedDay, day),

      eventLoader: (day) => [...state.eventsOf(day), ...homeState.notesOn(day)],
      onDaySelected: (selectedDay, focusedDay) => context.read<CalendarBloc>().add(
        CalendarEvent.onDaySelected(selectedDay: selectedDay, focusedDay: focusedDay),
      ),
      onPageChanged: (focusedDay) =>
          context.read<CalendarBloc>().add(CalendarEvent.onFocusedDayChanged(focusedDay: focusedDay)),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: context.textTheme.titleMedium!.copyWith(color: context.palette.textOnPrimaryColor),
        leftChevronIcon: Icon(Icons.chevron_left, color: context.palette.textOnPrimaryColor),
        rightChevronIcon: Icon(Icons.chevron_right, color: context.palette.textOnPrimaryColor),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: context.textTheme.titleSmall!.copyWith(color: context.palette.inactiveColor),
        weekendStyle: context.textTheme.titleSmall!.copyWith(color: context.palette.inactiveColor),
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle: context.textTheme.bodyMedium!.copyWith(color: context.palette.textOnPrimaryColor),
        weekendTextStyle: context.textTheme.bodyMedium!.copyWith(color: context.palette.textOnPrimaryColor),
        outsideTextStyle: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
        todayTextStyle: context.textTheme.bodyMedium!.copyWith(color: context.palette.textOnPrimaryColor),
        selectedTextStyle: context.textTheme.bodyMedium!.copyWith(color: context.palette.primaryColor),
        todayDecoration: BoxDecoration(color: context.palette.cardColor, shape: BoxShape.circle),
        selectedDecoration: BoxDecoration(color: context.palette.accentColor, shape: BoxShape.circle),
        markerDecoration: BoxDecoration(color: context.palette.accentColor, shape: BoxShape.circle),
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

class _DayContent extends StatelessWidget {
  const _DayContent({required this.events, required this.notes});

  final List<Event> events;
  final List<Note> notes;

  static const _bottomPadding = 96.0;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty && notes.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(Insets.xLarge),
            child: Text(
              context.translations.calendarEmpty,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(Insets.large, Insets.medium, Insets.large, _bottomPadding),
      sliver: SliverList.separated(
        itemCount: events.length + notes.length,
        separatorBuilder: (_, _) => Gap.small,
        itemBuilder: (context, index) =>
            index < events.length ? _EventTile(event: events[index]) : _NoteTile(note: notes[index - events.length]),
      ),
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
    return Dismissible(
      key: ValueKey(event.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => context.read<CalendarBloc>().add(CalendarEvent.onEventDeleted(id: event.id!)),
      background: const _DeleteBackground(),
      child: _buildTile(context),
    );
  }

  Widget _buildTile(BuildContext context) {
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
                      style: context.textTheme.bodyLarge!.copyWith(color: context.palette.textOnPrimaryColor),
                    ),
                    if (description != null && description.isNotEmpty) ...[
                      Gap.xSmall,
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
                      ),
                    ],
                  ],
                ),
              ),
              if (event.hasReminder) ...[
                HorizontalGap.small,
                Icon(Icons.notifications_active_outlined, size: _iconSize, color: context.palette.inactiveColor),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    if (event.id == null) {
      return false;
    }

    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.translations.eventEditorDeleteTitle),
        content: Text(context.translations.eventEditorDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.translations.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: context.palette.errorColor),
            child: Text(context.translations.commonDelete),
          ),
        ],
      ),
    );

    return isConfirmed ?? false;
  }

  void _onEventPressed(BuildContext context) {
    context.push(
      EventEditorScreen.routeName,
      extra: EventEditorArgument(calendarBloc: context.read<CalendarBloc>(), event: event),
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note});

  final Note note;

  static const _cornerRadius = 16.0;
  static const _iconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.cardColor,
      borderRadius: BorderRadius.circular(_cornerRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _onPressed(context),
        child: Padding(
          padding: const EdgeInsets.all(Insets.large),
          child: Row(
            children: [
              Icon(Icons.sticky_note_2_outlined, size: _iconSize, color: context.palette.accentColor),
              HorizontalGap.medium,
              Expanded(
                child: Text(
                  note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyLarge!.copyWith(color: context.palette.textOnPrimaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onPressed(BuildContext context) {
    final id = note.id;

    if (id == null) {
      return;
    }

    context.push(
      NoteDetailsScreen.routeName,
      extra: NoteDetailsArgument(
        homeBloc: context.read<HomeBloc>(),
        calendarBloc: context.read<CalendarBloc>(),
        noteId: id,
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  static const _cornerRadius = 16.0;
  static const _iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: Insets.xLarge),
      decoration: BoxDecoration(color: context.palette.errorColor, borderRadius: BorderRadius.circular(_cornerRadius)),
      child: Icon(Icons.delete_outline, size: _iconSize, color: context.palette.textOnPrimaryColor),
    );
  }
}
