import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/data/model/event/event.dart';
import 'package:note/presentation/common/app_back_button.dart';
import 'package:note/presentation/common/app_message.dart';
import 'package:note/presentation/common/dimen.dart';
import 'package:note/presentation/common/state_type.dart';
import 'package:note/presentation/screens/calendar/bloc/calendar_bloc.dart';
import 'package:note/presentation/screens/event_editor/reminder_offset.dart';

class EventEditorScreen extends StatefulWidget {
  static const routeName = '/event-editor';

  const EventEditorScreen({
    this.event,
    super.key,
  });

  final Event? event;

  @override
  State<EventEditorScreen> createState() => _EventEditorScreenState();
}

class _EventEditorScreenState extends State<EventEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late DateTime _startAt;
  late ReminderOffset _reminderOffset;

  static const _newEventHour = 9;
  static const _firstYear = 2000;
  static const _lastYear = 2100;

  @override
  void initState() {
    super.initState();
    final event = widget.event;

    _titleController = TextEditingController(text: event?.title ?? '');
    _descriptionController = TextEditingController(text: event?.description ?? '');
    _startAt = event?.startAt ?? _defaultStartAt();
    _reminderOffset = ReminderOffset.of(startAt: _startAt, remindAt: event?.remindAt);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CalendarBloc, CalendarState>(
      listenWhen: (previous, current) => previous.saveType != current.saveType,
      listener: _onSaveStateChanged,
      child: Scaffold(
        backgroundColor: context.palette.primaryColor,
        appBar: AppBar(
          backgroundColor: context.palette.primaryColor,
          foregroundColor: context.palette.textOnPrimaryColor,
          leading: const AppBackButton(),
          title: Text(
            widget.event == null ? context.translations.eventEditorNewTitle : context.translations.eventEditorEditTitle,
            style: context.textTheme.titleMedium!.copyWith(color: context.palette.textOnPrimaryColor),
          ),
          actions: [
            if (widget.event != null)
              IconButton(
                onPressed: _onDeletePressed,
                tooltip: context.translations.eventEditorDelete,
                icon: Icon(Icons.delete_outline, color: context.palette.errorColor),
              ),
            TextButton(
              onPressed: _onSavePressed,
              child: Text(
                context.translations.commonSave,
                style: context.textTheme.bodyLarge!.copyWith(color: context.palette.accentColor),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(Insets.large),
              children: [
                _EventTitleField(controller: _titleController),
                Gap.large,
                _EventDescriptionField(controller: _descriptionController),
                Gap.large,
                _EditorTile(
                  icon: Icons.event,
                  label: context.translations.eventEditorDate,
                  value: DateFormat.yMMMMEEEEd(context.translations.localeName).format(_startAt),
                  onTap: _onDatePressed,
                ),
                Gap.small,
                _EditorTile(
                  icon: Icons.schedule,
                  label: context.translations.eventEditorTime,
                  value: DateFormat.Hm().format(_startAt),
                  onTap: _onTimePressed,
                ),
                Gap.small,
                _ReminderField(
                  value: _reminderOffset,
                  onChanged: (offset) => setState(() => _reminderOffset = offset),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DateTime _defaultStartAt() {
    final day = context.read<CalendarBloc>().state.selectedDay;

    return DateTime(day.year, day.month, day.day, _newEventHour);
  }

  Future<void> _onDatePressed() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startAt,
      firstDate: DateTime(_firstYear),
      lastDate: DateTime(_lastYear, 12, 31),
    );

    if (picked == null) {
      return;
    }

    setState(
      () => _startAt = DateTime(picked.year, picked.month, picked.day, _startAt.hour, _startAt.minute),
    );
  }

  Future<void> _onTimePressed() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startAt),
    );

    if (picked == null) {
      return;
    }

    setState(
      () => _startAt = DateTime(_startAt.year, _startAt.month, _startAt.day, picked.hour, picked.minute),
    );
  }

  void _onSavePressed() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<CalendarBloc>().add(
          CalendarEvent.onEventSubmitted(
            id: widget.event?.id,
            title: _titleController.text,
            description: _descriptionController.text,
            startAt: _startAt,
            remindAt: _reminderOffset.remindAtFor(_startAt),
          ),
        );
  }

  Future<void> _onDeletePressed() async {
    final id = widget.event?.id;

    if (id == null) {
      return;
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

    if ((isConfirmed ?? false) && mounted) {
      context.read<CalendarBloc>().add(CalendarEvent.onEventDeleted(id: id));
    }
  }

  void _onSaveStateChanged(BuildContext context, CalendarState state) {
    switch (state.saveType) {
      case StateType.success:
        context.pop();
      case StateType.error:
        showAppMessage(context, message: context.translations.eventEditorSaveError);
      case StateType.initial:
      case StateType.loading:
      case StateType.loaded:
      case StateType.empty:
        break;
    }
  }
}

class _EventTitleField extends StatelessWidget {
  const _EventTitleField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.sentences,
      style: context.textTheme.displaySmall!.copyWith(color: context.palette.textOnPrimaryColor),
      cursorColor: context.palette.accentColor,
      validator: (value) => (value ?? '').trim().isEmpty ? context.translations.eventEditorNameRequired : null,
      decoration: InputDecoration(
        hintText: context.translations.eventEditorNameHint,
        hintStyle: context.textTheme.displaySmall!.copyWith(color: context.palette.inactiveColor),
        border: InputBorder.none,
        errorStyle: context.textTheme.labelSmall!.copyWith(color: context.palette.errorColor),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class _EventDescriptionField extends StatelessWidget {
  const _EventDescriptionField({required this.controller});

  final TextEditingController controller;

  static const _cornerRadius = 16.0;
  static const _maxLines = 4;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 1,
      maxLines: _maxLines,
      textCapitalization: TextCapitalization.sentences,
      style: context.textTheme.bodyLarge!.copyWith(color: context.palette.textOnPrimaryColor),
      cursorColor: context.palette.accentColor,
      decoration: InputDecoration(
        hintText: context.translations.eventEditorDescriptionHint,
        hintStyle: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
        filled: true,
        fillColor: context.palette.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_cornerRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _EditorTile extends StatelessWidget {
  const _EditorTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  static const _cornerRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.cardColor,
      borderRadius: BorderRadius.circular(_cornerRadius),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: context.palette.accentColor),
        title: Text(
          label,
          style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
        ),
        subtitle: Text(
          value,
          style: context.textTheme.bodyLarge!.copyWith(color: context.palette.textOnPrimaryColor),
        ),
      ),
    );
  }
}

class _ReminderField extends StatelessWidget {
  const _ReminderField({
    required this.value,
    required this.onChanged,
  });

  final ReminderOffset value;
  final ValueChanged<ReminderOffset> onChanged;

  static const _cornerRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.palette.cardColor,
        borderRadius: BorderRadius.circular(_cornerRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: Insets.large, vertical: Insets.small),
      child: Row(
        children: [
          Icon(Icons.notifications_none, color: context.palette.accentColor),
          HorizontalGap.large,
          Expanded(
            child: DropdownButton<ReminderOffset>(
              value: value,
              onChanged: (offset) => onChanged(offset ?? ReminderOffset.none),
              isExpanded: true,
              underline: const SizedBox.shrink(),
              dropdownColor: context.palette.cardColor,
              iconEnabledColor: context.palette.inactiveColor,
              style: context.textTheme.bodyLarge!.copyWith(color: context.palette.textOnPrimaryColor),
              items: [
                for (final offset in ReminderOffset.values)
                  DropdownMenuItem<ReminderOffset>(
                    value: offset,
                    child: Text(offset.label(context.translations)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
