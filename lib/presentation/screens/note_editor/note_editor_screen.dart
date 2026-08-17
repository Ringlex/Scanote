import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/data/model/note/checklist_item.dart';
import 'package:note/data/model/note/note.dart';
import 'package:note/data/model/note/scanned_text.dart';
import 'package:note/data/model/note/note_share.dart';
import 'package:note/data/ocr/ocr_service.dart';
import 'package:note/data/qr/barcode_service.dart';
import 'package:note/data/scan/scan_image_store.dart';
import 'package:note/data/speech/speech_service.dart';
import 'package:note/presentation/common/app_back_button.dart';
import 'package:note/presentation/common/widgets/scan_image_strip.dart';
import 'package:note/presentation/common/app_message.dart';
import 'package:note/presentation/common/protection_message.dart';
import 'package:note/data/protection/note_cipher.dart';
import 'package:note/data/protection/note_protection_service.dart';
import 'package:note/presentation/common/dimen.dart';
import 'package:note/presentation/common/state_type.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';
import 'package:note/presentation/screens/note_editor/widgets/note_checklist_editor.dart';
import 'package:note/presentation/screens/note_editor/widgets/note_format_toolbar.dart';
import 'package:note/presentation/screens/note_editor/widgets/scan_source_sheet.dart';
import 'package:note/presentation/injector_container.dart';

class NoteEditorScreen extends StatefulWidget {
  static const routeName = '/note-editor';

  const NoteEditorScreen({this.note, super.key});

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
  late DateTime? _date;

  late bool _isProtected;

  late List<String> _imageNames;

  late List<String> _initialImageNames;

  int _checklistRevision = 0;
  bool _isScanning = false;

  bool _isDictating = false;

  String _dictationPrefix = '';
  String _dictationSuffix = '';

  static const _firstYear = 2000;
  static const _lastYear = 2100;

