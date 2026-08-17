import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:note/core/app_logger/app_logger.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/data/model/note/checklist_item.dart';
import 'package:note/data/model/note/note.dart';
import 'package:note/data/model/note/note_dates.dart';
import 'package:note/presentation/common/app_back_button.dart';
import 'package:note/presentation/common/app_celebration.dart';
import 'package:note/presentation/common/app_message.dart';
import 'package:note/presentation/injector_container.dart';
import 'package:note/presentation/common/protection_message.dart';
import 'package:note/data/protection/note_cipher.dart';
import 'package:note/data/protection/note_protection_service.dart';
import 'package:note/presentation/common/dimen.dart';
import 'package:note/presentation/common/widgets/formatted_note_text.dart';
import 'package:note/presentation/common/widgets/scan_image_strip.dart';
import 'package:note/presentation/screens/calendar/bloc/calendar_bloc.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';
import 'package:note/presentation/screens/note_editor/note_editor_argument.dart';
import 'package:note/presentation/screens/note_details/widgets/note_qr_dialog.dart';
import 'package:note/presentation/screens/note_editor/note_editor_screen.dart';

class NoteDetailsScreen extends StatefulWidget {
  static const routeName = '/note-details';

  const NoteDetailsScreen({required this.noteId, super.key});

  final int noteId;

  @override
  State<NoteDetailsScreen> createState() => _NoteDetailsScreenState();
}

class _NoteDetailsScreenState extends State<NoteDetailsScreen> {
  String? _plainText;

  bool _isAsking = false;

  int get noteId => widget.noteId;

  void _openProtected(Note note) {
    if (_isAsking) {
      return;
    }

    _isAsking = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final key = await injector<NoteProtectionService>().unlockKey(
          title: context.mounted ? context.translations.noteProtectPromptTitle : '',
          subtitle: context.mounted ? context.translations.noteProtectOpenSubtitle : '',
          cancel: context.mounted ? context.translations.commonCancel : '',
        );

        final plainText = await NoteCipher.decrypt(payload: note.noteContents ?? '', key: key);

        if (!mounted) {
          return;
        }

        setState(() => _plainText = plainText);
      } on ProtectionException catch (error) {
        if (!mounted) {
          return;
        }

        if (error.failure != ProtectionFailure.cancelled) {
          showAppMessage(context, message: protectionMessage(context, error.failure));
        }

        context.pop();
      } on FormatException catch (error, stackTrace) {
        logSevere('A note is marked protected but holds no ciphertext', error, stackTrace);

        if (!mounted) {
          return;
        }

        showAppMessage(context, message: context.translations.noteProtectUnreadable);
        context.pop();
      } catch (error, stackTrace) {
        logSevere('A protected note could not be decrypted', error, stackTrace);

        if (!mounted) {
          return;
        }

        showAppMessage(context, message: context.translations.noteProtectKeyLost);
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listenWhen: (previous, current) => !_isCompleted(previous) && _isCompleted(current),
      listener: (context, state) => showChecklistCelebration(context, message: context.translations.checklistCompleted),
      builder: (context, state) {
        final stored = state.notes.firstWhereOrNull((note) => note.id == noteId);

        if (stored != null && stored.isLocked && _plainText == null) {
          _openProtected(stored);

          return const _LockedNote();
        }

        final note = stored != null && _plainText != null ? stored.copyWith(noteContents: _plainText) : stored;

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

                if (!note.isProtected)
                  IconButton(
                    onPressed: () => showNoteQrDialog(context, note: note, categoryName: state.categoryNameOf(note)),
                    tooltip: context.translations.noteQrShare,
                    icon: Icon(Icons.qr_code_2, color: context.palette.accentColor),
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
              : _NoteDetails(note: note, categoryName: state.categoryNameOf(note)),
        );
      },
    );
  }

  bool _isCompleted(HomeState state) {
    final note = state.notes.firstWhereOrNull((note) => note.id == noteId);

    return note != null && note.isChecklistCompleted;
  }

  void _onFavoritePressed(BuildContext context, Note note) {
    context.read<HomeBloc>().add(HomeEvent.onFavoriteToggled(noteId: note.id!));
  }

  void _onEditPressed(BuildContext context, Note note) {
    context.push(
      NoteEditorScreen.routeName,
      extra: NoteEditorArgument(homeBloc: context.read<HomeBloc>(), note: note),
    );
  }
}

