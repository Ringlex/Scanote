import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/data/model/note/checklist_item.dart';
import 'package:note/data/model/note/note.dart';
import 'package:note/presentation/common/app_back_button.dart';
import 'package:note/presentation/common/dimen.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';
import 'package:note/presentation/screens/note_editor/note_editor_argument.dart';
import 'package:note/presentation/screens/note_editor/note_editor_screen.dart';

class NoteDetailsScreen extends StatelessWidget {
  static const routeName = '/note-details';

  const NoteDetailsScreen({
    required this.noteId,
    super.key,
  });

  final int noteId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final note = state.notes.firstWhereOrNull((note) => note.id == noteId);

        return Scaffold(
          backgroundColor: context.palette.primaryColor,
          appBar: AppBar(
            backgroundColor: context.palette.primaryColor,
            foregroundColor: context.palette.textOnPrimaryColor,
            leading: const AppBackButton(),
            actions: [
              if (note != null) ...[
                IconButton(
                  onPressed: () => _onFavoritePressed(context, note),
                  tooltip: note.isFavorite
                      ? context.translations.noteDetailsFavoriteRemove
                      : context.translations.noteDetailsFavoriteAdd,
                  icon: Icon(
                    note.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: context.palette.accentColor,
                  ),
                ),
                IconButton(
                  onPressed: () => _onEditPressed(context, note),
                  tooltip: context.translations.noteDetailsEdit,
                  icon: Icon(Icons.edit, color: context.palette.accentColor),
                ),
              ],
            ],
          ),
          body: note == null
              ? const _MissingNote()
              : _NoteDetails(
                  note: note,
                  categoryName: state.categoryNameOf(note),
                ),
        );
      },
    );
  }

  void _onFavoritePressed(BuildContext context, Note note) {
    context.read<HomeBloc>().add(HomeEvent.onFavoriteToggled(noteId: note.id!));
  }

  void _onEditPressed(BuildContext context, Note note) {
    context.push(
      NoteEditorScreen.routeName,
      extra: NoteEditorArgument(
        homeBloc: context.read<HomeBloc>(),
        note: note,
      ),
    );
  }
}

class _MissingNote extends StatelessWidget {
  const _MissingNote();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        context.translations.noteDetailsMissing,
        style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
      ),
    );
  }
}

class _NoteDetails extends StatelessWidget {
  const _NoteDetails({
    required this.note,
    required this.categoryName,
  });

  final Note note;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(Insets.xLarge, 0, Insets.xLarge, Insets.xxxLarge),
      children: [
        Text(
          note.title,
          style: context.textTheme.displaySmall!.copyWith(color: context.palette.textOnPrimaryColor),
        ),
        if (categoryName != null) ...[
          Gap.medium,
          Align(
            alignment: Alignment.centerLeft,
            child: _CategoryBadge(name: categoryName!),
          ),
        ],
        Gap.xLarge,
        if (note.isChecklist)
          _NoteChecklist(note: note)
        else
          SelectableText(
            note.noteContents ?? '',
            style: context.textTheme.bodyLarge!.copyWith(color: context.palette.textOnPrimaryColor),
          ),
      ],
    );
  }
}

class _NoteChecklist extends StatelessWidget {
  const _NoteChecklist({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final items = note.checklistItems;

    if (items.isEmpty) {
      return Text(
        context.translations.noteDetailsEmptyChecklist,
        style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
      );
    }

    return Column(
      children: [
        for (final (index, item) in items.indexed)
          _ChecklistTile(
            item: item,
            onChanged: () => context.read<HomeBloc>().add(
                  HomeEvent.onChecklistItemToggled(
                    noteId: note.id!,
                    itemIndex: index,
                  ),
                ),
          ),
      ],
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.item,
    required this.onChanged,
  });

  final ChecklistItem item;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: item.isDone,
      onChanged: (_) => onChanged(),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: context.palette.accentColor,
      checkColor: context.palette.primaryColor,
      side: BorderSide(color: context.palette.inactiveColor),
      title: Text(
        item.label,
        style: context.textTheme.bodyLarge!.copyWith(
          color: item.isDone ? context.palette.inactiveColor : context.palette.textOnPrimaryColor,
          decoration: item.isDone ? TextDecoration.lineThrough : null,
        ),
      ),
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
      decoration: BoxDecoration(
        color: context.palette.accentColor,
        borderRadius: BorderRadius.circular(_cornerRadius),
      ),
      child: Text(
        name,
        style: context.textTheme.titleSmall!.copyWith(color: context.palette.primaryColor),
      ),
    );
  }
}
