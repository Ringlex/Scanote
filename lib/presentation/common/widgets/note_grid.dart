import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/data/model/note/note.dart';
import 'package:note/presentation/common/app_message.dart';
import 'package:note/presentation/common/dimen.dart';
import 'package:note/presentation/screens/calendar/bloc/calendar_bloc.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';
import 'package:note/presentation/screens/note_details/note_details_argument.dart';
import 'package:note/presentation/screens/note_details/note_details_screen.dart';

class NoteGrid extends StatelessWidget {
  const NoteGrid({required this.notes, required this.categoryNameOf, super.key});

  final List<Note> notes;
  final String? Function(Note note) categoryNameOf;

  static const _columnCount = 2;
  static const _cardRatio = 1.2;
  static const _bottomPadding = 96.0;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(Insets.large, Insets.large, Insets.large, _bottomPadding),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _columnCount,
          crossAxisSpacing: Insets.medium,
          mainAxisSpacing: Insets.medium,
          childAspectRatio: _cardRatio,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];

          return NoteCard(note: note, categoryName: categoryNameOf(note));
        },
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  const NoteCard({required this.note, required this.categoryName, super.key});

  final Note note;
  final String? categoryName;

  static const _cornerRadius = 16.0;
  static const _titleLines = 3;
  static const _favoriteIconSize = 18.0;
  static const _completedIconSize = 20.0;
  static const _lockIconSize = 18.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.cardColor,
      borderRadius: BorderRadius.circular(_cornerRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _onNotePressed(context),
        onLongPress: () => _onDeletePressed(context),
        child: Padding(
          padding: const EdgeInsets.all(Insets.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      maxLines: _titleLines,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium!.copyWith(color: context.palette.textOnPrimaryColor),
                    ),
                  ),
                  if (note.isLocked) ...[
                    HorizontalGap.xSmall,
                    Tooltip(
                      message: context.translations.noteLocked,
                      child: Icon(Icons.lock, size: _lockIconSize, color: context.palette.inactiveColor),
                    ),
                  ],

                  if (note.isChecklistCompleted) ...[
                    HorizontalGap.xSmall,
                    Tooltip(
                      message: context.translations.homeChecklistCompleted,
                      child: Icon(Icons.check_circle, size: _completedIconSize, color: context.palette.accentColor),
                    ),
                  ],
                  if (note.isFavorite) ...[
                    HorizontalGap.xSmall,
                    Icon(Icons.favorite, size: _favoriteIconSize, color: context.palette.accentColor),
                  ],
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (note.isChecklist) ...[_ChecklistProgress(note: note), Gap.small],
                  if (categoryName != null) _CategoryBadge(name: categoryName!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNotePressed(BuildContext context) {
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

  void _onDeletePressed(BuildContext context) {
    final id = note.id;

    if (id == null) {
      return;
    }

    final homeBloc = context.read<HomeBloc>();

    homeBloc.add(HomeEvent.onNoteDeleted(noteId: id));

    showAppMessage(
      context,
      message: context.translations.noteMovedToBin,
      isError: false,
      actionLabel: context.translations.commonUndo,
      onAction: () => homeBloc.add(HomeEvent.onNoteRestored(noteId: id)),
    );
  }
}

class _ChecklistProgress extends StatelessWidget {
  const _ChecklistProgress({required this.note});

  final Note note;

  static const _iconSize = 16.0;

  @override
  Widget build(BuildContext context) {
    final items = note.checklistItems;
    final isCompleted = note.isChecklistCompleted;
    final color = isCompleted ? context.palette.accentColor : context.palette.inactiveColor;

    return Row(
      children: [
        Icon(isCompleted ? Icons.task_alt : Icons.checklist, size: _iconSize, color: color),
        HorizontalGap.xSmall,
        Text(
          context.translations.homeChecklistProgress(note.checklistDoneCount, items.length),
          style: context.textTheme.labelSmall!.copyWith(color: color),
        ),
      ],
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.name});

  final String name;

  static const _cornerRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Insets.small, vertical: Insets.xSmall),
      decoration: BoxDecoration(color: context.palette.accentColor, borderRadius: BorderRadius.circular(_cornerRadius)),
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.titleSmall!.copyWith(color: context.palette.primaryColor),
      ),
    );
  }
}