class _LockedNote extends StatelessWidget {
  const _LockedNote();

  static const _iconSize = 48.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.primaryColor,
      appBar: AppBar(
        backgroundColor: context.palette.primaryColor,
        foregroundColor: context.palette.textOnPrimaryColor,
        leading: const AppBackButton(),
      ),
      body: Center(
        child: Icon(Icons.lock, size: _iconSize, color: context.palette.inactiveColor),
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
  const _NoteDetails({required this.note, required this.categoryName});

  final Note note;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(Insets.xLarge, 0, Insets.xLarge, Insets.xxxLarge),
      children: [
        Text(note.title, style: context.textTheme.displaySmall!.copyWith(color: context.palette.textOnPrimaryColor)),
        if (categoryName != null) ...[
          Gap.medium,
          Align(
            alignment: Alignment.centerLeft,
            child: _CategoryBadge(name: categoryName!),
          ),
        ],
        if (note.hasImages) ...[Gap.large, ScanImageStrip(names: note.imageNames)],
        Gap.xLarge,
        if (note.isChecklist) _NoteChecklist(note: note) else FormattedNoteText(text: note.noteContents ?? ''),
        _DetectedDates(note: note),
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
            onChanged: () =>
                context.read<HomeBloc>().add(HomeEvent.onChecklistItemToggled(noteId: note.id!, itemIndex: index)),
          ),
      ],
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({required this.item, required this.onChanged});

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
      decoration: BoxDecoration(color: context.palette.accentColor, borderRadius: BorderRadius.circular(_cornerRadius)),
      child: Text(name, style: context.textTheme.titleSmall!.copyWith(color: context.palette.primaryColor)),
    );
  }
}

class _DetectedDates extends StatelessWidget {
  const _DetectedDates({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final dates = NoteDates.parse(note.searchableText);

    if (dates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap.xLarge,
        Text(
          context.translations.noteDetailsDatesFound,
          style: context.textTheme.titleSmall!.copyWith(color: context.palette.inactiveColor),
        ),
        Gap.small,
        for (final match in dates) _DetectedDateTile(note: note, match: match),
      ],
    );
  }
}

class _DetectedDateTile extends StatelessWidget {
  const _DetectedDateTile({required this.note, required this.match});

  final Note note;
  final NoteDateMatch match;

  static const _cornerRadius = 16.0;
  static const _iconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.small),
      child: Material(
        color: context.palette.cardColor,
        borderRadius: BorderRadius.circular(_cornerRadius),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: () => _onPressed(context),
          leading: Icon(Icons.event_available, size: _iconSize, color: context.palette.accentColor),
          title: Text(
            '${DateFormat.yMMMMEEEEd(context.translations.localeName).format(match.date)}'
            ', ${DateFormat.Hm().format(match.date)}',
            style: context.textTheme.bodyLarge!.copyWith(color: context.palette.textOnPrimaryColor),
          ),

          subtitle: Text(
            match.text,
            style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
          ),
          trailing: Icon(Icons.add, color: context.palette.accentColor),
        ),
      ),
    );
  }

  void _onPressed(BuildContext context) {
    final calendarBloc = context.read<CalendarBloc>();
    final isAlreadyThere = calendarBloc.state.duplicateOf(title: note.title, startAt: match.date) != null;

    calendarBloc.add(CalendarEvent.onEventSubmitted(title: note.title, startAt: match.date, description: match.text));

    showAppMessage(
      context,
      message: isAlreadyThere
          ? context.translations.noteDetailsDateAlreadyAdded
          : context.translations.noteDetailsDateAdded,
      isError: false,
    );
  }
}
