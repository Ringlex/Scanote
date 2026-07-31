import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/data/model/note/checklist_item.dart';
import 'package:note/data/model/note/note.dart';
import 'package:note/presentation/common/app_back_button.dart';
import 'package:note/presentation/common/app_message.dart';
import 'package:note/presentation/common/dimen.dart';
import 'package:note/presentation/common/state_type.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';
import 'package:note/presentation/screens/note_editor/widgets/note_checklist_editor.dart';
import 'package:note/presentation/screens/note_editor/widgets/note_format_toolbar.dart';

class NoteEditorScreen extends StatefulWidget {
  static const routeName = '/note-editor';

  const NoteEditorScreen({
    this.note,
    super.key,
  });

  final Note? note;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentsFocusNode = FocusNode();

  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  late final TextEditingController _contentsController;

  late bool _isChecklist;
  late List<ChecklistItem> _checklistItems;

  @override
  void initState() {
    super.initState();
    final note = widget.note;

    _titleController = TextEditingController(text: note?.title ?? '');
    _contentsController = TextEditingController(text: note?.noteContents ?? '');
    _categoryController = TextEditingController(
      text: note == null ? '' : context.read<HomeBloc>().state.categoryNameOf(note) ?? '',
    );

    _isChecklist = note?.isChecklist ?? false;
    _checklistItems = note?.checklistItems ?? const [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _contentsController.dispose();
    _contentsFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) => previous.saveType != current.saveType,
      listener: _onSaveStateChanged,
      child: Scaffold(
        backgroundColor: context.palette.primaryColor,
        appBar: AppBar(
          backgroundColor: context.palette.primaryColor,
          foregroundColor: context.palette.textOnPrimaryColor,
          leading: const AppBackButton(),
          title: Text(
            widget.note == null ? context.translations.noteEditorNewTitle : context.translations.noteEditorEditTitle,
            style: context.textTheme.titleMedium!.copyWith(color: context.palette.textOnPrimaryColor),
          ),
          actions: [
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
          child: Padding(
            padding: const EdgeInsets.all(Insets.large),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _NoteTitleField(controller: _titleController),
                  Gap.large,
                  _NoteCategoryField(controller: _categoryController),
                  Gap.small,
                  _ChecklistSwitch(
                    isChecklist: _isChecklist,
                    onChanged: _onChecklistChanged,
                  ),
                  Gap.small,
                  if (!_isChecklist) ...[
                    NoteFormatToolbar(
                      controller: _contentsController,
                      focusNode: _contentsFocusNode,
                    ),
                    Gap.medium,
                  ],
                  Expanded(
                    child: _isChecklist
                        ? NoteChecklistEditor(
                            initialItems: _checklistItems,
                            onChanged: (items) => _checklistItems = items,
                          )
                        : _NoteContentsField(
                            controller: _contentsController,
                            focusNode: _contentsFocusNode,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onChecklistChanged(bool isChecklist) {
    setState(() => _isChecklist = isChecklist);
  }

  void _onSavePressed() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<HomeBloc>().add(
          HomeEvent.onNoteSubmitted(
            id: widget.note?.id,
            title: _titleController.text,
            contents: _contentsController.text,
            categoryName: _categoryController.text,
            checklistItems: _isChecklist ? _checklistItems : null,
          ),
        );
  }

  void _onSaveStateChanged(BuildContext context, HomeState state) {
    switch (state.saveType) {
      case StateType.success:
        context.pop();
      case StateType.error:
        showAppMessage(context, message: context.translations.noteEditorSaveError);
      case StateType.initial:
      case StateType.loading:
      case StateType.loaded:
      case StateType.empty:
        break;
    }
  }
}

class _ChecklistSwitch extends StatelessWidget {
  const _ChecklistSwitch({
    required this.isChecklist,
    required this.onChanged,
  });

  final bool isChecklist;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: isChecklist,
      onChanged: (value) => onChanged(value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: context.palette.accentColor,
      checkColor: context.palette.primaryColor,
      side: BorderSide(color: context.palette.inactiveColor),
      title: Text(
        context.translations.noteEditorChecklist,
        style: context.textTheme.bodyLarge!.copyWith(color: context.palette.textOnPrimaryColor),
      ),
      subtitle: Text(
        context.translations.noteEditorChecklistDescription,
        style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
      ),
    );
  }
}

class _NoteTitleField extends StatelessWidget {
  const _NoteTitleField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.sentences,
      style: context.textTheme.displaySmall!.copyWith(color: context.palette.textOnPrimaryColor),
      cursorColor: context.palette.accentColor,
      validator: (value) => (value ?? '').trim().isEmpty ? context.translations.noteEditorNameRequired : null,
      decoration: InputDecoration(
        hintText: context.translations.noteEditorNameHint,
        hintStyle: context.textTheme.displaySmall!.copyWith(color: context.palette.inactiveColor),
        border: InputBorder.none,
        errorStyle: context.textTheme.labelSmall!.copyWith(color: context.palette.errorColor),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class _NoteCategoryField extends StatelessWidget {
  const _NoteCategoryField({required this.controller});

  final TextEditingController controller;

  static const _cornerRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: controller,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.sentences,
          style: context.textTheme.bodyLarge!.copyWith(color: context.palette.textOnPrimaryColor),
          cursorColor: context.palette.accentColor,
          decoration: InputDecoration(
            hintText: context.translations.noteEditorCategoryHint,
            hintStyle: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
            prefixIcon: Icon(Icons.label_outline, color: context.palette.accentColor),
            filled: true,
            fillColor: context.palette.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_cornerRadius),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) => previous.categories != current.categories,
          builder: (context, state) => state.categories.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: Insets.small),
                  child: Wrap(
                    spacing: Insets.small,
                    children: [
                      for (final category in state.categories)
                        ActionChip(
                          label: Text(category.name),
                          labelStyle: context.textTheme.titleSmall!.copyWith(
                            color: context.palette.textOnPrimaryColor,
                          ),
                          backgroundColor: context.palette.cardColor,
                          side: BorderSide.none,
                          onPressed: () => controller.text = category.name,
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _NoteContentsField extends StatelessWidget {
  const _NoteContentsField({
    required this.controller,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      style: context.textTheme.bodyLarge!.copyWith(color: context.palette.textOnPrimaryColor),
      cursorColor: context.palette.accentColor,
      decoration: InputDecoration(
        hintText: context.translations.noteEditorContentsHint,
        hintStyle: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