  static const _dictationButtonPadding = 88.0;

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
    _date = note?.date;
    _isProtected = note?.isProtected ?? false;
    _imageNames = note?.imageNames ?? const [];
    _initialImageNames = _imageNames;
  }

  @override
  void dispose() {
    injector<SpeechService>().stop();
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

        floatingActionButton: _isChecklist ? null : _buildDictationButton(context),
        appBar: AppBar(
          backgroundColor: context.palette.primaryColor,
          foregroundColor: context.palette.textOnPrimaryColor,
          leading: const AppBackButton(),
          title: Text(
            widget.note?.id == null
                ? context.translations.noteEditorNewTitle
                : context.translations.noteEditorEditTitle,
            style: context.textTheme.titleMedium!.copyWith(color: context.palette.textOnPrimaryColor),
          ),
          actions: [
            IconButton(
              onPressed: _isScanning ? null : _onQrPressed,
              tooltip: context.translations.noteQrImport,
              icon: Icon(Icons.qr_code_scanner, color: context.palette.accentColor),
            ),
            IconButton(
              onPressed: _isScanning ? null : _onScanPressed,
              tooltip: context.translations.noteEditorScanTitle,
              icon: _isScanning
                  ? const _ScanSpinner()
                  : Icon(Icons.document_scanner_outlined, color: context.palette.accentColor),
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
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              Insets.large,
              Insets.large,
              Insets.large,
              _isChecklist ? Insets.large : _dictationButtonPadding,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _NoteTitleField(controller: _titleController),
                  Gap.large,
                  _NoteCategoryField(controller: _categoryController),
                  Gap.small,
                  _NoteDateField(date: _date, onPressed: _onDatePressed, onCleared: () => setState(() => _date = null)),
                  Gap.small,
                  _NoteLockField(
                    isLocked: _isProtected,
                    onPressed: _onLockPressed,
                    onCleared: () => setState(() => _isProtected = false),
                  ),
                  Gap.small,
                  _ChecklistSwitch(isChecklist: _isChecklist, onChanged: _onChecklistChanged),
                  Gap.small,
                  if (_imageNames.isNotEmpty) ...[
                    ScanImageStrip(names: _imageNames, onRemoved: _onImageRemoved),
                    Gap.small,
                  ],
                  if (!_isChecklist) ...[
                    NoteFormatToolbar(controller: _contentsController, focusNode: _contentsFocusNode),
                    if (_isDictating) ...[Gap.small, const _DictationHint()],
                    Gap.medium,
                  ],
                  if (_isChecklist)
                    NoteChecklistEditor(
                      key: ValueKey(_checklistRevision),
                      initialItems: _checklistItems,
                      onChanged: (items) => _checklistItems = items,
                    )
                  else
                    _NoteContentsField(controller: _contentsController, focusNode: _contentsFocusNode),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDictationButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: _isScanning ? null : _onDictatePressed,
      tooltip: _isDictating ? context.translations.noteEditorDictateStop : context.translations.noteEditorDictate,
      backgroundColor: _isDictating ? context.palette.errorColor : context.palette.accentColor,
      foregroundColor: context.palette.primaryColor,
      child: Icon(_isDictating ? Icons.mic : Icons.mic_none),
    );
  }

  void _onChecklistChanged(bool isChecklist) {
    if (isChecklist && _isDictating) {
      _stopDictation();
    }

    setState(() => _isChecklist = isChecklist);
  }

  Future<void> _onDictatePressed() async {
    final speech = injector<SpeechService>();

    if (_isDictating) {
      _stopDictation();

      return;
    }

    if (!await speech.prepare()) {
      if (mounted) {
        showAppMessage(context, message: context.translations.noteEditorDictateUnavailable);
      }

      return;
    }

    if (!mounted) {
      return;
    }

    final text = _contentsController.text;
    final selection = _contentsController.selection;
    final cursor = selection.isValid ? selection.start : text.length;

    _dictationPrefix = text.substring(0, cursor);
    _dictationSuffix = text.substring(cursor);

    setState(() => _isDictating = true);

    await speech.start(
      languageCode: context.translations.localeName,
      onResult: _onDictationResult,
      onStopped: () {
        if (mounted) {
          setState(() => _isDictating = false);
        }
      },
    );
  }

  void _onDictationResult(String text, bool isFinal) {
    if (!mounted) {
      return;
    }

    final prefix = _dictationPrefix.isEmpty || _dictationPrefix.endsWith(' ') || _dictationPrefix.endsWith('\n')
        ? _dictationPrefix
        : '$_dictationPrefix ';

    _contentsController.value = TextEditingValue(
      text: '$prefix$text$_dictationSuffix',
      selection: TextSelection.collapsed(offset: prefix.length + text.length),
    );
  }

  void _stopDictation() {
    setState(() => _isDictating = false);
    injector<SpeechService>().stop();
  }

  Future<void> _onSavePressed() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    var contents = _contentsController.text;
    var checklistItems = _isChecklist ? _checklistItems : null;

    if (_isProtected) {
      final sealed = await _seal(contents: contents);

      if (sealed == null || !mounted) {
        return;
      }

      contents = sealed;
      checklistItems = null;
    }

    if (!mounted) {
      return;
    }

    context.read<HomeBloc>().add(
      HomeEvent.onNoteSubmitted(
        id: widget.note?.id,
        title: _titleController.text,
        contents: contents,
        categoryName: _categoryController.text,
        checklistItems: checklistItems,
        date: _date,
        isProtected: _isProtected,
        imageNames: _imageNames,
      ),
    );
  }

  void _onImageRemoved(String name) {
    setState(() => _imageNames = [..._imageNames]..remove(name));
  }

  Future<void> _dropRemovedImages() async {
    final removed = [
      for (final name in _initialImageNames)
        if (!_imageNames.contains(name)) name,
    ];

    await injector<ScanImageStore>().deleteAll(names: removed);
  }

  Future<void> _onLockPressed() async {
    if (_isChecklist) {
      showAppMessage(context, message: context.translations.noteProtectTextOnly);

      return;
    }

    final isAvailable = await injector<NoteProtectionService>().isAvailable();

    if (!mounted) {
      return;
    }

    if (!isAvailable) {
      showAppMessage(context, message: context.translations.noteProtectUnavailable);

      return;
    }

    setState(() => _isProtected = true);
  }

  Future<String?> _seal({required String contents}) async {
    try {
      final key = await injector<NoteProtectionService>().unlockKey(
        title: context.translations.noteProtectPromptTitle,
        subtitle: context.translations.noteProtectPromptSubtitle,
        cancel: context.translations.commonCancel,
      );

      return await NoteCipher.encrypt(plainText: contents, key: key);
    } on ProtectionException catch (error) {
      if (mounted) {
        showAppMessage(context, message: protectionMessage(context, error.failure));
      }

      return null;
    }
  }

  Future<void> _onScanPressed() async {
    final source = await showScanSourceSheet(context, title: context.translations.noteEditorScanTitle);

    if (source == null || !mounted) {
      return;
    }

    final picked = await ImagePicker().pickImage(source: source);

    if (picked == null || !mounted) {
      return;
    }

    setState(() => _isScanning = true);

    final result = await injector<OcrService>().readLines(imagePath: picked.path).run();
    final imageName = await injector<ScanImageStore>().save(sourcePath: picked.path);

    if (!mounted) {
      return;
    }

    setState(() {
      _isScanning = false;

      if (imageName != null) {
        _imageNames = [..._imageNames, imageName];
      }
    });

    result.match((error) => showAppMessage(context, message: context.translations.noteEditorScanError), _applyScan);
  }

  Future<void> _onQrPressed() async {
    final source = await showScanSourceSheet(context, title: context.translations.noteQrImport);

    if (source == null || !mounted) {
      return;
    }

    final picked = await ImagePicker().pickImage(source: source);

    if (picked == null || !mounted) {
      return;
    }

    setState(() => _isScanning = true);

    final result = await injector<BarcodeService>().readFirstCode(imagePath: picked.path).run();

    if (!mounted) {
      return;
    }

    setState(() => _isScanning = false);

    result.match((error) => showAppMessage(context, message: context.translations.noteQrError), _applyQr);
  }

  void _applyQr(String? payload) {
    final shared = payload == null ? null : NoteShare.decode(payload);

    if (shared == null) {
      showAppMessage(context, message: context.translations.noteQrUnreadable);

      return;
    }

    setState(() {
      _titleController.text = shared.title;
      _categoryController.text = shared.categoryName ?? '';
      _isChecklist = shared.isChecklist;

      if (shared.isChecklist) {
        _checklistItems = shared.items;
        _checklistRevision++;
      } else {
        _contentsController.text = shared.contents ?? '';
      }
    });

    if (widget.note == null) {
      _onSavePressed();
    }
  }

  void _applyScan(List<String> lines) {
    final scanned = TextScan.classify(lines);

    if (scanned.isEmpty) {
      showAppMessage(context, message: context.translations.noteEditorScanEmpty);

      return;
    }

    setState(() {
      if (scanned.kind == ScannedTextKind.checklist) {
        _isChecklist = true;
        _checklistItems = [..._checklistItems, ...scanned.items];
        _checklistRevision++;

        return;
      }

      _isChecklist = false;
      _contentsController.text = _contentsController.text.isEmpty
          ? scanned.text
          : '${_contentsController.text}\n${scanned.text}';
    });
  }

  Future<void> _onDatePressed() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(_firstYear),
      lastDate: DateTime(_lastYear, 12, 31),
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _onSaveStateChanged(BuildContext context, HomeState state) {
    switch (state.saveType) {
      case StateType.success:
        unawaited(_dropRemovedImages());
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

class _DictationHint extends StatelessWidget {
  const _DictationHint();

  static const _iconSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.graphic_eq, size: _iconSize, color: context.palette.errorColor),
        HorizontalGap.small,
        Text(
          context.translations.noteEditorDictateListening,
          style: context.textTheme.bodyMedium!.copyWith(color: context.palette.errorColor),
        ),
      ],
    );
  }
}

