import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/data/database/db_helper.dart';
import 'package:note/data/model/note/note.dart';
import 'package:note/presentation/common/app_message.dart';
import 'package:note/presentation/common/dimen.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';

class BinScreen extends StatelessWidget {
  static const routeName = '/bin';

  const BinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.primaryColor,
      appBar: AppBar(
        title: Text(context.translations.binTitle),
        actions: [
          BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (previous, current) => previous.deletedNotes != current.deletedNotes,
            builder: (context, state) {
              if (state.deletedNotes.isEmpty) {
                return const SizedBox.shrink();
              }

              return TextButton(
                onPressed: () => _onEmptyPressed(context, count: state.deletedNotes.length),
                child: Text(context.translations.binEmptyAction, style: TextStyle(color: context.palette.errorColor)),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) => previous.deletedNotes != current.deletedNotes,
        builder: (context, state) {
          final notes = state.deletedNotes;

          if (notes.isEmpty) {
            return const _BinEmpty();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(Insets.medium),
                child: Text(
                  context.translations.binRetentionHint,
                  style: context.textTheme.bodySmall?.copyWith(color: context.palette.inactiveColor),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: Insets.medium),
                  itemCount: notes.length,
                  separatorBuilder: (_, _) => Gap.small,
                  itemBuilder: (_, index) => _BinTile(note: notes[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _onEmptyPressed(BuildContext context, {required int count}) async {
    final homeBloc = context.read<HomeBloc>();
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.translations.binEmptyTitle),
        content: Text(dialogContext.translations.binEmptyMessage(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.translations.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: dialogContext.palette.errorColor),
            child: Text(dialogContext.translations.commonDelete),
          ),
        ],
      ),
    );

    if (isConfirmed ?? false) {
      homeBloc.add(const HomeEvent.onBinEmptied());
    }
  }
}

class _BinTile extends StatelessWidget {
  const _BinTile({required this.note});

  final Note note;

  int get _daysLeft {
    final deletedAt = note.deletedAt;

    if (deletedAt == null) {
      return DBHelper.binRetention.inDays;
    }

    final left = DBHelper.binRetention - DateTime.now().difference(deletedAt);

    return left.isNegative ? 0 : left.inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: context.palette.cardColor, borderRadius: BorderRadius.circular(Insets.medium)),
      child: ListTile(
        title: Text(
          note.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyLarge?.copyWith(color: context.palette.textOnPrimaryColor),
        ),

        subtitle: Text(
          context.translations.binPurgesIn(_daysLeft),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(color: context.palette.inactiveColor),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: context.translations.binRestore,
              icon: Icon(Icons.restore_from_trash_outlined, color: context.palette.accentColor),
              onPressed: () => _onRestorePressed(context),
            ),
            IconButton(
              tooltip: context.translations.binDeleteForever,
              icon: Icon(Icons.delete_forever_outlined, color: context.palette.errorColor),
              onPressed: () => _onPurgePressed(context),
            ),
          ],
        ),
      ),
    );
  }

  void _onRestorePressed(BuildContext context) {
    final id = note.id;

    if (id == null) {
      return;
    }

    context.read<HomeBloc>().add(HomeEvent.onNoteRestored(noteId: id));
    showAppMessage(context, message: context.translations.binNoteRestored, isError: false);
  }

  Future<void> _onPurgePressed(BuildContext context) async {
    final id = note.id;

    if (id == null) {
      return;
    }

    final homeBloc = context.read<HomeBloc>();
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.translations.binDeleteForeverTitle),
        content: Text(dialogContext.translations.binDeleteForeverMessage(note.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.translations.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: dialogContext.palette.errorColor),
            child: Text(dialogContext.translations.commonDelete),
          ),
        ],
      ),
    );

    if (isConfirmed ?? false) {
      homeBloc.add(HomeEvent.onNotePurged(noteId: id));
    }
  }
}

class _BinEmpty extends StatelessWidget {
  const _BinEmpty();

  static const _iconSize = 64.0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Insets.xLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, size: _iconSize, color: context.palette.accentColor),
            Gap.large,
            Text(
              context.translations.binEmpty,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
            ),
          ],
        ),
      ),
    );
  }
}