class _ScanSpinner extends StatelessWidget {
  const _ScanSpinner();

  static const _size = 20.0;
  static const _width = 2.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: CircularProgressIndicator(strokeWidth: _width, color: context.palette.accentColor),
    );
  }
}

class _NoteDateField extends StatelessWidget {
  const _NoteDateField({required this.date, required this.onPressed, required this.onCleared});

  final DateTime? date;
  final VoidCallback onPressed;
  final VoidCallback onCleared;

  static const _cornerRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    final date = this.date;

    return Material(
      color: context.palette.cardColor,
      borderRadius: BorderRadius.circular(_cornerRadius),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onPressed,
        leading: Icon(Icons.event, color: context.palette.accentColor),
        title: Text(
          context.translations.noteEditorDate,
          style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
        ),
        subtitle: Text(
          date == null
              ? context.translations.noteEditorDateNone
              : DateFormat.yMMMMEEEEd(context.translations.localeName).format(date),
          style: context.textTheme.bodyLarge!.copyWith(color: context.palette.textOnPrimaryColor),
        ),
        trailing: date == null
            ? null
            : IconButton(
                onPressed: onCleared,
                tooltip: context.translations.noteEditorDateClear,
                icon: Icon(Icons.close, color: context.palette.inactiveColor),
              ),
      ),
    );
  }
}

class _NoteLockField extends StatelessWidget {
  const _NoteLockField({required this.isLocked, required this.onPressed, required this.onCleared});

  final bool isLocked;
  final VoidCallback onPressed;
  final VoidCallback onCleared;

  static const _cornerRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.cardColor,
      borderRadius: BorderRadius.circular(_cornerRadius),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onPressed,
        leading: Icon(
          isLocked ? Icons.fingerprint : Icons.lock_open,
          color: isLocked ? context.palette.accentColor : context.palette.inactiveColor,
        ),
        title: Text(
          context.translations.noteEditorLock,
          style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
        ),
        subtitle: Text(
          isLocked ? context.translations.noteEditorLockOn : context.translations.noteEditorLockOff,
          style: context.textTheme.bodyLarge!.copyWith(color: context.palette.textOnPrimaryColor),
        ),
        trailing: isLocked
            ? IconButton(
                onPressed: onCleared,
                tooltip: context.translations.noteEditorLockRemove,
                icon: Icon(Icons.close, color: context.palette.inactiveColor),
              )
            : null,
      ),
    );
  }
}

class _ChecklistSwitch extends StatelessWidget {
  const _ChecklistSwitch({required this.isChecklist, required this.onChanged});

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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(_cornerRadius), borderSide: BorderSide.none),
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
                          labelStyle: context.textTheme.titleSmall!.copyWith(color: context.palette.textOnPrimaryColor),
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
  const _NoteContentsField({required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  static const _minLines = 8;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      minLines: _minLines,
      maxLines: null,
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
